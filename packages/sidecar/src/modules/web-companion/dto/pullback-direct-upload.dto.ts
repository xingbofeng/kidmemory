/**
 * Direct Upload pullback DTOs.
 */

import type { DirectUploadPullbackStatus } from "../direct-upload-pullback-state.ts";

export interface PullbackDirectUploadRequest {
  /**
   * 可选。若指定，sidecar 仅回拉这些 objectKeys；不指定时回拉 sessionId 前缀下所有对象。
   */
  objectKeys?: string[];
  /**
   * 可选。会话签发时返回的一次性 token，用于验证 pullback 请求的合法性。
   */
  token?: string;
}

export interface PullbackDirectUploadItemResult {
  objectKey: string;
  status: DirectUploadPullbackStatus;
  errorCode: string | null;
  errorMessage: string | null;
}

export interface PullbackDirectUploadResponse {
  sessionId: string;
  results: PullbackDirectUploadItemResult[];
}
