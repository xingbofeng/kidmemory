import { strict as assert } from "node:assert";
import { test, describe } from "node:test";
import crypto from "node:crypto";

import { BrowseService } from "../../src/modules/web-companion/browse.service.ts";
import type { BrowseRepository } from "../../src/modules/web-companion/browse.service.ts";

// Mock database client for testing
class MockBrowseRepository implements BrowseRepository {
  private queries: Array<{ sql: string; params?: unknown[] }> = [];
  private mockResults: Map<string, any> = new Map();
  private shouldFail: Set<string> = new Set();

  query(sql: string, params?: unknown[]) {
    this.queries.push({ sql, params });

    // Check if this query should fail
    const normalizedSql = sql.trim().toLowerCase();
    if (this.shouldFail.has(normalizedSql)) {
      throw new Error(`Mock database error for: ${sql}`);
    }

    // Return mock result if available
    const key = this.getMockKey(sql);
    if (this.mockResults.has(key)) {
      return Promise.resolve(this.mockResults.get(key));
    }

    // Default empty result
    return Promise.resolve({ rows: [], rowCount: 0 });
  }

  async findSessionByToken(input: { sessionId: string; tokenHash: string }) {
    this.queries.push({ sql: "select * from web_companion_upload_sessions where id = $1 and token_hash = $2", params: [input.sessionId, input.tokenHash] });
    const result = this.mockResults.get("select_session") || { rows: [] };
    const row = result.rows[0];
    return row ? {
      sessionId: row.id,
      childId: row.child_id,
      tokenHash: row.token_hash,
      expiresAt: row.expires_at,
      status: row.status,
    } : null;
  }

  async findRecentAssets(input: { childId: string; limit: number }) {
    this.queries.push({ sql: "SELECT * FROM assets a WHERE a.child_id = $1 ORDER BY a.created_at DESC LIMIT $2", params: [input.childId, input.limit] });
    const result = this.mockResults.get("select_recent_assets") || { rows: [] };
    return result.rows.map((row: any) => ({
      id: row.id,
      title: row.title,
      type: row.type,
      childId: row.child_id,
      createdAt: row.created_at,
      description: row.description,
      tags: row.tags,
      metadata: row.metadata,
    }));
  }

  async findAssetForChild(input: { assetId: string; childId: string }) {
    this.queries.push({ sql: "select * from assets a where a.id = $1 and a.child_id = $2", params: [input.assetId, input.childId] });
    const result = this.mockResults.get("select_asset_details") || { rows: [] };
    const row = result.rows[0];
    return row ? {
      id: row.id,
      title: row.title,
      type: row.type,
      childId: row.child_id,
      createdAt: row.created_at,
      description: row.description,
      tags: row.tags,
      metadata: row.metadata,
    } : null;
  }

  async findBooksForChild(childId: string) {
    this.queries.push({ sql: "select * from books b where b.child_id = $1 ORDER BY b.created_at DESC", params: [childId] });
    const result = this.mockResults.get("select_books_list") || { rows: [] };
    return result.rows.map((row: any) => ({
      id: row.id,
      title: row.title,
      childId: row.child_id,
      createdAt: row.created_at,
      status: row.status,
      metadata: row.metadata,
    }));
  }

  async findBookForChild(input: { bookId: string; childId: string }) {
    this.queries.push({ sql: "select * from books b where b.id = $1 and b.child_id = $2", params: [input.bookId, input.childId] });
    const result = this.mockResults.get("select_book_details") || { rows: [] };
    const row = result.rows[0];
    return row ? {
      id: row.id,
      title: row.title,
      childId: row.child_id,
      createdAt: row.created_at,
      status: row.status,
      metadata: row.metadata,
    } : null;
  }

  async findShareTokenByHash(tokenHash: string) {
    this.queries.push({ sql: "select * from share_tokens where token_hash = $1", params: [tokenHash] });
    const result = this.mockResults.get("select_share_token") || { rows: [] };
    const row = result.rows[0];
    return row ? {
      childId: row.child_id,
      resourceType: row.resource_type,
      resourceId: row.resource_id || undefined,
      accessType: row.access_type,
      expiresAt: row.expires_at,
      status: row.status,
      accessCount: row.access_count,
      maxAccessCount: row.max_access_count,
    } : null;
  }

  // Test helpers
  getQueries() {
    return [...this.queries];
  }

  clearQueries() {
    this.queries = [];
  }

  setMockResult(sqlPattern: string, result: any) {
    this.mockResults.set(sqlPattern, result);
  }

