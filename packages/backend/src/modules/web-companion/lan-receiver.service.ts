/**
 * LAN Receiver 服务
 *
 * 负责局域网设备发现、配对和直传文件接收
 */

import crypto from "node:crypto";
import { promises as dns } from "node:dns";
import os from "node:os";
import { AppConfigService } from "../../infrastructure/config/app-config.service.ts";
import { DatasetService } from "../dataset/dataset.service.ts";

import type {
  LanDiscoveryResponse,
  LanUploadFile,
  LanPairRequest,
  LanPairResponse,
  LanSession,
  LanTokenValidationResult,
  LanUploadRequest,
  LanUploadResponse,
  LanSessionStatusResponse,
  NetworkDiscoveryOptions,
  NetworkDiscoveryResult,
  DiscoveredDevice,
  LanReceiverConfig,
  LanReceiverErrorCodeType,
} from "./lan-receiver.types.ts";

import {
  LanReceiverErrorCode,
  DEFAULT_LAN_CONFIG,
} from "./lan-receiver.types.ts";

export interface LanReceiverRepository {
  saveLanSession(session: LanSession): Promise<void>;
  getLanSessionById(sessionId: string): Promise<LanSession | null>;
  countReadyUploadsBySession(sessionId: string): Promise<number>;
  deleteExpiredSessions(now: Date): Promise<void>;
}

/**
 * LAN Receiver 核心服务
 *
 * 职责：
 * 1. 设备发现和广播
 * 2. 设备配对和会话管理
 * 3. 局域网直传文件接收
 * 4. 网络错误处理和重试
 * 5. 安全验证和访问控制
 */
export class LanReceiverService {
  private readonly appConfigService: AppConfigService;
  private readonly repository: LanReceiverRepository;
  private readonly datasetService: DatasetService;
  private readonly config: LanReceiverConfig;

  // 内存中的会话存储（用于快速访问）
  private readonly activeSessions = new Map<string, LanSession>();

  // 当前上传计数器（用于并发控制）
  private readonly uploadCounters = new Map<string, number>();
  private cleanupTimer: NodeJS.Timeout | null = null;

  constructor(
    appConfigService: AppConfigService,
    repository: LanReceiverRepository,
    datasetService: DatasetService,
  ) {
    this.appConfigService = appConfigService;
    this.repository = repository;
    this.datasetService = datasetService;

    // 合并配置
    this.config = {
      ...DEFAULT_LAN_CONFIG,
      ...(appConfigService.config as any).lanReceiver,
    };

    // 启动清理任务
    this.startCleanupTask();
  }

  // ============================================================================
  // 设备发现
  // ============================================================================

  /**
   * 获取设备发现信息
   */
  async getDiscoveryInfo(): Promise<LanDiscoveryResponse> {
    const networkInfo = await this.getNetworkInfo();

    return {
      deviceId: this.generateDeviceId(),
      deviceName: this.config.deviceName,
      version: this.config.version,
      capabilities: ["direct-upload", "file-transfer"],
      networkInfo: {
        ip: networkInfo.ip,
        port: this.config.port,
        protocol: "http",
      },
      security: {
        requiresAuth: true,
        supportedMethods: ["token", "qr-code"],
      },
    };
  }

