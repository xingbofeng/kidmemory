import type {
  components,
  operations,
} from "@kidmemory/protocol/generated/cloud-api/ts";

export type UploadItemResponseDto =
  components["schemas"]["UploadItemResponseDto"];
export type UpdateSyncStatusRequestDto =
  components["schemas"]["UpdateSyncStatusRequestDto"];
export type UpdateSyncStatusDto = UpdateSyncStatusRequestDto;
export type PendingSyncQueryDto =
  operations["UploadItemsController_getPendingSync"]["parameters"]["query"] & {
    deviceId?: string;
    limit?: number | string;
    offset?: number | string;
  };
