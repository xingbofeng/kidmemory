import path from "node:path";

import type {
  ExportArtifact,
  SampleDb,
  StorageSyncJob,
} from "../../../infrastructure/dataset-state/memory-dataset-db.ts";

const STORAGE_RETRY_BACKOFF_SECONDS = [5, 15, 30, 60];

export type StorageProviderForSync = {
  uploadFile(input: { localPath: string; objectPath: string; contentType?: string }): Promise<{
    ok: boolean;
    remoteUrl?: string;
    code?: string;
    message?: string;
    retryable?: boolean;
  }>;
  createSignedUrl(objectPath: string): Promise<{
    ok: boolean;
    url?: string;
    expiresInSeconds?: number;
    code?: string;
    message?: string;
  }>;
};

export function createStorageSyncService(dependencies: {
  db: SampleDb;
  provider: StorageProviderForSync;
}) {
  const { db, provider } = dependencies;

  return {
    async enqueueAssetSync(assetId: string) {
      const asset = await db.getAsset?.(assetId);
      if (!asset) return { enqueued: false, reason: "asset_not_found" };
      const objectPath = assetObjectPath(asset);
      await db.updateAssetStorageState?.({
        assetId,
        storageProvider: "supabase",
        storageStatus: "pending",
        storagePath: objectPath,
      });
      const enqueued = await db.enqueueStorageSyncJob?.({
        targetType: "asset",
        targetId: assetId,
        provider: "supabase",
        objectPath,
        maxAttempts: 5,
      });
      return enqueued || { enqueued: false, jobId: "" };
    },

    async enqueueExportArtifactSync(input: { artifactId: string; childId: string }) {
      const artifact = await db.getExportArtifact?.(input.artifactId);
      if (!artifact) return { enqueued: false, reason: "artifact_not_found" };
      const objectPath = exportArtifactObjectPath(artifact, input.childId);
      await db.updateExportArtifactStorageState?.({
        artifactId: input.artifactId,
        storageProvider: "supabase",
        storageStatus: "pending",
        storagePath: objectPath,
      });
      const enqueued = await db.enqueueStorageSyncJob?.({
        targetType: "export_artifact",
        targetId: input.artifactId,
        provider: "supabase",
        objectPath,
        maxAttempts: 5,
      });
      return enqueued || { enqueued: false, jobId: "" };
    },

    async runStorageSyncWorker(input: { limit?: number; now?: Date } = {}) {
      if (!db.claimStorageSyncJobs) {
        return { processed: 0, succeeded: 0, retried: 0, failed: 0, skipped: 0 };
      }
      const now = input.now || new Date();
      const jobs = await db.claimStorageSyncJobs({
        limit: Math.max(1, input.limit || 10),
        workerId: "sidecar-storage-worker",
        now,
        staleAfterSeconds: 60,
      });
      const summary = { processed: jobs.length, succeeded: 0, retried: 0, failed: 0, skipped: 0 };
      for (const job of jobs) {
        const result = await processStorageSyncJob({ db, provider, job, now });
        summary[result] += 1;
      }
      return summary;
    },

    async getShareMetadata(artifactId: string) {
      const artifact = await db.getExportArtifact?.(artifactId);
      if (!artifact) {
        return {
          ok: false,
          code: "EXPORT_ARTIFACT_NOT_FOUND",
          message: "导出物不存在。",
          action: "重新导出后再分享。",
        };
      }
      if (artifact.remoteUrl) {
        return {
          ok: true,
          url: artifact.remoteUrl,
          text: `KidMemory 作品集：${artifact.remoteUrl}`,
        };
      }
      if (!artifact.storagePath) {
        return {
          ok: false,
          code: "EXPORT_ARTIFACT_NOT_SYNCED",
          message: "导出物尚未同步到 Supabase Storage。",
          action: "先同步导出物后再复制分享文案。",
        };
      }
      const signed = await provider.createSignedUrl(artifact.storagePath);
      if (!signed.ok || !signed.url) {
        return {
          ok: false,
          code: signed.code || "SUPABASE_STORAGE_SIGNED_URL_FAILED",
          message: signed.message || "签名 URL 生成失败。",
          action: "检查 Supabase Storage 配置后重试。",
        };
      }
      return {
        ok: true,
        url: signed.url,
        expiresInSeconds: signed.expiresInSeconds,
        text: `KidMemory 作品集：${signed.url}\n链接有效期：${signed.expiresInSeconds || 0} 秒`,
      };
    },
  };
}

