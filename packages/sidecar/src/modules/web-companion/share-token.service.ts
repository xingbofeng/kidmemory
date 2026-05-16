import crypto from "node:crypto";
import { ShareIpLimiterService } from "./share-ip-limiter.service.ts";

export interface ShareTokenDto {
  id: string;
  token: string;
  childId: string;
  expiresAt: string;
  accessType: "read_only" | "time_limited";
  resourceType: "child_assets" | "specific_book" | "asset_collection";
  resourceId?: string;
  maxAccessCount?: number;
  shareUrl: string;
}

export interface CreateShareTokenInput {
  sessionId: string;
  sessionToken: string;
  childId?: string;
  resourceType: "child_assets" | "specific_book" | "asset_collection";
  resourceId?: string;
  expiresInHours?: number;
  maxAccessCount?: number;
  accessType?: "read_only" | "time_limited";
}

export interface ValidateShareTokenInput {
  token: string;
  clientIp?: string;
  userAgent?: string;
}

export interface ShareTokenValidation {
  isValid: boolean;
  shareToken?: {
    id: string;
    childId: string;
    resourceType: string;
    resourceId?: string;
    accessType: string;
  };
  error?: string;
}

export interface ShareSessionRecord {
  sessionId: string;
  childId: string;
  expiresAt: string;
  status: string;
}

export interface ShareTokenRecord {
  id: string;
  childId: string;
  expiresAt: string;
  accessType: "read_only" | "time_limited";
  resourceType: "child_assets" | "specific_book" | "asset_collection";
  resourceId?: string;
  accessCount: number;
  maxAccessCount?: number | null;
  status: string;
}

export interface CreateShareTokenRecordInput {
  id: string;
  tokenHash: string;
  childId: string;
  createdBySession: string;
  expiresAt: Date;
  accessType: "read_only" | "time_limited";
  resourceType: "child_assets" | "specific_book" | "asset_collection";
  resourceId?: string;
  maxAccessCount?: number;
}

export interface LogShareAccessInput {
  id: string;
  shareTokenId: string;
  result: string;
  clientIp?: string;
  userAgent?: string;
  resourceAccessed?: string;
}

export interface ShareTokenRepository {
  findSessionByToken(input: { sessionId: string; tokenHash: string }): Promise<ShareSessionRecord | null>;
  bookExistsForChild(input: { bookId: string; childId: string }): Promise<boolean>;
  createShareToken(input: CreateShareTokenRecordInput): Promise<ShareTokenRecord>;
  findShareTokenByHash(tokenHash: string): Promise<ShareTokenRecord | null>;
  markShareTokenExpired(id: string): Promise<void>;
  incrementShareTokenAccess(id: string): Promise<void>;
  logShareAccess(input: LogShareAccessInput): Promise<void>;
  revokeShareTokenForSession(input: { shareTokenId: string; childId: string; sessionId: string }): Promise<boolean>;
}

export class ShareTokenService {
  private readonly repository: ShareTokenRepository;
  private readonly baseUrl: string;
  private readonly ipLimiter: ShareIpLimiterService;

  constructor(
    repository: ShareTokenRepository, 
    baseUrl: string = "http://localhost:5173",
    ipLimiter?: ShareIpLimiterService
  ) {
    this.repository = repository;
    this.baseUrl = baseUrl;
    this.ipLimiter = ipLimiter || new ShareIpLimiterService();
  }

  async createShareToken(input: CreateShareTokenInput): Promise<ShareTokenDto> {
    const {
      sessionId,
      sessionToken,
      childId,
      resourceType,
      resourceId,
      expiresInHours = 24,
      maxAccessCount,
      accessType = "read_only",
    } = input;

    const session = await this.validateSession(sessionId, sessionToken);
    const targetChildId = childId || session.childId;

    if (targetChildId !== session.childId) {
      throw new Error("Cannot create share token for different child");
    }

    if (resourceType === "specific_book" && resourceId) {
      await this.validateBookAccess(resourceId, targetChildId);
    }

    const token = this.generateSecureToken();
    const shareToken = await this.repository.createShareToken({
      id: this.generateId("share"),
      tokenHash: this.hashToken(token),
      childId: targetChildId,
      createdBySession: sessionId,
      expiresAt: new Date(Date.now() + expiresInHours * 60 * 60 * 1000),
      accessType,
      resourceType,
      resourceId,
      maxAccessCount,
    });

    return {
      id: shareToken.id,
      token,
      childId: shareToken.childId,
      expiresAt: shareToken.expiresAt,
      accessType: shareToken.accessType,
      resourceType: shareToken.resourceType,
      resourceId: shareToken.resourceId,
      maxAccessCount: shareToken.maxAccessCount || undefined,
      shareUrl: this.generateShareUrl(token, resourceType, resourceId),
    };
  }

