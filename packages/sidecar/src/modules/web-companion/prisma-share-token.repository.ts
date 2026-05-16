import type { PrismaService } from "../../infrastructure/database/prisma.service.ts";
import type {
  CreateShareTokenRecordInput,
  LogShareAccessInput,
  ShareSessionRecord,
  ShareTokenRecord,
  ShareTokenRepository,
} from "./share-token.service.ts";

export class PrismaShareTokenRepository implements ShareTokenRepository {
  private readonly prisma: PrismaService;

  constructor(prisma: PrismaService) {
    this.prisma = prisma;
  }

  async findSessionByToken(input: { sessionId: string; tokenHash: string }): Promise<ShareSessionRecord | null> {
    const session = await this.prisma.uploadSession.findFirst({
      where: {
        id: input.sessionId,
        tokenHash: input.tokenHash,
      },
    });

    return session ? {
      sessionId: session.id,
      childId: session.childId,
      expiresAt: session.expiresAt.toISOString(),
      status: session.status,
    } : null;
  }

  async bookExistsForChild(input: { bookId: string; childId: string }): Promise<boolean> {
    const count = await this.prisma.book.count({
      where: {
        id: input.bookId,
        childId: input.childId,
      },
    });

    return count > 0;
  }

  async createShareToken(input: CreateShareTokenRecordInput): Promise<ShareTokenRecord> {
    const shareToken = await this.prisma.shareToken.create({
      data: {
        id: input.id,
        tokenHash: input.tokenHash,
        childId: input.childId,
        createdBySession: input.createdBySession,
        expiresAt: input.expiresAt,
        accessType: input.accessType,
        resourceType: input.resourceType,
        resourceId: input.resourceId || null,
        maxAccessCount: input.maxAccessCount || null,
      },
    });

    return this.mapShareToken(shareToken);
  }

  async findShareTokenByHash(tokenHash: string): Promise<ShareTokenRecord | null> {
    const shareToken = await this.prisma.shareToken.findUnique({
      where: { tokenHash },
    });

    return shareToken ? this.mapShareToken(shareToken) : null;
  }

  async markShareTokenExpired(id: string): Promise<void> {
    await this.prisma.shareToken.update({
      where: { id },
      data: { status: "expired" },
    });
  }

  async incrementShareTokenAccess(id: string): Promise<void> {
    await this.prisma.shareToken.update({
      where: { id },
      data: {
        accessCount: { increment: 1 },
        lastAccessedAt: new Date(),
      },
    });
  }

  async logShareAccess(input: LogShareAccessInput): Promise<void> {
    await this.prisma.shareAccessLog.create({
      data: {
        id: input.id,
        shareTokenId: input.shareTokenId,
        clientIp: input.clientIp || null,
        userAgent: input.userAgent || null,
        accessResult: input.result,
        resourceAccessed: input.resourceAccessed || null,
      },
    });
  }

  async revokeShareTokenForSession(input: { shareTokenId: string; childId: string; sessionId: string }): Promise<boolean> {
    const result = await this.prisma.shareToken.updateMany({
      where: {
        id: input.shareTokenId,
        status: "active",
        OR: [
          { childId: input.childId },
          { createdBySession: input.sessionId },
        ],
      },
      data: { status: "revoked" },
    });

    return result.count > 0;
  }

  private mapShareToken(shareToken: {
    id: string;
    childId: string;
    expiresAt: Date;
    accessType: string;
    resourceType: string;
    resourceId: string | null;
    accessCount: number;
    maxAccessCount: number | null;
    status: string;
  }): ShareTokenRecord {
    return {
      id: shareToken.id,
      childId: shareToken.childId,
      expiresAt: shareToken.expiresAt.toISOString(),
      accessType: shareToken.accessType as ShareTokenRecord["accessType"],
      resourceType: shareToken.resourceType as ShareTokenRecord["resourceType"],
      resourceId: shareToken.resourceId || undefined,
      accessCount: shareToken.accessCount,
      maxAccessCount: shareToken.maxAccessCount,
      status: shareToken.status,
    };
  }
}
