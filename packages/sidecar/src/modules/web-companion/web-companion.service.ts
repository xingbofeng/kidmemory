/**
 * Web Companion 服务层
 * 严格按照 PRD 规范实现会话管理和上传项管理
 */

import crypto from "node:crypto";
import { ServiceUnavailableException } from "@nestjs/common";

import { AppConfigService } from "../../infrastructure/config/app-config.service.ts";
import { createSupabaseStorageProvider } from "../storage/providers/supabase-storage.ts";
import { DatasetService } from "../dataset/dataset.service.ts";

import {
  UploadSessionStatus,
  UploadItemStatus,
  StorageProvider,
  WebCompanionErrorCode,
  DEFAULT_CONFIG,
  isValidSessionStatusTransition,
  isValidUploadItemStatusTransition,
  canCreateUploadItems,
  type WebCompanionErrorCodeType,
  type StorageProviderType,
  type UploadSessionStatusType,
  type UploadItemStatusType,
} from "./constants.ts";

import type {
  CreateSessionRequest,
  CreateSessionResponse,
  CreateUploadItemsRequest,
  CreateUploadItemsResponse,
  CommitUploadItemRequest,
  CommitUploadItemResponse,
  RetryUploadItemRequest,
  CloseSessionRequest,
  SessionSummaryResponse,
  SessionDetailResponse,
  UploadSession,
  UploadItem,
  CreateSessionOptions,
  CreateUploadItemOptions,
  SignedUploadTarget,
  TokenValidationResult,
  UploadItemCreationResult,
} from "./types.ts";

export interface CreateUploadItemWithAssetInput {
  sessionId: string;
  childId: string;
  uploadItemId: string;
  assetId: string;
  clientFileId: string;
  originalFilename: string;
  safeFilename: string;
  contentType: string;
  sizeBytes: number;
  provider: StorageProviderType;
  bucket: string;
  objectKey: string;
  status: UploadItemStatusType;
}

export interface UpdateUploadItemInput {
  sizeBytes?: number;
  contentType?: string;
  remoteEtag?: string | null;
  localPath?: string | null;
  assetId?: string;
  hashSha256?: string | null;
  errorCode?: WebCompanionErrorCodeType | null;
  errorMessage?: string | null;
  committedAt?: Date;
  readyAt?: Date;
}

export interface WebCompanionRepository {
  insertSession(session: Omit<UploadSession, "createdAt">): Promise<void>;
  getSessionById(sessionId: string): Promise<UploadSession | null>;
  updateSessionStatus(input: {
    sessionId: string;
    status: UploadSessionStatusType;
    closedAt?: Date;
  }): Promise<void>;
  countUploadItemsBySession(sessionId: string): Promise<number>;
  getUploadItemsBySession(sessionId: string): Promise<UploadItem[]>;
  getUploadItemById(uploadItemId: string): Promise<UploadItem | null>;
  createUploadItemWithAsset(input: CreateUploadItemWithAssetInput): Promise<UploadItem>;
  updateUploadItemStatus(input: {
    uploadItemId: string;
    status: UploadItemStatusType;
    updates: UpdateUploadItemInput;
  }): Promise<UploadItem | null>;
}

/**
 * Web Companion 核心服务
 *
 * 职责：
 * 1. 会话生命周期管理
 * 2. 上传项状态管理
 * 3. Token 验证和安全
 * 4. 存储提供商集成
 * 5. 业务规则验证
 */
export class WebCompanionService {
  private readonly appConfigService: AppConfigService;
  private readonly repository: WebCompanionRepository;
  private readonly datasetService: DatasetService;

  constructor(
    appConfigService: AppConfigService,
    repository: WebCompanionRepository,
    datasetService: DatasetService,
  ) {
    this.appConfigService = appConfigService;
    this.repository = repository;
    this.datasetService = datasetService;
  }

  // ============================================================================
  // 会话管理
  // ============================================================================

  /**
   * 创建上传会话（带重试逻辑处理并发冲突）
   */
  async createSession(request: CreateSessionRequest): Promise<CreateSessionResponse> {
    return this.createSessionWithRetry(request, 0);
  }

