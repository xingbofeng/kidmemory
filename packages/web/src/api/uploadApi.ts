import type { components } from '@kidmemory/protocol/cloud-api';
import { httpClient } from '../lib/http-client';
import type { SessionSummary } from '../types/trustedUpload';
import type { UploadSession } from '../types/api';

export type DirectUploadConfigResponse = components['schemas']['DirectUploadConfigResponseDto'];

export async function getDirectUploadConfig(sessionId: string, token: string): Promise<DirectUploadConfigResponse> {
  return httpClient.get<DirectUploadConfigResponse>(
    `/api/web-companion/direct-upload/sessions/${encodeURIComponent(sessionId)}/config?token=${encodeURIComponent(token)}`
  );
}

export interface PullbackDirectUploadRequest {
  token: string;
  objectKeys?: string[];
}

export interface PullbackDirectUploadResponse {
  sessionId: string;
  results: Array<{
    objectKey: string;
    status: string;
    errorCode?: string | null;
    errorMessage?: string | null;
  }>;
}

export async function pullbackDirectUpload(
  sessionId: string,
  request: PullbackDirectUploadRequest
): Promise<PullbackDirectUploadResponse> {
  return httpClient.post<PullbackDirectUploadResponse>(
    `/api/web-companion/direct-upload/sessions/${encodeURIComponent(sessionId)}/pullback`,
    request
  );
}

export type CreateUploadItemsRequest = components['schemas']['CreateUploadItemsRequestDto'];

export type CreateUploadItemsResponse = components['schemas']['CreateUploadItemsResponseDto'];

export type CommitUploadItemRequest = components['schemas']['CommitUploadItemRequestDto'];

export async function getUploadSession(sessionId: string, token: string): Promise<SessionSummary> {
  return httpClient.get<SessionSummary>(
    `/api/web-companion/sessions/${sessionId}?token=${encodeURIComponent(token)}`
  );
}

export async function createUploadSession(childId: string): Promise<UploadSession> {
  return httpClient.post<UploadSession>('/api/web-companion/sessions', {
    childId,
  });
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
