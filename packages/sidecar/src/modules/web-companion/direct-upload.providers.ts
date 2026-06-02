/**
 * Direct Upload production gateway adapters.
 *
 * 这些适配器把 service 层定义的 gateway 接口落到现有 sidecar infrastructure 上：
 *   - DirectUploadStorageGateway → 直接调用 Supabase Storage REST list / download。
 *   - DirectUploadAssetGateway   → 复用 DatasetService importAssets 写入素材库。
 *   - DirectUploadPullbackStore  → 直接读写 direct_upload_pullbacks 表。
 */

import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";

import type {
  DirectUploadAssetGateway,
  DirectUploadPullbackRow,
  DirectUploadPullbackStore,
  DirectUploadSessionStore,
  DirectUploadSessionStoreEntry,
  DirectUploadStorageGateway,
} from "./direct-upload.service.ts";
import type { DirectUploadPullbackStatus } from "./direct-upload-pullback-state.ts";
import type { DirectUploadRemoteObject } from "./dto/list-direct-upload-objects.dto.ts";

import { AppConfigService } from "../../infrastructure/config/app-config.service.ts";
import { isPrismaNotFoundError } from "../../infrastructure/database/prisma-errors.ts";
import type { DatasetService } from "../dataset/dataset.service.ts";
import { createObjectStorageProvider } from "../storage/providers/object-storage.ts";

type DatasetAssetImporter = Pick<DatasetService, "importAssets">;

interface DirectUploadPrismaClient {
  uploadSession: {
    create(input: {
      data: {
        id: string;
        childId: string;
        tokenHash: string;
        status: string;
        expiresAt: Date;
        maxItems: number;
        directUploadBucket?: string | null;
      };
    }): Promise<UploadSessionRow>;
    findUnique(input: { where: { id: string } }): Promise<UploadSessionRow | null>;
    deleteMany(input: {
      where: { id?: string | { startsWith: string }; expiresAt?: { lt: Date }; status?: string };
    }): Promise<{ count: number }>;
  };
  directUploadPullback: {
    upsert(input: {
      where: { sessionId_objectKey: { sessionId: string; objectKey: string } };
      create: {
        id: string;
        sessionId: string;
        childId: string;
        objectKey: string;
        status: DirectUploadPullbackStatus;
      };
      update: { updatedAt: Date };
    }): Promise<PullbackRow>;
    findMany(input: {
      where: { sessionId: string };
      orderBy?: { createdAt: "asc" | "desc" };
    }): Promise<PullbackRow[]>;
    update(input: {
      where: { id: string };
      data: {
        status?: DirectUploadPullbackStatus;
        assetId?: string | null;
        localPath?: string | null;
        errorCode?: string | null;
        errorMessage?: string | null;
        pulledAt?: Date;
      };
    }): Promise<PullbackRow>;
    findUnique(input: { where: { id: string } }): Promise<PullbackRow | null>;
  };
}

interface UploadSessionRow {
  id: string;
  childId: string;
  tokenHash: string;
  status: string;
  expiresAt: Date;
  maxItems: number;
  directUploadBucket?: string | null;
}

// ---- DirectUploadStorageGateway --------------------------------------------

/**
 * 通过当前对象存储 provider 实现 list / download。
 * 调用方（DirectUploadService）已负责把 prefix 限制为 `{sessionId}/`，这里负责把
 * session 持久化 bucket 覆盖到运行时对象存储配置上。
 */
export class SupabaseDirectUploadStorageGateway implements DirectUploadStorageGateway {
  private readonly appConfig: AppConfigService;
  private readonly fetchImpl: typeof fetch;

  constructor(appConfig: AppConfigService, fetchImpl: typeof fetch = fetch) {
    this.appConfig = appConfig;
    this.fetchImpl = fetchImpl;
  }

  async listObjects({
    bucket,
    prefix,
  }: {
    bucket: string;
    prefix: string;
  }): Promise<DirectUploadRemoteObject[]> {
    return this.providerForBucket(bucket).listObjects({ prefix });
  }

