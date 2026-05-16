import type { components } from '@kidmemory/protocol/generated/cloud-api/ts';

/**
 * Cloud-API DTOs for sidecar sync.
 *
 * 响应类型直接绑定 protocol/generated，避免与 OpenAPI 漂移。
 * 请求类型暂保留本地定义（当前 OpenAPI 未生成请求体 schema）。
 */

// ============================================================================
// Device Registration & Heartbeat
// ============================================================================

export interface RegisterDeviceDto {
  machineId: string;
  platform: string;
  hostname: string;
}

export type DeviceResponseDto = components['schemas']['DeviceResponseDto'];

// ============================================================================
// Upload Items
// ============================================================================

export type UploadItemResponseDto = components['schemas']['UploadItemResponseDto'];

export interface UpdateSyncStatusDto {
  status: 'synced' | 'failed';
  syncedAt?: string;
  errorMessage?: string;
}

// ============================================================================
// Jobs
// ============================================================================

export type JobResponseDto = components['schemas']['JobResponseDto'];

export interface UpdateJobStatusDto {
  status: 'claimed' | 'processing' | 'completed' | 'failed' | 'pending';
  claimedAt?: string;
  errorMessage?: string;
  completedAt?: string;
}
