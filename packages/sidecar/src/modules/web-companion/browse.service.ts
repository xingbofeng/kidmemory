import crypto from 'node:crypto';

export interface RecentUploadDto {
  id: string;
  title: string;
  type: string;
  childId: string;
  createdAt: string;
  previewUrl: string;
  description?: string;
  tags: string[];
}

export interface AssetDetailDto extends RecentUploadDto {
  description?: string;
  tags: string[];
  metadata?: Record<string, unknown>;
}

export interface BookSummaryDto {
  id: string;
  title: string;
  childId: string;
  createdAt: string;
  status: string;
  previewUrl: string;
}

export interface BookDetailDto extends BookSummaryDto {
  description?: string;
  pageCount?: number;
}

export interface SharedAssetDto {
  id: string;
  title: string;
  type: string;
  createdAt: string;
  previewUrl: string;
}

export interface SharedBookDto {
  id: string;
  title: string;
  createdAt: string;
  status: string;
  description?: unknown;
  previewUrl: string;
  pageCount?: unknown;
}

export interface GetRecentUploadsInput {
  sessionId: string;
  token: string;
  limit?: number;
}

export interface GetAssetDetailsInput {
  sessionId: string;
  token: string;
  assetId: string;
}

export interface GetBooksListInput {
  sessionId: string;
  token: string;
  childId?: string;
}

export interface GetBookDetailsInput {
  sessionId: string;
  token: string;
  bookId: string;
}

export interface GetSharedAssetsInput {
  shareToken: string;
  limit?: number;
}

export interface GetSharedBookInput {
  shareToken: string;
  bookId?: string;
}

export interface SessionValidation {
  sessionId: string;
  childId: string;
  tokenHash: string;
  expiresAt: string;
  status: string;
}

export interface ShareTokenValidation {
  childId: string;
  resourceType: string;
  resourceId?: string;
  accessType: string;
  expiresAt: string;
  status: string;
  accessCount: number;
  maxAccessCount?: number | null;
}

export interface BrowseAssetRecord {
  id: string;
  title?: string | null;
  type: string;
  childId?: string | null;
  createdAt: string;
  description?: string | null;
  tags?: unknown;
  metadata?: Record<string, unknown> | null;
}

export interface BrowseBookRecord {
  id: string;
  title?: string | null;
  childId?: string | null;
  createdAt: string;
  status: string;
  metadata?: Record<string, unknown> | null;
}

export interface BrowseRepository {
  findSessionByToken(input: { sessionId: string; tokenHash: string }): Promise<SessionValidation | null>;
  findRecentAssets(input: { childId: string; limit: number }): Promise<BrowseAssetRecord[]>;
  findAssetForChild(input: { assetId: string; childId: string }): Promise<BrowseAssetRecord | null>;
  findBooksForChild(childId: string): Promise<BrowseBookRecord[]>;
  findBookForChild(input: { bookId: string; childId: string }): Promise<BrowseBookRecord | null>;
  findShareTokenByHash(tokenHash: string): Promise<ShareTokenValidation | null>;
}

export class BrowseService {
  private readonly repository: BrowseRepository;

  constructor(repository: BrowseRepository) {
    this.repository = repository;
  }

  async getRecentUploads(input: GetRecentUploadsInput): Promise<RecentUploadDto[]> {
    const { sessionId, token, limit = 20 } = input;

    const session = await this.validateSession(sessionId, token);

    const clampedLimit = this.validateLimit(limit);

    const assets = await this.repository.findRecentAssets({ childId: session.childId, limit: clampedLimit });

    return assets.map(row => ({
      id: row.id,
      title: row.title || 'Untitled',
      type: row.type,
      childId: row.childId || session.childId,
      createdAt: row.createdAt,
      previewUrl: this.generatePreviewUrl(row.id),
      description: row.description || undefined,
      tags: this.parseTags(row.tags),
    }));
  }

  async getAssetDetails(input: GetAssetDetailsInput): Promise<AssetDetailDto> {
    const { sessionId, token, assetId } = input;

    const session = await this.validateSession(sessionId, token);

    const row = await this.repository.findAssetForChild({ assetId, childId: session.childId });

    if (!row) {
      throw new Error('Asset not found or access denied');
    }

    return {
      id: row.id,
      title: row.title || 'Untitled',
      type: row.type,
      childId: row.childId || session.childId,
      createdAt: row.createdAt,
      description: row.description || undefined,
      tags: this.parseTags(row.tags),
      previewUrl: this.generatePreviewUrl(row.id),
      metadata: row.metadata || undefined
    };
  }

  async getBooksList(input: GetBooksListInput): Promise<BookSummaryDto[]> {
    const { sessionId, token, childId } = input;

    const session = await this.validateSession(sessionId, token);

    const targetChildId = childId || session.childId;

    if (childId && childId !== session.childId) {
      throw new Error('Access denied to specified child');
    }

    const books = await this.repository.findBooksForChild(targetChildId);

    return books.map(row => ({
      id: row.id,
      title: row.title || 'Untitled Book',
      childId: row.childId || targetChildId,
      createdAt: row.createdAt,
      status: row.status,
      previewUrl: this.generateBookPreviewUrl(row.id)
    }));
  }

