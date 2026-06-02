import { Inject, Injectable } from "@nestjs/common";
import type { Prisma } from "@prisma/client";

import { isPrismaNotFoundError } from "../database/prisma-errors.ts";
import { PrismaService } from "../database/prisma.service.ts";
import type {
  Child,
  EmbeddingJob,
  EmbeddingJobStatus,
  ExportArtifact,
  SampleAsset,
  SampleDb,
  SearchCandidatePoolItem,
  SearchFilters,
  SearchRecallResult,
  StorageSyncJob,
  StorageSyncJobStatus,
} from "./memory-dataset-db.ts";

type PrismaAsset = Awaited<ReturnType<PrismaService["asset"]["findFirstOrThrow"]>>;
type PrismaEmbeddingJob = Awaited<ReturnType<PrismaService["embeddingJob"]["findFirstOrThrow"]>>;
type PrismaStorageSyncJob = Awaited<ReturnType<PrismaService["storageSyncJob"]["findFirstOrThrow"]>>;
type PrismaCandidatePoolItem = Awaited<ReturnType<PrismaService["candidatePoolItem"]["findFirstOrThrow"]>>;
type PrismaExportArtifact = Awaited<ReturnType<PrismaService["exportArtifact"]["findFirstOrThrow"]>>;

export class PrismaDatasetDbService implements SampleDb {
  private readonly prisma: PrismaService;

  constructor(prisma: PrismaService) {
    this.prisma = prisma;
  }

  async connect() {
    await this.prisma.$connect();
    // Verify the backing DB is reachable before promoting this instance as
    // the active dataset store.
    await this.prisma.child.count();
    return this;
  }

  async upsertChild(child: Child) {
    await this.prisma.child.upsert({
      where: { id: child.id },
      create: {
        id: child.id,
        name: child.name,
        birthday: child.birthday ? new Date(child.birthday) : null,
        notes: child.notes || "",
        metadata: jsonObject(child.metadata),
      },
      update: {
        name: child.name,
        birthday: child.birthday ? new Date(child.birthday) : null,
        notes: child.notes || "",
        metadata: jsonObject(child.metadata),
      },
    });
  }

  async upsertAsset(asset: SampleAsset) {
    const data = assetToPrisma(asset);
    await this.prisma.asset.upsert({
      where: { id: asset.id },
      create: { id: asset.id, ...data },
      update: data,
    });
  }

  async getChildren() {
    const children = await this.prisma.child.findMany({ orderBy: { createdAt: "asc" } });
    return children.map((child) => ({
      id: child.id,
      name: child.name,
      birthday: child.birthday ? dateOnly(child.birthday) : undefined,
      notes: child.notes || undefined,
      metadata: jsonRecord(child.metadata),
      created_at: child.createdAt.toISOString(),
      updated_at: child.updatedAt.toISOString(),
    }));
  }

  async getChild(id: string) {
    const child = await this.prisma.child.findUnique({ where: { id } });
    if (!child) return null;
    return {
      id: child.id,
      name: child.name,
      birthday: child.birthday ? dateOnly(child.birthday) : undefined,
      notes: child.notes || undefined,
      metadata: jsonRecord(child.metadata),
      created_at: child.createdAt.toISOString(),
      updated_at: child.updatedAt.toISOString(),
    };
  }

  async deleteChild(id: string) {
    const result = await this.prisma.child.deleteMany({ where: { id } });
    return result.count > 0;
  }

  async getAssets(filter: { type?: string; childId?: string } = {}) {
    const where: Prisma.AssetWhereInput = {};
    if (filter.type) where.type = filter.type;
    if (filter.childId) where.childId = filter.childId;
    const assets = await this.prisma.asset.findMany({
      where,
      orderBy: [{ capturedAt: "desc" }, { createdAt: "desc" }],
    });
    return assets.map(rowToAsset);
  }

  async getAssetsByIds(ids: string[]) {
    if (ids.length === 0) return [];
    const assets = await this.prisma.asset.findMany({ where: { id: { in: ids } } });
    const byId = new Map(assets.map((asset) => [asset.id, rowToAsset(asset)]));
    return ids.map((id) => byId.get(id)).filter(Boolean) as SampleAsset[];
  }

  async getAsset(id: string) {
    const asset = await this.prisma.asset.findUnique({ where: { id } });
    return asset ? rowToAsset(asset) : null;
  }

