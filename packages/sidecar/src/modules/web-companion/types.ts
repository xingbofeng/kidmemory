/**
 * Web Companion DTO 类型定义
 * 严格按照 PRD 8. 后端 API 草案定义
 */

import type {
  UploadSessionStatusType,
  UploadItemStatusType,
  StorageProviderType,
  WebCompanionErrorCodeType,
} from "./constants.ts";
import type { components } from "@kidmemory/protocol/generated/sidecar/ts";

// ============================================================================
// 请求 DTO
// ============================================================================

/**
 * 创建会话请求
 */
export type CreateSessionRequest = components["schemas"]["CreateSessionRequestDto"];

/**
 * 创建上传项请求
 */
export type CreateUploadItemsRequest = components["schemas"]["CreateUploadItemsRequestDto"];

/**
 * Commit 上传项请求
 */
export type CommitUploadItemRequest = components["schemas"]["CommitUploadItemRequestDto"];

/**
 * 重试上传项请求
 */
export type RetryUploadItemRequest = components["schemas"]["RetryUploadItemRequestDto"];

/**
 * 关闭会话请求
 */
export type CloseSessionRequest = components["schemas"]["CloseSessionRequestDto"];

// ============================================================================
// 响应 DTO
// ============================================================================

/**
 * 创建会话响应
 */
export type CreateSessionResponse = components["schemas"]["CreateSessionResponseDto"];

/**
 * 会话摘要响应
 */
export type SessionSummaryResponse = components["schemas"]["SessionSummaryResponseDto"];

/**
 * 签名上传目标
 */
export interface SignedUploadTarget {
  method: "PUT";
  url: string;
  expiresAt: string;
  headers: Record<string, string>;
}

/**
 * 上传项响应
 */
export type UploadItemResponse = components["schemas"]["UploadItemResponseDto"];

/**
 * 创建上传项响应
 */
export type CreateUploadItemsResponse = components["schemas"]["CreateUploadItemsResponseDto"];

/**
 * Commit 上传项响应
 */
export type CommitUploadItemResponse = components["schemas"]["CommitUploadItemResponseDto"];

/**
 * 上传项详情
 */
export interface UploadItemDetail {
  uploadItemId: string;
  assetId: string;
  filename: string;
  status: UploadItemStatusType;
  provider: StorageProviderType;
  objectKey: string;
  errorCode?: WebCompanionErrorCodeType;
  createdAt: string;
  updatedAt: string;
}

/**
 * 会话详情响应
 */
export type SessionDetailResponse = components["schemas"]["SessionDetailResponseDto"];

// ============================================================================
// 错误响应 DTO
// ============================================================================

/**
 * 错误响应
 */
export interface ErrorPayload {
  error: {
    code: WebCompanionErrorCodeType;
    message: string;
    details?: Record<string, unknown>;
  };
}

// ============================================================================
// 内部数据模型
// ============================================================================

/**
 * 上传会话数据模型
 */
export interface UploadSession {
  id: string;
  childId: string;
  tokenHash: string;
  status: UploadSessionStatusType;
  expiresAt: Date;
  maxItems: number;
  createdAt: Date;
  closedAt?: Date;
  lastSeenAt?: Date;
}

/**
 * 上传项数据模型
 */
export interface UploadItem {
  id: string;
  sessionId: string;
  assetId: string;
  clientFileId?: string;
  originalFilename: string;
  safeFilename: string;
  contentType: string;
  sizeBytes: number;
  provider: StorageProviderType;
  bucket?: string;
  objectKey: string;
  status: UploadItemStatusType;
  remoteEtag?: string;
  localPath?: string;
  hashSha256?: string;
  errorCode?: WebCompanionErrorCodeType;
  errorMessage?: string;
  createdAt: Date;
  updatedAt: Date;
  committedAt?: Date;
  readyAt?: Date;
}

// ============================================================================
// 服务层接口
// ============================================================================

/**
 * 创建会话选项
 */
export interface CreateSessionOptions {
  childId: string;
  expiresInMinutes: number;
  maxItems: number;
  preferredProviders: StorageProviderType[];
}

/**
 * 创建上传项选项
 */
export interface CreateUploadItemOptions {
  sessionId: string;
  session: UploadSession;
  files: {
    clientFileId: string;
    filename: string;
    contentType: string;
    sizeBytes: number;
  }[];
  provider: StorageProviderType;
}

/**
 * Token 验证结果
 */
export interface TokenValidationResult {
  valid: boolean;
  session?: UploadSession;
  errorCode?: WebCompanionErrorCodeType;
}

/**
 * 上传项创建结果
 */
export interface UploadItemCreationResult {
  success: boolean;
  items: UploadItem[];
  errors: {
    clientFileId: string;
    errorCode: WebCompanionErrorCodeType;
    message: string;
  }[];
}

// ============================================================================
// 配置接口
// ============================================================================

/**
 * Web Companion 配置
 */
export interface WebCompanionConfig {
  baseUrl: string;
  sessionTtlMinutes: number;
  maxItemsPerSession: number;
  maxFileSizeBytes: number;
  allowedContentTypes: string[];
  supabase?: {
    url: string;
    serviceRoleKey: string;
    uploadBucket: string;
  };
  lan?: {
    host: string;
    port: number;
  };
}

// ============================================================================
// 工具类型
// ============================================================================

/**
 * 分页参数
 */
export interface PaginationParams {
  limit?: number;
  offset?: number;
}

/**
 * 排序参数
 */
export interface SortParams {
  field: string;
  direction: "asc" | "desc";
}

/**
 * 查询过滤器
 */
export interface QueryFilter {
  sessionId?: string;
  status?: UploadItemStatusType;
  provider?: StorageProviderType;
  createdAfter?: Date;
  createdBefore?: Date;
}
