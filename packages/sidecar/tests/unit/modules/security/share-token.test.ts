import assert from "node:assert/strict";
import crypto from "node:crypto";
import { beforeEach, describe, test } from "node:test";

import { ShareTokenService } from "../../../../src/modules/web-companion/share-token.service.ts";
import type {
  CreateShareTokenRecordInput,
  LogShareAccessInput,
  ShareSessionRecord,
  ShareTokenRecord,
  ShareTokenRepository,
} from "../../../../src/modules/web-companion/share-token.service.ts";

const baseUrl = "http://localhost:5173";
const sessionId = "session_123";
const sessionToken = "valid_token";

class MemoryShareTokenRepository implements ShareTokenRepository {
  session: ShareSessionRecord | null = activeSession();
  shareToken: ShareTokenRecord | null = null;
  shareTokenHash = tokenHash("valid_token_123");
  bookIds = new Set(["book_789"]);
  incrementAllowed = true;
  revokeAllowed = true;
  createdTokens: CreateShareTokenRecordInput[] = [];
  bookRequests: Array<{ bookId: string; childId: string }> = [];
  shareTokenLookups: string[] = [];
  incrementInputs: Array<{ id: string; maxAccessCount?: number | null }> = [];
  accessLogs: LogShareAccessInput[] = [];
  expiredIds: string[] = [];
  revokedInputs: Array<{ shareTokenId: string; childId: string; sessionId: string }> = [];

  async findSessionByToken(input: { sessionId: string; tokenHash: string }) {
    if (
      !this.session ||
      input.sessionId !== this.session.sessionId ||
      input.tokenHash !== tokenHash(sessionToken)
    ) {
      return null;
    }
    return this.session;
  }

  async bookExistsForChild(input: { bookId: string; childId: string }) {
    this.bookRequests.push(input);
    return input.childId === "child_456" && this.bookIds.has(input.bookId);
  }

  async createShareToken(input: CreateShareTokenRecordInput) {
    this.createdTokens.push(input);
    return {
      id: input.id,
      childId: input.childId,
      expiresAt: input.expiresAt.toISOString(),
      accessType: input.accessType,
      resourceType: input.resourceType,
      resourceId: input.resourceId,
      accessCount: 0,
      maxAccessCount: input.maxAccessCount ?? null,
      status: "active",
    } satisfies ShareTokenRecord;
  }

  async findShareTokenByHash(hash: string) {
    this.shareTokenLookups.push(hash);
    return this.shareToken && hash === this.shareTokenHash ? this.shareToken : null;
  }

  async markShareTokenExpired(id: string) {
    this.expiredIds.push(id);
  }

  async incrementShareTokenAccessIfAllowed(input: {
    id: string;
    maxAccessCount?: number | null;
  }) {
    this.incrementInputs.push(input);
    return this.incrementAllowed;
  }

  async logShareAccess(input: LogShareAccessInput) {
    this.accessLogs.push(input);
  }

  async revokeShareTokenForSession(input: {
    shareTokenId: string;
    childId: string;
    sessionId: string;
  }) {
    this.revokedInputs.push(input);
    return this.revokeAllowed;
  }
}

