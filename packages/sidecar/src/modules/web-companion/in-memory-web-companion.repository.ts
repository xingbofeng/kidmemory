import type {
  CreateUploadItemWithAssetInput,
  UpdateUploadItemInput,
  WebCompanionRepository,
} from "./web-companion.service.ts";
import type { UploadItem, UploadSession } from "./types.ts";
import {
  UploadItemStatus,
  type UploadItemStatusType,
  type UploadSessionStatusType,
} from "./constants.ts";

export class InMemoryWebCompanionRepository implements WebCompanionRepository {
  private readonly sessions = new Map<string, UploadSession>();
  private readonly items = new Map<string, UploadItem>();

  async insertSession(session: Omit<UploadSession, "createdAt">): Promise<void> {
    this.sessions.set(session.id, {
      ...session,
      createdAt: new Date(),
    });
  }

  async getSessionById(sessionId: string): Promise<UploadSession | null> {
    return this.sessions.get(sessionId) || null;
  }

  async updateSessionStatus(input: {
    sessionId: string;
    status: UploadSessionStatusType;
    closedAt?: Date;
  }): Promise<void> {
    const session = this.sessions.get(input.sessionId);
    if (!session) return;
    this.sessions.set(input.sessionId, {
      ...session,
      status: input.status,
      closedAt: input.closedAt,
    });
  }

  async countUploadItemsBySession(sessionId: string): Promise<number> {
    return [...this.items.values()].filter((item) => item.sessionId === sessionId).length;
  }

  async getUploadItemsBySession(sessionId: string): Promise<UploadItem[]> {
    return [...this.items.values()]
      .filter((item) => item.sessionId === sessionId)
      .sort((left, right) => left.createdAt.getTime() - right.createdAt.getTime());
  }

  async getUploadItemById(uploadItemId: string): Promise<UploadItem | null> {
    return this.items.get(uploadItemId) || null;
  }

  async createUploadItemWithAsset(input: CreateUploadItemWithAssetInput): Promise<UploadItem> {
    const now = new Date();
    const item: UploadItem = {
      id: input.uploadItemId,
      sessionId: input.sessionId,
      assetId: input.assetId,
      clientFileId: input.clientFileId,
      originalFilename: input.originalFilename,
      safeFilename: input.safeFilename,
      contentType: input.contentType,
      sizeBytes: input.sizeBytes,
      provider: input.provider,
      bucket: input.bucket,
      objectKey: input.objectKey,
      status: input.status,
      remoteEtag: null,
      localPath: null,
      hashSha256: null,
      errorCode: null,
      errorMessage: null,
      createdAt: now,
      updatedAt: now,
    };
    this.items.set(item.id, item);
    return item;
  }

  async updateUploadItemStatus(input: {
    uploadItemId: string;
    status: UploadItemStatusType;
    updates: UpdateUploadItemInput;
  }): Promise<UploadItem | null> {
    const item = this.items.get(input.uploadItemId);
    if (!item) return null;
    const next: UploadItem = {
      ...item,
      ...input.updates,
      status: input.status,
      updatedAt: new Date(),
    };
    this.items.set(next.id, next);
    return next;
  }

  async commitUploadItemIfNotCommitted(input: {
    uploadItemId: string;
    status: UploadItemStatusType;
    updates: UpdateUploadItemInput;
  }): Promise<UploadItem | null> {
    const item = this.items.get(input.uploadItemId);
    if (!item || item.committedAt) return null;
    if (item.status !== UploadItemStatus.UPLOADING) return null;
    const next: UploadItem = {
      ...item,
      ...input.updates,
      status: input.status,
      updatedAt: new Date(),
    };
    this.items.set(next.id, next);
    return next;
  }
}
