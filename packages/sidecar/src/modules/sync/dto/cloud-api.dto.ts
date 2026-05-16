/**
 * Cloud-API DTOs
 *
 * 定义与 Cloud-API 交互的数据传输对象。
 */

// ============================================================================
// Device Registration & Heartbeat
// ============================================================================

export interface RegisterDeviceDto {
  machineId: string;
  platform: string;
  hostname: string;
}

export interface DeviceResponseDto {
  id: string;
  machineId: string;
  platform: string;
  hostname: string;
  lastSeenAt: string;
  createdAt: string;
  updatedAt: string;
}

// ============================================================================
// Upload Items
// ============================================================================

export interface UploadItemResponseDto {
  id: string;
  sessionId: string;
  childId: string;
  fileName: string;
  fileSize: number;
  mimeType: string;
  objectKey: string;
  status: 'pending' | 'synced' | 'failed';
  syncedAt: string | null;
  errorMessage: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface UpdateSyncStatusDto {
  status: 'synced' | 'failed';
  syncedAt?: string;
  errorMessage?: string;
}

// ============================================================================
// Jobs
// ============================================================================

export interface JobResponseDto {
  id: string;
  deviceId: string;
  jobType: string;
  payload: Record<string, unknown>;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  result: Record<string, unknown> | null;
  errorMessage: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface UpdateJobStatusDto {
  status: 'processing' | 'completed' | 'failed';
  result?: Record<string, unknown>;
  errorMessage?: string;
  completedAt?: string;
}