describe("ShareTokenService", () => {
  let repository: MemoryShareTokenRepository;
  let service: ShareTokenService;

  beforeEach(() => {
    repository = new MemoryShareTokenRepository();
    service = new ShareTokenService(repository, baseUrl);
  });

  test("creates share tokens for child assets", async () => {
    const result = await service.createShareToken({
      sessionId,
      sessionToken,
      resourceType: "child_assets",
    });

    assert.equal(result.childId, "child_456");
    assert.equal(result.resourceType, "child_assets");
    assert.equal(result.accessType, "read_only");
    assert.match(result.shareUrl, /^http:\/\/localhost:5173\/share\/browse\?token=/);
    assert.equal(repository.createdTokens.length, 1);
    assert.equal(repository.createdTokens[0].childId, "child_456");
    assert.equal(repository.createdTokens[0].createdBySession, sessionId);
    assert.equal(repository.createdTokens[0].tokenHash, tokenHash(result.token));
  });

  test("creates share tokens for session-owned books", async () => {
    const result = await service.createShareToken({
      sessionId,
      sessionToken,
      resourceType: "specific_book",
      resourceId: "book_789",
    });

    assert.equal(result.resourceType, "specific_book");
    assert.equal(result.resourceId, "book_789");
    assert.match(result.shareUrl, /^http:\/\/localhost:5173\/share\/book\?/);
    assert.match(result.shareUrl, /bookId=book_789/);
    assert.deepEqual(repository.bookRequests, [
      { bookId: "book_789", childId: "child_456" },
    ]);
  });

  test("validates active share tokens and logs successful access", async () => {
    repository.shareToken = shareTokenRecord({
      id: "share_789",
      childId: "child_456",
      resourceType: "child_assets",
      accessCount: 5,
    });

    const result = await service.validateShareToken({
      token: "valid_token_123",
      clientIp: "192.168.1.1",
      userAgent: "Mozilla/5.0",
    });

    assert.equal(result.isValid, true);
    assert.equal(result.shareToken?.childId, "child_456");
    assert.equal(result.shareToken?.resourceType, "child_assets");
    assert.deepEqual(repository.shareTokenLookups, [tokenHash("valid_token_123")]);
    assert.deepEqual(repository.incrementInputs, [{ id: "share_789", maxAccessCount: null }]);
    assert.equal(repository.accessLogs[0].result, "success");
  });

  test("expires active records when share tokens are past their expiry", async () => {
    repository.shareToken = shareTokenRecord({
      id: "share_789",
      expiresAt: pastIso(),
    });

    const result = await service.validateShareToken({ token: "valid_token_123" });

    assert.equal(result.isValid, false);
    assert.equal(result.error, "Share token has expired");
    assert.deepEqual(repository.expiredIds, ["share_789"]);
    assert.equal(repository.accessLogs[0].result, "expired");
  });

  test("returns access-limit errors when the repository cannot increment access", async () => {
    repository.incrementAllowed = false;
    repository.shareToken = shareTokenRecord({
      id: "share_789",
      accessCount: 10,
      maxAccessCount: 10,
    });

    const result = await service.validateShareToken({ token: "valid_token_123" });

    assert.equal(result.isValid, false);
    assert.equal(result.error, "Share token access limit exceeded");
    assert.equal(repository.accessLogs[0].result, "rate_limited");
  });

  test("revokes share tokens through the repository session boundary", async () => {
    await service.revokeShareToken("share_789", sessionId, sessionToken);

    assert.deepEqual(repository.revokedInputs, [
      { shareTokenId: "share_789", childId: "child_456", sessionId },
    ]);
  });

  test("rejects invalid sessions before creating share tokens", async () => {
    repository.session = null;

    await assert.rejects(
      () => service.createShareToken({
        sessionId: "invalid_session",
        sessionToken: "invalid_token",
        resourceType: "child_assets",
      }),
      /Session not found/,
    );
  });

  test("rejects specific-book share tokens when the book is not session-owned", async () => {
    repository.bookIds.clear();

    await assert.rejects(
      () => service.createShareToken({
        sessionId,
        sessionToken,
        resourceType: "specific_book",
        resourceId: "missing_book",
      }),
      /Book not found/,
    );
  });

  test("generates unique secure tokens", async () => {
    const first = await service.createShareToken({
      sessionId,
      sessionToken,
      resourceType: "child_assets",
    });
    const second = await service.createShareToken({
      sessionId,
      sessionToken,
      resourceType: "child_assets",
    });

    assert.notEqual(first.token, second.token);
    assert(first.token.length >= 32);
    assert(second.token.length >= 32);
  });
});

function activeSession(overrides: Partial<ShareSessionRecord> = {}): ShareSessionRecord {
  return {
    sessionId,
    childId: "child_456",
    expiresAt: futureIso(),
    status: "active",
    ...overrides,
  };
}

function shareTokenRecord(overrides: Partial<ShareTokenRecord> = {}): ShareTokenRecord {
  return {
    id: "share_789",
    childId: "child_456",
    expiresAt: futureIso(),
    accessType: "read_only",
    resourceType: "child_assets",
    accessCount: 0,
    maxAccessCount: null,
    status: "active",
    ...overrides,
  };
}

function tokenHash(token: string): string {
  return crypto.createHash("sha256").update(token).digest("hex");
}

function futureIso(): string {
  return new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
}

function pastIso(): string {
  return new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
}