  /**
   * 创建会话的内部实现，支持重试
   */
  private async createSessionWithRetry(
    request: CreateSessionRequest,
    retryCount: number
  ): Promise<CreateSessionResponse> {
    const MAX_RETRIES = 3;

    // 验证子账户存在
    await this.validateChildExists(request.childId);

    // 生成会话 ID 和 Token
    const sessionId = this.generateSessionId();
    const token = this.generateSecureToken();
    const tokenHash = this.hashToken(token);

    // 计算过期时间
    const expiresInMinutes = request.expiresInMinutes ?? DEFAULT_CONFIG.SESSION_TTL_MINUTES;
    const expiresAt = new Date(Date.now() + expiresInMinutes * 60 * 1000);

    // 创建会话记录
    const session: Omit<UploadSession, "createdAt"> = {
      id: sessionId,
      childId: request.childId,
      tokenHash,
      status: UploadSessionStatus.ACTIVE,
      expiresAt,
      maxItems: request.maxItems ?? DEFAULT_CONFIG.MAX_ITEMS_PER_SESSION,
      closedAt: undefined,
      lastSeenAt: undefined,
    };

    try {
      await this.insertSession(session);

      // 生成 Web URL
      const webUrl = this.generateWebUrl(sessionId, token);

      console.log(`[WebCompanionService] Session created: ${sessionId}`);

      return {
        sessionId,
        token,
        webUrl,
        expiresAt: expiresAt.toISOString(),
        maxItems: session.maxItems,
      };
    } catch (error) {
      // 检查是否是唯一性冲突错误
      if (this.isUniqueViolationError(error) && retryCount < MAX_RETRIES) {
        console.warn(
          `[WebCompanionService] Session ID collision detected, retrying (${retryCount + 1}/${MAX_RETRIES})`
        );
        return this.createSessionWithRetry(request, retryCount + 1);
      }
      throw error;
    }
  }

  /**
   * 检查是否是数据库唯一性冲突错误
   */
  private isUniqueViolationError(error: unknown): boolean {
    if (error && typeof error === 'object' && 'code' in error) {
      const code = (error as { code: string }).code;
      return code === '23505' || code === 'P2002';
    }
    return false;
  }

  /**
   * 获取会话摘要
   */
  async getSessionSummary(sessionId: string, token?: string): Promise<SessionSummaryResponse> {
    const session = await this.getSessionById(sessionId);

    // 检查会话是否过期
    if (session.status === UploadSessionStatus.EXPIRED || session.expiresAt < new Date()) {
      throw this.createError(WebCompanionErrorCode.SESSION_EXPIRED, "Session has expired");
    }

    // 如果提供了 token，验证其有效性
    if (token) {
      const validation = await this.validateToken(token, sessionId);
      if (!validation.valid) {
        throw this.createError(validation.errorCode!, "Invalid token");
      }
    }

    // 获取子账户信息
    const child = await this.getChildById(session.childId);

    // 统计已使用的上传项数量
    const usedItems = await this.countUploadItemsBySession(sessionId);

    // 检查存储提供商可用性
    const providers = await this.checkProviderAvailability();

    return {
      sessionId: session.id,
      status: session.status,
      child: {
        id: child.id,
        displayName: child.name,
      },
      expiresAt: session.expiresAt.toISOString(),
      maxItems: session.maxItems,
      usedItems,
      providers,
    };
  }

  /**
   * 获取会话详情
   */
  async getSessionDetail(sessionId: string, token?: string): Promise<SessionDetailResponse> {
    const session = await this.getSessionById(sessionId);

    // 验证 token
    if (token) {
      const validation = await this.validateToken(token, sessionId);
      if (!validation.valid) {
        throw this.createError(validation.errorCode!);
      }
    }

    // 获取所有上传项
    const items = await this.getUploadItemsBySession(sessionId);

    return {
      sessionId: session.id,
      items: items.map(item => ({
        uploadItemId: item.id,
        assetId: item.assetId,
        filename: item.originalFilename,
        status: item.status,
        provider: item.provider,
        objectKey: item.objectKey,
        errorCode: item.errorCode,
        createdAt: item.createdAt.toISOString(),
        updatedAt: item.updatedAt.toISOString(),
      })),
    };
  }

