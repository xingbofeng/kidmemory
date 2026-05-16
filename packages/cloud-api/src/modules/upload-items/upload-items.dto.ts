import { ApiProperty } from '@nestjs/swagger';

export class UploadItemResponseDto {
  @ApiProperty({ type: String })
  id: string;

  @ApiProperty({ type: String })
  sessionId: string;

  @ApiProperty({ type: String, required: false })
  deviceId?: string;

  @ApiProperty({ type: String })
  objectKey: string;

  @ApiProperty({ type: String })
  fileName: string;

  @ApiProperty({ type: String, required: false })
  fileSize?: bigint;

  @ApiProperty({ type: String, required: false })
  mimeType?: string;

  @ApiProperty({ type: String })
  status: string;

  @ApiProperty({ type: Date, required: false })
  uploadedAt?: Date;

  @ApiProperty({ type: Date, required: false })
  syncedAt?: Date;

  @ApiProperty({ type: String, required: false })
  errorMessage?: string;

  @ApiProperty({ type: Date })
  createdAt: Date;

  @ApiProperty({ type: Date })
  updatedAt: Date;
}

export class UpdateSyncStatusDto {
  @ApiProperty({
    type: String,
    description: 'New status',
    enum: ['synced', 'failed'],
  })
  status: 'synced' | 'failed';

  @ApiProperty({
    type: String,
    description: 'Sync timestamp (for synced status)',
    required: false,
  })
  syncedAt?: string;

  @ApiProperty({
    type: String,
    description: 'Error message (for failed status)',
    required: false,
  })
  errorMessage?: string;
}

export class PendingSyncQueryDto {
  @ApiProperty({
    type: String,
    description: 'Device ID to filter by',
    required: false,
  })
  deviceId?: string;

  @ApiProperty({
    type: Number,
    description: 'Maximum number of items to return',
    default: 10,
    required: false,
  })
  limit?: number;

  @ApiProperty({
    type: Number,
    description: 'Number of items to skip',
    default: 0,
    required: false,
  })
  offset?: number;
}
