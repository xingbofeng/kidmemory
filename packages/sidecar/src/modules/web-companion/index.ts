/**
 * Web Companion 模块导出
 * 统一导出所有常量、类型和枚举
 */

// 常量和枚举
export {
  UploadSessionStatus,
  UploadItemStatus,
  StorageProvider,
  WebCompanionErrorCode,
  SESSION_STATUS_TRANSITIONS,
  UPLOAD_ITEM_STATUS_TRANSITIONS,
  DEFAULT_CONFIG,
  isValidSessionStatusTransition,
  isValidUploadItemStatusTransition,
  canCreateUploadItems,
  isUploadItemTerminal,
  canRetryUploadItem,
} from "./constants.ts";

// 类型定义 - 从 constants.ts 导出的类型
export type {
  UploadSessionStatusType,
  UploadItemStatusType,
  StorageProviderType,
  WebCompanionErrorCodeType,
} from "./constants.ts";

// 类型定义 - 从 types.ts 导出的类型
export type {
  // 请求 DTO
  CreateSessionRequest,
  CreateUploadItemsRequest,
  CommitUploadItemRequest,
  RetryUploadItemRequest,
  CloseSessionRequest,
  // 响应 DTO
  CreateSessionResponse,
  SessionSummaryResponse,
  SignedUploadTarget,
  UploadItemResponse,
  CreateUploadItemsResponse,
  CommitUploadItemResponse,
  UploadItemDetail,
  SessionDetailResponse,
  ErrorResponse,
  // 内部数据模型
  UploadSession,
  UploadItem,
  // 服务层接口
  CreateSessionOptions,
  CreateUploadItemOptions,
  TokenValidationResult,
  UploadItemCreationResult,
  // 配置接口
  WebCompanionConfig,
  // 工具类型
  PaginationParams,
  SortParams,
  QueryFilter,
} from "./types.ts";