  /**
   * 发现局域网设备
   */
  async discoverLanDevices(options: NetworkDiscoveryOptions): Promise<NetworkDiscoveryResult> {
    const { timeout, serviceType = this.config.discoveryService } = options;

    try {
      // 使用 mDNS 发现设备
      const devices = await this.performMdnsDiscovery(serviceType, timeout);

      return { devices };
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);

      if (errorMessage.includes("timeout")) {
        throw this.createError(LanReceiverErrorCode.DISCOVERY_TIMEOUT, "Device discovery timed out");
      }

      throw this.createError(LanReceiverErrorCode.MDNS_RESOLUTION_FAILED, `mDNS resolution failed: ${errorMessage}`);
    }
  }

  // ============================================================================
  // 设备配对
  // ============================================================================

  /**
   * 处理设备配对请求
   */
  async handlePairRequest(request: LanPairRequest): Promise<LanPairResponse> {
    console.log(`[LanReceiverService] Pairing request from device: ${request.deviceId}`);

    // 验证配对码（如果提供）
    if (request.pairingCode && !this.validatePairingCode(request.pairingCode)) {
      throw this.createError(LanReceiverErrorCode.PAIRING_FAILED, "Invalid pairing code");
    }

    const childId = request.childId?.trim();
    if (!childId) {
      throw this.createError(LanReceiverErrorCode.PAIRING_FAILED, "childId is required for LAN pairing");
    }

    // 生成会话
    const sessionId = this.generateLanSessionId();
    const token = this.generateSecureToken();
    const tokenHash = this.hashToken(token);

    const expiresAt = new Date(Date.now() + this.config.sessionTtlMinutes * 60 * 1000);

    const session: LanSession = {
      id: sessionId,
      deviceId: request.deviceId,
      childId,
      tokenHash,
      expiresAt,
      createdAt: new Date(),
      maxConcurrentUploads: this.config.maxConcurrentUploads,
      currentUploads: 0,
    };

    // 保存会话
    await this.saveLanSession(session);
    this.activeSessions.set(sessionId, session);
    this.uploadCounters.set(sessionId, 0);

    console.log(`[LanReceiverService] LAN session created: ${sessionId}`);

    return {
      success: true,
      sessionId,
      token,
      expiresAt: expiresAt.toISOString(),
      endpoints: {
        upload: `/api/web-companion/lan/sessions/${sessionId}/upload`,
        status: `/api/web-companion/lan/sessions/${sessionId}/status`,
      },
    };
  }

  // ============================================================================
  // 文件上传
  // ============================================================================

  /**
   * 处理局域网直传文件上传
   */
  async handleDirectUpload(
    sessionId: string,
    token: string,
    files: LanUploadFile[],
  ): Promise<LanUploadResponse> {
    console.log(`[LanReceiverService] Direct upload for session ${sessionId}, files: ${files.length}`);

    // 验证会话和token
    const validation = await this.validateLanToken(sessionId, token);
    if (!validation.valid) {
      throw this.createError(validation.errorCode as LanReceiverErrorCodeType, "Invalid session or token");
    }

    const session = validation.session!;

    // 检查并发上传限制
    const currentUploads = this.uploadCounters.get(sessionId) || 0;
    if (currentUploads + files.length > session.maxConcurrentUploads) {
      throw this.createError(
        LanReceiverErrorCode.UPLOAD_LIMIT_EXCEEDED,
        `Concurrent upload limit exceeded: ${currentUploads}/${session.maxConcurrentUploads}`,
      );
    }

    // 验证文件
    this.validateUploadFiles(files);

    const uploadedFiles: LanUploadResponse["uploadedFiles"] = [];
    const errors: LanUploadResponse["errors"] = [];

    // 更新上传计数器
    this.uploadCounters.set(sessionId, currentUploads + files.length);

    try {
      // 处理每个文件
      for (const file of files) {
        try {
          const result = await this.processDirectUploadFile(session, file);
          uploadedFiles.push(result);
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : String(error);
          console.error(`[LanReceiverService] Failed to process file ${file.originalname}:`, error);

          errors.push({
            filename: file.originalname,
            errorCode: LanReceiverErrorCode.NETWORK_ERROR,
            message: errorMessage,
          });
        }
      }

      console.log(`[LanReceiverService] Direct upload completed: ${uploadedFiles.length} success, ${errors.length} errors`);

      return {
        success: errors.length === 0,
        uploadedFiles,
        errors,
      };
    } finally {
      // 减少上传计数器
      const newCount = Math.max(0, (this.uploadCounters.get(sessionId) || 0) - files.length);
      this.uploadCounters.set(sessionId, newCount);

      // 更新会话的当前上传数
      session.currentUploads = newCount;
      this.activeSessions.set(sessionId, session);
    }
  }

  /**
   * 获取LAN会话状态
   */
  async getLanSessionStatus(sessionId: string, token: string): Promise<LanSessionStatusResponse> {
    const validation = await this.validateLanToken(sessionId, token);
    if (!validation.valid) {
      throw this.createError(validation.errorCode as LanReceiverErrorCodeType, "Invalid session or token");
    }

    const session = validation.session!;
    const totalUploaded = await this.countUploadedFilesBySession(sessionId);

    return {
      sessionId: session.id,
      status: session.expiresAt > new Date() ? "active" : "expired",
      expiresAt: session.expiresAt.toISOString(),
      currentUploads: session.currentUploads,
      maxConcurrentUploads: session.maxConcurrentUploads,
      totalUploaded,
    };
  }

  // ============================================================================
  // Token 验证
  // ============================================================================

  /**
   * 验证LAN会话token
   */
  async validateLanToken(sessionId: string, token: string): Promise<LanTokenValidationResult> {
    try {
      // 先从内存缓存查找
      let session = this.activeSessions.get(sessionId);

      // 如果内存中没有，从数据库加载
      if (!session) {
        session = await this.getLanSessionById(sessionId);
        if (session) {
          this.activeSessions.set(sessionId, session);
        }
      }

      if (!session) {
        return { valid: false, errorCode: LanReceiverErrorCode.SESSION_NOT_FOUND };
      }

      // 检查过期
      if (session.expiresAt < new Date()) {
        // 清理过期会话
        this.activeSessions.delete(sessionId);
        this.uploadCounters.delete(sessionId);
        return { valid: false, errorCode: LanReceiverErrorCode.SESSION_EXPIRED };
      }

      // 验证token
      const tokenHash = this.hashToken(token);
      if (!this.constantTimeCompare(session.tokenHash, tokenHash)) {
        return { valid: false, errorCode: LanReceiverErrorCode.TOKEN_INVALID };
      }

      // 更新最后访问时间
      session.lastSeenAt = new Date();
      this.activeSessions.set(sessionId, session);

      return { valid: true, session };
    } catch (error) {
      console.error(`[LanReceiverService] Token validation error:`, error);
      return { valid: false, errorCode: LanReceiverErrorCode.SESSION_NOT_FOUND };
    }
  }

  // ============================================================================
  // 私有辅助方法
  // ============================================================================

  private generateDeviceId(): string {
    // 基于MAC地址或其他硬件信息生成稳定的设备ID
    const hostname = os.hostname();
    return `desktop-${crypto.createHash("md5").update(hostname).digest("hex").slice(0, 8)}`;
  }

  private generateLanSessionId(): string {
    return `lan-session-${Date.now().toString(36)}-${crypto.randomBytes(6).toString("hex")}`;
  }

  private generateSecureToken(): string {
    return crypto.randomBytes(32).toString("hex");
  }

  private hashToken(token: string): string {
    return crypto.createHash("sha256").update(token).digest("hex");
  }

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

  private validatePairingCode(code: string): boolean {
    // 简单的6位数字配对码验证
    return /^\d{6}$/.test(code);
  }

  private validateUploadFiles(files: LanUploadFile[]): void {
    for (const file of files) {
      // 检查文件大小
      if (file.size > this.config.maxFileSizeBytes) {
        throw this.createError(
          LanReceiverErrorCode.FILE_SIZE_EXCEEDED,
          `File ${file.originalname} exceeds size limit: ${file.size} > ${this.config.maxFileSizeBytes}`,
        );
      }

      // 检查文件类型
      if (!this.config.allowedFileTypes.includes(file.mimetype)) {
        throw this.createError(
          LanReceiverErrorCode.FILE_TYPE_NOT_SUPPORTED,
          `File type not supported: ${file.mimetype}`,
        );
      }
    }
  }

  private async processDirectUploadFile(
    session: LanSession,
    file: LanUploadFile,
  ): Promise<LanUploadResponse["uploadedFiles"][0]> {
    const assetId = this.generateAssetId();

    // 保存文件到临时位置
    const fs = await import("node:fs/promises");
    const path = await import("node:path");
    const os = await import("node:os");

    const tempDir = await fs.mkdtemp(path.join(os.tmpdir(), "lan-upload-"));
    const tempFilePath = path.join(tempDir, file.originalname);

    try {
      // 写入文件
      await fs.writeFile(tempFilePath, file.buffer);

      // 使用 DatasetService 导入文件
      const importResult = await this.datasetService.importAssets({
        childId: session.childId,
        paths: [tempFilePath],
        recursive: false,
      });

      if (!importResult.ok || importResult.imported.length === 0) {
        throw new Error("Asset import failed");
      }

      const importedAsset = importResult.imported[0];

      console.log(`[LanReceiverService] File imported successfully: ${file.originalname} -> ${assetId}`);

      return {
        filename: file.originalname,
        assetId,
        status: "ready",
        localPath: importedAsset.path || tempFilePath,
      };
    } finally {
      // 清理临时文件
      try {
        await fs.unlink(tempFilePath);
        await fs.rmdir(tempDir);
      } catch {
        // 忽略清理错误
      }
    }
  }

  private generateAssetId(): string {
    return `asset_${Date.now()}_${crypto.randomBytes(8).toString("hex")}`;
  }

  private async getNetworkInfo(): Promise<{ ip: string }> {
    const os = await import("node:os");
    const interfaces = os.networkInterfaces();

    // 查找第一个非回环的IPv4地址
    for (const name of Object.keys(interfaces)) {
      const iface = interfaces[name];
      if (iface) {
        for (const alias of iface) {
          if (alias.family === "IPv4" && !alias.internal) {
            return { ip: alias.address };
          }
        }
      }
    }

    return { ip: "127.0.0.1" };
  }

  private async performMdnsDiscovery(serviceType: string, timeout: number): Promise<DiscoveredDevice[]> {
    const query = async () => {
      try {
        const srvRecords = await dns.resolveSrv(serviceType);
        const devices: DiscoveredDevice[] = [];
        for (const record of srvRecords) {
          const [addresses, txtRecords] = await Promise.all([
            dns.resolve4(record.name).catch(() => [] as string[]),
            dns.resolveTxt(serviceType).catch(() => [] as string[][]),
          ]);
          const txt = Object.fromEntries(
            txtRecords.flat().map((entry) => {
              const [key, ...value] = entry.split("=");
              return [key, value.join("=")];
            }).filter(([key]) => key),
          );
          devices.push({
            deviceId: txt.deviceId || record.name,
            address: addresses[0] || record.name,
            port: record.port,
            capabilities: (txt.capabilities || "direct-upload,file-transfer").split(",").filter(Boolean),
            txt,
          });
        }
        return devices;
      } catch (error) {
        const code = error instanceof Error ? (error as Error & { code?: string }).code : undefined;
        if (code === "ENODATA" || code === "ENOTFOUND") return [];
        throw error;
      }
    };

    return this.withTimeout(query(), timeout);
  }

  private async withTimeout<T>(promise: Promise<T>, timeout: number): Promise<T> {
    let timer: NodeJS.Timeout | undefined;
    try {
      return await Promise.race([
        promise,
        new Promise<never>((_, reject) => {
          timer = setTimeout(() => reject(new Error("Discovery timeout")), timeout);
        }),
      ]);
    } finally {
      if (timer) clearTimeout(timer);
    }
  }

  private createError(code: LanReceiverErrorCodeType, message?: string): Error {
    const error = new Error(message || `LAN Receiver Error: ${code}`);
    (error as any).code = code;
    return error;
  }

  // ============================================================================
  // 数据库操作
  // ============================================================================

  private async saveLanSession(session: LanSession): Promise<void> {
    await this.repository.saveLanSession(session);
  }

  private async getLanSessionById(sessionId: string): Promise<LanSession | null> {
    return this.repository.getLanSessionById(sessionId);
  }

  private async countUploadedFilesBySession(sessionId: string): Promise<number> {
    return this.repository.countReadyUploadsBySession(sessionId);
  }

  private startCleanupTask(): void {
    // 每5分钟清理过期会话
    this.cleanupTimer = setInterval(() => {
      this.cleanupExpiredSessions().catch(error => {
        console.error("[LanReceiverService] Cleanup task error:", error);
      });
    }, 5 * 60 * 1000);
    this.cleanupTimer.unref?.();
  }

  onModuleDestroy(): void {
    if (this.cleanupTimer) {
      clearInterval(this.cleanupTimer);
      this.cleanupTimer = null;
    }
  }

  private async cleanupExpiredSessions(): Promise<void> {
    const now = new Date();
    const expiredSessions: string[] = [];

    // 检查内存中的会话
    for (const [sessionId, session] of this.activeSessions.entries()) {
      if (session.expiresAt < now) {
        expiredSessions.push(sessionId);
      }
    }

    // 清理过期会话
    for (const sessionId of expiredSessions) {
      this.activeSessions.delete(sessionId);
      this.uploadCounters.delete(sessionId);
    }

    if (expiredSessions.length > 0) {
      console.log(`[LanReceiverService] Cleaned up ${expiredSessions.length} expired sessions`);
    }

    await this.repository.deleteExpiredSessions(now);
  }
}
