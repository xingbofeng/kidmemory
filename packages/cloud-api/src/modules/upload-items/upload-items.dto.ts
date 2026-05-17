import type { components, operations } from '@kidmemory/protocol/generated/cloud-api/ts';

export type UploadItemResponseDto = components['schemas']['UploadItemResponseDto'];
export type UpdateSyncStatusDto = components['schemas']['UpdateSyncStatusRequestDto'];
export type PendingSyncQueryDto = NonNullable<operations['UploadItemsController_getPendingSync']['parameters']['query']>;