  /**
   * 关闭会话（幂等操作）
   */
  async closeSession(sessionId: string, request: CloseSessionRequest): Promise<void> {
    console.log(`[WebCompanionService] Closing session: ${sessionId}`);

    // 验证 token
    const validation = await this.validateToken(request.token, sessionId);
    if (!validation.valid) {
      throw this.createError(validation.errorCode!, "Invalid token");
    }

    const session = validation.session!;

    // 检查会话是否已经关闭（幂等性）
    if (session.status === UploadSessionStatus.CLOSED) {
      console.log(`[WebCompanionService] Session ${sessionId} is already closed`);
      return; // 幂等返回，不抛出错误
    }

    // 检查状态转换是否有效
    if (!isValidSessionStatusTransition(session.status, UploadSessionStatus.CLOSED)) {
      throw this.createError(WebCompanionErrorCode.SESSION_EXPIRED, "Cannot close expired session");
    }

    // 更新会话状态
    await this.updateSessionStatus(sessionId, UploadSessionStatus.CLOSED, new Date());

    // 通知 SessionQuotaMiddleware 释放配额
    const sessionQuotaMiddleware = (global as any).sessionQuotaMiddleware;
    if (sessionQuotaMiddleware && session.childId) {
      sessionQuotaMiddleware.recordSessionClosure(session.childId, sessionId);
    }

    console.log(`[WebCompanionService] Session closed: ${sessionId}`);
  }

  // ============================================================================
  // 上传项管理
  // ============================================================================

  /**
   * 创建上传项
   */
  async createUploadItems(
    sessionId: string,
    request: CreateUploadItemsRequest,
  ): Promise<CreateUploadItemsResponse> {
    console.log(`[WebCompanionService] Creating upload items for session ${sessionId}, count: ${request.files.length}`);

    // 验证 token 和会话状态
    const validation = await this.validateToken(request.token, sessionId);
    if (!validation.valid) {
      throw this.createError(validation.errorCode!, "Invalid token");
    }

    const session = validation.session!;

    // 检查会话是否可以创建新的上传项
    if (!canCreateUploadItems(session.status)) {
      throw this.createError(WebCompanionErrorCode.SESSION_CLOSED, "Session is closed");
    }

    // 检查上传项数量限制
    const currentCount = await this.countUploadItemsBySession(sessionId);
    if (currentCount + request.files.length > session.maxItems) {
      throw this.createError(WebCompanionErrorCode.ITEM_LIMIT_EXCEEDED, "Item limit exceeded");
    }

    // 验证文件
    this.validateFiles(request.files);

    // 创建上传项
    const result = await this.createUploadItemsInternal({
      sessionId,
      session,
      files: request.files,
      provider: request.provider,
    });

    if (!result.success) {
      // 如果有错误，抛出第一个错误
      const firstError = result.errors[0];
      throw this.createError(firstError.errorCode, firstError.message);
    }

    console.log(`[WebCompanionService] Created ${result.items.length} upload items for session ${sessionId}`);

    // 生成签名上传目标（如果需要）
    const items = await Promise.all(
      result.items.map(async (item) => {
        const signedUpload = item.provider === StorageProvider.SUPABASE
          ? await this.generateSignedUploadTargetWithFailureState(item)
          : undefined;
        const uploadItem = signedUpload
          ? await this.updateUploadItemStatus(item.id, UploadItemStatus.UPLOADING, {})
          : item;

        return {
          clientFileId: uploadItem.clientFileId || "",
          uploadItemId: uploadItem.id,
          assetId: uploadItem.assetId,
          objectKey: uploadItem.objectKey,
          status: uploadItem.status,
          signedUpload: signedUpload ? {
            ...signedUpload,
          } : undefined,
        };
      }),
    );

    return { items };
  }

  private async generateSignedUploadTargetWithFailureState(item: UploadItem) {
    try {
      return await this.generateSignedUploadTarget(item);
    } catch (error) {
      await this.updateUploadItemStatus(item.id, UploadItemStatus.FAILED, {
        errorCode: this.getErrorCode(error) ?? WebCompanionErrorCode.SIGNED_UPLOAD_UNAVAILABLE,
        errorMessage: error instanceof Error ? error.message : String(error),
      });
      throw error;
    }
  }

