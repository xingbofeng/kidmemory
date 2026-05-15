import { strict as assert } from "node:assert";
import { test, describe } from "node:test";
import crypto from "node:crypto";

import { ShareTokenService } from "../../src/modules/web-companion/share-token.service.ts";
import type { CreateShareTokenRecordInput, LogShareAccessInput, ShareTokenRepository } from "../../src/modules/web-companion/share-token.service.ts";

// Mock database client for testing
class MockShareTokenRepository implements ShareTokenRepository {
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
    const result = await this.query(
      "SELECT id, child_id, expires_at, status FROM web_companion_upload_sessions WHERE id = $1 AND token_hash = $2",
      [input.sessionId, input.tokenHash],
    );
    const row = result.rows[0];
    return row ? {
      sessionId: row.id,
      childId: row.child_id,
      expiresAt: row.expires_at,
      status: row.status,
    } : null;
  }

  async bookExistsForChild(input: { bookId: string; childId: string }) {
    const result = await this.query("SELECT id FROM books WHERE id = $1 AND child_id = $2", [input.bookId, input.childId]);
    return result.rows.length > 0;
  }

  async createShareToken(input: CreateShareTokenRecordInput) {
    const result = await this.query(
      "INSERT INTO share_tokens (id, token_hash, child_id, created_by_session, expires_at, access_type, resource_type, resource_id, max_access_count) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING id, child_id, expires_at, access_type, resource_type, resource_id, max_access_count",
      [
        input.id,
        input.tokenHash,
        input.childId,
        input.createdBySession,
        input.expiresAt.toISOString(),
        input.accessType,
        input.resourceType,
        input.resourceId || null,
        input.maxAccessCount || null,
      ],
    );
    const row = result.rows[0];
    return {
      id: row.id,
      childId: row.child_id,
      expiresAt: row.expires_at,
      accessType: row.access_type,
      resourceType: row.resource_type,
      resourceId: row.resource_id || undefined,
      accessCount: row.access_count || 0,
      maxAccessCount: row.max_access_count,
      status: row.status || "active",
    };
  }

  async findShareTokenByHash(tokenHash: string) {
    const result = await this.query("SELECT * FROM share_tokens WHERE token_hash = $1", [tokenHash]);
    const row = result.rows[0];
    return row ? {
      id: row.id,
      childId: row.child_id,
      expiresAt: row.expires_at,
      accessType: row.access_type,
      resourceType: row.resource_type,
      resourceId: row.resource_id || undefined,
      accessCount: row.access_count,
      maxAccessCount: row.max_access_count,
      status: row.status,
    } : null;
  }

  async markShareTokenExpired(id: string) {
    await this.query("UPDATE share_tokens SET status = 'expired' WHERE id = $1", [id]);
  }

  async incrementShareTokenAccess(id: string) {
    await this.query("UPDATE share_tokens SET access_count = access_count + 1, last_accessed_at = NOW() WHERE id = $1", [id]);
  }

  async logShareAccess(input: LogShareAccessInput) {
    await this.query(
      "INSERT INTO share_access_logs (id, share_token_id, client_ip, user_agent, access_result, resource_accessed) VALUES ($1,$2,$3,$4,$5,$6)",
      [input.id, input.shareTokenId, input.clientIp || null, input.userAgent || null, input.result, input.resourceAccessed || null],
    );
  }

  async revokeShareTokenForSession(input: { shareTokenId: string; childId: string; sessionId: string }) {
    const result = await this.query(
      "UPDATE share_tokens SET status = 'revoked' WHERE id = $1 AND (child_id = $2 OR created_by_session = $3) AND status = 'active'",
      [input.shareTokenId, input.childId, input.sessionId],
    );
    return result.rowCount > 0;
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
    if (normalized.includes('select') && normalized.includes('books')) {
      return 'select_book';
    }
    if (normalized.includes('insert into share_tokens')) {
      return 'insert_share_token';
    }
    if (normalized.includes('select') && normalized.includes('share_tokens')) {
      return 'select_share_token';
    }
    if (normalized.includes('update share_tokens')) {
      return 'update_share_token';
    }
    if (normalized.includes('insert into share_access_logs')) {
      return 'insert_access_log';
    }
    return 'default';
  }
}