  async findAssetByChildAndHash(childId: string, hash: string) {
    const asset = await this.prisma.asset.findFirst({ where: { childId, hash } });
    return asset ? rowToAsset(asset) : null;
  }

  async updateAssetMetadata(
    id: string,
    updates: { title?: string; description?: string; tags?: string[]; capturedAt?: string; type?: string },
  ) {
    const data: Prisma.AssetUpdateInput = {};
    if (updates.title !== undefined) data.title = updates.title;
    if (updates.description !== undefined) data.description = updates.description;
    if (updates.tags !== undefined) data.tags = updates.tags;
    if (updates.capturedAt !== undefined) data.capturedAt = updates.capturedAt ? new Date(updates.capturedAt) : null;
    if (updates.type !== undefined) data.type = updates.type;
    if (Object.keys(data).length === 0) return this.getAsset(id);
    try {
      const asset = await this.prisma.asset.update({ where: { id }, data });
      return rowToAsset(asset);
    } catch (error) {
      if (isPrismaNotFoundError(error)) return null;
      throw error;
    }
  }

  async deleteAsset(id: string) {
    const result = await this.prisma.asset.deleteMany({ where: { id } });
    return result.count > 0;
  }

  async deleteChildRelatedRecords(childId: string) {
    return this.prisma.$transaction(async (tx) => {
      const deletedAgentJobs = await tx.agentJob.deleteMany({
        where: {
          OR: [
            { childId },
            { book: { is: { childId } } },
          ],
        },
      });
      const deletedBooks = await tx.book.deleteMany({ where: { childId } });
      const deletedDirectUploadPullbacks = await tx.directUploadPullback.deleteMany({ where: { childId } });
      const deletedLanSessions = await tx.lanSession.deleteMany({ where: { childId } });
      return {
        deletedAgentJobs: deletedAgentJobs.count,
        deletedBooks: deletedBooks.count,
        deletedDirectUploadPullbacks: deletedDirectUploadPullbacks.count,
        deletedLanSessions: deletedLanSessions.count,
      };
    });
  }

  async deleteAssetsByChildId(childId: string) {
    return this.prisma.$transaction(async (tx) => {
      const assets = await tx.asset.findMany({
        where: { childId },
        select: { id: true },
      });
      const assetIds = assets.map((asset) => asset.id);
      if (assetIds.length > 0) {
        await tx.storageSyncJob.deleteMany({
          where: { targetType: "asset", targetId: { in: assetIds } },
        });
      }
      const result = await tx.asset.deleteMany({ where: { childId } });
      return result.count;
    });
  }

  async deleteEmbeddingJobsByAssetIds(assetIds: string[]) {
    if (assetIds.length === 0) return 0;
    const result = await this.prisma.embeddingJob.deleteMany({ where: { assetId: { in: assetIds } } });
    return result.count;
  }

  async deleteCandidatePoolItemsByChildId(childId: string) {
    const result = await this.prisma.candidatePoolItem.deleteMany({ where: { childId } });
    return result.count;
  }

  async prepareAssetForIndexing(assetId: string) {
    try {
      const asset = await this.prisma.asset.update({
        where: { id: assetId },
        data: {
          embeddingVersion: { increment: 1 },
          embeddingStatus: "pending",
          searchable: false,
          embeddingUpdatedAt: new Date(),
          lastEmbeddingErrorCode: null,
          lastEmbeddingErrorMessage: null,
        },
      });
      await this.prisma.assetEmbedding.deleteMany({ where: { assetId } });
      return { assetId: asset.id, metadataVersion: asset.embeddingVersion };
    } catch (error) {
      if (isPrismaNotFoundError(error)) return null;
      throw error;
    }
  }

