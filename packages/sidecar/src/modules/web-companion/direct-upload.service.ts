/**
 * Web Companion Supabase Direct Upload service.
 *
 * 安全底线：
 *   - service role key、数据库连接串、本地绝对路径只保留在 sidecar，不进入返回体。
 *   - 前端通过 createSession 拿到的 anonKey 是 Supabase public key，但仍由 sidecar 中转避免硬编码。
 *
 * 状态机：见 direct-upload-pullback-state.ts。
 */

import {
  AppConfigService,
  assertWebCompanionDirectUploadReady,
} from "../../infrastructure/config/app-config.service.ts";
import { trimTrailingSlash } from "../../infrastructure/url/trailing-slash.ts";

import type {
  CreateDirectUploadSessionRequest,
  CreateDirectUploadSessionResponse,
} from "./dto/create-direct-upload-session.dto.ts";
import type {
  DirectUploadRemoteObject,
  ListDirectUploadObjectsResponse,
} from "./dto/list-direct-upload-objects.dto.ts";
import type {
  PullbackDirectUploadRequest,
  PullbackDirectUploadResponse,
  PullbackDirectUploadItemResult,
} from "./dto/pullback-direct-upload.dto.ts";
import type { GetDirectUploadStatusResponse } from "./dto/get-direct-upload-status.dto.ts";
import {
  applyDirectUploadPullbackTransition,
  type DirectUploadPullbackStatus,
} from "./direct-upload-pullback-state.ts";

/**
 * Storage 网关：sidecar 用 service role key（若配置）或 anon key 通过 Supabase Storage REST 调用 list / download。
 * 这里用接口而不是直接耦合 Supabase SDK，便于：
 *  1. 单测中替换为内存假实现；
 *  2. 后续迁移到 signed URL 时只换 gateway 不换 service。
 */
export interface DirectUploadStorageGateway {
  listObjects(input: { bucket: string; prefix: string }): Promise<DirectUploadRemoteObject[]>;
  downloadObject(input: {
    bucket: string;
    objectKey: string;
  }): Promise<{ body: Buffer; contentType: string; size: number }>;
}

/**
 * Asset 网关：把回拉的二进制写入本地托管目录与 `assets`。
 * 抽出接口避免 service 直接操作文件系统与 dataset.service，便于测试。
 */
export interface DirectUploadAssetGateway {
  importPullback(input: {
    objectKey: string;
    childId: string;
    sessionId: string;
    body: Buffer;
    contentType: string;
  }): Promise<{ assetId: string; localPath: string }>;
}

/**
 * Pullback 持久化网关：包装 `direct_upload_pullbacks` 表。
 */
export interface DirectUploadPullbackStore {
  upsertPending(input: {
    sessionId: string;
    childId: string;
    objectKey: string;
  }): Promise<DirectUploadPullbackRow>;
  findBySessionId(sessionId: string): Promise<DirectUploadPullbackRow[]>;
  update(
    id: string,
    patch: Partial<DirectUploadPullbackRow>,
  ): Promise<DirectUploadPullbackRow | null>;
}

export interface DirectUploadPullbackRow {
  id: string;
  sessionId: string;
  childId: string;
  objectKey: string;
  status: DirectUploadPullbackStatus;
  assetId: string | null;
  localPath: string | null;
  errorCode: string | null;
  errorMessage: string | null;
}

export interface DirectUploadIdFactory {
  nextSessionId(): string;
}

type DirectUploadAppConfig = Pick<AppConfigService, "config">;

export interface DirectUploadServiceDeps {
  appConfig: DirectUploadAppConfig;
  storage: DirectUploadStorageGateway;
  assets: DirectUploadAssetGateway;
  pullback: DirectUploadPullbackStore;
  idFactory: DirectUploadIdFactory;
  /** 内存中保存 sessionId → childId 的映射（不持久化 session 本身）。 */
  sessionStore?: Map<string, SessionStoreEntry>;
  /** 验证 childId 是否存在于数据库，返回 true 表示存在。可选，未提供时跳过验证。 */
  childExists?: (childId: string) => Promise<boolean>;
}

interface SessionStoreEntry {
  childId: string;
  bucket: string;
  expiresAt: Date;
  token: string;
}

export class DirectUploadService {
  private readonly appConfig: DirectUploadAppConfig;
  private readonly storage: DirectUploadStorageGateway;
  private readonly assets: DirectUploadAssetGateway;
  private readonly pullbackStore: DirectUploadPullbackStore;
  private readonly idFactory: DirectUploadIdFactory;
  private readonly childExists: ((childId: string) => Promise<boolean>) | undefined;
  /** sessionId → childId/bucket 的内存映射。Direct Upload 刻意不持久化 session 本身（与 Trusted Upload 隔离）。 */
  private readonly sessionStore: Map<string, SessionStoreEntry>;
  private cleanupTimer: NodeJS.Timeout | null = null;