  /**
   * 提交上传项
   */
  async commitUploadItem(
    sessionId: string,
    uploadItemId: string,
    request: CommitUploadItemRequest,
  ): Promise<CommitUploadItemResponse> {
    console.log(`[WebCompanionService] Committing upload item ${uploadItemId} for session ${sessionId}`);

    // 验证 token
    const validation = await this.validateToken(request.token, sessionId);
    if (!validation.valid) {
      throw this.createError(validation.errorCode!, "Invalid token");
    }

    // 获取上传项
    const item = await this.getUploadItemById(uploadItemId);
    if (item.sessionId !== sessionId) {
      throw this.createError(WebCompanionErrorCode.UPLOAD_ITEM_NOT_FOUND, "Upload item not found in session");
    }

    // 幂等性检查：如果已经 committed，返回幂等结果
    if (item.committedAt) {
      console.log(`[WebCompanionService] Upload item ${uploadItemId} already committed, returning idempotent result`);
      return {
        uploadItemId: item.id,
        status: item.status,
        idempotent: true,
      };
    }

    // 验证 object key 匹配
    if (item.objectKey !== request.objectKey) {
      throw this.createError(WebCompanionErrorCode.OBJECT_KEY_MISMATCH, "Object key mismatch");
    }

    // 检查状态转换
    if (!isValidUploadItemStatusTransition(item.status, UploadItemStatus.UPLOADED_REMOTE)) {
      throw this.createError(WebCompanionErrorCode.COMMIT_CONFLICT, "Invalid status transition");
    }

    // 更新上传项状态
    const updatedItem = await this.updateUploadItemStatus(
      uploadItemId,
      UploadItemStatus.UPLOADED_REMOTE,
      {
        sizeBytes: request.sizeBytes,
        contentType: request.contentType,
        remoteEtag: request.remoteEtag,
        committedAt: new Date(),
      },
    );

    console.log(`[WebCompanionService] Upload item committed: ${uploadItemId}, starting pullback`);

    // 启动回拉流程（异步）
    this.startPullbackProcess(updatedItem).catch(error => {
      console.error(`[WebCompanionService] Pullback failed for item ${uploadItemId}:`, error);
    });

    return {
      uploadItemId: updatedItem.id,
      status: updatedItem.status,
      idempotent: false,
    };
  }

  /**
   * 重试上传项
   */
  async retryUploadItem(
    sessionId: string,
    uploadItemId: string,
    request: RetryUploadItemRequest,
  ): Promise<CommitUploadItemResponse> {
    console.log(`[WebCompanionService] Retrying upload item ${uploadItemId} for session ${sessionId}`);

    // 验证 token
    const validation = await this.validateToken(request.token, sessionId);
    if (!validation.valid) {
      throw this.createError(validation.errorCode!, "Invalid token");
    }

    // 获取上传项
    const item = await this.getUploadItemById(uploadItemId);
    if (item.sessionId !== sessionId) {
      throw this.createError(WebCompanionErrorCode.UPLOAD_ITEM_NOT_FOUND, "Upload item not found in session");
    }

    // 检查是否可以重试
    if (item.status !== UploadItemStatus.FAILED) {
      throw this.createError(WebCompanionErrorCode.COMMIT_CONFLICT, "Can only retry failed items");
    }

    // 重置状态到 PENDING
    const updatedItem = await this.updateUploadItemStatus(
      uploadItemId,
      UploadItemStatus.PENDING,
      {
        errorCode: undefined,
        errorMessage: undefined,
      },
    );

    console.log(`[WebCompanionService] Upload item reset to pending: ${uploadItemId}`);

    return {
      uploadItemId: updatedItem.id,
      status: updatedItem.status,
    };
  }

  // ============================================================================
  // 私有辅助方法
  // ============================================================================

  private generateSessionId(): string {
    return `session_${Date.now()}_${crypto.randomBytes(8).toString("hex")}`;
  }

  private generateUploadItemId(): string {
    return `item_${Date.now()}_${crypto.randomBytes(8).toString("hex")}`;
  }

  private generateAssetId(): string {
    return `asset_${Date.now()}_${crypto.randomBytes(8).toString("hex")}`;
  }

