import type { operations } from '@kidmemory/protocol/sidecar';
import { httpClient } from '../lib/http-client';
import type { SessionDetail, SessionSummary } from '../types/trustedUpload';

type JsonResponse<
  OperationId extends keyof operations,
  Status extends keyof operations[OperationId]['responses'],
> = operations[OperationId]['responses'][Status] extends { content: { 'application/json': infer Body } }
  ? Body
  : never

type JsonRequestBody<OperationId extends keyof operations> = operations[OperationId] extends {
  requestBody: { content: { 'application/json': infer Body } }
} ? Body : never

export type DirectUploadConfigResponse = JsonResponse<'DirectUploadController_getSessionConfig', 200>;

export async function getDirectUploadConfig(sessionId: string, token: string): Promise<DirectUploadConfigResponse> {
  return httpClient.get<DirectUploadConfigResponse>(
    `/api/web-companion/direct-upload/sessions/${encodeURIComponent(sessionId)}/config?token=${encodeURIComponent(token)}`
  );
}

export type PullbackDirectUploadRequest = JsonRequestBody<'DirectUploadController_pullback'>;

export type PullbackDirectUploadResponse = JsonResponse<'DirectUploadController_pullback', 201>;

export async function pullbackDirectUpload(
  sessionId: string,
  request: PullbackDirectUploadRequest
): Promise<PullbackDirectUploadResponse> {
  return httpClient.post<PullbackDirectUploadResponse>(
    `/api/web-companion/direct-upload/sessions/${encodeURIComponent(sessionId)}/pullback`,
    request
  );
}

export interface SignDirectUploadObjectRequest {
  token: string;
  objectKey: string;
  contentType?: string;
  sizeBytes?: number;
}

export interface SignDirectUploadObjectResponse {
  method: 'PUT';
  url: string;
  expiresAt: string;
  headers: Record<string, string>;
}

export async function signDirectUploadObject(
  sessionId: string,
  request: SignDirectUploadObjectRequest
): Promise<SignDirectUploadObjectResponse> {
  return httpClient.post<SignDirectUploadObjectResponse>(
    `/api/web-companion/direct-upload/sessions/${encodeURIComponent(sessionId)}/sign-upload`,
    request
  );
}

export type CreateUploadItemsRequest = JsonRequestBody<'WebCompanionController_createUploadItems'>;

export type CreateUploadItemsResponse = JsonResponse<'WebCompanionController_createUploadItems', 201>;

export type CommitUploadItemRequest = JsonRequestBody<'WebCompanionController_commitUploadItem'>;

export type CommitUploadItemResponse = JsonResponse<'WebCompanionController_commitUploadItem', 200>;

export async function getUploadSession(sessionId: string, token: string): Promise<SessionSummary> {
  return httpClient.get<SessionSummary>(
    `/api/web-companion/sessions/${sessionId}?token=${encodeURIComponent(token)}`
  );
}

export async function getUploadSessionDetail(sessionId: string, token: string): Promise<SessionDetail> {
  return httpClient.get<SessionDetail>(
    `/api/web-companion/sessions/${sessionId}/detail?token=${encodeURIComponent(token)}`
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
): Promise<CommitUploadItemResponse> {
  return httpClient.put<CommitUploadItemResponse>(
    `/api/web-companion/sessions/${sessionId}/items/${uploadItemId}/commit`,
    request
  );
}
