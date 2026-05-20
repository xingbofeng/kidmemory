import { ApiProperty } from '@nestjs/swagger';

export class JobResponseDto {
  @ApiProperty({ type: String })
  id: string;

  @ApiProperty({ type: String, required: false })
  deviceId?: string;

  @ApiProperty({
    type: String,
    enum: ['book_generation', 'asset_processing', 'export_pdf', 'export_long_image', 'import', 'sync', 'export', 'cleanup'],
  })
  type:
    | 'book_generation'
    | 'asset_processing'
    | 'export_pdf'
    | 'export_long_image'
    | 'import'
    | 'sync'
    | 'export'
    | 'cleanup';

  @ApiProperty({ type: Object, nullable: true, additionalProperties: true })
  payload: Record<string, never> | null;

  @ApiProperty({ type: String, enum: ['pending', 'claimed', 'processing', 'completed', 'failed'] })
  status: 'pending' | 'claimed' | 'processing' | 'completed' | 'failed';

  @ApiProperty({ type: Number })
  priority: number;

  @ApiProperty({ type: String, required: false })
  claimedAt?: string;

  @ApiProperty({ type: String, required: false })
  completedAt?: string;

  @ApiProperty({ type: String, required: false })
  errorMessage?: string;

  @ApiProperty({ type: String })
  createdAt: string;

  @ApiProperty({ type: String })
  updatedAt: string;
}

export class UpdateJobStatusRequestDto {
  @ApiProperty({ type: String, enum: ['pending', 'claimed', 'processing', 'completed', 'failed'] })
  status: 'pending' | 'claimed' | 'processing' | 'completed' | 'failed';

  @ApiProperty({ type: String, required: false })
  claimedAt?: string;

  @ApiProperty({ type: String, required: false })
  completedAt?: string;

  @ApiProperty({ type: String, required: false })
  errorMessage?: string;
}

export type UpdateJobStatusDto = UpdateJobStatusRequestDto;

export type PendingJobsQueryDto = {
  deviceId?: string;
  limit?: number | string;
};