  async downloadObject({
    bucket,
    objectKey,
  }: {
    bucket: string;
    objectKey: string;
  }): Promise<{ body: Buffer; contentType: string; size: number }> {
    return this.providerForBucket(bucket).downloadObject(objectKey);
  }

  private providerForBucket(bucket: string) {
    const cfg = this.appConfig.config.supabaseStorage;
    return createObjectStorageProvider({
      config: {
        ...cfg,
        bucket,
      },
      fetch: this.fetchImpl,
    });
  }
}

// ---- DirectUploadAssetGateway ----------------------------------------------

/**
 * 通过 DatasetService 把回拉的二进制写入本地托管目录与 assets 表。
 */
export class DatasetServiceDirectUploadAssetGateway implements DirectUploadAssetGateway {
  private readonly dataset: DatasetAssetImporter;

  constructor(dataset: DatasetAssetImporter) {
    this.dataset = dataset;
  }

  async importPullback({
    objectKey,
    childId,
    body,
    contentType,
  }: {
    objectKey: string;
    childId: string;
    sessionId: string;
    body: Buffer;
    contentType: string;
  }): Promise<{ assetId: string; localPath: string }> {
    const safeName = sanitizeFilename(objectKey.split("/").pop() || "upload.jpg");
    const tempDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-direct-upload-"));
    const tempPath = path.join(tempDir, safeName);
    try {
      await fs.writeFile(tempPath, body);
      void contentType; // dataset import infers from file content

      const result = await this.dataset.importAssets({
        childId,
        paths: [tempPath],
        recursive: false,
      });
      const imported = result.imported?.[0] as
        | { id?: string; assetId?: string; path?: string; imagePath?: string }
        | undefined;
      if (!imported) {
        throw new Error(
          `dataset.importAssets returned no imported entry for objectKey=${objectKey}`,
        );
      }
      const assetId = imported.assetId || imported.id;
      const localPath = imported.imagePath || imported.path || tempPath;
      if (!assetId) {
        throw new Error(
          `dataset.importAssets returned an imported entry without id for objectKey=${objectKey}`,
        );
      }
      return {
        assetId,
        localPath,
      };
    } finally {
      await fs.rm(tempDir, { recursive: true, force: true });
    }
  }
}

// ---- DirectUploadPullbackStore ---------------------------------------------

export class PrismaDirectUploadSessionStore implements DirectUploadSessionStore {
  private readonly prisma: DirectUploadPrismaClient;
  private readonly maxItems: number;

  constructor(prisma: DirectUploadPrismaClient, maxItems: number) {
    this.prisma = prisma;
    this.maxItems = maxItems;
  }

  async insert(session: DirectUploadSessionStoreEntry): Promise<void> {
    if (!session.sessionId.startsWith("wcs_direct_")) {
      throw new Error("Direct upload session id must start with wcs_direct_");
    }
    await this.prisma.uploadSession.create({
      data: {
        id: session.sessionId,
        childId: session.childId,
        tokenHash: session.tokenHash,
        status: "active",
        expiresAt: session.expiresAt,
        maxItems: this.maxItems,
        directUploadBucket: session.bucket,
      },
    });
  }

  async findBySessionId(sessionId: string): Promise<DirectUploadSessionStoreEntry | null> {
    if (!sessionId.startsWith("wcs_direct_")) return null;
    const session = await this.prisma.uploadSession.findUnique({ where: { id: sessionId } });
    if (!session || session.status !== "active") return null;
    return {
      sessionId: session.id,
      childId: session.childId,
      bucket: session.directUploadBucket ?? "",
      expiresAt: session.expiresAt,
      tokenHash: session.tokenHash,
    };
  }

  async delete(sessionId: string): Promise<void> {
    if (!sessionId.startsWith("wcs_direct_")) return;
    await this.prisma.uploadSession.deleteMany({ where: { id: sessionId } });
  }

  async deleteExpired(now: Date): Promise<number> {
    const result = await this.prisma.uploadSession.deleteMany({
      where: {
        id: { startsWith: "wcs_direct_" },
        expiresAt: { lt: now },
        status: "active",
      },
    });
    return result.count;
  }
}

