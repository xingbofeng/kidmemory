import crypto from 'node:crypto';

export interface RecentUploadDto {
  id: string;
  title: string;
  type: string;
  childId: string;
  createdAt: string;
  previewUrl?: string;
}

export interface AssetDetailDto {
  id: string;
  title: string;
  type: string;
  childId: string;
  createdAt: string;
  description?: string;
  tags?: string[];
  previewUrl?: string;
  metadata?: Record<string, any>;
}

export interface BookSummaryDto {
  id: string;
  title: string;
  childId: string;
  createdAt: string;
  status: string;
  previewUrl?: string;
}

export interface BookDetailDto {
  id: string;
  title: string;
  childId: string;
  createdAt: string;
  status: string;
  description?: string;
  previewUrl?: string;
  pageCount?: number;
}

// Share-specific DTOs
export interface SharedAssetDto {
  id: string;
  title: string;
  type: string;
  createdAt: string;
  previewUrl?: string;
}

export interface SharedBookDto {
  id: string;
  title: string;
  createdAt: string;
  status: string;
  description?: string;
  previewUrl?: string;
  pageCount?: number;
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

// Share-specific inputs
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
  metadata?: Record<string, any> | null;
}

export interface BrowseBookRecord {
  id: string;
  title?: string | null;
  childId?: string | null;
  createdAt: string;
  status: string;
  metadata?: Record<string, any> | null;
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

    // Validate session and token
    const session = await this.validateSession(sessionId, token);

    // Validate and clamp limit
    const clampedLimit = this.validateLimit(limit);

    const assets = await this.repository.findRecentAssets({ childId: session.childId, limit: clampedLimit });

    return assets.map(row => ({
      id: row.id,
      title: row.title || 'Untitled',
      type: row.type,
      childId: row.childId || session.childId,
      createdAt: row.createdAt,
      previewUrl: this.generatePreviewUrl(row.id)
    }));
  }

  async getAssetDetails(input: GetAssetDetailsInput): Promise<AssetDetailDto> {
    const { sessionId, token, assetId } = input;

    // Validate session and token
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

    // Validate session and token
    const session = await this.validateSession(sessionId, token);

    // Use specified childId or default to session's child
    const targetChildId = childId || session.childId;

    // Ensure the requested childId matches the session's child for security
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

    // Validate session and token
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
      description: row.metadata?.description,
      previewUrl: this.generateBookPreviewUrl(row.id),
      pageCount: row.metadata?.pageCount
    };
  }

  // Share-specific methods
  async getSharedAssets(input: GetSharedAssetsInput): Promise<SharedAssetDto[]> {
    const { shareToken, limit = 20 } = input;

    // Validate share token and get context
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

    // Validate share token and get context
    const shareContext = await this.validateShareToken(shareToken);

    let targetBookId = bookId;

    // If share token is for a specific book, use that book ID
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
    // Hash the token for comparison
    const tokenHash = this.hashToken(token);

    const session = await this.repository.findSessionByToken({ sessionId, tokenHash });

    if (!session) {
      throw new Error('Session not found or token invalid');
    }

    // Check if session is expired
    const now = new Date();
    const expiresAt = new Date(session.expiresAt);
    if (now > expiresAt) {
      throw new Error('Session expired');
    }

    // Check if session is active
    if (session.status !== 'active') {
      throw new Error('Session not active');
    }

    return session;
  }

  private async validateShareToken(shareToken: string): Promise<ShareTokenValidation> {
    const tokenHash = this.hashToken(shareToken);

    const token = await this.repository.findShareTokenByHash(tokenHash);

    if (!token) {
      throw new Error('Share token not found');
    }

    // Check if token is active
    if (token.status !== 'active') {
      throw new Error('Share token has been revoked');
    }

    // Check expiration
    const now = new Date();
    const expiresAt = new Date(token.expiresAt);
    if (now > expiresAt) {
      throw new Error('Share token has expired');
    }

    // Check access count limit
    if (token.maxAccessCount && token.accessCount >= token.maxAccessCount) {
      throw new Error('Share token access limit exceeded');
    }

    return token;
  }

  private hashToken(token: string): string {
    return crypto.createHash('sha256').update(token).digest('hex');
  }

  private generatePreviewUrl(assetId: string): string {
    // Generate API-relative preview URL that doesn't expose local paths
    return `/api/assets/${assetId}/preview`;
  }

  private generateBookPreviewUrl(bookId: string): string {
    // Generate API-relative book preview URL
    return `/api/books/${bookId}/preview`;
  }

  private parseTags(tags: any): string[] {
    if (!tags) return [];

    // If it's already an array, return it
    if (Array.isArray(tags)) return tags;

    // If it's a string, try to parse as JSON
    if (typeof tags === 'string') {
      try {
        const parsed = JSON.parse(tags);
        return Array.isArray(parsed) ? parsed : [];
      } catch {
        // If JSON parsing fails, treat as a single tag
        return [tags];
      }
    }

    return [];
  }

  private validateLimit(limit: number): number {
    // Clamp limit between 1 and 100
    return Math.max(1, Math.min(100, limit));
  }
}