  async enqueueEmbeddingJob(input: { assetId: string; metadataVersion: number; maxAttempts?: number; sourceQuery?: string }) {
    const id = `embjob_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
    try {
      const job = await this.prisma.embeddingJob.create({
        data: {
          id,
          assetId: input.assetId,
          metadataVersion: input.metadataVersion,
          status: "pending",
          attempt: 0,
          maxAttempts: input.maxAttempts || 5,
          runAfter: new Date(),
          sourceQuery: input.sourceQuery || null,
        },
      });
      return { enqueued: true, jobId: job.id };
    } catch (error) {
      if (!isPrismaUniqueConflict(error)) throw error;
      const existing = await this.prisma.embeddingJob.findUnique({
        where: { assetId_metadataVersion: { assetId: input.assetId, metadataVersion: input.metadataVersion } },
        select: { id: true },
      });
      return { enqueued: false, jobId: existing?.id || id };
    }
  }

  async claimEmbeddingJobs(options: { limit: number; workerId: string; now?: Date; staleAfterSeconds?: number }) {
    const now = options.now || new Date();
    await this.releaseStaleEmbeddingJobs(now, options.staleAfterSeconds || 60);
    const due = await this.prisma.embeddingJob.findMany({
      where: { status: { in: ["pending", "retry_wait"] }, runAfter: { lte: now } },
      orderBy: { createdAt: "asc" },
      take: Math.max(1, options.limit),
    });
    const claimed: EmbeddingJob[] = [];
    for (const job of due) {
      const result = await this.prisma.embeddingJob.updateMany({
        where: { id: job.id, status: job.status },
        data: { status: "running", lockedBy: options.workerId, lockedAt: now },
      });
      if (result.count === 1) {
        claimed.push(rowToEmbeddingJob({ ...job, status: "running", lockedBy: options.workerId, lockedAt: now, updatedAt: now }));
      }
    }
    return claimed;
  }

  async markEmbeddingJobDone(jobId: string) {
    await this.prisma.embeddingJob.updateMany({ where: { id: jobId }, data: { status: "done", lockedBy: null, lockedAt: null } });
  }

  async markEmbeddingJobRetry(input: { jobId: string; attempt: number; runAfter: Date; errorCode: string; errorMessage: string }) {
    await this.prisma.embeddingJob.updateMany({
      where: { id: input.jobId },
      data: {
        status: "retry_wait",
        attempt: input.attempt,
        runAfter: input.runAfter,
        lockedBy: null,
        lockedAt: null,
        lastErrorCode: input.errorCode,
        lastErrorMessage: input.errorMessage,
      },
    });
  }

  async markEmbeddingJobFailed(input: { jobId: string; attempt: number; errorCode: string; errorMessage: string }) {
    await this.prisma.embeddingJob.updateMany({
      where: { id: input.jobId },
      data: {
        status: "failed",
        attempt: input.attempt,
        lockedBy: null,
        lockedAt: null,
        lastErrorCode: input.errorCode,
        lastErrorMessage: input.errorMessage,
      },
    });
  }

  async getEmbeddingJobsByStatus(status: EmbeddingJobStatus, childId?: string) {
    const jobs = await this.prisma.embeddingJob.findMany({
      where: {
        status,
        asset: childId ? { childId } : undefined,
      },
      orderBy: { createdAt: "asc" },
    });
    return jobs.map(rowToEmbeddingJob);
  }

  async storeAssetEmbedding(input: { assetId: string; metadataVersion: number; embedding: number[]; model: string }) {
    const now = new Date();
    const result = await this.prisma.$transaction(async (tx) => {
      const updated = await tx.asset.updateMany({
        where: { id: input.assetId, embeddingVersion: input.metadataVersion },
        data: {
          embeddingStatus: "ready",
          searchable: true,
          embeddingUpdatedAt: now,
          lastEmbeddingErrorCode: null,
          lastEmbeddingErrorMessage: null,
        },
      });
      if (updated.count !== 1) return false;
      await tx.assetEmbedding.upsert({
        where: { assetId: input.assetId },
        create: {
          assetId: input.assetId,
          embeddingData: jsonArray(input.embedding),
          model: input.model,
          createdAt: now,
        },
        update: {
          embeddingData: jsonArray(input.embedding),
          model: input.model,
        },
      });
      return true;
    });
    return result;
  }

  async markAssetEmbeddingFailed(input: { assetId: string; metadataVersion: number; errorCode: string; errorMessage: string }) {
    await this.prisma.asset.updateMany({
      where: { id: input.assetId, embeddingVersion: input.metadataVersion },
      data: {
        embeddingStatus: "failed",
        searchable: false,
        embeddingUpdatedAt: new Date(),
        lastEmbeddingErrorCode: input.errorCode,
        lastEmbeddingErrorMessage: input.errorMessage,
      },
    });
  }

  async searchAssetsByVector(input: { childId: string; vector: number[]; topK: number; filters?: SearchFilters }) {
    const where = vectorSearchWhere(input.childId, input.filters);
    const assets = await this.prisma.asset.findMany({
      where,
      include: { assetEmbedding: true },
      orderBy: [{ embeddingUpdatedAt: "desc" }, { updatedAt: "desc" }],
    });
    return assets
      .map((asset) => {
        const embedding = vectorFromJson(asset.assetEmbedding?.embeddingData);
        if (!embedding) return null;
        return { asset: rowToAsset(asset), semanticScore: cosineSimilarity(input.vector, embedding) };
      })
      .filter((entry): entry is SearchRecallResult => Boolean(entry))
      .sort((a, b) => b.semanticScore - a.semanticScore)
      .slice(0, Math.max(1, input.topK));
  }

  async listCandidatePoolItems(childId: string) {
    const items = await this.prisma.candidatePoolItem.findMany({ where: { childId }, orderBy: { createdAt: "desc" } });
    return items.map(rowToCandidatePoolItem);
  }

  async addCandidatePoolItems(input: { childId: string; assetIds: string[]; sourceQuery?: string }) {
    if (input.assetIds.length === 0) return { added: 0 };
    let added = 0;
    for (const assetId of input.assetIds) {
      try {
        await this.prisma.candidatePoolItem.create({
          data: { childId: input.childId, assetId, sourceQuery: input.sourceQuery || null },
        });
        added += 1;
      } catch (error) {
        if (!isPrismaUniqueConflict(error)) throw error;
      }
    }
    return { added };
  }

  async removeCandidatePoolItems(input: { childId: string; assetIds: string[] }) {
    if (input.assetIds.length === 0) return { removed: 0 };
    const result = await this.prisma.candidatePoolItem.deleteMany({
      where: { childId: input.childId, assetId: { in: input.assetIds } },
    });
    return { removed: result.count };
  }

  async enqueueStorageSyncJob(input: {
    targetType: "asset" | "export_artifact";
    targetId: string;
    provider?: "supabase";
    objectPath: string;
    maxAttempts?: number;
  }) {
    const provider = input.provider || "supabase";
    const id = `storagejob_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
    try {
      const job = await this.prisma.storageSyncJob.create({
        data: {
          id,
          targetType: input.targetType,
          targetId: input.targetId,
          provider,
          objectPath: input.objectPath,
          status: "pending",
          attempt: 0,
          maxAttempts: input.maxAttempts || 5,
          runAfter: new Date(),
        },
      });
      return { enqueued: true, jobId: job.id };
    } catch (error) {
      if (!isPrismaUniqueConflict(error)) throw error;
      const existing = await this.prisma.storageSyncJob.findFirst({
        where: { targetType: input.targetType, targetId: input.targetId, provider, objectPath: input.objectPath },
        select: { id: true },
      });
      return { enqueued: false, jobId: existing?.id || id };
    }
  }

