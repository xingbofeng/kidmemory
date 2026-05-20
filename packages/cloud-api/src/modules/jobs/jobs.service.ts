import { Injectable, NotFoundException, BadRequestException, Inject } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service.ts';
import { JobResponseDto, UpdateJobStatusDto, PendingJobsQueryDto } from './jobs.dto.ts';

@Injectable()
export class JobsService {
  constructor(@Inject(PrismaService) private readonly prisma: PrismaService) {}

  /**
   * Get pending jobs (status = 'pending')
   * Ordered by priority (higher first) then createdAt (older first)
   */
  async getPendingJobs(query: PendingJobsQueryDto): Promise<JobResponseDto[]> {
    const limit =
      typeof query.limit === 'string'
        ? Number.parseInt(query.limit, 10) || 5
        : query.limit || 5;

    const where: {
      status: string;
      OR?: Array<{ deviceId: string | null }>;
    } = {
      status: 'pending',
    };

    // Filter by deviceId or unassigned jobs
    if (typeof query.deviceId === 'string' && query.deviceId.length > 0) {
      where.OR = [
        { deviceId: query.deviceId },
        { deviceId: null },
      ];
    }

    const jobs = await this.prisma.job.findMany({
      where,
      take: limit,
      orderBy: [
        { priority: 'desc' }, // Higher priority first
        { createdAt: 'asc' },  // Older first
      ],
    });

    return jobs.map((job) => this.toJobResponse(job));
  }

  /**
   * Update job status
   */
  async updateStatus(jobId: string, dto: UpdateJobStatusDto): Promise<JobResponseDto> {
    // Validate status transition
    const job = await this.prisma.job.findUnique({
      where: { id: jobId },
    });

    if (!job) {
      throw new NotFoundException(`Job ${jobId} not found`);
    }

    // Validate transition
    if (!this.isValidTransition(job.status, dto.status)) {
      throw new BadRequestException(
        `Invalid status transition from ${job.status} to ${dto.status}`
      );
    }

    // Update status
    const updateData: {
      status: UpdateJobStatusDto['status'];
      claimedAt?: Date;
      completedAt?: Date;
      errorMessage?: string;
    } = {
      status: dto.status,
    };

    if (dto.status === 'claimed') {
      updateData.claimedAt = dto.claimedAt ? new Date(dto.claimedAt) : new Date();
    } else if (dto.status === 'completed' || dto.status === 'failed') {
      updateData.completedAt = dto.completedAt ? new Date(dto.completedAt) : new Date();
      if (dto.status === 'failed') {
        updateData.errorMessage = dto.errorMessage;
      }
    }

    const updated = await this.prisma.job.update({
      where: { id: jobId },
      data: updateData,
    });

    return this.toJobResponse(updated);
  }

  /**
   * Validate status transition
   */
  private isValidTransition(from: string, to: string): boolean {
    const validTransitions: Record<string, string[]> = {
      'pending': ['claimed'],
      'claimed': ['processing', 'pending'], // Can unclaim
      'processing': ['completed', 'failed'],
      'failed': ['pending'], // Allow retry
      'completed': [], // Terminal state
    };

    return validTransitions[from]?.includes(to) || false;
  }

  private toJobResponse(job: {
    id: string;
    deviceId: string | null;
    type: string;
    payload: unknown;
    status: string;
    priority: number;
    claimedAt: Date | null;
    completedAt: Date | null;
    errorMessage: string | null;
    createdAt: Date;
    updatedAt: Date;
  }): JobResponseDto {
    const payload =
      job.payload !== null &&
      typeof job.payload === 'object' &&
      !Array.isArray(job.payload)
        ? (job.payload as Record<string, never>)
        : null;

    return {
      ...job,
      type: job.type as JobResponseDto['type'],
      status: job.status as JobResponseDto['status'],
      deviceId: job.deviceId ?? undefined,
      claimedAt: job.claimedAt?.toISOString(),
      completedAt: job.completedAt?.toISOString(),
      errorMessage: job.errorMessage ?? undefined,
      createdAt: job.createdAt.toISOString(),
      updatedAt: job.updatedAt.toISOString(),
      payload,
    };
  }
}
