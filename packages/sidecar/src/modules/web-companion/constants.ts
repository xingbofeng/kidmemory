/**
 * Web Companion 状态枚举和错误码常量
 * 严格按照 PRD 规范定义
 */

// ============================================================================
// 会话状态枚举
// ============================================================================

/**
 * 上传会话状态
 */
export const UploadSessionStatus = {
  /** 活跃状态，可以创建新的上传项 */
  ACTIVE: "active",
  /** 已关闭，不能创建新的上传项，但已有项可以继续完成 */
  CLOSED: "closed",
  /** 已过期，不能进行任何操作 */
  EXPIRED: "expired",
} as const;

export type UploadSessionStatusType = typeof UploadSessionStatus[keyof typeof UploadSessionStatus];

/**
 * 上传项状态
 */
export const UploadItemStatus = {
  /** 待处理，刚创建但未开始上传 */
  PENDING: "pending",
  /** 正在生成签名上传目标 */
  SIGNING: "signing",
  /** 正在上传到远端 */
  UPLOADING: "uploading",
  /** 已上传到远端，等待回拉 */
  UPLOADED_REMOTE: "uploaded_remote",
  /** 正在从远端拉取到本地 */
  PULLING_LOCAL: "pulling_local",
  /** 已就绪，完成本地入库 */
  READY: "ready",
  /** 失败状态 */
  FAILED: "failed",
  /** 已取消 */
  CANCELED: "canceled",
} as const;

export type UploadItemStatusType = typeof UploadItemStatus[keyof typeof UploadItemStatus];

/**
 * 存储提供商类型
 */
export const StorageProvider = {
  /** 局域网直传 */
  LAN: "lan",
  /** Supabase Storage */
  SUPABASE: "supabase",
} as const;

export type StorageProviderType = typeof StorageProvider[keyof typeof StorageProvider];

// ============================================================================
// 错误码常量
// ============================================================================

/**
 * Web Companion 错误码
 * 按照 PRD 10.4 错误响应规范定义
 */
export const WebCompanionErrorCode = {
  // 会话相关错误
  /** 会话未找到 */
  SESSION_NOT_FOUND: "SESSION_NOT_FOUND",
  /** 会话已过期 */
  SESSION_EXPIRED: "SESSION_EXPIRED",
  /** 会话已关闭 */
  SESSION_CLOSED: "SESSION_CLOSED",
  /** Token 无效 */
  TOKEN_INVALID: "TOKEN_INVALID",
  /** Token 缺失 */
  TOKEN_REQUIRED: "TOKEN_REQUIRED",

  // 上传限制错误
  /** 超过单会话上传项数量限制 */
  ITEM_LIMIT_EXCEEDED: "ITEM_LIMIT_EXCEEDED",
  /** 不支持的文件类型 */
  FILE_TYPE_UNSUPPORTED: "FILE_TYPE_UNSUPPORTED",
  /** 文件过大 */
  FILE_TOO_LARGE: "FILE_TOO_LARGE",

  // 存储提供商错误
  /** 存储提供商不可用 */
  PROVIDER_UNAVAILABLE: "PROVIDER_UNAVAILABLE",
  /** 存储提供商错误 */
  STORAGE_PROVIDER_ERROR: "STORAGE_PROVIDER_ERROR",
  /** 存储提供商不可用 */
  STORAGE_PROVIDER_UNAVAILABLE: "STORAGE_PROVIDER_UNAVAILABLE",
  /** 无法生成签名上传目标 */
  SIGNED_UPLOAD_UNAVAILABLE: "SIGNED_UPLOAD_UNAVAILABLE",

  // 上传项相关错误
  /** Object key 不匹配 */
  OBJECT_KEY_MISMATCH: "OBJECT_KEY_MISMATCH",
  /** 上传项未找到 */
  UPLOAD_ITEM_NOT_FOUND: "UPLOAD_ITEM_NOT_FOUND",
  /** 上传项重复 */
  UPLOAD_ITEM_DUPLICATE: "UPLOAD_ITEM_DUPLICATE",
  /** 上传项创建失败 */
  UPLOAD_ITEM_CREATION_FAILED: "UPLOAD_ITEM_CREATION_FAILED",
  /** Commit 冲突 */
  COMMIT_CONFLICT: "COMMIT_CONFLICT",

  // 回拉和存储错误
  /** 回拉失败 */
  PULLBACK_FAILED: "PULLBACK_FAILED",
  /** 本地存储失败 */
  LOCAL_STORAGE_FAILED: "LOCAL_STORAGE_FAILED",
  /** 内部错误 */
  INTERNAL_ERROR: "INTERNAL_ERROR",
} as const;

