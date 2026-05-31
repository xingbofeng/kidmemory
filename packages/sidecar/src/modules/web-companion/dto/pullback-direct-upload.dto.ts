/**
 * Direct Upload pullback DTOs.
 */

import type { DirectUploadPullbackStatus } from "../direct-upload-pullback-state.ts";

export interface PullbackDirectUploadRequest {
  token: string;
  objectKeys?: string[];
}

export interface PullbackDirectUploadItemResult {
  objectKey: string;
  status: Extract<DirectUploadPullbackStatus, "ready" | "failed">;
  errorCode: string | null;
  errorMessage: string | null;
}

export interface PullbackDirectUploadResponse {
  sessionId: string;
  results: PullbackDirectUploadItemResult[];
}
