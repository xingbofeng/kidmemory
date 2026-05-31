import type {
  BrowseAssetRecord,
  BrowseBookRecord,
  BrowseRepository,
  SessionValidation,
  ShareTokenValidation,
} from "./browse.service.ts";
import type { PrismaService } from "../../infrastructure/database/prisma.service.ts";

type PrismaJsonObject = Record<string, unknown>;

export class PrismaBrowseRepository implements BrowseRepository {
  private readonly prisma: PrismaService;

  constructor(prisma: PrismaService) {
    this.prisma = prisma;
  }

  async findSessionByToken(input: { sessionId: string; tokenHash: string }): Promise<SessionValidation | null> {
    const session = await this.prisma.uploadSession.findFirst({
      where: {
        id: input.sessionId,
        tokenHash: input.tokenHash,
      },
    });

    if (!session) {
      return null;
    }

    return {
      sessionId: session.id,
      childId: session.childId,
      tokenHash: session.tokenHash,
      expiresAt: session.expiresAt.toISOString(),
      status: session.status,
    };
  }

  async findRecentAssets(input: { childId: string; limit: number }): Promise<BrowseAssetRecord[]> {
    const assets = await this.prisma.asset.findMany({
      where: { childId: input.childId },
      orderBy: { createdAt: "desc" },
      take: input.limit,
    });

    return assets.map((asset) => ({
      id: asset.id,
      title: asset.title,
      type: asset.type,
      childId: asset.childId,
      createdAt: asset.createdAt.toISOString(),
      description: asset.description,
      tags: asset.tags,
      metadata: this.asObject(asset.metadata),
    }));
  }

  async findAssetForChild(input: { assetId: string; childId: string }): Promise<BrowseAssetRecord | null> {
    const asset = await this.prisma.asset.findFirst({
      where: {
        id: input.assetId,
        childId: input.childId,
      },
    });

    if (!asset) {
      return null;
    }

    return {
      id: asset.id,
      title: asset.title,
      type: asset.type,
      childId: asset.childId,
      createdAt: asset.createdAt.toISOString(),
      description: asset.description,
      tags: asset.tags,
      metadata: this.asObject(asset.metadata),
    };
  }

  async findBooksForChild(childId: string): Promise<BrowseBookRecord[]> {
    const books = await this.prisma.book.findMany({
      where: { childId },
      orderBy: { createdAt: "desc" },
    });

    return books.map((book) => ({
      id: book.id,
      title: book.title,
      childId: book.childId,
      createdAt: book.createdAt.toISOString(),
      status: book.status,
      metadata: this.asObject(book.metadata),
    }));
  }

  async findBookForChild(input: { bookId: string; childId: string }): Promise<BrowseBookRecord | null> {
    const book = await this.prisma.book.findFirst({
      where: {
        id: input.bookId,
        childId: input.childId,
      },
    });

    if (!book) {
      return null;
    }

    return {
      id: book.id,
      title: book.title,
      childId: book.childId,
      createdAt: book.createdAt.toISOString(),
      status: book.status,
      metadata: this.asObject(book.metadata),
    };
  }

  async findShareTokenByHash(tokenHash: string): Promise<ShareTokenValidation | null> {
    const shareToken = await this.prisma.shareToken.findUnique({
      where: { tokenHash },
    });

    if (!shareToken) {
      return null;
    }

    return {
      childId: shareToken.childId,
      resourceType: shareToken.resourceType,
      resourceId: shareToken.resourceId || undefined,
      accessType: shareToken.accessType,
      expiresAt: shareToken.expiresAt.toISOString(),
      status: shareToken.status,
      accessCount: shareToken.accessCount,
      maxAccessCount: shareToken.maxAccessCount,
    };
  }

  private asObject(value: unknown): PrismaJsonObject {
    return typeof value === "object" && value !== null && !Array.isArray(value) ? value as PrismaJsonObject : {};
  }
}