  constructor(deps: DirectUploadServiceDeps) {
    this.appConfig = deps.appConfig;
    this.storage = deps.storage;
    this.assets = deps.assets;
    this.pullbackStore = deps.pullback;
    this.idFactory = deps.idFactory;
    this.childExists = deps.childExists;
    this.sessionStore = deps.sessionStore ?? new Map();

    this.startCleanupTimer();
  }

  private startCleanupTimer(): void {
    this.cleanupTimer = setInterval(() => {
      this.cleanupExpiredSessions();
    }, 60 * 60 * 1000);

    // 确保 Node.js 进程退出时不会被定时器阻塞
    if (this.cleanupTimer.unref) {
      this.cleanupTimer.unref();
    }
  }

  private cleanupExpiredSessions(): void {
    const now = new Date();

    for (const [sessionId, entry] of this.sessionStore.entries()) {
      if (entry.expiresAt < now) {
        this.sessionStore.delete(sessionId);
      }
    }
  }

  destroy(): void {
    if (this.cleanupTimer) {
      clearInterval(this.cleanupTimer);
      this.cleanupTimer = null;
    }
  }

  async createSession(
    request: CreateDirectUploadSessionRequest,
  ): Promise<CreateDirectUploadSessionResponse> {
    assertWebCompanionDirectUploadReady(this.appConfig.config);

    const childId = (request.childId || "").trim();
    if (!childId) {
      const error = new Error("childId is required before creating a direct upload session.");
      (error as Error & { code?: string }).code = "child_id_required";
      throw error;
    }

    if (this.childExists) {
      const exists = await this.childExists(childId);
      if (!exists) {
        const error = new Error(`childId '${childId}' does not exist.`);
        (error as Error & { code?: string }).code = "child_not_found";
        throw error;
      }
    }

    const sessionId = this.idFactory.nextSessionId();

    const config = this.appConfig.config;
    const bucket = config.webCompanionDirectUpload.bucket;
    const sessionPath = `${bucket}/${sessionId}`;
    const token = generateSecureToken();
    const publicUrl = buildPublicUrl(config.webCompanionDirectUpload.publicUrl, {
      sessionId,
      childId,
      bucket,
      supabaseUrl: config.supabaseStorage.url,
      token,
    });

    const expiresAt = new Date(
      Date.now() + config.webCompanionDirectUpload.expiresAtHintSeconds * 1000,
    );
    this.sessionStore.set(sessionId, { childId, bucket, expiresAt, token });

    return {
      sessionId,
      childId,
      bucket,
      sessionPath,
      supabaseUrl: config.supabaseStorage.url,
      anonKey: config.supabaseStorage.anonKey,
      publicUrl,
      recommendedClientLimit: config.webCompanionDirectUpload.recommendedClientLimit,
      expiresAtHintSeconds: config.webCompanionDirectUpload.expiresAtHintSeconds,
      token,
    };
  }

  async getSessionConfig(
    sessionId: string,
    token: string,
  ): Promise<{ supabaseUrl: string; anonKey: string; bucket: string; recommendedClientLimit: number }> {
    assertWebCompanionDirectUploadReady(this.appConfig.config);
    const session = this.validateSessionToken(sessionId, token);
    const config = this.appConfig.config;
    return {
      supabaseUrl: config.supabaseStorage.url,
      anonKey: config.supabaseStorage.anonKey,
      bucket: session.bucket,
      recommendedClientLimit: config.webCompanionDirectUpload.recommendedClientLimit,
    };
  }

  async listObjects(sessionId: string, token: string): Promise<ListDirectUploadObjectsResponse> {
    assertWebCompanionDirectUploadReady(this.appConfig.config);
    const session = this.validateSessionToken(sessionId, token);
    const bucket = session.bucket;
    const prefix = `${sessionId}/`;
    const objects = await this.storage.listObjects({ bucket, prefix });
    return {
      sessionId,
      bucket,
      objects,
    };
  }

  async pullback(
    sessionId: string,
    request?: Partial<PullbackDirectUploadRequest> | null,
  ): Promise<PullbackDirectUploadResponse> {
    assertWebCompanionDirectUploadReady(this.appConfig.config);
    const bucket = this.appConfig.config.webCompanionDirectUpload.bucket;
    if (!request || typeof request !== "object" || typeof request.token !== "string") {
      const error = new Error("Direct upload token is required for pullback.");
      (error as Error & { code?: string }).code = "token_required";
      throw error;
    }
    const session = this.validateSessionToken(sessionId, request.token);

    const childId = session.childId;

    const remoteObjects = await this.storage.listObjects({
      bucket,
      prefix: `${sessionId}/`,
    });

    const requestedObjectKeys = request.objectKeys;
    const targetObjects = requestedObjectKeys && requestedObjectKeys.length > 0
      ? remoteObjects.filter((object) => requestedObjectKeys.includes(object.objectKey))
      : remoteObjects;

    const results: PullbackDirectUploadItemResult[] = [];
    for (const object of targetObjects) {
      const result = await this.processOnePullback(sessionId, childId, bucket, object);
      results.push(result);
    }

    return { sessionId, results };
  }