/**
 * 通过 Prisma ORM 读写 direct_upload_pullbacks 表。
 */
export class PrismaDirectUploadPullbackStore implements DirectUploadPullbackStore {
  private readonly prisma: DirectUploadPrismaClient;

  constructor(prisma: DirectUploadPrismaClient) {
    this.prisma = prisma;
  }

  async upsertPending(input: {
    sessionId: string;
    childId: string;
    objectKey: string;
  }): Promise<DirectUploadPullbackRow> {
    const id = `dup_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
    const row = await this.prisma.directUploadPullback.upsert({
      where: {
        sessionId_objectKey: {
          sessionId: input.sessionId,
          objectKey: input.objectKey,
        },
      },
      create: {
        id,
        sessionId: input.sessionId,
        childId: input.childId,
        objectKey: input.objectKey,
        status: "pending_remote",
      },
      update: {
        updatedAt: new Date(),
      },
    });
    return rowToPullback(row);
  }

  async findBySessionId(sessionId: string): Promise<DirectUploadPullbackRow[]> {
    const rows = await this.prisma.directUploadPullback.findMany({
      where: { sessionId },
      orderBy: { createdAt: "asc" },
    });
    return rows.map(rowToPullback);
  }

  async update(
    id: string,
    patch: Partial<DirectUploadPullbackRow>,
  ): Promise<DirectUploadPullbackRow | null> {
    const data: {
      status?: DirectUploadPullbackStatus;
      assetId?: string | null;
      localPath?: string | null;
      errorCode?: string | null;
      errorMessage?: string | null;
      pulledAt?: Date;
    } = {};
    if (patch.status !== undefined) {
      data.status = patch.status;
    }
    if (patch.assetId !== undefined) {
      data.assetId = patch.assetId;
    }
    if (patch.localPath !== undefined) {
      data.localPath = patch.localPath;
    }
    if (patch.errorCode !== undefined) {
      data.errorCode = patch.errorCode;
    }
    if (patch.errorMessage !== undefined) {
      data.errorMessage = patch.errorMessage;
    }
    if (patch.status === "ready") {
      data.pulledAt = new Date();
    }
    if (Object.keys(data).length === 0) {
      return this.findById(id);
    }
    try {
      const row = await this.prisma.directUploadPullback.update({
        where: { id },
        data,
      });
      return rowToPullback(row);
    } catch (error) {
      if (isPrismaNotFoundError(error)) {
        return null;
      }
      throw error;
    }
  }

  private async findById(id: string): Promise<DirectUploadPullbackRow | null> {
    const row = await this.prisma.directUploadPullback.findUnique({
      where: { id },
    });
    return row ? rowToPullback(row) : null;
  }
}

// ---- Helpers ---------------------------------------------------------------

interface PullbackRow {
  id: string;
  sessionId?: string;
  session_id?: string;
  childId?: string;
  child_id?: string;
  objectKey?: string;
  object_key?: string;
  status: string;
  assetId?: string | null;
  asset_id?: string | null;
  localPath?: string | null;
  local_path?: string | null;
  errorCode?: string | null;
  error_code?: string | null;
  errorMessage?: string | null;
  error_message?: string | null;
}

function rowToPullback(row: PullbackRow): DirectUploadPullbackRow {
  return {
    id: row.id,
    sessionId: row.sessionId || row.session_id || "",
    childId: row.childId || row.child_id,
    objectKey: row.objectKey || row.object_key || "",
    status: row.status as DirectUploadPullbackStatus,
    assetId: row.assetId || row.asset_id || null,
    localPath: row.localPath || row.local_path || null,
    errorCode: row.errorCode || row.error_code || null,
    errorMessage: row.errorMessage || row.error_message || null,
  };
}

function sanitizeFilename(filename: string): string {
  const base = path.basename(filename).replace(/[^a-zA-Z0-9._-]+/g, "_");
  return base || "upload.jpg";
}