  setShouldFail(sqlPattern: string) {
    this.shouldFail.add(sqlPattern);
  }

  private getMockKey(sql: string): string {
    const normalized = sql.trim().toLowerCase();
    if (normalized.includes('select') && normalized.includes('web_companion_upload_sessions')) {
      return 'select_session';
    }
    if (normalized.includes('select') && normalized.includes('assets') && normalized.includes('order by')) {
      return 'select_recent_assets';
    }
    if (normalized.includes('select') && normalized.includes('assets') && normalized.includes('where a.id')) {
      return 'select_asset_details';
    }
    if (normalized.includes('select') && normalized.includes('books') && normalized.includes('order by')) {
      return 'select_books_list';
    }
    if (normalized.includes('select') && normalized.includes('books') && normalized.includes('where b.id')) {
      return 'select_book_details';
    }
    if (normalized.includes('select') && normalized.includes('share_tokens')) {
      return 'select_share_token';
    }
    return 'default';
  }
}

describe("BrowseService", () => {
  test("should get recent uploads for valid session", async () => {
    const mockDb = new MockBrowseRepository();
    const service = new BrowseService(mockDb as any);

    // Mock valid session
    mockDb.setMockResult('select_session', {
      rows: [{
        id: 'session_123',
        child_id: 'child_456',
        token_hash: crypto.createHash('sha256').update('valid_token').digest('hex'),
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        status: 'active'
      }]
    });

    // Mock recent assets
    mockDb.setMockResult('select_recent_assets', {
      rows: [
        {
          id: 'asset_1',
          title: '测试图片1',
          type: 'image',
          child_id: 'child_456',
          created_at: '2026-05-15T10:30:00Z',
          metadata: {}
        },
        {
          id: 'asset_2',
          title: '测试图片2',
          type: 'image',
          child_id: 'child_456',
          created_at: '2026-05-14T15:20:00Z',
          metadata: {}
        }
      ]
    });

    const result = await service.getRecentUploads({
      sessionId: 'session_123',
      token: 'valid_token',
      limit: 10
    });

    assert.equal(result.length, 2);
    assert.equal(result[0].id, 'asset_1');
    assert.equal(result[0].title, '测试图片1');
    assert.equal(result[0].childId, 'child_456');
    assert(result[0].previewUrl.includes('/api/assets/asset_1/preview'));

    const queries = mockDb.getQueries();
    assert(queries.some(q => q.sql.includes('web_companion_upload_sessions')));
    assert(queries.some(q => q.sql.includes('ORDER BY a.created_at DESC')));
  });

  test("should enforce child scope for recent uploads", async () => {
    const mockDb = new MockBrowseRepository();
    const service = new BrowseService(mockDb as any);

    // Mock valid session for child_456
    mockDb.setMockResult('select_session', {
      rows: [{
        id: 'session_123',
        child_id: 'child_456',
        token_hash: crypto.createHash('sha256').update('valid_token').digest('hex'),
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        status: 'active'
      }]
    });

    // Mock assets - should only return assets for child_456
    mockDb.setMockResult('select_recent_assets', {
      rows: [
        {
          id: 'asset_1',
          title: '测试图片1',
          type: 'image',
          child_id: 'child_456',
          created_at: '2026-05-15T10:30:00Z',
          metadata: {}
        }
      ]
    });

    await service.getRecentUploads({
      sessionId: 'session_123',
      token: 'valid_token'
    });

    const queries = mockDb.getQueries();
    const assetQuery = queries.find(q => q.sql.includes('FROM assets a'));
    assert(assetQuery);
    assert.equal(assetQuery.params?.[0], 'child_456'); // Should query only session's child
  });

  test("should get asset details with proper tags parsing", async () => {
    const mockDb = new MockBrowseRepository();
    const service = new BrowseService(mockDb as any);

    // Mock valid session
    mockDb.setMockResult('select_session', {
      rows: [{
        id: 'session_123',
        child_id: 'child_456',
        token_hash: crypto.createHash('sha256').update('valid_token').digest('hex'),
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        status: 'active'
      }]
    });

    // Mock asset with JSON tags
    mockDb.setMockResult('select_asset_details', {
      rows: [{
        id: 'asset_1',
        title: '测试图片',
        type: 'image',
        child_id: 'child_456',
        created_at: '2026-05-15T10:30:00Z',
        description: '测试描述',
        tags: '["家庭", "快乐", "成长"]',
        metadata: { location: '公园' }
      }]
    });

    const result = await service.getAssetDetails({
      sessionId: 'session_123',
      token: 'valid_token',
      assetId: 'asset_1'
    });

    assert.equal(result.id, 'asset_1');
    assert.equal(result.title, '测试图片');
    assert.deepEqual(result.tags, ['家庭', '快乐', '成长']);
    assert.equal(result.description, '测试描述');
    assert.deepEqual(result.metadata, { location: '公园' });
  });

  test("should handle different tag formats", async () => {
    const mockDb = new MockBrowseRepository();
    const service = new BrowseService(mockDb as any);

    // Mock valid session
    mockDb.setMockResult('select_session', {
      rows: [{
        id: 'session_123',
        child_id: 'child_456',
        token_hash: crypto.createHash('sha256').update('valid_token').digest('hex'),
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        status: 'active'
      }]
    });

    // Test cases for different tag formats
    const testCases = [
      { tags: null, expected: [] },
      { tags: '["tag1", "tag2"]', expected: ['tag1', 'tag2'] },
      { tags: 'single_tag', expected: ['single_tag'] },
      { tags: ['array', 'tags'], expected: ['array', 'tags'] },
      { tags: '', expected: [] },
      { tags: 'invalid_json[', expected: ['invalid_json['] }
    ];

    for (const testCase of testCases) {
      mockDb.clearQueries();
      mockDb.setMockResult('select_asset_details', {
        rows: [{
          id: 'asset_1',
          title: '测试图片',
          type: 'image',
          child_id: 'child_456',
          created_at: '2026-05-15T10:30:00Z',
          description: '测试描述',
          tags: testCase.tags,
          metadata: {}
        }]
      });

      const result = await service.getAssetDetails({
        sessionId: 'session_123',
        token: 'valid_token',
        assetId: 'asset_1'
      });

      assert.deepEqual(result.tags, testCase.expected,
        `Failed for tags: ${JSON.stringify(testCase.tags)}`);
    }
  });

  test("should reject cross-child asset access", async () => {
    const mockDb = new MockBrowseRepository();
    const service = new BrowseService(mockDb as any);

    // Mock valid session for child_456
    mockDb.setMockResult('select_session', {
      rows: [{
        id: 'session_123',
        child_id: 'child_456',
        token_hash: crypto.createHash('sha256').update('valid_token').digest('hex'),
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        status: 'active'
      }]
    });

    // Mock no asset found (because it belongs to different child)
    mockDb.setMockResult('select_asset_details', { rows: [] });

    try {
      await service.getAssetDetails({
        sessionId: 'session_123',
        token: 'valid_token',
        assetId: 'asset_from_different_child'
      });
      assert.fail('Should have thrown an error');
    } catch (error) {
      assert(error instanceof Error);
      assert(error.message.includes('Asset not found or access denied'));
    }
  });

  test("should validate and clamp limits", async () => {
    const mockDb = new MockBrowseRepository();
    const service = new BrowseService(mockDb as any);

    // Mock valid session
    mockDb.setMockResult('select_session', {
      rows: [{
        id: 'session_123',
        child_id: 'child_456',
        token_hash: crypto.createHash('sha256').update('valid_token').digest('hex'),
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        status: 'active'
      }]
    });

    mockDb.setMockResult('select_recent_assets', { rows: [] });

    // Test limit clamping
    await service.getRecentUploads({
      sessionId: 'session_123',
      token: 'valid_token',
      limit: 200 // Should be clamped to 100
    });

    const queries = mockDb.getQueries();
    const assetQuery = queries.find(q => q.sql.includes('LIMIT'));
    assert(assetQuery);
    assert.equal(assetQuery.params?.[1], 100); // Should be clamped to 100

    mockDb.clearQueries();

    await service.getRecentUploads({
      sessionId: 'session_123',
      token: 'valid_token',
      limit: -5 // Should be clamped to 1
    });

    const queries2 = mockDb.getQueries();
    const assetQuery2 = queries2.find(q => q.sql.includes('LIMIT'));
    assert(assetQuery2);
    assert.equal(assetQuery2.params?.[1], 1); // Should be clamped to 1
  });

  test("should get books list for session child", async () => {
    const mockDb = new MockBrowseRepository();
    const service = new BrowseService(mockDb as any);

    // Mock valid session
    mockDb.setMockResult('select_session', {
      rows: [{
        id: 'session_123',
        child_id: 'child_456',
        token_hash: crypto.createHash('sha256').update('valid_token').digest('hex'),
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        status: 'active'
      }]
    });

    // Mock books
    mockDb.setMockResult('select_books_list', {
      rows: [
        {
          id: 'book_1',
          title: '我的成长故事',
          child_id: 'child_456',
          created_at: '2026-05-15T10:30:00Z',
          status: 'completed'
        }
      ]
    });

    const result = await service.getBooksList({
      sessionId: 'session_123',
      token: 'valid_token'
    });

    assert.equal(result.length, 1);
    assert.equal(result[0].id, 'book_1');
    assert.equal(result[0].title, '我的成长故事');
    assert.equal(result[0].childId, 'child_456');
    assert(result[0].previewUrl.includes('/api/books/book_1/preview'));
  });

  test("should reject cross-child books access", async () => {
    const mockDb = new MockBrowseRepository();
    const service = new BrowseService(mockDb as any);

    // Mock valid session for child_456
    mockDb.setMockResult('select_session', {
      rows: [{
        id: 'session_123',
        child_id: 'child_456',
        token_hash: crypto.createHash('sha256').update('valid_token').digest('hex'),
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        status: 'active'
      }]
    });

    try {
      await service.getBooksList({
        sessionId: 'session_123',
        token: 'valid_token',
        childId: 'different_child' // Should be rejected
      });
      assert.fail('Should have thrown an error');
    } catch (error) {
      assert(error instanceof Error);
      assert(error.message.includes('Access denied to specified child'));
    }
  });

  test("should reject invalid session token", async () => {
    const mockDb = new MockBrowseRepository();
    const service = new BrowseService(mockDb as any);

    // Mock no session found
    mockDb.setMockResult('select_session', { rows: [] });

    try {
      await service.getRecentUploads({
        sessionId: 'invalid_session',
        token: 'invalid_token'
      });
      assert.fail('Should have thrown an error');
    } catch (error) {
      assert(error instanceof Error);
      assert(error.message.includes('Session not found or token invalid'));
    }
  });

  test("should reject expired session", async () => {
    const mockDb = new MockBrowseRepository();
    const service = new BrowseService(mockDb as any);

    // Mock expired session
    mockDb.setMockResult('select_session', {
      rows: [{
        id: 'session_123',
        child_id: 'child_456',
        token_hash: crypto.createHash('sha256').update('valid_token').digest('hex'),
        expires_at: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(), // Expired
        status: 'active'
      }]
    });

    try {
      await service.getRecentUploads({
        sessionId: 'session_123',
        token: 'valid_token'
      });
      assert.fail('Should have thrown an error');
    } catch (error) {
      assert(error instanceof Error);
      assert(error.message.includes('Session expired'));
    }
  });

  test("should get shared assets with valid share token", async () => {
    const mockDb = new MockBrowseRepository();
    const service = new BrowseService(mockDb as any);

    // Mock valid share token
    mockDb.setMockResult('select_share_token', {
      rows: [{
        child_id: 'child_456',
        resource_type: 'child_assets',
        resource_id: null,
        access_type: 'read_only',
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        status: 'active',
        access_count: 5,
        max_access_count: null
      }]
    });

    // Mock shared assets
    mockDb.setMockResult('select_recent_assets', {
      rows: [
        {
          id: 'asset_1',
          title: '分享的图片',
          type: 'image',
          created_at: '2026-05-15T10:30:00Z'
        }
      ]
    });

    const result = await service.getSharedAssets({
      shareToken: 'valid_share_token',
      limit: 10
    });

    assert.equal(result.length, 1);
    assert.equal(result[0].id, 'asset_1');
    assert.equal(result[0].title, '分享的图片');
    assert(result[0].previewUrl.includes('/api/assets/asset_1/preview'));
  });

  test("should reject share token for specific book when requesting assets", async () => {
    const mockDb = new MockBrowseRepository();
    const service = new BrowseService(mockDb as any);

    // Mock share token for specific book
    mockDb.setMockResult('select_share_token', {
      rows: [{
        child_id: 'child_456',
        resource_type: 'specific_book',
        resource_id: 'book_123',
        access_type: 'read_only',
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        status: 'active',
        access_count: 5,
        max_access_count: null
      }]
    });

    try {
      await service.getSharedAssets({
        shareToken: 'book_share_token'
      });
      assert.fail('Should have thrown an error');
    } catch (error) {
      assert(error instanceof Error);
      assert(error.message.includes('This share token is for a specific book, not assets'));
    }
  });
});
