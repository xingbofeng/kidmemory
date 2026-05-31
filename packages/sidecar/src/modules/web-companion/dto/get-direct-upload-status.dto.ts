/**
 * Direct Upload status DTOs.
 */

import type { DirectUploadPullbackStatus } from "../direct-upload-pullback-state.ts";

export interface GetDirectUploadStatusResponse {
  sessionId: string;
  items: Array<{
    objectKey: string;
    status: DirectUploadPullbackStatus;
    errorCode: string | null;
    errorMessage: string | null;
  }>;
  summary: Record<DirectUploadPullbackStatus, number>;
}
