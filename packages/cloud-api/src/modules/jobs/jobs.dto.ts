import type { components, operations } from '@kidmemory/protocol/generated/cloud-api/ts';

export type JobResponseDto = components['schemas']['JobResponseDto'];
export type UpdateJobStatusDto = components['schemas']['UpdateJobStatusRequestDto'];
export type PendingJobsQueryDto = NonNullable<operations['JobsController_getPendingJobs']['parameters']['query']>;