  async claimStorageSyncJobs(options: { limit: number; workerId: string; now?: Date; staleAfterSeconds?: number }) {
    const now = options.now || new Date();
    await this.releaseStaleStorageJobs(now, options.staleAfterSeconds || 60);
    const due = await this.prisma.storageSyncJob.findMany({
      where: { status: { in: ["pending", "retry_wait"] }, runAfter: { lte: now } },
      orderBy: { createdAt: "asc" },
      take: Math.max(1, options.limit),
    });
    const claimed: StorageSyncJob[] = [];
    for (const job of due) {
      const result = await this.prisma.storageSyncJob.updateMany({
        where: { id: job.id, status: job.status },
        data: { status: "running", lockedBy: options.workerId, lockedAt: now },
      });
      if (result.count === 1) {
        claimed.push(rowToStorageSyncJob({ ...job, status: "running", lockedBy: options.workerId, lockedAt: now, updatedAt: now }));
      }
    }
    return claimed;
  }

  async markStorageSyncJobDone(jobId: string) {
    await this.prisma.storageSyncJob.updateMany({ where: { id: jobId }, data: { status: "done", lockedBy: null, lockedAt: null } });
  }

  async markStorageSyncJobRetry(input: { jobId: string; attempt: number; runAfter: Date; errorCode: string; errorMessage: string }) {
    await this.prisma.storageSyncJob.updateMany({
      where: { id: input.jobId },
      data: {
        status: "retry_wait",
        attempt: input.attempt,
        runAfter: input.runAfter,
        lockedBy: null,
        lockedAt: null,
        lastErrorCode: input.errorCode,
        lastErrorMessage: input.errorMessage,
      },
    });
  }

