import { BadRequestException, Inject, Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';

import { PrismaService } from '../../infrastructure/database/prisma.service.ts';
import {
  CommitUploadItemRequestDto,
  CommitUploadItemResponseDto,
  CreateUploadItemsRequestDto,
  CreateUploadItemsResponseDto,
  DirectUploadConfigResponseDto,
  SessionSummaryResponseDto,
  ShareTokenValidationResponseDto,
  SharedAssetDto,
  SharedBookDto,
} from './web-companion.dto.ts';

type ShareValidationInput = {
  token: string;
  clientIp?: string;
  userAgent?: string;
};

@Injectable()
export class WebCompanionService {
  constructor(@Inject(PrismaService) private readonly prisma: PrismaService) {}

  async getDirectUploadConfig(sessionId: string): Promise<DirectUploadConfigResponseDto> {
    await this.requireSession(sessionId);
    return {
      anonKey: process.env.SUPABASE_ANON_KEY || 'dev-anon-key',
    };
  }

  async getSessionSummary(sessionId: string, token?: string): Promise<SessionSummaryResponseDto> {
    this.requireTrustedSessionToken(token);
    const session = await this.requireSession(sessionId);
    const usedItems = await this.prisma.uploadItem.count({
      where: { sessionId },
    });

    return {
      sessionId: session.id,
      status: session.status,
      child: {
        id: session.childId,
        displayName: session.childId,
      },
      expiresAt: session.expiresAt.toISOString(),
      maxItems: session.maxItems,
      usedItems,
      providers: {
        lan: { available: false },
        supabase: { available: true },
      },
    };
  }

  async createUploadItems(
    sessionId: string,
    request: CreateUploadItemsRequestDto,
  ): Promise<CreateUploadItemsResponseDto> {
    this.requireTrustedSessionToken(request.token);
    const session = await this.requireSession(sessionId);

    if (session.status !== 'active') {
      throw new BadRequestException('Session is not active');
    }

    if (session.expiresAt.getTime() <= Date.now()) {
      throw new BadRequestException('Session expired');
    }

    const existing = await this.prisma.uploadItem.count({ where: { sessionId } });
    if (existing + request.files.length > session.maxItems) {
      throw new BadRequestException('Item limit exceeded');
    }

    const items = await Promise.all(
      request.files.map(async (file, index) => {
        const objectKey = `${sessionId}/${Date.now()}-${index}-${sanitizeFileName(file.filename)}`;
        const created = await this.prisma.uploadItem.create({
          data: {
            sessionId,
            objectKey,
            fileName: file.filename,
            fileSize: BigInt(file.sizeBytes),
            mimeType: file.contentType,
            status: 'pending',
          },
        });

        return {
          clientFileId: file.clientFileId,
          uploadItemId: created.id,
          assetId: created.id,
          objectKey: created.objectKey,
          status: created.status,
        };
      }),
    );

    return { items };
  }

  async commitUploadItem(
    sessionId: string,
    uploadItemId: string,
    request: CommitUploadItemRequestDto,
  ): Promise<CommitUploadItemResponseDto> {
    this.requireTrustedSessionToken(request.token);
    await this.requireSession(sessionId);
    const item = await this.prisma.uploadItem.findUnique({
      where: { id: uploadItemId },
    });

    if (!item || item.sessionId !== sessionId) {
      throw new NotFoundException(`Upload item ${uploadItemId} not found`);
    }

    if (item.objectKey !== request.objectKey) {
      throw new BadRequestException('Object key mismatch');
    }

    const updated = await this.prisma.uploadItem.update({
      where: { id: uploadItemId },
      data: {
        status: 'uploaded',
        uploadedAt: new Date(),
        fileSize: BigInt(request.sizeBytes),
        mimeType: request.contentType,
      },
    });

    return {
      uploadItemId: updated.id,
      status: updated.status,
    };
  }

  async validateShareToken(input: ShareValidationInput): Promise<ShareTokenValidationResponseDto> {
    const shareToken = await this.prisma.shareToken.findUnique({
      where: { token: input.token },
    });
    if (!shareToken) {
      return invalidShareToken('Share token not found');
    }

    if (shareToken.revokedAt) {
      return invalidShareToken('Share token revoked');
    }

    if (shareToken.expiresAt && shareToken.expiresAt.getTime() <= Date.now()) {
      return invalidShareToken('Share token expired');
    }

    if (shareToken.accessLimit !== null && shareToken.accessCount >= shareToken.accessLimit) {
      return invalidShareToken('Share token access limit exceeded');
    }

    await this.prisma.shareToken.update({
      where: { id: shareToken.id },
      data: {
        accessCount: shareToken.accessCount + 1,
      },
    });

    await this.prisma.shareAccessLog.create({
      data: {
        tokenId: shareToken.id,
        ipAddress: input.clientIp || 'unknown',
        userAgent: input.userAgent || null,
      },
    });

    return {
      isValid: true,
      shareToken: {
        id: shareToken.id,
        childId: shareToken.childId,
        resourceType: shareToken.bookId ? 'specific_book' : 'child_assets',
        resourceId: shareToken.bookId ?? undefined,
        accessType: 'read',
      },
    };
  }

  async getSharedAssets(shareToken: string, limit = 20): Promise<SharedAssetDto[]> {
    const token = await this.prisma.shareToken.findUnique({ where: { token: shareToken } });
    if (!token) {
      throw new NotFoundException('Share token not found');
    }

    const items = await this.prisma.uploadItem.findMany({
      where: {
        status: { in: ['uploaded', 'synced'] },
        session: {
          childId: token.childId,
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
      take: limit,
    });

    return items.map((item) => ({
      id: item.id,
      title: item.fileName,
      type: (item.mimeType || '').startsWith('image/') ? 'photo' : 'file',
      createdAt: item.createdAt.toISOString(),
    }));
  }

  async getSharedBook(shareToken: string, bookId?: string): Promise<SharedBookDto> {
    const token = await this.prisma.shareToken.findUnique({ where: { token: shareToken } });
    if (!token) {
      throw new NotFoundException('Share token not found');
    }

    const targetBookId = token.bookId || bookId;
    if (!targetBookId) {
      throw new NotFoundException('Unable to determine book');
    }

    return {
      id: targetBookId,
      title: `Book ${targetBookId}`,
      childId: token.childId,
      createdAt: token.createdAt.toISOString(),
      status: 'ready',
    };
  }

  private async requireSession(sessionId: string) {
    const session = await this.prisma.uploadSession.findUnique({
      where: { id: sessionId },
    });
    if (!session) {
      throw new NotFoundException(`Session ${sessionId} not found`);
    }
    return session;
  }

  private requireTrustedSessionToken(token?: string) {
    if (!token || token.trim().length === 0) {
      throw new UnauthorizedException('Trusted upload token required');
    }
  }
}

function sanitizeFileName(filename: string): string {
  return filename.replace(/[^a-zA-Z0-9._-]+/g, '_');
}

function invalidShareToken(error: string): ShareTokenValidationResponseDto {
  return { isValid: false, error };
}
