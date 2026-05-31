import assert from "node:assert/strict";
import crypto from "node:crypto";
import { beforeEach, describe, test } from "node:test";

import { BrowseService } from "../../../../src/modules/web-companion/browse.service.ts";
import type {
  BrowseAssetRecord,
  BrowseBookRecord,
  BrowseRepository,
  SessionValidation,
  ShareTokenValidation,
} from "../../../../src/modules/web-companion/browse.service.ts";

const validSessionToken = "valid_token";
const validShareToken = "valid_share_token";

class MemoryBrowseRepository implements BrowseRepository {
  session: SessionValidation | null = activeSession();
  shareToken: ShareTokenValidation | null = null;
  shareTokenHash = tokenHash(validShareToken);
  assets: BrowseAssetRecord[] = [];
  books: BrowseBookRecord[] = [];
  recentAssetRequests: Array<{ childId: string; limit: number }> = [];
  bookListRequests: string[] = [];
  shareTokenLookups: string[] = [];

  async findSessionByToken(input: { sessionId: string; tokenHash: string }) {
    if (
      !this.session ||
      input.sessionId !== this.session.sessionId ||
      input.tokenHash !== this.session.tokenHash
    ) {
      return null;
    }
    return this.session;
  }

  async findRecentAssets(input: { childId: string; limit: number }) {
    this.recentAssetRequests.push(input);
    return this.assets
      .filter((asset) => asset.childId === input.childId)
      .slice(0, input.limit);
  }

  async findAssetForChild(input: { assetId: string; childId: string }) {
    return this.assets.find(
      (asset) => asset.id === input.assetId && asset.childId === input.childId,
    ) ?? null;
  }

  async findBooksForChild(childId: string) {
    this.bookListRequests.push(childId);
    return this.books.filter((book) => book.childId === childId);
  }

  async findBookForChild(input: { bookId: string; childId: string }) {
    return this.books.find(
      (book) => book.id === input.bookId && book.childId === input.childId,
    ) ?? null;
  }

  async findShareTokenByHash(hash: string) {
    this.shareTokenLookups.push(hash);
    return this.shareToken && hash === this.shareTokenHash ? this.shareToken : null;
  }
}

describe("BrowseService repository boundary", () => {
  let repository: MemoryBrowseRepository;
  let service: BrowseService;

  beforeEach(() => {
    repository = new MemoryBrowseRepository();
    service = new BrowseService(repository);
  });

  test("returns recent uploads inside the session child scope", async () => {
    repository.assets = [
      assetRecord({ id: "asset_1", title: "测试图片1", childId: "child_456" }),
      assetRecord({ id: "asset_2", title: "测试图片2", childId: "child_456" }),
      assetRecord({ id: "asset_3", title: "其他孩子", childId: "other_child" }),
    ];

    const result = await service.getRecentUploads({
      sessionId: "session_123",
      token: validSessionToken,
      limit: 10,
    });

    assert.equal(result.length, 2);
    assert.equal(result[0].id, "asset_1");
    assert.equal(result[0].childId, "child_456");
    assert.equal(result[0].previewUrl, "/assets/asset_1/preview");
    assert.deepEqual(repository.recentAssetRequests, [
      { childId: "child_456", limit: 10 },
    ]);
  });

  test("parses repository tag values into asset detail tags", async () => {
    const cases: Array<{ tags: unknown; expected: string[] }> = [
      { tags: null, expected: [] },
      { tags: "[\"家庭\", \"快乐\"]", expected: ["家庭", "快乐"] },
      { tags: "single_tag", expected: ["single_tag"] },
      { tags: ["array", "tags", 1], expected: ["array", "tags"] },
      { tags: "", expected: [] },
      { tags: "invalid_json[", expected: ["invalid_json["] },
    ];

    for (const { tags, expected } of cases) {
      repository.assets = [
        assetRecord({
          id: "asset_1",
          childId: "child_456",
          description: "测试描述",
          tags,
          metadata: { location: "公园" },
        }),
      ];

      const result = await service.getAssetDetails({
        sessionId: "session_123",
        token: validSessionToken,
        assetId: "asset_1",
      });

      assert.deepEqual(result.tags, expected);
      assert.equal(result.description, "测试描述");
      assert.deepEqual(result.metadata, { location: "公园" });
    }
  });

  test("clamps recent upload limits before querying the repository", async () => {
    await service.getRecentUploads({
      sessionId: "session_123",
      token: validSessionToken,
      limit: 200,
    });
    await service.getRecentUploads({
      sessionId: "session_123",
      token: validSessionToken,
      limit: -5,
    });

    assert.deepEqual(repository.recentAssetRequests.map((request) => request.limit), [100, 1]);
  });

  test("rejects cross-child book filters before querying books", async () => {
    await assert.rejects(
      () => service.getBooksList({
        sessionId: "session_123",
        token: validSessionToken,
        childId: "other_child",
      }),
      /Access denied to specified child/,
    );

    assert.deepEqual(repository.bookListRequests, []);
  });

  test("uses share-token child scope for shared assets", async () => {
    repository.shareToken = activeShareToken({ resourceType: "child_assets" });
    repository.assets = [
      assetRecord({ id: "asset_1", title: "分享的图片", childId: "child_456" }),
      assetRecord({ id: "asset_2", title: "其他孩子", childId: "other_child" }),
    ];

    const result = await service.getSharedAssets({
      shareToken: validShareToken,
      limit: 10,
    });

    assert.equal(result.length, 1);
    assert.equal(result[0].id, "asset_1");
    assert.equal(result[0].previewUrl, "/assets/asset_1/preview");
    assert.deepEqual(repository.shareTokenLookups, [tokenHash(validShareToken)]);
    assert.deepEqual(repository.recentAssetRequests, [
      { childId: "child_456", limit: 10 },
    ]);
  });

  test("rejects book-only share tokens when requesting shared assets", async () => {
    repository.shareTokenHash = tokenHash("book_share_token");
    repository.shareToken = activeShareToken({
      resourceType: "specific_book",
      resourceId: "book_123",
    });

    await assert.rejects(
      () => service.getSharedAssets({ shareToken: "book_share_token" }),
      /This share token is for a specific book, not assets/,
    );
  });
});

function activeSession(overrides: Partial<SessionValidation> = {}): SessionValidation {
  return {
    sessionId: "session_123",
    childId: "child_456",
    tokenHash: tokenHash(validSessionToken),
    expiresAt: futureIso(),
    status: "active",
    ...overrides,
  };
}

function activeShareToken(overrides: Partial<ShareTokenValidation> = {}): ShareTokenValidation {
  return {
    childId: "child_456",
    resourceType: "child_assets",
    accessType: "read_only",
    expiresAt: futureIso(),
    status: "active",
    accessCount: 0,
    maxAccessCount: null,
    ...overrides,
  };
}

function assetRecord(overrides: Partial<BrowseAssetRecord> = {}): BrowseAssetRecord {
  return {
    id: "asset_1",
    title: "测试图片",
    type: "image",
    childId: "child_456",
    createdAt: "2026-05-15T10:30:00Z",
    metadata: {},
    ...overrides,
  };
}

function tokenHash(token: string): string {
  return crypto.createHash("sha256").update(token).digest("hex");
}

function futureIso(): string {
  return new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
}
