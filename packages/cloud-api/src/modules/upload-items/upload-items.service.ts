import { Injectable, NotFoundException, BadRequestException, Inject } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service.ts';
import { UploadItemResponseDto, UpdateSyncStatusDto, PendingSyncQueryDto } from './upload-items.dto.ts';

@Injectable()
export class UploadItemsService {
  constructor(@Inject(PrismaService) private readonly prisma: PrismaService) {}

  /**
   * Get pending sync items (status = 'uploaded')
   */
  async getPendingSync(query: PendingSyncQueryDto): Promise<UploadItemResponseDto[]> {
    const limit = query.limit || 10;
    const offset = query.offset || 0;

    const where: {
      status: string;
      deviceId?: string;
    } = {
      status: 'uploaded',
    };

    if (query.deviceId) {
      where.deviceId = query.deviceId;
    }

    const items = await this.prisma.uploadItem.findMany({
      where,
      take: limit,
      skip: offset,
      orderBy: {
        uploadedAt: 'asc', // Oldest first
      },
      include: {
        session: {
          select: {
            childId: true,
          },
        },
      },
    });

    return items.map((item) => ({
      id: item.id,
      sessionId: item.sessionId,
      childId: item.session.childId,
      deviceId: item.deviceId ?? undefined,
      objectKey: item.objectKey,
      fileName: item.fileName,
      fileSize: item.fileSize ?? undefined,
      mimeType: item.mimeType ?? undefined,
      status: item.status,
      uploadedAt: item.uploadedAt ?? undefined,
      syncedAt: item.syncedAt ?? undefined,
      errorMessage: item.errorMessage ?? undefined,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    }));
  }

  private async findMappedUploadItem(itemId: string): Promise<UploadItemResponseDto> {
    const item = await this.prisma.uploadItem.findUnique({
      where: { id: itemId },
      include: {
        session: {
          select: {
            childId: true,
          },
        },
      },
    });

    if (!item) {
      throw new NotFoundException(`Upload item ${itemId} not found`);
    }

    return {
      id: item.id,
      sessionId: item.sessionId,
      childId: item.session.childId,
      deviceId: item.deviceId ?? undefined,
      objectKey: item.objectKey,
      fileName: item.fileName,
      fileSize: item.fileSize ?? undefined,
      mimeType: item.mimeType ?? undefined,
      status: item.status,
      uploadedAt: item.uploadedAt ?? undefined,
      syncedAt: item.syncedAt ?? undefined,
      errorMessage: item.errorMessage ?? undefined,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    };
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
    const updateData: {
      status: UpdateSyncStatusDto['status'];
      syncedAt?: Date;
      errorMessage?: string;
    } = {
      status: dto.status,
    };

    if (dto.status === 'synced') {
      updateData.syncedAt = dto.syncedAt ? new Date(dto.syncedAt) : new Date();
    } else if (dto.status === 'failed') {
      updateData.errorMessage = dto.errorMessage;
    }

    await this.prisma.uploadItem.update({
      where: { id: itemId },
      data: updateData,
    });

    return this.findMappedUploadItem(itemId);
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
