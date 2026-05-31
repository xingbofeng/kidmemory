import crypto from "node:crypto";
import { promises as dns } from "node:dns";
import os from "node:os";
import { Logger } from "@nestjs/common";
import { AppConfigService } from "../../infrastructure/config/app-config.service.ts";
import { DatasetService } from "../dataset/dataset.service.ts";

import type {
  LanDiscoveryResponse,
  LanUploadFile,
  LanPairRequest,
  LanPairResponse,
  LanSession,
  LanTokenValidationResult,
  LanUploadInput,
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

type LanReceiverAppConfig = AppConfigService["config"] & {
  lanReceiver?: Partial<LanReceiverConfig>;
};

type LanReceiverError = Error & {
  code: LanReceiverErrorCodeType;
};

export class LanReceiverService {
  private readonly logger = new Logger(LanReceiverService.name);
  private readonly appConfigService: AppConfigService;
  private readonly repository: LanReceiverRepository;
  private readonly datasetService: DatasetService;
  private readonly config: LanReceiverConfig;

  private readonly activeSessions = new Map<string, LanSession>();

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

    const appConfig = appConfigService.config as LanReceiverAppConfig;
    this.config = {
      ...DEFAULT_LAN_CONFIG,
      ...appConfig.lanReceiver,
    };

    this.startCleanupTask();
  }

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

  async discoverLanDevices(options: NetworkDiscoveryOptions): Promise<NetworkDiscoveryResult> {
    const { timeout, serviceType = this.config.discoveryService } = options;

    try {
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

  async handlePairRequest(request: LanPairRequest): Promise<LanPairResponse> {
    if (request.pairingCode && !this.validatePairingCode(request.pairingCode)) {
      throw this.createError(LanReceiverErrorCode.PAIRING_FAILED, "Invalid pairing code");
    }

    const childId = request.childId?.trim();
    if (!childId) {
      throw this.createError(LanReceiverErrorCode.PAIRING_FAILED, "childId is required for LAN pairing");
    }

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

    await this.saveLanSession(session);
    this.activeSessions.set(sessionId, session);
    this.uploadCounters.set(sessionId, 0);

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

  async handleDirectUpload(
    sessionId: string,
    token: string,
    files: LanUploadFile[],
  ): Promise<LanUploadResponse> {
    const validation = await this.validateLanToken(sessionId, token);
    if (!validation.valid) {
      throw this.createError(validation.errorCode as LanReceiverErrorCodeType, "Invalid session or token");
    }

    const session = validation.session!;

    const currentUploads = this.uploadCounters.get(sessionId) || 0;
    if (currentUploads + files.length > session.maxConcurrentUploads) {
      throw this.createError(
        LanReceiverErrorCode.UPLOAD_LIMIT_EXCEEDED,
        `Concurrent upload limit exceeded: ${currentUploads}/${session.maxConcurrentUploads}`,
      );
    }

    this.validateUploadFiles(files);

    const uploadedFiles: LanUploadResponse["uploadedFiles"] = [];
    const errors: LanUploadResponse["errors"] = [];

    this.uploadCounters.set(sessionId, currentUploads + files.length);

    try {
      for (const file of files) {
        try {
          const result = await this.processDirectUploadFile(session, file);
          uploadedFiles.push(result);
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : String(error);
          this.logger.error(
            `[LanReceiverService] Failed to process file ${file.originalname}`,
            error instanceof Error ? error.stack : String(error),
          );

          errors.push({
            filename: file.originalname,
            errorCode: LanReceiverErrorCode.NETWORK_ERROR,
            message: errorMessage,
          });
        }
      }

      return {
        success: errors.length === 0,
        uploadedFiles,
        errors,
      };
    } finally {
      const newCount = Math.max(0, (this.uploadCounters.get(sessionId) || 0) - files.length);
      this.uploadCounters.set(sessionId, newCount);

      session.currentUploads = newCount;
      this.activeSessions.set(sessionId, session);
    }
  }

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

  async validateLanToken(sessionId: string, token: string): Promise<LanTokenValidationResult> {
    try {
      let session = this.activeSessions.get(sessionId);

      if (!session) {
        session = await this.getLanSessionById(sessionId);
        if (session) {
          this.activeSessions.set(sessionId, session);
        }
      }

      if (!session) {
        return { valid: false, errorCode: LanReceiverErrorCode.SESSION_NOT_FOUND };
      }

      if (session.expiresAt < new Date()) {
        this.activeSessions.delete(sessionId);
        this.uploadCounters.delete(sessionId);
        return { valid: false, errorCode: LanReceiverErrorCode.SESSION_EXPIRED };
      }

      const tokenHash = this.hashToken(token);
      if (!this.constantTimeCompare(session.tokenHash, tokenHash)) {
        return { valid: false, errorCode: LanReceiverErrorCode.TOKEN_INVALID };
      }

      session.lastSeenAt = new Date();
      this.activeSessions.set(sessionId, session);

      return { valid: true, session };
    } catch (error) {
      this.logger.error(
        "[LanReceiverService] Token validation error",
        error instanceof Error ? error.stack : String(error),
      );
      return { valid: false, errorCode: LanReceiverErrorCode.SESSION_NOT_FOUND };
    }
  }

  private generateDeviceId(): string {
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
    return /^\d{6}$/.test(code);
  }

  private validateUploadFiles(files: LanUploadFile[]): void {
    for (const file of files) {
      if (file.size > this.config.maxFileSizeBytes) {
        throw this.createError(
          LanReceiverErrorCode.FILE_SIZE_EXCEEDED,
          `File ${file.originalname} exceeds size limit: ${file.size} > ${this.config.maxFileSizeBytes}`,
        );
      }

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

    const fs = await import("node:fs/promises");
    const path = await import("node:path");
    const os = await import("node:os");

    const tempDir = await fs.mkdtemp(path.join(os.tmpdir(), "lan-upload-"));
    const tempFilePath = path.join(tempDir, file.originalname);

    try {
      await fs.writeFile(tempFilePath, file.buffer);

      const importResult = await this.datasetService.importAssets({
        childId: session.childId,
        paths: [tempFilePath],
        recursive: false,
      });

      if (!importResult.ok || importResult.imported.length === 0) {
        throw new Error("Asset import failed");
      }

      const importedAsset = importResult.imported[0];

      return {
        filename: file.originalname,
        assetId,
        status: "ready",
        localPath: importedAsset.path || tempFilePath,
      };
    } finally {
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
    const error = new Error(message || `LAN Receiver Error: ${code}`) as LanReceiverError;
    error.code = code;
    return error;
  }

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
    this.cleanupTimer = setInterval(() => {
      this.cleanupExpiredSessions().catch(error => {
        this.logger.error(
          "[LanReceiverService] Cleanup task error",
          error instanceof Error ? error.stack : String(error),
        );
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

    for (const [sessionId, session] of this.activeSessions.entries()) {
      if (session.expiresAt < now) {
        expiredSessions.push(sessionId);
      }
    }

    for (const sessionId of expiredSessions) {
      this.activeSessions.delete(sessionId);
      this.uploadCounters.delete(sessionId);
    }

    await this.repository.deleteExpiredSessions(now);
  }
}
