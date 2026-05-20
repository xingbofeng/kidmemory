import { ApiProperty } from '@nestjs/swagger';

export class DirectUploadConfigResponseDto {
  @ApiProperty({ type: String })
  anonKey: string;
}

export class SessionSummaryResponseDto {
  @ApiProperty({ type: String })
  sessionId: string;

  @ApiProperty({ type: String })
  status: string;

  @ApiProperty({ type: Object })
  child: {
    id: string;
    displayName: string;
  };

  @ApiProperty({ type: String })
  expiresAt: string;

  @ApiProperty({ type: Number })
  maxItems: number;

  @ApiProperty({ type: Number })
  usedItems: number;

  @ApiProperty({ type: Object })
  providers: {
    lan: { available: boolean };
    supabase: { available: boolean };
  };
}

export class CreateUploadFileDto {
  @ApiProperty({ type: String })
  clientFileId: string;

  @ApiProperty({ type: String })
  filename: string;

  @ApiProperty({ type: String })
  contentType: string;

  @ApiProperty({ type: Number })
  sizeBytes: number;
}

export class CreateUploadItemsRequestDto {
  @ApiProperty({ type: String })
  token: string;

  @ApiProperty({ type: String, enum: ['lan', 'supabase'], required: false })
  provider?: 'lan' | 'supabase';

  @ApiProperty({ type: () => [CreateUploadFileDto] })
  files: CreateUploadFileDto[];
}

export class SignedUploadTargetDto {
  @ApiProperty({ type: String })
  method: string;

  @ApiProperty({ type: String })
  url: string;

  @ApiProperty({ type: Object, additionalProperties: { type: 'string' } })
  headers: Record<string, string>;

  @ApiProperty({ type: String, required: false })
  expiresAt?: string;
}

export class CreatedUploadItemDto {
  @ApiProperty({ type: String })
  clientFileId: string;

  @ApiProperty({ type: String })
  uploadItemId: string;

  @ApiProperty({ type: String })
  assetId: string;

  @ApiProperty({ type: String })
  objectKey: string;

  @ApiProperty({ type: String })
  status: string;

  @ApiProperty({ type: () => SignedUploadTargetDto, required: false })
  signedUpload?: SignedUploadTargetDto;
}

export class CreateUploadItemsResponseDto {
  @ApiProperty({ type: () => [CreatedUploadItemDto] })
  items: CreatedUploadItemDto[];
}

export class CommitUploadItemRequestDto {
  @ApiProperty({ type: String })
  token: string;

  @ApiProperty({ type: String })
  objectKey: string;

  @ApiProperty({ type: String })
  contentType: string;

  @ApiProperty({ type: Number })
  sizeBytes: number;

  @ApiProperty({ type: String, required: false })
  uploadToken?: string;

  @ApiProperty({ type: String, required: false })
  checksumSha256?: string;

  @ApiProperty({ type: Object, required: false, additionalProperties: true })
  metadata?: Record<string, unknown>;
}

export class CommitUploadItemResponseDto {
  @ApiProperty({ type: String })
  uploadItemId: string;

  @ApiProperty({ type: String })
  status: string;
}

export class ShareTokenValidationResponseDto {
  @ApiProperty({ type: Boolean })
  isValid: boolean;

  @ApiProperty({ type: String, required: false })
  error?: string;

  @ApiProperty({ type: Object, required: false })
  shareToken?: {
    id: string;
    childId: string;
    resourceType: 'specific_book' | 'child_assets';
    resourceId?: string;
    accessType: 'read';
  };
}

export class SharedAssetDto {
  @ApiProperty({ type: String })
  id: string;

  @ApiProperty({ type: String })
  title: string;

  @ApiProperty({ type: String })
  type: string;

  @ApiProperty({ type: String })
  createdAt: string;
}

export class SharedBookDto {
  @ApiProperty({ type: String })
  id: string;

  @ApiProperty({ type: String })
  title: string;

  @ApiProperty({ type: String })
  childId: string;

  @ApiProperty({ type: String })
  createdAt: string;

  @ApiProperty({ type: String })
  status: string;
}
