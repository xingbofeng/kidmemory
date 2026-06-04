import { BadRequestException, Inject, Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { createRequire } from 'node:module';

import { PrismaService } from '../../infrastructure/database/prisma.service.ts';
import {
  CommitUploadItemRequestDto,
  CommitUploadItemResponseDto,
  CreateUploadItemsRequestDto,
  CreateUploadItemsResponseDto,
  DirectUploadConfigResponseDto,
  SignedUploadTargetDto,
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
      provider: 'cos',
      uploadMode: 'signed-url',
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
        cos: { available: isCosConfigured() },
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

        const signedUpload = createCosSignedUploadTarget({
          objectKey: created.objectKey,
          contentType: file.contentType,
        });

        return {
          clientFileId: file.clientFileId,
          uploadItemId: created.id,
          assetId: created.id,
          objectKey: created.objectKey,
          status: created.status,
          signedUpload,
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

function isCosConfigured() {
  return Boolean(
    process.env.COS_BUCKET?.trim() &&
    process.env.COS_REGION?.trim() &&
    process.env.COS_SECRET_ID?.trim() &&
    process.env.COS_SECRET_KEY?.trim(),
  );
}

type CosClient = {
  getObjectUrl?: (
    params: Record<string, unknown>,
    callback?: (error: Error | null, data?: { Url?: string }) => void,
  ) => string | undefined;
};

function createCosSignedUploadTarget(input: {
  objectKey: string;
  contentType: string;
}): SignedUploadTargetDto {
  if (!isCosConfigured()) {
    throw new BadRequestException('Tencent COS direct upload is not configured');
  }

  const require = createRequire(import.meta.url);
  const COS = require('cos-nodejs-sdk-v5') as new (options: {
    SecretId: string;
    SecretKey: string;
  }) => CosClient;
  const bucket = process.env.COS_BUCKET?.trim() ?? '';
  const region = process.env.COS_REGION?.trim() ?? 'ap-guangzhou';
  const ttlSeconds = Number(process.env.COS_SIGNED_URL_TTL_SECONDS ?? '900') || 900;
  const cos = new COS({
    SecretId: process.env.COS_SECRET_ID?.trim() ?? '',
    SecretKey: process.env.COS_SECRET_KEY?.trim() ?? '',
  });
  if (!cos.getObjectUrl) {
    throw new BadRequestException('Tencent COS SDK cannot create signed upload URLs');
  }

  const url = cos.getObjectUrl({
    Bucket: bucket,
    Region: region,
    Key: normalizeObjectKey(input.objectKey),
    Sign: true,
    Method: 'PUT',
    Expires: ttlSeconds,
  });
  if (!url) {
    throw new BadRequestException('Tencent COS SDK returned an empty signed upload URL');
  }

  return {
    method: 'PUT',
    url,
    headers: {
      'content-type': input.contentType || 'application/octet-stream',
    },
    expiresAt: new Date(Date.now() + ttlSeconds * 1000).toISOString(),
  };
}

function normalizeObjectKey(objectKey: string): string {
  return objectKey.split('/').filter(Boolean).join('/');
}
