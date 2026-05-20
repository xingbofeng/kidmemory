import { Controller, Get, Put, Query, Param, Body, HttpCode, HttpStatus, Inject } from '@nestjs/common';
import { ApiBody, ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { JobsService } from './jobs.service.ts';
import { JobResponseDto, UpdateJobStatusRequestDto } from './jobs.dto.ts';
import type { PendingJobsQueryDto, UpdateJobStatusDto } from './jobs.dto.ts';

@ApiTags('jobs')
@Controller('/jobs')
export class JobsController {
  constructor(@Inject(JobsService) private readonly jobsService: JobsService) {}

  @Get('/pending')
  @ApiOperation({ summary: 'Get pending jobs for device' })
  @ApiQuery({ name: 'deviceId', required: false, description: 'Filter by device ID (null = unassigned)' })
  @ApiQuery({ name: 'limit', required: false, description: 'Maximum jobs to return', type: Number })
  @ApiResponse({ status: 200, description: 'Pending jobs retrieved', type: JobResponseDto, isArray: true })
  async getPendingJobs(@Query() query: PendingJobsQueryDto): Promise<JobResponseDto[]> {
    return this.jobsService.getPendingJobs(query);
  }

  @Put('/:id/status')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update job status' })
  @ApiBody({ type: UpdateJobStatusRequestDto })
  @ApiResponse({ status: 200, description: 'Status updated', type: JobResponseDto })
  @ApiResponse({ status: 400, description: 'Invalid status transition' })
  @ApiResponse({ status: 404, description: 'Job not found' })
  async updateStatus(
    @Param('id') id: string,
    @Body() dto: UpdateJobStatusDto,
  ): Promise<JobResponseDto> {
    return this.jobsService.updateStatus(id, dto);
  }
}