  async getStatus(sessionId: string, token: string): Promise<GetDirectUploadStatusResponse> {
    this.validateSessionToken(sessionId, token);
    const rows = await this.pullbackStore.findBySessionId(sessionId);
    const summary = {
      pending_remote: 0,
      downloading: 0,
      ready: 0,
      failed: 0,
    };
    const items = rows.map((row) => {
      summary[row.status]++;
      return {
        objectKey: row.objectKey,
        status: row.status,
        errorCode: row.errorCode,
        errorMessage: row.errorMessage,
      };
    });
    return { sessionId, items, summary };
  }

  private validateSessionToken(sessionId: string, token?: string): SessionStoreEntry {
    if (!token) {
      const error = new Error("Direct upload token is required.");
      (error as Error & { code?: string }).code = "token_required";
      throw error;
    }

    const session = this.sessionStore.get(sessionId);
    if (!session) {
      throw new Error(`Direct upload session ${sessionId} is not known by this sidecar process.`);
    }

    if (session.expiresAt < new Date()) {
      this.sessionStore.delete(sessionId);
      const error = new Error("Direct upload session has expired.");
      (error as Error & { code?: string }).code = "session_expired";
      throw error;
    }

    if (token !== session.token) {
      const error = new Error("Invalid session token.");
      (error as Error & { code?: string }).code = "invalid_token";
      throw error;
    }

    return session;
  }

  /**
   * Pullback 单个对象。状态机：pending_remote → downloading → ready / failed。
   * 幂等：若该 (sessionId, objectKey) 已经 ready，跳过 import，直接返回 ready。
   */
  private async processOnePullback(
    sessionId: string,
    childId: string,
    bucket: string,
    object: DirectUploadRemoteObject,
  ): Promise<PullbackDirectUploadItemResult> {
    const row = await this.pullbackStore.upsertPending({
      sessionId,
      childId,
      objectKey: object.objectKey,
    });

    if (row.status === "ready") {
      return {
        objectKey: row.objectKey,
        status: "ready",
        errorCode: null,
        errorMessage: null,
      };
    }

    let downloading = applyDirectUploadPullbackTransition(toRecord(row), {
      type: "begin_download",
    });
    await this.pullbackStore.update(row.id, {
      status: downloading.status,
      errorCode: null,
      errorMessage: null,
    });

    try {
      const downloaded = await this.storage.downloadObject({
        bucket,
        objectKey: object.objectKey,
      });
      const imported = await this.assets.importPullback({
        objectKey: object.objectKey,
        childId,
        sessionId,
        body: downloaded.body,
        contentType: downloaded.contentType,
      });
      const ready = applyDirectUploadPullbackTransition(downloading, {
        type: "mark_ready",
        assetId: imported.assetId,
        localPath: imported.localPath,
        pulledAt: new Date().toISOString(),
      });
      await this.pullbackStore.update(row.id, {
        status: ready.status,
        assetId: ready.assetId,
        localPath: ready.localPath,
        errorCode: null,
        errorMessage: null,
      });
      return {
        objectKey: ready.objectKey,
        status: "ready",
        errorCode: null,
        errorMessage: null,
      };
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      const failed = applyDirectUploadPullbackTransition(downloading, {
        type: "mark_failed",
        errorCode: classifyError(error),
        errorMessage: message,
      });
      await this.pullbackStore.update(row.id, {
        status: failed.status,
        assetId: null,
        localPath: null,
        errorCode: failed.errorCode,
        errorMessage: failed.errorMessage,
      });
      return {
        objectKey: failed.objectKey,
        status: "failed",
        errorCode: failed.errorCode,
        errorMessage: failed.errorMessage,
      };
    }
  }
}

function buildPublicUrl(
  publicBase: string,
  params: { sessionId: string; childId: string; bucket: string; supabaseUrl: string; token: string },
): string {
  const base = trimTrailingSlash(publicBase);
  const query = new URLSearchParams({
    sessionId: params.sessionId,
    childId: params.childId,
    bucket: params.bucket,
    supabaseUrl: params.supabaseUrl,
    token: params.token,
  });
  return `${base}/direct-upload?${query.toString()}`;
}

function classifyError(error: unknown): string {
  if (error instanceof Error) {
    const message = error.message.toLowerCase();
    if (message.includes("not found")) return "remote_object_missing";
    if (message.includes("import")) return "asset_import_failed";
  }
  return "remote_download_failed";
}

function toRecord(row: DirectUploadPullbackRow) {
  return {
    id: row.id,
    sessionId: row.sessionId,
    childId: row.childId,
    objectKey: row.objectKey,
    status: row.status,
    assetId: row.assetId,
    localPath: row.localPath,
    errorCode: row.errorCode,
    errorMessage: row.errorMessage,
    pulledAt: null,
  };
}

export type { CreateDirectUploadSessionRequest, CreateDirectUploadSessionResponse };

function generateSecureToken(): string {
  const bytes = new Uint8Array(32);
  crypto.getRandomValues(bytes);
  return Array.from(bytes).map(b => b.toString(16).padStart(2, '0')).join('');
}
