import { Injectable, NotFoundException, BadRequestException, Inject } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service.ts';
import { UploadItemResponseDto, UpdateSyncStatusDto, PendingSyncQueryDto } from './upload-items.dto.ts';

@Injectable()
export class UploadItemsService {
  constructor(@Inject(PrismaService) private readonly prisma: PrismaService) {}

  private parseIntegerQuery(value: unknown, fallback: number, min: number, max: number): number {
    if (typeof value === 'number' && Number.isFinite(value)) {
      return Math.min(max, Math.max(min, Math.trunc(value)));
    }
    if (typeof value === 'string' && value.trim().length > 0) {
      const parsed = Number.parseInt(value, 10);
      if (Number.isFinite(parsed)) {
        return Math.min(max, Math.max(min, parsed));
      }
    }
    return fallback;
  }

  /**
   * Get pending sync items (status = 'uploaded')
   */
  async getPendingSync(query: PendingSyncQueryDto): Promise<UploadItemResponseDto[]> {
    const limit = this.parseIntegerQuery(query.limit, 10, 1, 200);
    const offset = this.parseIntegerQuery(query.offset, 0, 0, 1_000_000);

    const where: {
      status: string;
      deviceId?: string;
    } = {
      status: 'uploaded',
    };

    if (typeof query.deviceId === 'string' && query.deviceId.length > 0) {
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
      fileSize: item.fileSize === null ? undefined : item.fileSize.toString(),
      mimeType: item.mimeType ?? undefined,
      status: item.status,
      uploadedAt: item.uploadedAt?.toISOString(),
      syncedAt: item.syncedAt?.toISOString(),
      errorMessage: item.errorMessage ?? undefined,
      createdAt: item.createdAt.toISOString(),
      updatedAt: item.updatedAt.toISOString(),
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
      fileSize: item.fileSize === null ? undefined : item.fileSize.toString(),
      mimeType: item.mimeType ?? undefined,
      status: item.status,
      uploadedAt: item.uploadedAt?.toISOString(),
      syncedAt: item.syncedAt?.toISOString(),
      errorMessage: item.errorMessage ?? undefined,
      createdAt: item.createdAt.toISOString(),
      updatedAt: item.updatedAt.toISOString(),
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
