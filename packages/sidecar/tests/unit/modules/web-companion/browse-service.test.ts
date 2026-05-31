import { describe, it, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { BrowseService } from '../../../../src/modules/web-companion/browse.service.ts';
import type {
  BrowseAssetRecord,
  BrowseBookRecord,
  BrowseRepository,
  SessionValidation,
} from '../../../../src/modules/web-companion/browse.service.ts';

class FakeBrowseRepository implements BrowseRepository {
  session: SessionValidation | null = {
    sessionId: 'session_123',
    childId: 'child_456',
    tokenHash: 'hash_abc',
    expiresAt: new Date(Date.now() + 3600000).toISOString(),
    status: 'active'
  };
  assets: BrowseAssetRecord[] = [
    {
      id: 'asset_1',
      title: 'Test Photo 1',
      type: 'image',
      createdAt: new Date().toISOString(),
      childId: 'child_456'
    },
    {
      id: 'asset_2',
      title: 'Test Photo 2',
      type: 'image',
      createdAt: new Date().toISOString(),
      childId: 'child_456'
    }
  ];
  books: BrowseBookRecord[] = [
    {
      id: 'book_1',
      title: 'My First Book',
      childId: 'child_456',
      createdAt: new Date().toISOString(),
      status: 'completed'
    }
  ];

  async findSessionByToken() {
    return this.session;
  }

  async findRecentAssets(input: { childId: string; limit: number }) {
    return this.assets
      .filter((asset) => asset.childId === input.childId)
      .slice(0, input.limit);
  }

  async findAssetForChild(input: { assetId: string; childId: string }) {
    return this.assets.find((candidate) => candidate.id === input.assetId && candidate.childId === input.childId) ?? null;
  }

  async findBooksForChild(childId: string) {
    return this.books.filter((book) => book.childId === childId);
  }

  async findBookForChild(input: { bookId: string; childId: string }) {
    return this.books.find((candidate) => candidate.id === input.bookId && candidate.childId === input.childId) ?? null;
  }

  async findShareTokenByHash() {
    return null;
  }
}

describe('BrowseService', () => {
  let browseService: BrowseService;
  let repository: FakeBrowseRepository;

  beforeEach(() => {
    repository = new FakeBrowseRepository();
    browseService = new BrowseService(repository);
  });

  describe('getRecentUploads', () => {
    it('should return recent uploads for valid session', async () => {
      const result = await browseService.getRecentUploads({
        sessionId: 'session_123',
        token: 'valid_token',
        limit: 10
      });

      assert.ok(Array.isArray(result));
      assert.equal(result.length, 2);
      assert.equal(result[0].id, 'asset_1');
      assert.equal(result[0].title, 'Test Photo 1');
    });

    it('should reject invalid session token', async () => {
      repository.session = null;

      await assert.rejects(
        () => browseService.getRecentUploads({
          sessionId: 'session_123',
          token: 'invalid_token',
          limit: 10
        }),
        /Session not found or token invalid/
      );
    });

    it('should filter assets by session child context', async () => {
      const result = await browseService.getRecentUploads({
        sessionId: 'session_123',
        token: 'valid_token',
        limit: 10
      });

      // All returned assets should belong to the session's child
      result.forEach(asset => {
        assert.equal(asset.childId, 'child_456');
      });
    });
  });

  describe('getAssetDetails', () => {
    it('should return asset details for session-owned asset', async () => {
      const result = await browseService.getAssetDetails({
        sessionId: 'session_123',
        token: 'valid_token',
        assetId: 'asset_1'
      });

      assert.equal(result.id, 'asset_1');
      assert.equal(result.title, 'Test Photo 1');
      assert.equal(result.type, 'image');
    });

    it('should reject access to assets not owned by session child', async () => {
      repository.assets = [{
        id: 'asset_1',
        title: 'Other Child Asset',
        type: 'image',
        childId: 'other_child',
        createdAt: new Date().toISOString()
      }];

      await assert.rejects(
        () => browseService.getAssetDetails({
          sessionId: 'session_123',
          token: 'valid_token',
          assetId: 'asset_1'
        }),
        /Asset not found or access denied/
      );
    });
  });

  describe('getBooksList', () => {
    it('should return books for session child', async () => {
      const result = await browseService.getBooksList({
        sessionId: 'session_123',
        token: 'valid_token'
      });

      assert.ok(Array.isArray(result));
      assert.equal(result.length, 1);
      assert.equal(result[0].id, 'book_1');
      assert.equal(result[0].title, 'My First Book');
    });

    it('should filter books by child when childId specified', async () => {
      const result = await browseService.getBooksList({
        sessionId: 'session_123',
        token: 'valid_token',
        childId: 'child_456'
      });

      result.forEach(book => {
        assert.equal(book.childId, 'child_456');
      });
    });
  });

  describe('getBookDetails', () => {
    it('should return book details for session-accessible book', async () => {
      const result = await browseService.getBookDetails({
        sessionId: 'session_123',
        token: 'valid_token',
        bookId: 'book_1'
      });

      assert.equal(result.id, 'book_1');
      assert.equal(result.title, 'My First Book');
      assert.equal(result.status, 'completed');
    });
  });

  describe('session validation', () => {
    it('should reject expired sessions', async () => {
      repository.session = {
        sessionId: 'session_123',
        childId: 'child_456',
        tokenHash: 'hash_abc',
        expiresAt: new Date(Date.now() - 3600000).toISOString(),
        status: 'active'
      };

      await assert.rejects(
        () => browseService.getRecentUploads({
          sessionId: 'session_123',
          token: 'valid_token',
          limit: 10
        }),
        /Session expired/
      );
    });

    it('should reject closed sessions', async () => {
      repository.session = {
        sessionId: 'session_123',
        childId: 'child_456',
        tokenHash: 'hash_abc',
        expiresAt: new Date(Date.now() + 3600000).toISOString(),
        status: 'closed'
      };

      await assert.rejects(
        () => browseService.getRecentUploads({
          sessionId: 'session_123',
          token: 'valid_token',
          limit: 10
        }),
        /Session not active/
      );
    });
  });
});
