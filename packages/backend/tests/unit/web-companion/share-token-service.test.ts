import { beforeEach, describe, it } from "node:test";
import assert from "node:assert/strict";

import { ShareTokenService } from "../../../src/modules/web-companion/share-token.service.ts";
import type {
  CreateShareTokenRecordInput,
  LogShareAccessInput,
  ShareSessionRecord,
  ShareTokenRecord,
  ShareTokenRepository,
} from "../../../src/modules/web-companion/share-token.service.ts";

class FakeShareTokenRepository implements ShareTokenRepository {
  session: ShareSessionRecord | null = {
    sessionId: "session_123",
    childId: "child_456",
    expiresAt: new Date(Date.now() + 3600000).toISOString(),
    status: "active",
  };
  bookExists = true;
  shareToken: ShareTokenRecord | null = {
    id: "share_123",
    childId: "child_456",
    expiresAt: new Date(Date.now() + 24 * 3600000).toISOString(),
    accessType: "read_only",
    resourceType: "child_assets",
    accessCount: 0,
    maxAccessCount: null,
    status: "active",
  };
  createdTokens: CreateShareTokenRecordInput[] = [];
  accessLogs: LogShareAccessInput[] = [];
  expiredTokenIds: string[] = [];
  incrementedTokenIds: string[] = [];
  revokeResult = true;
  revokeInputs: Array<{ shareTokenId: string; childId: string; sessionId: string }> = [];

  async findSessionByToken(): Promise<ShareSessionRecord | null> {
    return this.session;
  }

  async bookExistsForChild(): Promise<boolean> {
    return this.bookExists;
  }

  async createShareToken(input: CreateShareTokenRecordInput): Promise<ShareTokenRecord> {
    this.createdTokens.push(input);
    return {
      id: "share_123",
      childId: input.childId,
      expiresAt: input.expiresAt.toISOString(),
      accessType: input.accessType,
      resourceType: input.resourceType,
      resourceId: input.resourceId,
      accessCount: 0,
      maxAccessCount: input.maxAccessCount ?? null,
      status: "active",
    };
  }

  async findShareTokenByHash(): Promise<ShareTokenRecord | null> {
    return this.shareToken;
  }

  async markShareTokenExpired(id: string): Promise<void> {
    this.expiredTokenIds.push(id);
  }

  async incrementShareTokenAccess(id: string): Promise<void> {
    this.incrementedTokenIds.push(id);
  }

  async logShareAccess(input: LogShareAccessInput): Promise<void> {
    this.accessLogs.push(input);
  }

  async revokeShareTokenForSession(input: { shareTokenId: string; childId: string; sessionId: string }): Promise<boolean> {
    this.revokeInputs.push(input);
    return this.revokeResult;
  }
}