  private generateSecureToken(): string {
    return crypto.randomBytes(32).toString("hex");
  }

  private hashToken(token: string): string {
    return crypto.createHash("sha256").update(token).digest("hex");
  }

  private generateWebUrl(sessionId: string, token: string): string {
    const baseUrl = this.appConfigService.config.sidecar.webCompanionBaseUrl;
    const query = new URLSearchParams({ sessionId, token });
    return `${baseUrl.replace(/\/$/, "")}/trusted-upload?${query.toString()}`;
  }

  private async validateToken(token: string, sessionId: string): Promise<TokenValidationResult> {
    try {
      const session = await this.getSessionById(sessionId);
      const tokenHash = this.hashToken(token);

      // 使用常量时间比较防止时序攻击
      if (!this.constantTimeCompare(session.tokenHash, tokenHash)) {
        return { valid: false, errorCode: WebCompanionErrorCode.TOKEN_INVALID };
      }

      if (session.expiresAt < new Date()) {
        return { valid: false, errorCode: WebCompanionErrorCode.SESSION_EXPIRED };
      }

      return { valid: true, session };
    } catch (error) {
      return { valid: false, errorCode: WebCompanionErrorCode.SESSION_NOT_FOUND };
    }
  }

  /**
   * 常量时间字符串比较，防止时序攻击
   */
  private constantTimeCompare(a: string, b: string): boolean {
    if (a.length !== b.length) {
      return false;
    }

    let result = 0;
    for (let i = 0; i < a.length; i++) {
      result |= a.charCodeAt(i) ^ b.charCodeAt(i);
    }
    return result === 0;
  }

  private validateFiles(files: CreateUploadItemsRequest["files"]): void {
    for (const file of files) {
      // 检查文件大小
      if (file.sizeBytes > DEFAULT_CONFIG.MAX_FILE_SIZE_BYTES) {
        throw this.createError(WebCompanionErrorCode.FILE_TOO_LARGE);
      }

      // 检查内容类型
      if (!(DEFAULT_CONFIG.ALLOWED_CONTENT_TYPES as readonly string[]).includes(file.contentType)) {
        throw this.createError(WebCompanionErrorCode.FILE_TYPE_UNSUPPORTED);
      }
    }
  }

  private createError(code: string, message?: string): Error {
    const error = new Error(message || `Web Companion Error: ${code}`);
    const customError = error as Error & { code?: string };
    customError.code = code;
    return error;
  }

  private getErrorCode(error: unknown): WebCompanionErrorCodeType | undefined {
    if (!error || typeof error !== "object") return undefined;
    const maybeError = error as { code?: unknown };
    if (typeof maybeError.code !== "string") return undefined;
    if (!Object.values(WebCompanionErrorCode).includes(maybeError.code as WebCompanionErrorCodeType)) {
      return undefined;
    }
    return maybeError.code as WebCompanionErrorCodeType;
  }

  // ============================================================================
  // 数据库操作方法（待实现）
  // ============================================================================

  private async insertSession(session: Omit<UploadSession, "createdAt">): Promise<void> {
    await this.repository.insertSession(session);
  }

  private async getSessionById(sessionId: string): Promise<UploadSession> {
    const session = await this.repository.getSessionById(sessionId);
    if (!session) {
      throw this.createError(WebCompanionErrorCode.SESSION_NOT_FOUND, `Session ${sessionId} not found`);
    }
    return session;
  }

  private async updateSessionStatus(
    sessionId: string,
    status: UploadSessionStatusType,
    closedAt?: Date,
  ): Promise<void> {
    await this.repository.updateSessionStatus({ sessionId, status, closedAt });
  }

  private async countUploadItemsBySession(sessionId: string): Promise<number> {
    return this.repository.countUploadItemsBySession(sessionId);
  }

  private async getUploadItemsBySession(sessionId: string): Promise<UploadItem[]> {
    return this.repository.getUploadItemsBySession(sessionId);
  }

  private async getUploadItemById(uploadItemId: string): Promise<UploadItem> {
    const item = await this.repository.getUploadItemById(uploadItemId);
    if (!item) {
      throw this.createError(WebCompanionErrorCode.UPLOAD_ITEM_NOT_FOUND, `Upload item ${uploadItemId} not found`);
    }
    return item;
  }

