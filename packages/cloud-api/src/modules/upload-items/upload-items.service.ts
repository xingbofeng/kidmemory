import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service.ts';
import { UploadItemResponseDto, UpdateSyncStatusDto, PendingSyncQueryDto } from './upload-items.dto.ts';

@Injectable()
export class UploadItemsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Get pending sync items (status = 'uploaded')
   */
  async getPendingSync(query: PendingSyncQueryDto): Promise<UploadItemResponseDto[]> {
    const limit = query.limit || 10;
    const offset = query.offset || 0;

    const where: any = {
      status: 'uploaded',
    };

    if (query.deviceId) {
      where.deviceId = query.deviceId;
    }

    return this.prisma.uploadItem.findMany({
      where,
      take: limit,
      skip: offset,
      orderBy: {
        uploadedAt: 'asc', // Oldest first
      },
    });
  }

  /**
   * Update sync status
   */
  async updateSyncStatus(itemId: string, dto: UpdateSyncStatusDto): Promise<UploadItemResponseDto> {
    // Validate status transition
    const item = await this.prisma.uploadItem.findUnique({
      where: { id: itemId },
    });

    if (!item) {
      throw new NotFoundException(`Upload item ${itemId} not found`);
    }

    // Validate transition
    if (!this.isValidTransition(item.status, dto.status)) {
      throw new BadRequestException(
        `Invalid status transition from ${item.status} to ${dto.status}`
      );
    }

    // Update status
    const updateData: any = {
      status: dto.status,
    };

    if (dto.status === 'synced') {
      updateData.syncedAt = dto.syncedAt ? new Date(dto.syncedAt) : new Date();
    } else if (dto.status === 'failed') {
      updateData.errorMessage = dto.errorMessage;
    }

    return this.prisma.uploadItem.update({
      where: { id: itemId },
      data: updateData,
    });
  }

  /**
   * Validate status transition
   */
  private isValidTransition(from: string, to: string): boolean {
    const validTransitions: Record<string, string[]> = {
      'pending': ['uploaded', 'failed'],
      'uploaded': ['synced', 'failed'],
      'failed': ['uploaded'], // Allow retry
      'synced': [], // Terminal state
    };

    return validTransitions[from]?.includes(to) || false;
  }
}
