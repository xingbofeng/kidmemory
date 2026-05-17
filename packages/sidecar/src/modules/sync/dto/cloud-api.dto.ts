import type { components } from '@kidmemory/protocol/generated/cloud-api/ts';

/**
 * Cloud-API DTOs for sidecar sync.
 *
 * 请求/响应类型都绑定 protocol/generated，避免与 OpenAPI 漂移。
 */

// ============================================================================
// Device Registration & Heartbeat
// ============================================================================

export type RegisterDeviceDto = components['schemas']['RegisterDeviceRequestDto'];

export type DeviceResponseDto = components['schemas']['DeviceResponseDto'];

// ============================================================================
// Upload Items
// ============================================================================

export type UploadItemResponseDto = components['schemas']['UploadItemResponseDto'];

export type UpdateSyncStatusDto = components['schemas']['UpdateSyncStatusRequestDto'];

// ============================================================================
// Jobs
// ============================================================================

export type JobResponseDto = components['schemas']['JobResponseDto'];

export type UpdateJobStatusDto = components['schemas']['UpdateJobStatusRequestDto'];
