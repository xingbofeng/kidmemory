/**
 * Upload API Module
 * 
 * Handles all upload-related API calls
 */

import type { components } from '@kidmemory/protocol/generated/cloud-api/ts';
import { httpClient } from '../lib/http-client';
import type { SessionSummary, UploadItem, UploadProvider } from '../types/trustedUpload';

/**
 * Direct Upload API
 */
export type DirectUploadConfigResponse = components['schemas']['DirectUploadConfigResponseDto'];

export async function getDirectUploadConfig(sessionId: string): Promise<DirectUploadConfigResponse> {
  return httpClient.get<DirectUploadConfigResponse>(
    `/api/web-companion/direct-upload/sessions/${encodeURIComponent(sessionId)}/config`
  );
}

/**
 * Trusted Upload API
 */
export type CreateUploadItemsRequest = Omit<components['schemas']['CreateUploadItemsRequestDto'], 'provider'> & {
  provider: UploadProvider;
};

export type CreateUploadItemsResponse = Omit<components['schemas']['CreateUploadItemsResponseDto'], 'items'> & {
  items: UploadItem[];
};

export type CommitUploadItemRequest = components['schemas']['CommitUploadItemRequestDto'];

export async function getUploadSession(sessionId: string, token: string): Promise<SessionSummary> {
  return httpClient.get<SessionSummary>(
    `/api/web-companion/sessions/${sessionId}?token=${encodeURIComponent(token)}`
  );
}

export async function createUploadItems(
  sessionId: string,
  request: CreateUploadItemsRequest
): Promise<CreateUploadItemsResponse> {
  return httpClient.post<CreateUploadItemsResponse>(
    `/api/web-companion/sessions/${sessionId}/items`,
    request
  );
}

export async function commitUploadItem(
  sessionId: string,
  uploadItemId: string,
  request: CommitUploadItemRequest
): Promise<void> {
  return httpClient.put(
    `/api/web-companion/sessions/${sessionId}/items/${uploadItemId}/commit`,
    request
  );
}
