import { isPrismaNotFoundError } from "../../infrastructure/database/prisma-errors.ts";
import type { PrismaService } from "../../infrastructure/database/prisma.service.ts";
import type {
  CreateUploadItemWithAssetInput,
  UpdateUploadItemInput,
  WebCompanionRepository,
} from "./web-companion.service.ts";
import type {
  UploadItem,
  UploadSession,
} from "./types.ts";
import type {
  StorageProviderType,
  UploadItemStatusType,
  UploadSessionStatusType,
  WebCompanionErrorCodeType,
} from "./constants.ts";

export class PrismaWebCompanionRepository implements WebCompanionRepository {
  private readonly prisma: PrismaService;

  constructor(prisma: PrismaService) {
    this.prisma = prisma;
  }

  async insertSession(session: Omit<UploadSession, "createdAt">): Promise<void> {
    await this.prisma.uploadSession.create({
      data: {
        id: session.id,
        childId: session.childId,
        tokenHash: session.tokenHash,
        status: session.status,
        expiresAt: session.expiresAt,
        maxItems: session.maxItems,
        closedAt: session.closedAt ?? null,
        lastSeenAt: session.lastSeenAt ?? null,
      },
    });
  }

  async getSessionById(sessionId: string): Promise<UploadSession | null> {
    const session = await this.prisma.uploadSession.findUnique({
      where: { id: sessionId },
    });
    return session ? mapSession(session) : null;
  }

  async updateSessionStatus(input: {
    sessionId: string;
    status: UploadSessionStatusType;
    closedAt?: Date;
  }): Promise<void> {
    await this.prisma.uploadSession.update({
      where: { id: input.sessionId },
      data: {
        status: input.status,
        closedAt: input.closedAt ?? null,
      },
    });
  }

  async countUploadItemsBySession(sessionId: string): Promise<number> {
    return this.prisma.uploadItem.count({
      where: { sessionId },
    });
  }

  async getUploadItemsBySession(sessionId: string): Promise<UploadItem[]> {
    const items = await this.prisma.uploadItem.findMany({
      where: { sessionId },
      orderBy: { createdAt: "asc" },
    });
    return items.map(mapUploadItem);
  }

  async getUploadItemById(uploadItemId: string): Promise<UploadItem | null> {
    const item = await this.prisma.uploadItem.findUnique({
      where: { id: uploadItemId },
    });
    return item ? mapUploadItem(item) : null;
  }

  async createUploadItemWithAsset(input: CreateUploadItemWithAssetInput): Promise<UploadItem> {
    const item = await this.prisma.$transaction(async (tx) => {
      await tx.asset.create({
        data: {
          id: input.assetId,
          childId: input.childId,
          type: "photo",
          title: input.originalFilename,
          originalFilename: input.originalFilename,
          contentType: input.contentType,
          sizeBytes: BigInt(input.sizeBytes),
          storageProvider: input.provider,
          storageStatus: "pending",
          license: "user_uploaded",
        },
      });

      return tx.uploadItem.create({
        data: {
          id: input.uploadItemId,
          sessionId: input.sessionId,
          assetId: input.assetId,
          clientFileId: input.clientFileId,
          originalFilename: input.originalFilename,
          safeFilename: input.safeFilename,
          contentType: input.contentType,
          sizeBytes: BigInt(input.sizeBytes),
          provider: input.provider,
          bucket: input.bucket || null,
          objectKey: input.objectKey,
          status: input.status,
        },
      });
    });

    return mapUploadItem(item);
  }

