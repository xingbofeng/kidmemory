import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service.ts';
import { JobResponseDto, UpdateJobStatusDto, PendingJobsQueryDto } from './jobs.dto.ts';

@Injectable()
export class JobsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Get pending jobs (status = 'pending')
   * Ordered by priority (higher first) then createdAt (older first)
   */
  async getPendingJobs(query: PendingJobsQueryDto): Promise<JobResponseDto[]> {
    const limit = query.limit || 5;

    const where: any = {
      status: 'pending',
    };

    // Filter by deviceId or unassigned jobs
    if (query.deviceId) {
      where.OR = [
        { deviceId: query.deviceId },
        { deviceId: null },
      ];
    }

    return this.prisma.job.findMany({
      where,
      take: limit,
      orderBy: [
        { priority: 'desc' }, // Higher priority first
        { createdAt: 'asc' },  // Older first
      ],
    });
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
    const updateData: any = {
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

    return this.prisma.job.update({
      where: { id: jobId },
      data: updateData,
    });
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
}