  async markStorageSyncJobFailed(input: { jobId: string; attempt: number; errorCode: string; errorMessage: string }) {
    await this.prisma.storageSyncJob.updateMany({
      where: { id: input.jobId },
      data: {
        status: "failed",
        attempt: input.attempt,
        lockedBy: null,
        lockedAt: null,
        lastErrorCode: input.errorCode,
        lastErrorMessage: input.errorMessage,
      },
    });
  }

  async getStorageSyncJobsByStatus(status: StorageSyncJobStatus) {
    const jobs = await this.prisma.storageSyncJob.findMany({ where: { status }, orderBy: { createdAt: "asc" } });
    return jobs.map(rowToStorageSyncJob);
  }

  async updateAssetStorageState(input: { assetId: string; storageProvider: string; storageStatus: string; storagePath?: string; remoteUrl?: string }) {
    try {
      const asset = await this.prisma.asset.update({
        where: { id: input.assetId },
        data: {
          storageProvider: input.storageProvider,
          storageStatus: input.storageStatus,
          storagePath: input.storagePath,
          remoteUrl: input.remoteUrl,
        },
      });
      return rowToAsset(asset);
    } catch (error) {
      if (isPrismaNotFoundError(error)) return null;
      throw error;
    }
  }

  async upsertExportArtifact(artifact: ExportArtifact) {
    const row = await this.prisma.exportArtifact.upsert({
      where: { id: artifact.id },
      create: {
        id: artifact.id,
        jobId: artifact.jobId,
        kind: artifact.kind,
        localPath: artifact.localPath,
        storageProvider: artifact.storageProvider || "local",
        storageStatus: artifact.storageStatus || "local_only",
        storagePath: artifact.storagePath || null,
        remoteUrl: artifact.remoteUrl || null,
        createdAt: artifact.createdAt ? new Date(artifact.createdAt) : undefined,
      },
      update: {
        jobId: artifact.jobId,
        kind: artifact.kind,
        localPath: artifact.localPath,
        storageProvider: artifact.storageProvider || "local",
        storageStatus: artifact.storageStatus || "local_only",
        storagePath: artifact.storagePath || null,
        remoteUrl: artifact.remoteUrl || null,
      },
    });
    return rowToExportArtifact(row);
  }

  async getExportArtifact(id: string) {
    const row = await this.prisma.exportArtifact.findUnique({ where: { id } });
    return row ? rowToExportArtifact(row) : null;
  }

  async updateExportArtifactStorageState(input: { artifactId: string; storageProvider: string; storageStatus: string; storagePath?: string; remoteUrl?: string }) {
    try {
      const row = await this.prisma.exportArtifact.update({
        where: { id: input.artifactId },
        data: {
          storageProvider: input.storageProvider,
          storageStatus: input.storageStatus,
          storagePath: input.storagePath,
          remoteUrl: input.remoteUrl,
        },
      });
      return rowToExportArtifact(row);
    } catch (error) {
      if (isPrismaNotFoundError(error)) return null;
      throw error;
    }
  }

  private async releaseStaleEmbeddingJobs(now: Date, staleAfterSeconds: number) {
    const staleBefore = new Date(now.getTime() - Math.max(1, staleAfterSeconds) * 1000);
    const stale = await this.prisma.embeddingJob.findMany({
      where: { status: "running", lockedAt: { lte: staleBefore } },
    });
    for (const job of stale) {
      const attempt = job.attempt + 1;
      await this.prisma.embeddingJob.updateMany({
        where: { id: job.id, status: "running" },
        data: {
          attempt,
          status: attempt >= job.maxAttempts ? "failed" : "pending",
          runAfter: attempt >= job.maxAttempts ? job.runAfter : now,
          lockedBy: null,
          lockedAt: null,
          lastErrorCode: attempt >= job.maxAttempts ? job.lastErrorCode || "stale_timeout" : job.lastErrorCode,
          lastErrorMessage: attempt >= job.maxAttempts ? job.lastErrorMessage || "job lock timeout" : job.lastErrorMessage,
        },
      });
    }
  }

