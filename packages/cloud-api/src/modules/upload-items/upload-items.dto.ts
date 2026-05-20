import { ApiProperty } from '@nestjs/swagger';

export class UploadItemResponseDto {
  @ApiProperty({ type: String })
  id: string;

  @ApiProperty({ type: String })
  sessionId: string;

  @ApiProperty({ type: String, required: false })
  childId?: string;

  @ApiProperty({ type: String, required: false })
  deviceId?: string;

  @ApiProperty({ type: String })
  objectKey: string;

  @ApiProperty({ type: String })
  fileName: string;

  @ApiProperty({ type: String, required: false })
  fileSize?: string;

  @ApiProperty({ type: String, required: false })
  mimeType?: string;

  @ApiProperty({ type: String, enum: ['pending', 'uploaded', 'synced', 'failed'] })
  status: string;

  @ApiProperty({ type: String, required: false })
  uploadedAt?: string;

  @ApiProperty({ type: String, required: false })
  syncedAt?: string;

  @ApiProperty({ type: String, required: false })
  errorMessage?: string;

  @ApiProperty({ type: String })
  createdAt: string;

  @ApiProperty({ type: String })
  updatedAt: string;
}

export class UpdateSyncStatusRequestDto {
  @ApiProperty({ type: String, enum: ['uploaded', 'synced', 'failed'] })
  status: 'uploaded' | 'synced' | 'failed';

  @ApiProperty({ type: String, required: false })
  syncedAt?: string;

  @ApiProperty({ type: String, required: false })
  errorMessage?: string;
}

export type UpdateSyncStatusDto = UpdateSyncStatusRequestDto;

export type PendingSyncQueryDto = {
  deviceId?: string;
  limit?: number | string;
  offset?: number | string;
};
