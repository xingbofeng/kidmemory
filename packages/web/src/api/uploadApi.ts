/**
 * Upload API Module
 * 
 * Handles all upload-related API calls
 */

import { httpClient } from '../lib/http-client';

/**
 * Direct Upload API
 */
export interface DirectUploadConfigResponse {
  anonKey: string;
}

export async function getDirectUploadConfig(sessionId: string): Promise<DirectUploadConfigResponse> {
  return httpClient.get<DirectUploadConfigResponse>(
    `/api/web-companion/direct-upload/sessions/${encodeURIComponent(sessionId)}/config`
  );
}

/**
 * Trusted Upload API
 */
export interface SessionSummary {
  sessionId: string;
  status: string;
  child: {
    id: string;
    displayName: string;
  };
  expiresAt: string;
  maxItems: number;
  usedItems: number;
  providers?: {
    lan?: { available: boolean };
    supabase?: { available: boolean };
  };
}

export interface UploadItem {
  clientFileId: string;
  uploadItemId: string;
  assetId: string;
  objectKey: string;
  status: string;
  signedUpload?: {
    method: string;
    url: string;
    expiresAt: string;
    headers: Record<string, string>;
  };
}

export interface CreateUploadItemsRequest {
  token: string;
  provider: 'lan' | 'supabase';
  files: Array<{
    clientFileId: string;
    filename: string;
    contentType: string;
    sizeBytes: number;
  }>;
}

export interface CreateUploadItemsResponse {
  items: UploadItem[];
}

export interface CommitUploadItemRequest {
  token: string;
  objectKey: string;
  sizeBytes: number;
  contentType: string;
}

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