/**
 * 错误码类型
 */
export type WebCompanionErrorCodeType = typeof WebCompanionErrorCode[keyof typeof WebCompanionErrorCode];

// ============================================================================
// 状态流转验证
// ============================================================================

/**
 * 会话状态流转规则
 */
export const SESSION_STATUS_TRANSITIONS: Record<UploadSessionStatusType, UploadSessionStatusType[]> = {
  [UploadSessionStatus.ACTIVE]: [UploadSessionStatus.CLOSED, UploadSessionStatus.EXPIRED],
  [UploadSessionStatus.CLOSED]: [UploadSessionStatus.EXPIRED],
  [UploadSessionStatus.EXPIRED]: [], // 终态，不能转换
};

/**
 * 上传项状态流转规则
 */
export const UPLOAD_ITEM_STATUS_TRANSITIONS: Record<UploadItemStatusType, UploadItemStatusType[]> = {
  [UploadItemStatus.PENDING]: [
    UploadItemStatus.SIGNING,
    UploadItemStatus.UPLOADING,
    UploadItemStatus.READY, // 局域网直传
    UploadItemStatus.FAILED,
    UploadItemStatus.CANCELED,
  ],
  [UploadItemStatus.SIGNING]: [
    UploadItemStatus.UPLOADING,
    UploadItemStatus.FAILED,
    UploadItemStatus.CANCELED,
  ],
  [UploadItemStatus.UPLOADING]: [
    UploadItemStatus.UPLOADED_REMOTE,
    UploadItemStatus.FAILED,
    UploadItemStatus.CANCELED,
  ],
  [UploadItemStatus.UPLOADED_REMOTE]: [
    UploadItemStatus.PULLING_LOCAL,
    UploadItemStatus.READY, // 如果不需要回拉
    UploadItemStatus.FAILED,
  ],
  [UploadItemStatus.PULLING_LOCAL]: [
    UploadItemStatus.READY,
    UploadItemStatus.FAILED,
  ],
  [UploadItemStatus.READY]: [], // 终态
  [UploadItemStatus.FAILED]: [
    // 重试时可以回到之前的状态
    UploadItemStatus.PENDING,
    UploadItemStatus.SIGNING,
    UploadItemStatus.UPLOADING,
    UploadItemStatus.PULLING_LOCAL,
  ],
  [UploadItemStatus.CANCELED]: [], // 终态
};

// ============================================================================
// 验证函数
// ============================================================================

/**
 * 验证会话状态转换是否有效
 */
export function isValidSessionStatusTransition(
  from: UploadSessionStatusType,
  to: UploadSessionStatusType,
): boolean {
  return SESSION_STATUS_TRANSITIONS[from]?.includes(to) ?? false;
}

/**
 * 验证上传项状态转换是否有效
 */
export function isValidUploadItemStatusTransition(
  from: UploadItemStatusType,
  to: UploadItemStatusType,
): boolean {
  return UPLOAD_ITEM_STATUS_TRANSITIONS[from]?.includes(to) ?? false;
}

/**
 * 检查会话是否可以创建新的上传项
 */
export function canCreateUploadItems(sessionStatus: UploadSessionStatusType): boolean {
  return sessionStatus === UploadSessionStatus.ACTIVE;
}

/**
 * 检查上传项是否处于终态
 */
export function isUploadItemTerminal(status: UploadItemStatusType): boolean {
  return status === UploadItemStatus.READY || status === UploadItemStatus.CANCELED;
}

/**
 * 检查上传项是否可以重试
 */
export function canRetryUploadItem(status: UploadItemStatusType): boolean {
  return status === UploadItemStatus.FAILED;
}

// ============================================================================
// 默认配置常量
// ============================================================================

/**
 * 默认配置值
 */
export const DEFAULT_CONFIG = {
  /** 默认会话有效期（分钟） */
  SESSION_TTL_MINUTES: 180,
  /** 默认单会话最大上传项数量 */
  MAX_ITEMS_PER_SESSION: 200,
  /** 默认最大文件大小（字节） */
  MAX_FILE_SIZE_BYTES: 50 * 1024 * 1024, // 50MB
  /** 支持的内容类型 */
  ALLOWED_CONTENT_TYPES: [
    "image/jpeg",
    "image/png",
    "image/webp",
    "image/heic",
    "image/heif",
  ],
} as const;