describe("ShareTokenService", () => {
  test("should create share token for child assets", async () => {
    const mockDb = new MockShareTokenRepository();
    const service = new ShareTokenService(mockDb as any, 'http://localhost:5173');

    // Mock valid session
    mockDb.setMockResult('select_session', {
      rows: [{
        id: 'session_123',
        child_id: 'child_456',
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        status: 'active'
      }]
    });

    // Mock successful share token creation
    mockDb.setMockResult('insert_share_token', {
      rows: [{
        id: 'share_789',
        child_id: 'child_456',
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        access_type: 'read_only',
        resource_type: 'child_assets',
        resource_id: null,
        max_access_count: null
      }]
    });

    const result = await service.createShareToken({
      sessionId: 'session_123',
      sessionToken: 'valid_token',
      resourceType: 'child_assets'
    });

    assert.equal(result.childId, 'child_456');
    assert.equal(result.resourceType, 'child_assets');
    assert.equal(result.accessType, 'read_only');
    assert(result.token.length > 0);
    assert(result.shareUrl.includes('share/browse'));

    const queries = mockDb.getQueries();
    assert(queries.some(q => q.sql.includes('web_companion_upload_sessions')));
    assert(queries.some(q => q.sql.includes('INSERT INTO share_tokens')));
  });

  test("should create share token for specific book", async () => {
    const mockDb = new MockShareTokenRepository();
    const service = new ShareTokenService(mockDb as any, 'http://localhost:5173');

    // Mock valid session
    mockDb.setMockResult('select_session', {
      rows: [{
        id: 'session_123',
        child_id: 'child_456',
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        status: 'active'
      }]
    });

    // Mock book validation
    mockDb.setMockResult('select_book', {
      rows: [{
        id: 'book_789'
      }]
    });

    // Mock successful share token creation
    mockDb.setMockResult('insert_share_token', {
      rows: [{
        id: 'share_789',
        child_id: 'child_456',
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        access_type: 'read_only',
        resource_type: 'specific_book',
        resource_id: 'book_789',
        max_access_count: null
      }]
    });

    const result = await service.createShareToken({
      sessionId: 'session_123',
      sessionToken: 'valid_token',
      resourceType: 'specific_book',
      resourceId: 'book_789'
    });

    assert.equal(result.resourceType, 'specific_book');
    assert.equal(result.resourceId, 'book_789');
    assert(result.shareUrl.includes('share/book'));
    assert(result.shareUrl.includes('bookId=book_789'));
  });

  test("should validate active share token", async () => {
    const mockDb = new MockShareTokenRepository();
    const service = new ShareTokenService(mockDb as any);

    // Mock valid share token
    const futureDate = new Date(Date.now() + 24 * 60 * 60 * 1000);
    mockDb.setMockResult('select_share_token', {
      rows: [{
        id: 'share_789',
        child_id: 'child_456',
        expires_at: futureDate.toISOString(),
        access_type: 'read_only',
        resource_type: 'child_assets',
        resource_id: null,
        access_count: 5,
        max_access_count: null,
        status: 'active'
      }]
    });

    // Mock successful update
    mockDb.setMockResult('update_share_token', { rowCount: 1 });

    const result = await service.validateShareToken({
      token: 'valid_token_123',
      clientIp: '192.168.1.1',
      userAgent: 'Mozilla/5.0'
    });

    assert.equal(result.isValid, true);
    assert.equal(result.shareToken?.childId, 'child_456');
    assert.equal(result.shareToken?.resourceType, 'child_assets');

    const queries = mockDb.getQueries();
    assert(queries.some(q => q.sql.includes('UPDATE share_tokens SET access_count')));
    assert(queries.some(q => q.sql.includes('INSERT INTO share_access_logs')));
  });

  test("should reject expired share token", async () => {
    const mockDb = new MockShareTokenRepository();
    const service = new ShareTokenService(mockDb as any);

    // Mock expired share token
    const pastDate = new Date(Date.now() - 24 * 60 * 60 * 1000);
    mockDb.setMockResult('select_share_token', {
      rows: [{
        id: 'share_789',
        child_id: 'child_456',
        expires_at: pastDate.toISOString(),
        access_type: 'read_only',
        resource_type: 'child_assets',
        resource_id: null,
        access_count: 5,
        max_access_count: null,
        status: 'active'
      }]
    });

    const result = await service.validateShareToken({
      token: 'expired_token_123'
    });

    assert.equal(result.isValid, false);
    assert.equal(result.error, 'Share token has expired');

    const queries = mockDb.getQueries();
    assert(queries.some(q => q.sql.includes('UPDATE share_tokens SET status')));
  });

  test("should reject token with exceeded access limit", async () => {
    const mockDb = new MockShareTokenRepository();
    const service = new ShareTokenService(mockDb as any);

    // Mock share token with exceeded access limit
    const futureDate = new Date(Date.now() + 24 * 60 * 60 * 1000);
    mockDb.setMockResult('select_share_token', {
      rows: [{
        id: 'share_789',
        child_id: 'child_456',
        expires_at: futureDate.toISOString(),
        access_type: 'read_only',
        resource_type: 'child_assets',
        resource_id: null,
        access_count: 10,
        max_access_count: 10,
        status: 'active'
      }]
    });

    const result = await service.validateShareToken({
      token: 'limited_token_123'
    });

    assert.equal(result.isValid, false);
    assert.equal(result.error, 'Share token access limit exceeded');
  });

  test("should revoke share token", async () => {
    const mockDb = new MockShareTokenRepository();
    const service = new ShareTokenService(mockDb as any);

    // Mock valid session
    mockDb.setMockResult('select_session', {
      rows: [{
        id: 'session_123',
        child_id: 'child_456',
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        status: 'active'
      }]
    });

    // Mock successful revocation
    mockDb.setMockResult('update_share_token', { rowCount: 1 });

    await service.revokeShareToken('share_789', 'session_123', 'valid_token');

    const queries = mockDb.getQueries();
    assert(queries.some(q =>
      q.sql.includes('UPDATE share_tokens') &&
      q.sql.includes("SET status = 'revoked'")
    ));
  });

  test("should reject invalid session", async () => {
    const mockDb = new MockShareTokenRepository();
    const service = new ShareTokenService(mockDb as any);

    // Mock no session found
    mockDb.setMockResult('select_session', { rows: [] });

    try {
      await service.createShareToken({
        sessionId: 'invalid_session',
        sessionToken: 'invalid_token',
        resourceType: 'child_assets'
      });
      assert.fail('Should have thrown an error');
    } catch (error) {
      assert(error instanceof Error);
      assert(error.message.includes('Session not found'));
    }
  });

  test("should reject access to non-existent book", async () => {
    const mockDb = new MockShareTokenRepository();
    const service = new ShareTokenService(mockDb as any);

    // Mock valid session
    mockDb.setMockResult('select_session', {
      rows: [{
        id: 'session_123',
        child_id: 'child_456',
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        status: 'active'
      }]
    });

    // Mock book not found
    mockDb.setMockResult('select_book', { rows: [] });

    try {
      await service.createShareToken({
        sessionId: 'session_123',
        sessionToken: 'valid_token',
        resourceType: 'specific_book',
        resourceId: 'non_existent_book'
      });
      assert.fail('Should have thrown an error');
    } catch (error) {
      assert(error instanceof Error);
      assert(error.message.includes('Book not found'));
    }
  });

  test("should generate secure tokens", async () => {
    const mockDb = new MockShareTokenRepository();
    const service = new ShareTokenService(mockDb as any);

    // Mock valid session and successful creation
    mockDb.setMockResult('select_session', {
      rows: [{
        id: 'session_123',
        child_id: 'child_456',
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        status: 'active'
      }]
    });

    mockDb.setMockResult('insert_share_token', {
      rows: [{
        id: 'share_789',
        child_id: 'child_456',
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
        access_type: 'read_only',
        resource_type: 'child_assets',
        resource_id: null,
        max_access_count: null
      }]
    });

    const result1 = await service.createShareToken({
      sessionId: 'session_123',
      sessionToken: 'valid_token',
      resourceType: 'child_assets'
    });

    mockDb.clearQueries();

    const result2 = await service.createShareToken({
      sessionId: 'session_123',
      sessionToken: 'valid_token',
      resourceType: 'child_assets'
    });

    // Tokens should be different
    assert.notEqual(result1.token, result2.token);

    // Tokens should be long enough to be secure
    assert(result1.token.length >= 32);
    assert(result2.token.length >= 32);
  });
});