  private async createUploadItemsInternal(
    options: CreateUploadItemOptions,
  ): Promise<UploadItemCreationResult> {
    const items: UploadItem[] = [];
    const errors: Array<{
      clientFileId: string;
      errorCode: WebCompanionErrorCodeType;
      message: string;
    }> = [];

    // 使用事务确保 asset 和 upload_item 创建的原子性
    for (const file of options.files) {
      try {
        const uploadItemId = this.generateUploadItemId();
        const assetId = this.generateAssetId();
        const safeFilename = this.sanitizeFilename(file.filename);
        const bucket = this.getBucketForProvider(options.provider);
        const objectKey = this.generateObjectKey(options.session.childId, uploadItemId, safeFilename);

        const item = await this.repository.createUploadItemWithAsset({
          sessionId: options.sessionId,
          childId: options.session.childId,
          uploadItemId,
          assetId,
          clientFileId: file.clientFileId,
          originalFilename: file.filename,
          safeFilename,
          contentType: file.contentType,
          sizeBytes: file.sizeBytes,
          provider: options.provider,
          bucket,
          objectKey,
          status: UploadItemStatus.PENDING,
        });

        items.push(item);
        console.log(`[WebCompanionService] Upload item created: ${item.id} for file ${file.filename}`);
      } catch (error) {
        console.error(`[WebCompanionService] Failed to create upload item for ${file.filename}:`, error);
        errors.push({
          clientFileId: file.clientFileId,
          errorCode: WebCompanionErrorCode.INTERNAL_ERROR,
          message: error instanceof Error ? error.message : String(error),
        });
      }
    }

    return {
      success: errors.length === 0,
      items,
      errors,
    };
  }

  private async updateUploadItemStatus(
    uploadItemId: string,
    status: UploadItemStatusType,
    updates: Partial<UploadItem>,
  ): Promise<UploadItem> {
    const updatedItem = await this.repository.updateUploadItemStatus({
      uploadItemId,
      status,
      updates: {
        ...updates,
        committedAt: status === UploadItemStatus.UPLOADED_REMOTE ? new Date() : updates.committedAt,
        readyAt: status === UploadItemStatus.READY ? new Date() : updates.readyAt,
      },
    });
    if (!updatedItem) {
      throw this.createError(WebCompanionErrorCode.UPLOAD_ITEM_NOT_FOUND, `Upload item ${uploadItemId} not found`);
    }
    return updatedItem;
  }

  private async validateChildExists(childId: string): Promise<void> {
    const child = this.unwrapChildResult(await this.getDatasetChild(childId));
    if (!child) {
      throw this.createError(WebCompanionErrorCode.SESSION_NOT_FOUND, `Child ${childId} not found`);
    }
  }

  private async getChildById(childId: string): Promise<{ id: string; name: string }> {
    const child = this.unwrapChildResult(await this.getDatasetChild(childId));
    if (!child) {
      throw this.createError(WebCompanionErrorCode.SESSION_NOT_FOUND, `Child ${childId} not found`);
    }
    return {
      id: child.id,
      name: child.name || child.id,
    };
  }

  private async getDatasetChild(childId: string): Promise<unknown> {
    const dataset = this.datasetService as DatasetService & {
      getChildById?: (id: string) => Promise<unknown>;
    };
    if (typeof dataset.getChild === "function") return dataset.getChild(childId);
    if (typeof dataset.getChildById === "function") return dataset.getChildById(childId);
    return null;
  }

  private unwrapChildResult(result: unknown): { id: string; name?: string } | null {
    if (!result || typeof result !== "object") return null;
    if ("child" in result) {
      return this.unwrapChildResult((result as { child?: unknown }).child);
    }
    const maybeChild = result as { id?: unknown; name?: unknown; displayName?: unknown };
    if (typeof maybeChild.id !== "string") return null;
    return {
      id: maybeChild.id,
      name:
        typeof maybeChild.name === "string"
          ? maybeChild.name
          : (typeof maybeChild.displayName === "string" ? maybeChild.displayName : undefined),
    };
  }