describe("ShareTokenService", () => {
  let shareTokenService: ShareTokenService;
  let repository: FakeShareTokenRepository;

  beforeEach(() => {
    repository = new FakeShareTokenRepository();
    shareTokenService = new ShareTokenService(repository, "http://localhost:5173");
  });

  describe("createShareToken", () => {
    it("should create share token for child assets", async () => {
      const result = await shareTokenService.createShareToken({
        sessionId: "session_123",
        sessionToken: "valid_token",
        resourceType: "child_assets",
        expiresInHours: 24,
      });

      assert.ok(result.id);
      assert.ok(result.token);
      assert.equal(result.childId, "child_456");
      assert.equal(result.resourceType, "child_assets");
      assert.equal(result.accessType, "read_only");
      assert.ok(result.shareUrl.includes("share/browse"));
      assert.equal(repository.createdTokens.length, 1);
      assert.equal(repository.createdTokens[0].createdBySession, "session_123");
    });

    it("should create share token for specific book", async () => {
      const result = await shareTokenService.createShareToken({
        sessionId: "session_123",
        sessionToken: "valid_token",
        resourceType: "specific_book",
        resourceId: "book_1",
        expiresInHours: 48,
      });

      assert.equal(result.resourceType, "specific_book");
      assert.equal(result.resourceId, "book_1");
      assert.ok(result.shareUrl.includes("share/book"));
      assert.ok(result.shareUrl.includes("bookId=book_1"));
    });

    it("should reject creating token for different child", async () => {
      await assert.rejects(
        () => shareTokenService.createShareToken({
          sessionId: "session_123",
          sessionToken: "valid_token",
          childId: "other_child",
          resourceType: "child_assets",
        }),
        /Cannot create share token for different child/,
      );
    });

    it("should validate book access when creating book share token", async () => {
      repository.bookExists = false;

      await assert.rejects(
        () => shareTokenService.createShareToken({
          sessionId: "session_123",
          sessionToken: "valid_token",
          resourceType: "specific_book",
          resourceId: "nonexistent_book",
        }),
        /Book not found or access denied/,
      );
    });
  });

  describe("validateShareToken", () => {
    it("should validate active share token", async () => {
      const result = await shareTokenService.validateShareToken({
        token: "valid_token",
        clientIp: "127.0.0.1",
        userAgent: "test-agent",
      });

      assert.equal(result.isValid, true);
      assert.ok(result.shareToken);
      assert.equal(result.shareToken.childId, "child_456");
      assert.equal(result.shareToken.resourceType, "child_assets");
      assert.deepEqual(repository.incrementedTokenIds, ["share_123"]);
      assert.equal(repository.accessLogs[0].result, "success");
    });

    it("should reject non-existent token", async () => {
      repository.shareToken = null;

      const result = await shareTokenService.validateShareToken({
        token: "invalid_token",
      });

      assert.equal(result.isValid, false);
      assert.equal(result.error, "Share token not found");
    });

    it("should reject expired token", async () => {
      repository.shareToken = {
        ...repository.shareToken!,
        expiresAt: new Date(Date.now() - 3600000).toISOString(),
      };

      const result = await shareTokenService.validateShareToken({
        token: "expired_token",
      });

      assert.equal(result.isValid, false);
      assert.equal(result.error, "Share token has expired");
      assert.deepEqual(repository.expiredTokenIds, ["share_123"]);
      assert.equal(repository.accessLogs[0].result, "expired");
    });

    it("should reject revoked token", async () => {
      repository.shareToken = {
        ...repository.shareToken!,
        status: "revoked",
      };

      const result = await shareTokenService.validateShareToken({
        token: "revoked_token",
      });

      assert.equal(result.isValid, false);
      assert.equal(result.error, "Share token has been revoked");
      assert.equal(repository.accessLogs[0].result, "revoked");
    });

    it("should reject token that exceeded access limit", async () => {
      repository.shareToken = {
        ...repository.shareToken!,
        accessCount: 10,
        maxAccessCount: 10,
      };

      const result = await shareTokenService.validateShareToken({
        token: "limited_token",
      });

      assert.equal(result.isValid, false);
      assert.equal(result.error, "Share token access limit exceeded");
      assert.equal(repository.accessLogs[0].result, "rate_limited");
    });
  });

  describe("revokeShareToken", () => {
    it("should revoke share token created by session", async () => {
      await assert.doesNotReject(
        () => shareTokenService.revokeShareToken(
          "share_123",
          "session_123",
          "valid_token",
        ),
      );

      assert.deepEqual(repository.revokeInputs, [{
        shareTokenId: "share_123",
        childId: "child_456",
        sessionId: "session_123",
      }]);
    });

    it("should reject revoking token not owned by session", async () => {
      repository.revokeResult = false;

      await assert.rejects(
        () => shareTokenService.revokeShareToken(
          "other_share_token",
          "session_123",
          "valid_token",
        ),
        /Share token not found or access denied/,
      );
    });
  });

  describe("security features", () => {
    it("should generate cryptographically secure tokens", async () => {
      const result1 = await shareTokenService.createShareToken({
        sessionId: "session_123",
        sessionToken: "valid_token",
        resourceType: "child_assets",
      });

      const result2 = await shareTokenService.createShareToken({
        sessionId: "session_123",
        sessionToken: "valid_token",
        resourceType: "child_assets",
      });

      assert.notEqual(result1.token, result2.token);
      assert.ok(result1.token.length >= 32);
      assert.ok(result2.token.length >= 32);
    });

    it("should log access attempts for audit trail", async () => {
      await shareTokenService.validateShareToken({
        token: "valid_token",
        clientIp: "192.168.1.1",
        userAgent: "Mozilla/5.0",
      });

      assert.equal(repository.accessLogs.length, 1);
      assert.equal(repository.accessLogs[0].clientIp, "192.168.1.1");
      assert.equal(repository.accessLogs[0].userAgent, "Mozilla/5.0");
    });
  });
});