  private async releaseStaleStorageJobs(now: Date, staleAfterSeconds: number) {
    const staleBefore = new Date(now.getTime() - Math.max(1, staleAfterSeconds) * 1000);
    const stale = await this.prisma.storageSyncJob.findMany({
      where: { status: "running", lockedAt: { lte: staleBefore } },
    });
    for (const job of stale) {
      const attempt = job.attempt + 1;
      await this.prisma.storageSyncJob.updateMany({
        where: { id: job.id, status: "running" },
        data: {
          attempt,
          status: attempt >= job.maxAttempts ? "failed" : "pending",
          runAfter: attempt >= job.maxAttempts ? job.runAfter : now,
          lockedBy: null,
          lockedAt: null,
          lastErrorCode: attempt >= job.maxAttempts ? job.lastErrorCode || "stale_timeout" : job.lastErrorCode,
          lastErrorMessage: attempt >= job.maxAttempts ? job.lastErrorMessage || "storage sync lock timeout" : job.lastErrorMessage,
        },
      });
    }
  }
}

Inject(PrismaService)(PrismaDatasetDbService, undefined, 0);
Injectable()(PrismaDatasetDbService);

function assetToPrisma(asset: SampleAsset): Omit<Prisma.AssetUncheckedCreateInput, "id"> {
  return {
    childId: asset.childId || null,
    type: asset.type,
    title: asset.title,
    description: asset.description || "",
    tags: asset.tags || [],
    imagePath: asset.imagePath || null,
    thumbnailPath: asset.thumbnailPath || null,
    sourceUrl: asset.sourceUrl || null,
    license: asset.license,
    hash: asset.hash || null,
    originalFilename: asset.originalFilename || null,
    originalPath: asset.originalPath || null,
    storageProvider: asset.storageProvider || "local",
    storageStatus: asset.storageStatus || "local_only",
    storagePath: asset.storagePath || asset.imagePath || null,
    remoteUrl: asset.remoteUrl || null,
    embeddingStatus: asset.embeddingStatus || "pending",
    embeddingVersion: typeof asset.embeddingVersion === "number" ? asset.embeddingVersion : 0,
    searchable: asset.searchable === true,
    embeddingUpdatedAt: asset.embeddingUpdatedAt ? new Date(asset.embeddingUpdatedAt) : null,
    lastEmbeddingErrorCode: asset.lastEmbeddingErrorCode || null,
    lastEmbeddingErrorMessage: asset.lastEmbeddingErrorMessage || null,
    capturedAt: asset.capturedAt ? new Date(asset.capturedAt) : null,
  };
}

function rowToAsset(row: PrismaAsset): SampleAsset {
  return {
    id: row.id,
    childId: row.childId || undefined,
    type: row.type,
    title: row.title,
    description: row.description,
    tags: row.tags,
    imagePath: row.imagePath || "",
    thumbnailPath: row.thumbnailPath || "",
    sourceUrl: row.sourceUrl || "",
    license: row.license,
    capturedAt: row.capturedAt ? row.capturedAt.toISOString() : undefined,
    hash: row.hash || undefined,
    originalFilename: row.originalFilename || undefined,
    originalPath: row.originalPath || undefined,
    storageProvider: row.storageProvider || undefined,
    storageStatus: row.storageStatus || undefined,
    storagePath: row.storagePath || undefined,
    remoteUrl: row.remoteUrl || undefined,
    updatedAt: row.updatedAt.toISOString(),
    embeddingStatus: normalizeAssetEmbeddingStatus(row.embeddingStatus),
    embeddingVersion: row.embeddingVersion,
    searchable: row.searchable,
    embeddingUpdatedAt: row.embeddingUpdatedAt ? row.embeddingUpdatedAt.toISOString() : undefined,
    lastEmbeddingErrorCode: row.lastEmbeddingErrorCode || undefined,
    lastEmbeddingErrorMessage: row.lastEmbeddingErrorMessage || undefined,
  };
}

