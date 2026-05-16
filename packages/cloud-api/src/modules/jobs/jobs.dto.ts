import { ApiProperty } from '@nestjs/swagger';

export class JobResponseDto {
  @ApiProperty({ type: String })
  id: string;

  @ApiProperty({ type: String, required: false })
  deviceId?: string;

  @ApiProperty({
    type: String,
    description: 'Job type',
    enum: ['book_generation', 'asset_processing', 'export_pdf', 'export_long_image'],
  })
  type: string;

  @ApiProperty({
    type: Object,
    description: 'Job payload (JSON)',
  })
  payload: any;

  @ApiProperty({
    type: String,
    description: 'Job status',
    enum: ['pending', 'claimed', 'processing', 'completed', 'failed'],
  })
  status: string;

  @ApiProperty({
    type: Number,
    description: 'Priority (higher = more urgent)',
    default: 0,
  })
  priority: number;

  @ApiProperty({ type: Date, required: false })
  claimedAt?: Date;

  @ApiProperty({ type: Date, required: false })
  completedAt?: Date;

  @ApiProperty({ type: String, required: false })
  errorMessage?: string;

  @ApiProperty({ type: Date })
  createdAt: Date;

  @ApiProperty({ type: Date })
  updatedAt: Date;
}

export class UpdateJobStatusDto {
  @ApiProperty({
    type: String,
    description: 'New status',
    enum: ['claimed', 'processing', 'completed', 'failed', 'pending'],
  })
  status: 'claimed' | 'processing' | 'completed' | 'failed' | 'pending';

  @ApiProperty({
    type: String,
    description: 'Claimed timestamp (for claimed status)',
    required: false,
  })
  claimedAt?: string;

  @ApiProperty({
    type: String,
    description: 'Completed timestamp (for completed/failed status)',
    required: false,
  })
  completedAt?: string;

  @ApiProperty({
    type: String,
    description: 'Error message (for failed status)',
    required: false,
  })
  errorMessage?: string;
}

export class PendingJobsQueryDto {
  @ApiProperty({
    type: String,
    description: 'Device ID to filter by (null = unassigned jobs)',
    required: false,
  })
  deviceId?: string;

  @ApiProperty({
    type: Number,
    description: 'Maximum number of jobs to return',
    default: 5,
    required: false,
  })
  limit?: number;
}
