import { Injectable, NotFoundException, BadRequestException, Inject } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service.ts';
import { isValidStatusTransition, type StatusTransitions } from '../../infrastructure/state/status-transition.ts';
import { UploadItemResponseDto, UpdateSyncStatusDto, PendingSyncQueryDto } from './upload-items.dto.ts';

interface UploadItemRecord {
  id: string;
  sessionId: string;
  session: { childId: string };
  deviceId: string | null;
  objectKey: string;
  fileName: string;
  fileSize: bigint | number | null;
  mimeType: string | null;
  status: string;
  uploadedAt: Date | null;
  syncedAt: Date | null;
  errorMessage: string | null;
  createdAt: Date;
  updatedAt: Date;
}

const UPLOAD_ITEM_STATUS_TRANSITIONS: StatusTransitions = {
  pending: ['uploaded', 'failed'],
  uploaded: ['synced', 'failed'],
  failed: ['uploaded'],
  synced: [],
};

export interface UploadItemsPrismaClient {
  uploadItem: {
    findMany(input: {
      where: {
        status: string;
        deviceId?: string;
      };
      take: number;
      skip: number;
      orderBy: { uploadedAt: 'asc' };
      include: { session: { select: { childId: true } } };
    }): Promise<UploadItemRecord[]>;
    findUnique(input: {
      where: { id: string };
      include?: { session: { select: { childId: true } } };
    }): Promise<UploadItemRecord | null>;
    update(input: {
      where: { id: string };
      data: {
        status: UpdateSyncStatusDto['status'];
        syncedAt?: Date;
        errorMessage?: string;
      };
    }): Promise<unknown>;
  };
}

@Injectable()
export class UploadItemsService {
  constructor(@Inject(PrismaService) private readonly prisma: UploadItemsPrismaClient) {}

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
        uploadedAt: 'asc',
      },
      include: {
        session: {
          select: {
            childId: true,
          },
        },
      },
    });

    return items.map((item) => this.toUploadItemResponse(item));
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

    return this.toUploadItemResponse(item);
  }

  private toUploadItemResponse(item: UploadItemRecord): UploadItemResponseDto {
    return {
      id: item.id,
      sessionId: item.sessionId,
      childId: item.session.childId,
      deviceId: item.deviceId ?? undefined,
      objectKey: item.objectKey,
      fileName: item.fileName,
      fileSize: item.fileSize === null ? undefined : item.fileSize.toString(),
      mimeType: item.mimeType ?? undefined,
      status: item.status as UploadItemResponseDto['status'],
      uploadedAt: item.uploadedAt?.toISOString(),
      syncedAt: item.syncedAt?.toISOString(),
      errorMessage: item.errorMessage ?? undefined,
      createdAt: item.createdAt.toISOString(),
      updatedAt: item.updatedAt.toISOString(),
    };
  }

  async updateSyncStatus(itemId: string, dto: UpdateSyncStatusDto): Promise<UploadItemResponseDto> {
    const item = await this.prisma.uploadItem.findUnique({
      where: { id: itemId },
    });

    if (!item) {
      throw new NotFoundException(`Upload item ${itemId} not found`);
    }

    if (!isValidStatusTransition(item.status, dto.status, UPLOAD_ITEM_STATUS_TRANSITIONS)) {
      throw new BadRequestException(
        `Invalid status transition from ${item.status} to ${dto.status}`
      );
    }

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

}