  async validateShareToken(input: ValidateShareTokenInput): Promise<ShareTokenValidation> {
    const { token, clientIp, userAgent } = input;

    try {
      // Check IP rate limit first
      if (clientIp && !this.ipLimiter.checkLimit(clientIp)) {
        const blockedTime = this.ipLimiter.getBlockedTimeRemaining(clientIp);
        return { 
          isValid: false, 
          error: `Too many requests from this IP. Please try again in ${blockedTime} seconds.` 
        };
      }

      const shareToken = await this.repository.findShareTokenByHash(this.hashToken(token));

      if (!shareToken) {
        return { isValid: false, error: "Share token not found" };
      }

      if (shareToken.status !== "active") {
        await this.logAccess(shareToken.id, "revoked", clientIp, userAgent);
        return { isValid: false, error: "Share token has been revoked" };
      }

      const now = new Date();
      const expiresAt = new Date(shareToken.expiresAt);
      if (now > expiresAt) {
        await this.repository.markShareTokenExpired(shareToken.id);
        await this.logAccess(shareToken.id, "expired", clientIp, userAgent);
        return { isValid: false, error: "Share token has expired" };
      }

      if (shareToken.maxAccessCount && shareToken.accessCount >= shareToken.maxAccessCount) {
        await this.logAccess(shareToken.id, "rate_limited", clientIp, userAgent);
        return { isValid: false, error: "Share token access limit exceeded" };
      }

      await this.repository.incrementShareTokenAccess(shareToken.id);
      await this.logAccess(shareToken.id, "success", clientIp, userAgent);

      return {
        isValid: true,
        shareToken: {
          id: shareToken.id,
          childId: shareToken.childId,
          resourceType: shareToken.resourceType,
          resourceId: shareToken.resourceId,
          accessType: shareToken.accessType,
        },
      };
    } catch (error) {
      console.error("Share token validation error:", error);
      return { isValid: false, error: "Token validation failed" };
    }
  }

  async revokeShareToken(shareTokenId: string, sessionId: string, sessionToken: string): Promise<void> {
    const session = await this.validateSession(sessionId, sessionToken);
    const revoked = await this.repository.revokeShareTokenForSession({
      shareTokenId,
      childId: session.childId,
      sessionId,
    });

    if (!revoked) {
      throw new Error("Share token not found or access denied");
    }
  }

  private async validateSession(sessionId: string, token: string): Promise<ShareSessionRecord> {
    const session = await this.repository.findSessionByToken({
      sessionId,
      tokenHash: this.hashToken(token),
    });

    if (!session) {
      throw new Error("Session not found or token invalid");
    }

    if (session.status !== "active") {
      throw new Error("Session not active");
    }

    if (new Date() > new Date(session.expiresAt)) {
      throw new Error("Session expired");
    }

    return session;
  }

  private async validateBookAccess(bookId: string, childId: string): Promise<void> {
    const exists = await this.repository.bookExistsForChild({ bookId, childId });
    if (!exists) {
      throw new Error("Book not found or access denied");
    }
  }

  private async logAccess(
    shareTokenId: string,
    result: string,
    clientIp?: string,
    userAgent?: string,
    resourceAccessed?: string,
  ): Promise<void> {
    await this.repository.logShareAccess({
      id: this.generateId("log"),
      shareTokenId,
      clientIp,
      userAgent,
      result,
      resourceAccessed,
    });
  }

  private generateSecureToken(): string {
    return crypto.randomBytes(32).toString("base64url");
  }

  private hashToken(token: string): string {
    return crypto.createHash("sha256").update(token).digest("hex");
  }

  private generateId(prefix: string): string {
    return `${prefix}_${Date.now()}_${crypto.randomBytes(4).toString("hex")}`;
  }

  private generateShareUrl(token: string, resourceType: string, resourceId?: string): string {
    const params = new URLSearchParams({ token });

    if (resourceType === "specific_book" && resourceId) {
      params.set("bookId", resourceId);
      return `${this.baseUrl}/share/book?${params.toString()}`;
    }

    if (resourceType === "asset_collection" && resourceId) {
      params.set("collectionId", resourceId);
      return `${this.baseUrl}/share/collection?${params.toString()}`;
    }

    return `${this.baseUrl}/share/browse?${params.toString()}`;
  }
}