function rowToEmbeddingJob(row: PrismaEmbeddingJob): EmbeddingJob {
  return {
    id: row.id,
    assetId: row.assetId,
    metadataVersion: row.metadataVersion,
    status: row.status as EmbeddingJobStatus,
    attempt: row.attempt,
    maxAttempts: row.maxAttempts,
    runAfter: row.runAfter.toISOString(),
    lockedBy: row.lockedBy || "",
    lockedAt: row.lockedAt ? row.lockedAt.toISOString() : "",
    sourceQuery: row.sourceQuery || "",
    lastErrorCode: row.lastErrorCode || "",
    lastErrorMessage: row.lastErrorMessage || "",
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
  };
}

function rowToStorageSyncJob(row: PrismaStorageSyncJob): StorageSyncJob {
  return {
    id: row.id,
    targetType: row.targetType === "export_artifact" ? "export_artifact" : "asset",
    targetId: row.targetId,
    provider: "supabase",
    objectPath: row.objectPath,
    status: row.status as StorageSyncJobStatus,
    attempt: row.attempt,
    maxAttempts: row.maxAttempts,
    runAfter: row.runAfter.toISOString(),
    lockedBy: row.lockedBy || "",
    lockedAt: row.lockedAt ? row.lockedAt.toISOString() : "",
    lastErrorCode: row.lastErrorCode || "",
    lastErrorMessage: row.lastErrorMessage || "",
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
  };
}

function rowToCandidatePoolItem(row: PrismaCandidatePoolItem): SearchCandidatePoolItem {
  return {
    childId: row.childId,
    assetId: row.assetId,
    sourceQuery: row.sourceQuery || "",
    createdAt: row.createdAt.toISOString(),
  };
}

function rowToExportArtifact(row: PrismaExportArtifact): ExportArtifact {
  return {
    id: row.id,
    jobId: row.jobId,
    kind: row.kind === "long_image_png" || row.kind === "long_image_jpg" ? row.kind : "pdf",
    localPath: row.localPath,
    storageProvider: row.storageProvider || undefined,
    storageStatus: row.storageStatus || undefined,
    storagePath: row.storagePath || undefined,
    remoteUrl: row.remoteUrl || undefined,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
  };
}

function vectorSearchWhere(childId: string, filters?: SearchFilters): Prisma.AssetWhereInput {
  const where: Prisma.AssetWhereInput = {
    childId,
    embeddingStatus: "ready",
    searchable: true,
  };
  if (filters?.types?.length) where.type = { in: filters.types };
  if (filters?.tags?.length) where.tags = { hasEvery: filters.tags };
  if (filters?.capturedFrom || filters?.capturedTo) {
    where.capturedAt = {};
    if (filters.capturedFrom) where.capturedAt.gte = new Date(filters.capturedFrom);
    if (filters.capturedTo) where.capturedAt.lte = new Date(filters.capturedTo);
  }
  return where;
}

function normalizeAssetEmbeddingStatus(value: unknown): "pending" | "failed" | "ready" | undefined {
  return value === "pending" || value === "failed" || value === "ready" ? value : undefined;
}

function jsonObject(value: Record<string, unknown> | undefined): Prisma.InputJsonObject {
  return (value || {}) as Prisma.InputJsonObject;
}

function jsonArray(value: number[]): Prisma.InputJsonArray {
  return value;
}

function jsonRecord(value: Prisma.JsonValue): Record<string, unknown> {
  return value && typeof value === "object" && !Array.isArray(value) ? value as Record<string, unknown> : {};
}

function vectorFromJson(value: Prisma.JsonValue | undefined): number[] | null {
  if (!Array.isArray(value)) return null;
  const vector = value.filter((entry): entry is number => typeof entry === "number" && Number.isFinite(entry));
  return vector.length === value.length && vector.length > 0 ? vector : null;
}

function cosineSimilarity(a: number[], b: number[]) {
  const length = Math.min(a.length, b.length);
  if (length === 0) return 0;
  let dot = 0;
  let normA = 0;
  let normB = 0;
  for (let index = 0; index < length; index += 1) {
    dot += a[index] * b[index];
    normA += a[index] * a[index];
    normB += b[index] * b[index];
  }
  if (normA === 0 || normB === 0) return 0;
  return dot / (Math.sqrt(normA) * Math.sqrt(normB));
}

function dateOnly(value: Date) {
  return value.toISOString().slice(0, 10);
}

function isPrismaUniqueConflict(error: unknown) {
  return (error as { code?: unknown })?.code === "P2002";
}
