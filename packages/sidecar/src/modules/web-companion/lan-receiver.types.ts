/**
 * LAN Receiver 类型定义
 *
 * 支持局域网设备发现、配对和直传文件接收
 */

// ============================================================================
// LAN 发现和配对
// ============================================================================

/**
 * LAN 设备发现响应
 */
export interface LanDiscoveryResponse {
  deviceId: string;
  deviceName: string;
  version: string;
  capabilities: string[];
  networkInfo: {
    ip: string;
    port: number;
    protocol: string;
  };
  security: {
    requiresAuth: boolean;
    supportedMethods: string[];
  };
}

/**
 * LAN 设备配对请求
 */
export interface LanPairRequest {
  deviceId: string;
  childId: string;
  pairingCode?: string;
}

/**
 * LAN 设备配对响应
 */
export interface LanPairResponse {
  success: boolean;
  sessionId: string;
  token: string;
  expiresAt: string;
  endpoints: {
    upload: string;
    status: string;
  };
}

// ============================================================================
// LAN 会话管理
// ============================================================================

/**
 * LAN 会话数据模型
 */
export interface LanSession {
  id: string;
  deviceId: string;
  childId: string;
  tokenHash: string;
  expiresAt: Date;
  createdAt: Date;
  lastSeenAt?: Date;
  maxConcurrentUploads: number;
  currentUploads: number;
}

/**
 * LAN Token 验证结果
 */
export interface LanTokenValidationResult {
  valid: boolean;
  session?: LanSession;
  errorCode?: string;
}

// ============================================================================
// LAN 文件上传
// ============================================================================

export interface LanUploadFile {
  originalname: string;
  mimetype: string;
  size: number;
  buffer: Buffer;
}

/**
 * LAN 文件上传请求
 */
export interface LanUploadRequest {
  sessionId: string;
  token: string;
  files: LanUploadFile[];
}

/**
 * LAN 文件上传响应
 */
export interface LanUploadResponse {
  success: boolean;
  uploadedFiles: Array<{
    filename: string;
    assetId: string;
    status: string;
    localPath: string;
  }>;
  errors: Array<{
    filename: string;
    errorCode: string;
    message: string;
  }>;
}

/**
 * LAN 会话状态响应
 */
export interface LanSessionStatusResponse {
  sessionId: string;
  status: string;
  expiresAt: string;
  currentUploads: number;
  maxConcurrentUploads: number;
  totalUploaded: number;
}

// ============================================================================
// 网络发现
// ============================================================================

/**
 * 网络设备发现选项
 */
export interface NetworkDiscoveryOptions {
  timeout: number;
  serviceType?: string;
}

/**
 * 发现的设备信息
 */
export interface DiscoveredDevice {
  deviceId: string;
  address: string;
  port: number;
  capabilities: string[];
  txt?: Record<string, string>;
}

/**
 * 网络发现结果
 */
export interface NetworkDiscoveryResult {
  devices: DiscoveredDevice[];
}

// ============================================================================
// 错误码
// ============================================================================

/**
 * LAN Receiver 错误码
 */
export const LanReceiverErrorCode = {
  // 设备和会话错误
  DEVICE_NOT_FOUND: "DEVICE_NOT_FOUND",
  SESSION_NOT_FOUND: "LAN_SESSION_NOT_FOUND",
  SESSION_EXPIRED: "LAN_SESSION_EXPIRED",
  TOKEN_INVALID: "LAN_TOKEN_INVALID",
  PAIRING_FAILED: "PAIRING_FAILED",

  // 上传限制错误
  UPLOAD_LIMIT_EXCEEDED: "UPLOAD_LIMIT_EXCEEDED",
  FILE_TYPE_NOT_SUPPORTED: "FILE_TYPE_NOT_SUPPORTED",
  FILE_SIZE_EXCEEDED: "FILE_SIZE_EXCEEDED",

  // 网络错误
  NETWORK_TIMEOUT: "NETWORK_TIMEOUT",
  NETWORK_ERROR: "NETWORK_ERROR",
  CONNECTION_INTERRUPTED: "CONNECTION_INTERRUPTED",

  // 发现错误
  DISCOVERY_TIMEOUT: "DISCOVERY_TIMEOUT",
  MDNS_RESOLUTION_FAILED: "MDNS_RESOLUTION_FAILED",
} as const;

export type LanReceiverErrorCodeType = typeof LanReceiverErrorCode[keyof typeof LanReceiverErrorCode];

// ============================================================================
// 配置
// ============================================================================

/**
 * LAN Receiver 配置
 */
export interface LanReceiverConfig {
  enabled: boolean;
  port: number;
  maxConcurrentUploads: number;
  sessionTtlMinutes: number;
  allowedFileTypes: string[];
  maxFileSizeBytes: number;
  discoveryService: string;
  deviceName: string;
  version: string;
}

/**
 * 默认 LAN 配置
 */
export const DEFAULT_LAN_CONFIG: LanReceiverConfig = {
  enabled: true,
  port: 4317,
  maxConcurrentUploads: 3,
  sessionTtlMinutes: 30,
  allowedFileTypes: [
    "image/jpeg",
    "image/png",
    "image/webp",
    "image/heic",
    "image/heif",
    "video/mp4",
    "video/quicktime",
  ],
  maxFileSizeBytes: 100 * 1024 * 1024, // 100MB
  discoveryService: "_kidmemory._tcp",
  deviceName: "Kid Memory Desktop",
  version: "current",
};