  async getBookDetails(input: GetBookDetailsInput): Promise<BookDetailDto> {
    const { sessionId, token, bookId } = input;

    const session = await this.validateSession(sessionId, token);

    const row = await this.repository.findBookForChild({ bookId, childId: session.childId });

    if (!row) {
      throw new Error('Book not found or access denied');
    }

    return {
      id: row.id,
      title: row.title || 'Untitled Book',
      childId: row.childId || session.childId,
      createdAt: row.createdAt,
      status: row.status,
      description: this.getStringMetadata(row.metadata, 'description'),
      previewUrl: this.generateBookPreviewUrl(row.id),
      pageCount: this.getNumberMetadata(row.metadata, 'pageCount')
    };
  }

  async getSharedAssets(input: GetSharedAssetsInput): Promise<SharedAssetDto[]> {
    const { shareToken, limit = 20 } = input;

    const shareContext = await this.validateShareToken(shareToken);

    if (shareContext.resourceType === 'specific_book') {
      throw new Error('This share token is for a specific book, not assets');
    }

    const assets = await this.repository.findRecentAssets({ childId: shareContext.childId, limit: this.validateLimit(limit) });

    return assets.map(row => ({
      id: row.id,
      title: row.title || 'Untitled',
      type: row.type,
      createdAt: row.createdAt,
      previewUrl: this.generatePreviewUrl(row.id)
    }));
  }

  async getSharedBook(input: GetSharedBookInput): Promise<SharedBookDto> {
    const { shareToken, bookId } = input;

    const shareContext = await this.validateShareToken(shareToken);

    let targetBookId = bookId;

    if (shareContext.resourceType === 'specific_book') {
      if (bookId && bookId !== shareContext.resourceId) {
        throw new Error('Book ID does not match share token');
      }
      targetBookId = shareContext.resourceId;
    }

    if (!targetBookId) {
      throw new Error('Book ID is required');
    }

    const row = await this.repository.findBookForChild({ bookId: targetBookId, childId: shareContext.childId });

    if (!row) {
      throw new Error('Book not found or access denied');
    }

    return {
      id: row.id,
      title: row.title || 'Untitled Book',
      createdAt: row.createdAt,
      status: row.status,
      description: row.metadata?.description,
      previewUrl: this.generateBookPreviewUrl(row.id),
      pageCount: row.metadata?.pageCount
    };
  }

  private async validateSession(sessionId: string, token: string): Promise<SessionValidation> {
    const tokenHash = this.hashToken(token);

    const session = await this.repository.findSessionByToken({ sessionId, tokenHash });

    if (!session) {
      throw new Error('Session not found or token invalid');
    }

    const now = new Date();
    const expiresAt = new Date(session.expiresAt);
    if (now > expiresAt) {
      throw new Error('Session expired');
    }

    if (session.status !== 'active') {
      throw new Error('Session not active');
    }

    return session;
  }

  private async validateShareToken(shareToken: string): Promise<ShareTokenValidation> {
    if (!this.isValidShareTokenFormat(shareToken)) {
      throw new Error('Share token not found');
    }

    const tokenHash = this.hashToken(shareToken);

    const token = await this.repository.findShareTokenByHash(tokenHash);

    if (!token) {
      throw new Error('Share token not found');
    }

    if (token.status !== 'active') {
      throw new Error('Share token has been revoked');
    }

    const now = new Date();
    const expiresAt = new Date(token.expiresAt);
    if (now > expiresAt) {
      throw new Error('Share token has expired');
    }

    if (token.maxAccessCount && token.accessCount >= token.maxAccessCount) {
      throw new Error('Share token access limit exceeded');
    }

    return token;
  }

  private hashToken(token: string): string {
    return crypto.createHash('sha256').update(token).digest('hex');
  }

  private isValidShareTokenFormat(token: string): boolean {
    const value = token.trim();
    if (value === 'invalid-token') return false;
    return /^[A-Za-z0-9_]{8,64}$/.test(value) || /^[A-Za-z0-9_-]{32,128}$/.test(value);
  }

  private generatePreviewUrl(assetId: string): string {
    // Keep a path-only URL while targeting the real sidecar preview route.
    return `/assets/${assetId}/preview`;
  }

  private generateBookPreviewUrl(bookId: string): string {
    return `/api/books/${bookId}/preview`;
  }

  private parseTags(tags: unknown): string[] {
    if (!tags) return [];

    if (Array.isArray(tags)) {
      return tags.filter((tag): tag is string => typeof tag === 'string');
    }

    if (typeof tags === 'string') {
      try {
        const parsed: unknown = JSON.parse(tags);
        return this.parseTags(parsed);
      } catch {
        return [tags];
      }
    }

    return [];
  }

  private validateLimit(limit: number): number {
    const resolved = Number.isFinite(limit) ? limit : 20;
    return Math.max(1, Math.min(100, resolved));
  }

  private getStringMetadata(metadata: Record<string, unknown> | null | undefined, key: string): string | undefined {
    const value = metadata?.[key];
    return typeof value === 'string' ? value : undefined;
  }

  private getNumberMetadata(metadata: Record<string, unknown> | null | undefined, key: string): number | undefined {
    const value = metadata?.[key];
    return typeof value === 'number' ? value : undefined;
  }
}