  async updateUploadItemStatus(input: {
    uploadItemId: string;
    status: UploadItemStatusType;
    updates: UpdateUploadItemInput;
  }): Promise<UploadItem | null> {
    const data: {
      status: UploadItemStatusType;
      sizeBytes?: bigint;
      contentType?: string;
      remoteEtag?: string | null;
      localPath?: string | null;
      assetId?: string;
      hashSha256?: string | null;
      errorCode?: WebCompanionErrorCodeType | null;
      errorMessage?: string | null;
      committedAt?: Date;
      readyAt?: Date;
    } = { status: input.status };

    if (input.updates.sizeBytes !== undefined) data.sizeBytes = BigInt(input.updates.sizeBytes);
    if (input.updates.contentType !== undefined) data.contentType = input.updates.contentType;
    if (input.updates.remoteEtag !== undefined) data.remoteEtag = input.updates.remoteEtag;
    if (input.updates.localPath !== undefined) data.localPath = input.updates.localPath;
    if (input.updates.assetId !== undefined) data.assetId = input.updates.assetId;
    if (input.updates.hashSha256 !== undefined) data.hashSha256 = input.updates.hashSha256;
    if (input.updates.errorCode !== undefined) data.errorCode = input.updates.errorCode;
    if (input.updates.errorMessage !== undefined) data.errorMessage = input.updates.errorMessage;
    if (input.updates.committedAt !== undefined) data.committedAt = input.updates.committedAt;
    if (input.updates.readyAt !== undefined) data.readyAt = input.updates.readyAt;

    try {
      const item = await this.prisma.uploadItem.update({
        where: { id: input.uploadItemId },
        data,
      });
      return mapUploadItem(item);
    } catch (error) {
      if (isPrismaNotFoundError(error)) {
        return null;
      }
      throw error;
    }
  }

  async commitUploadItemIfNotCommitted(input: {
    uploadItemId: string;
    status: UploadItemStatusType;
    updates: UpdateUploadItemInput;
  }): Promise<UploadItem | null> {
    const updateData: {
      status: UploadItemStatusType;
      sizeBytes?: bigint;
      contentType?: string;
      remoteEtag?: string | null;
      committedAt?: Date;
    } = { status: input.status };

    if (input.updates.sizeBytes !== undefined) updateData.sizeBytes = BigInt(input.updates.sizeBytes);
    if (input.updates.contentType !== undefined) updateData.contentType = input.updates.contentType;
    if (input.updates.remoteEtag !== undefined) updateData.remoteEtag = input.updates.remoteEtag;
    if (input.updates.committedAt !== undefined) updateData.committedAt = input.updates.committedAt;

    const result = await this.prisma.uploadItem.updateMany({
      where: {
        id: input.uploadItemId,
        committedAt: null,
        status: "uploading",
      },
      data: updateData,
    });

    if (result.count === 0) {
      return null;
    }

    const committed = await this.prisma.uploadItem.findUnique({
      where: { id: input.uploadItemId },
    });
    return committed ? mapUploadItem(committed) : null;
  }
}

function mapSession(session: {
  id: string;
  childId: string;
  tokenHash: string;
  status: string;
  expiresAt: Date;
  maxItems: number;
  createdAt: Date;
  closedAt: Date | null;
  lastSeenAt: Date | null;
}): UploadSession {
  return {
    id: session.id,
    childId: session.childId,
    tokenHash: session.tokenHash,
    status: session.status as UploadSessionStatusType,
    expiresAt: session.expiresAt,
    maxItems: session.maxItems,
    createdAt: session.createdAt,
    closedAt: session.closedAt ?? undefined,
    lastSeenAt: session.lastSeenAt ?? undefined,
  };
}

function mapUploadItem(item: {
  id: string;
  sessionId: string;
  assetId: string;
  clientFileId: string | null;
  originalFilename: string;
  safeFilename: string;
  contentType: string;
  sizeBytes: bigint;
  provider: string;
  bucket: string | null;
  objectKey: string;
  status: string;
  remoteEtag: string | null;
  localPath: string | null;
  hashSha256: string | null;
  errorCode: string | null;
  errorMessage: string | null;
  createdAt: Date;
  updatedAt: Date;
  committedAt: Date | null;
  readyAt: Date | null;
}): UploadItem {
  return {
    id: item.id,
    sessionId: item.sessionId,
    assetId: item.assetId,
    clientFileId: item.clientFileId,
    originalFilename: item.originalFilename,
    safeFilename: item.safeFilename,
    contentType: item.contentType,
    sizeBytes: Number(item.sizeBytes),
    provider: item.provider as StorageProviderType,
    bucket: item.bucket ?? undefined,
    objectKey: item.objectKey,
    status: item.status as UploadItemStatusType,
    remoteEtag: item.remoteEtag,
    localPath: item.localPath,
    hashSha256: item.hashSha256,
    errorCode: item.errorCode as WebCompanionErrorCodeType | null,
    errorMessage: item.errorMessage,
    createdAt: item.createdAt,
    updatedAt: item.updatedAt,
    committedAt: item.committedAt ?? undefined,
    readyAt: item.readyAt ?? undefined,
  };
}