async function processStorageSyncJob(input: {
  db: SampleDb;
  provider: StorageProviderForSync;
  job: StorageSyncJob;
  now: Date;
}) {
  const source = await resolveSyncSource(input.db, input.job);
  if (!source) {
    await input.db.markStorageSyncJobFailed?.({
      jobId: input.job.id,
      attempt: input.job.attempt + 1,
      errorCode: "STORAGE_SYNC_TARGET_NOT_FOUND",
      errorMessage: "storage sync target not found",
    });
    return "failed" as const;
  }

  const uploaded = await input.provider.uploadFile({
    localPath: source.localPath,
    objectPath: input.job.objectPath,
    contentType: contentTypeForPath(source.localPath),
  });
  const nextAttempt = input.job.attempt + 1;
  if (uploaded.ok) {
    if (input.job.targetType === "asset") {
      await input.db.updateAssetStorageState?.({
        assetId: input.job.targetId,
        storageProvider: "supabase",
        storageStatus: "synced",
        storagePath: input.job.objectPath,
        remoteUrl: uploaded.remoteUrl || "",
      });
    } else {
      await input.db.updateExportArtifactStorageState?.({
        artifactId: input.job.targetId,
        storageProvider: "supabase",
        storageStatus: "synced",
        storagePath: input.job.objectPath,
        remoteUrl: uploaded.remoteUrl || "",
      });
    }
    await input.db.markStorageSyncJobDone?.(input.job.id);
    return "succeeded" as const;
  }

  if (uploaded.retryable && nextAttempt < input.job.maxAttempts) {
    const waitSeconds = STORAGE_RETRY_BACKOFF_SECONDS[Math.min(nextAttempt - 1, STORAGE_RETRY_BACKOFF_SECONDS.length - 1)];
    await input.db.markStorageSyncJobRetry?.({
      jobId: input.job.id,
      attempt: nextAttempt,
      runAfter: new Date(input.now.getTime() + waitSeconds * 1000),
      errorCode: uploaded.code || "SUPABASE_STORAGE_RETRYABLE",
      errorMessage: uploaded.message || "storage sync retryable failure",
    });
    return "retried" as const;
  }

  if (input.job.targetType === "asset") {
    await input.db.updateAssetStorageState?.({
      assetId: input.job.targetId,
      storageProvider: "supabase",
      storageStatus: "failed",
      storagePath: input.job.objectPath,
    });
  } else {
    await input.db.updateExportArtifactStorageState?.({
      artifactId: input.job.targetId,
      storageProvider: "supabase",
      storageStatus: "failed",
      storagePath: input.job.objectPath,
    });
  }
  await input.db.markStorageSyncJobFailed?.({
    jobId: input.job.id,
    attempt: nextAttempt,
    errorCode: uploaded.code || "SUPABASE_STORAGE_SYNC_FAILED",
    errorMessage: uploaded.message || "storage sync failed",
  });
  return "failed" as const;
}

async function resolveSyncSource(db: SampleDb, job: StorageSyncJob) {
  if (job.targetType === "asset") {
    const asset = await db.getAsset?.(job.targetId);
    if (!asset?.imagePath) return null;
    return { localPath: asset.imagePath };
  }
  const artifact = await db.getExportArtifact?.(job.targetId);
  if (!artifact?.localPath) return null;
  return { localPath: artifact.localPath };
}

function assetObjectPath(asset: any) {
  const childId = sanitizePathPart(asset.childId || "unknown-child");
  const assetId = sanitizePathPart(asset.id);
  const ext = extensionForPath(asset.imagePath);
  const baseName = sanitizePathPart(asset.hash || path.basename(asset.imagePath || "asset", path.extname(asset.imagePath || "")));
  return `children/${childId}/assets/${assetId}/${baseName}${ext}`;
}

function exportArtifactObjectPath(artifact: ExportArtifact, childId: string) {
  return `children/${sanitizePathPart(childId)}/exports/${sanitizePathPart(artifact.jobId)}/${sanitizePathPart(artifact.id)}${extensionForArtifact(artifact)}`;
}

function extensionForArtifact(artifact: ExportArtifact) {
  if (artifact.kind === "pdf") return ".pdf";
  if (artifact.kind === "long_image_jpg") return ".jpg";
  return ".png";
}

function extensionForPath(value: string) {
  const ext = path.extname(value || "").toLowerCase();
  return ext || ".bin";
}

function sanitizePathPart(value: string) {
  return String(value || "item")
    .trim()
    .replace(/[^a-zA-Z0-9._-]/g, "-")
    .replace(/-+/g, "-")
    .replace(/^\.+$/, "item")
    || "item";
}

function contentTypeForPath(value: string) {
  switch (path.extname(value).toLowerCase()) {
    case ".jpg":
    case ".jpeg":
      return "image/jpeg";
    case ".png":
      return "image/png";
    case ".webp":
      return "image/webp";
    case ".pdf":
      return "application/pdf";
    default:
      return "application/octet-stream";
  }
}
