/**
 * Direct Upload status DTOs.
 */

import type { DirectUploadPullbackStatus } from "../direct-upload-pullback-state.ts";

export interface DirectUploadStatusItem {
  objectKey: string;
  status: DirectUploadPullbackStatus;
  errorCode: string | null;
  errorMessage: string | null;
}

export interface DirectUploadStatusSummary {
  pending_remote: number;
  downloading: number;
  ready: number;
  failed: number;
}

export interface GetDirectUploadStatusResponse {
  sessionId: string;
  items: DirectUploadStatusItem[];
  summary: DirectUploadStatusSummary;
}