  private async checkProviderAvailability(): Promise<SessionSummaryResponse["providers"]> {
    const config = this.appConfigService.config.supabaseStorage;

    // 实际检查 Supabase 配置
    const supabaseAvailable = !!(
      config.url &&
      config.serviceRoleKey &&
      config.bucket
    );

    return {
      lan: { available: false },
      supabase: { available: supabaseAvailable },
    };
  }

  private async generateSignedUploadTarget(item: UploadItem): Promise<SignedUploadTarget> {
    const config = this.appConfigService.config.supabaseStorage;

    // 验证 Supabase 配置
    if (!config.url || !config.serviceRoleKey || !config.bucket) {
      throw this.createError(
        WebCompanionErrorCode.PROVIDER_UNAVAILABLE,
        "Supabase configuration is incomplete"
      );
    }

    // 只为 Supabase provider 生成 signed upload
    if (item.provider !== StorageProvider.SUPABASE) {
      throw this.createError(
        WebCompanionErrorCode.PROVIDER_UNAVAILABLE,
        `Signed upload not supported for provider: ${item.provider}`
      );
    }

    const storageProvider = createSupabaseStorageProvider({ config });
    const signedUpload = await storageProvider.createSignedUploadUrl(item.objectKey);
    if (signedUpload.ok) {
      const ttlSeconds = signedUpload.expiresInSeconds || config.signedUrlTtlSeconds || 900;
      return {
        method: "PUT",
        url: signedUpload.url,
        expiresAt: new Date(Date.now() + ttlSeconds * 1000),
        headers: {},
      };
    }

    // 动态导入 Supabase SDK
    const { createClient } = await import("@supabase/supabase-js");

    const supabase = createClient(config.url, config.serviceRoleKey, {
      auth: {
        persistSession: false,
      },
    });

    // 生成 signed upload URL
    const { data, error } = await supabase.storage
      .from(item.bucket)
      .createSignedUploadUrl(item.objectKey);

    if (error) {
      throw this.createError(
        WebCompanionErrorCode.SIGNED_UPLOAD_UNAVAILABLE,
        `Failed to generate signed upload URL: ${error.message}`
      );
    }

    // 计算过期时间
    const ttlSeconds = config.signedUrlTtlSeconds || 900; // 默认 15 分钟
    const expiresAt = new Date(Date.now() + ttlSeconds * 1000);

    return {
      method: "PUT",
      url: data.signedUrl,
      expiresAt,
      headers: {
        "content-type": item.contentType,
      },
    };
  }

