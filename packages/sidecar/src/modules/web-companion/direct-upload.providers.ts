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
  DirectUploadStorageGateway,
} from "./direct-upload.service.ts";
import type { DirectUploadPullbackStatus } from "./direct-upload-pullback-state.ts";
import type { DirectUploadRemoteObject } from "./dto/list-direct-upload-objects.dto.ts";

import { AppConfigService } from "../../infrastructure/config/app-config.service.ts";
import { isPrismaNotFoundError } from "../../infrastructure/database/prisma-errors.ts";
import { trimTrailingSlash } from "../../infrastructure/url/trailing-slash.ts";
import type { DatasetService } from "../dataset/dataset.service.ts";

type DatasetAssetImporter = Pick<DatasetService, "importAssets">;

interface DirectUploadPrismaClient {
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

// ---- DirectUploadStorageGateway --------------------------------------------

/**
 * 通过 Supabase Storage REST API 实现 list / download。
 *
 * 优先使用 service role key（仅 sidecar 持有）；缺失时回退到 anon key + bucket policy。
 * 调用方（DirectUploadService）已负责把 prefix 限制为 `{sessionId}/`。
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
    const { url, apiKey } = this.endpointAndKey();
    const listUrl = `${trimTrailingSlash(url)}/storage/v1/object/list/${encodeURIComponent(bucket)}`;
    const response = await this.fetchImpl(listUrl, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        apikey: apiKey,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        prefix,
        limit: 1000,
        offset: 0,
        sortBy: { column: "name", order: "asc" },
      }),
    });
    if (!response.ok) {
      throw new Error(
        `Supabase Storage list failed: HTTP ${response.status} ${response.statusText}`,
      );
    }
    const items = (await response.json()) as Array<{
      name: string;
      metadata?: { size?: number; mimetype?: string; lastModified?: string };
      updated_at?: string;
    }>;
    return items
      .filter((item) => item.name && !item.name.endsWith("/"))
      .map((item) => ({
        objectKey: `${prefix}${item.name}`,
        size: item.metadata?.size ?? 0,
        contentType: item.metadata?.mimetype || "application/octet-stream",
        lastModified:
          item.metadata?.lastModified || item.updated_at || new Date().toISOString(),
      }));
  }

  async downloadObject({
    bucket,
    objectKey,
  }: {
    bucket: string;
    objectKey: string;
  }): Promise<{ body: Buffer; contentType: string; size: number }> {
    const { url, apiKey } = this.endpointAndKey();
    const objectUrl = `${trimTrailingSlash(url)}/storage/v1/object/${encodeURIComponent(bucket)}/${objectKey
      .split("/")
      .map(encodeURIComponent)
      .join("/")}`;
    const response = await this.fetchImpl(objectUrl, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        apikey: apiKey,
      },
    });
    if (!response.ok) {
      throw new Error(
        `Supabase Storage download failed: HTTP ${response.status} ${response.statusText}`,
      );
    }
    const arrayBuffer = await response.arrayBuffer();
    const body = Buffer.from(arrayBuffer);
    return {
      body,
      contentType: response.headers.get("content-type") || "application/octet-stream",
      size: body.byteLength,
    };
  }

  /**
   * 选择 list/download 使用的密钥：service role key（更稳） > anon key（更安全）。
   * 这一行为对前端不可见，前端始终拿到的是 anon key。
   */
  private endpointAndKey() {
    const cfg = this.appConfig.config.supabaseStorage;
    const apiKey = cfg.serviceRoleKey || cfg.anonKey;
    if (!cfg.url || !apiKey) {
      throw new Error("Supabase storage URL or key missing for direct-upload gateway.");
    }
    return { url: cfg.url, apiKey };
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
  }
}

// ---- DirectUploadPullbackStore ---------------------------------------------

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