  private async startPullbackProcess(item: UploadItem, retryCount = 0): Promise<void> {
    const MAX_RETRIES = 3;
    const RETRY_DELAY_BASE = 1000; // 1 秒基础延迟

    console.log(`[WebCompanionService] Starting pullback for item ${item.id}, attempt ${retryCount + 1}`);

    // 幂等性检查：如果已经在 pulling_local 或 ready 状态，直接返回
    if (item.status === UploadItemStatus.PULLING_LOCAL) {
      console.log(`[WebCompanionService] Item ${item.id} is already pulling_local, skipping duplicate pullback`);
      return;
    }

    if (item.status === UploadItemStatus.READY) {
      console.log(`[WebCompanionService] Item ${item.id} is already ready, skipping duplicate pullback`);
      return;
    }

    try {
      // 更新状态为 pulling_local
      await this.updateUploadItemStatus(item.id, UploadItemStatus.PULLING_LOCAL, {});

      // 获取会话信息以获取正确的childId
      const session = await this.getSessionById(item.sessionId);

      const config = this.appConfigService.config.supabaseStorage;
      const storageProvider = createSupabaseStorageProvider({ config });
      const signedDownload = await storageProvider.createSignedUrl(item.objectKey);
      if (!signedDownload.ok || !signedDownload.url) {
        throw new Error(signedDownload.message || "Failed to generate signed download URL");
      }
      const response = await fetch(signedDownload.url);
      if (!response.ok) {
        throw new Error(`Failed to download object: HTTP ${response.status}`);
      }
      const arrayBuffer = await response.arrayBuffer();
      const body = Buffer.from(arrayBuffer);

      // 计算 hash
      const crypto = await import("node:crypto");
      const hash = crypto.createHash("sha256").update(body).digest("hex");

      // 将文件保存到临时位置，然后使用 importAssets 导入
      const fs = await import("node:fs/promises");
      const path = await import("node:path");
      const os = await import("node:os");

      // 创建临时文件
      const tempDir = await fs.mkdtemp(path.join(os.tmpdir(), 'web-companion-'));
      const tempFilePath = path.join(tempDir, item.safeFilename);

      try {
        // 写入临时文件
        await fs.writeFile(tempFilePath, body);

        // 使用 importAssets 导入（注意：这是复数方法）
        const importResult = await this.datasetService.importAssets({
          childId: session.childId,
          paths: [tempFilePath],
          recursive: false,
        });

        // 清理临时文件
        await fs.unlink(tempFilePath);
        await fs.rmdir(tempDir);

        const importedAsset = importResult.imported[0];
        const duplicateAssetId = importResult.duplicates[0]?.existingAssetId;
        const duplicateAsset = duplicateAssetId
          ? (await this.datasetService.getAsset(duplicateAssetId)).asset
          : undefined;
        const assetId = importedAsset?.id || duplicateAsset?.id;
        const localPath = importedAsset?.path
          || duplicateAsset?.imagePath
          || duplicateAsset?.thumbnailPath
          || duplicateAsset?.storagePath;

        if (!importResult.ok || !assetId || !localPath) {
          throw new Error('Asset import failed');
        }

        // 更新状态为 ready，使用导入的资产信息
        await this.updateUploadItemStatus(item.id, UploadItemStatus.READY, {
          assetId,
          localPath,
          hashSha256: hash,
          readyAt: new Date(),
        });
      } catch (importError) {
        // 清理临时文件（如果存在）
        try {
          await fs.unlink(tempFilePath);
          await fs.rmdir(tempDir);
        } catch {
          // 忽略清理错误
        }
        throw importError;
      }

      console.log(`[WebCompanionService] Pullback completed for item ${item.id}`);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      const isRetryable = this.isRetryableError(error);

      console.error(
        `[WebCompanionService] Pullback failed for item ${item.id}:`,
        errorMessage,
        `(retryable: ${isRetryable}, attempt: ${retryCount + 1}/${MAX_RETRIES})`
      );

      // 如果是可重试的错误且未达到最大重试次数，则重试
      if (isRetryable && retryCount < MAX_RETRIES) {
        const delay = RETRY_DELAY_BASE * Math.pow(2, retryCount); // 指数退避
        console.log(`[WebCompanionService] Retrying pullback for item ${item.id} after ${delay}ms`);

        await this.sleep(delay);
        return this.startPullbackProcess(item, retryCount + 1);
      }

      // 更新状态为 failed
      await this.updateUploadItemStatus(item.id, UploadItemStatus.FAILED, {
        errorCode: WebCompanionErrorCode.PULLBACK_FAILED,
        errorMessage,
      });

      console.error(`[WebCompanionService] Pullback permanently failed for item ${item.id} after ${retryCount + 1} attempts`);
    }
  }

  /**
   * 判断错误是否可重试
   */
  private isRetryableError(error: unknown): boolean {
    if (error instanceof Error) {
      const message = error.message.toLowerCase();
      // 网络错误、超时、临时性错误可以重试
      return (
        message.includes('network') ||
        message.includes('timeout') ||
        message.includes('econnreset') ||
        message.includes('econnrefused') ||
        message.includes('temporary') ||
        message.includes('503') ||
        message.includes('502')
      );
    }
    return false;
  }

  /**
   * 延迟函数
   */
  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  private getBucketForProvider(provider: StorageProviderType): string {
    if (provider === StorageProvider.SUPABASE) {
      return this.appConfigService.config.supabaseStorage.bucket;
    }
    return '';
  }

  private sanitizeFilename(filename: string): string {
    // 移除路径分隔符和特殊字符
    return filename.replace(/[/\\]/g, '_').replace(/[^\w\s.-]/g, '');
  }

  private generateObjectKey(childId: string, uploadItemId: string, filename: string): string {
    const timestamp = Date.now();
    const random = Math.random().toString(36).substring(2, 8);
    return `web-companion/${childId}/${uploadItemId}/${timestamp}_${random}_${filename}`;
  }
}
