/**
 * WebCompanionService 单元测试
 * 测试会话管理、上传项管理、Token 验证等核心业务逻辑
 */

import assert from "node:assert/strict";
import { describe, test, beforeEach, mock } from "node:test";
import crypto from "node:crypto";

import { WebCompanionService } from "../../../../src/modules/web-companion/web-companion.service.ts";
import type {
  CreateUploadItemWithAssetInput,
  UpdateUploadItemInput,
  WebCompanionRepository,
} from "../../../../src/modules/web-companion/web-companion.service.ts";
import { AppConfigService } from "../../../../src/infrastructure/config/app-config.service.ts";
import { DatasetService } from "../../../../src/modules/dataset/dataset.service.ts";

import {
  UploadSessionStatus,
  UploadItemStatus,
  StorageProvider,
  DEFAULT_CONFIG,
} from "../../../../src/modules/web-companion/constants.ts";

import type {
  CreateSessionRequest,
  CreateUploadItemsRequest,
  CommitUploadItemRequest,
  UploadSession,
  UploadItem,
} from "../../../../src/modules/web-companion/types.ts";

type QueryBackedDb = {
  query(sql: string, params?: any[]): Promise<{ rows: any[]; rowCount?: number }>;
  transaction(callback: (client: { query: QueryBackedDb["query"] }) => Promise<unknown>): Promise<unknown>;
};

class QueryBackedWebCompanionRepository implements WebCompanionRepository {
  private readonly db: QueryBackedDb;

  constructor(db: QueryBackedWebCompanionRepository["db"]) {
    this.db = db;
  }

  async insertSession(session: Omit<UploadSession, "createdAt">): Promise<void> {
    await this.db.query(
      `INSERT INTO web_companion_upload_sessions
       (id, child_id, token_hash, status, expires_at, max_items, closed_at, last_seen_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      [
        session.id,
        session.childId,
        session.tokenHash,
        session.status,
        session.expiresAt,
        session.maxItems,
        session.closedAt || null,
        session.lastSeenAt || null,
      ],
    );
  }

  async getSessionById(sessionId: string): Promise<UploadSession | null> {
    const result = await this.db.query(
      `SELECT id, child_id, token_hash, status, expires_at, max_items, created_at, closed_at, last_seen_at
       FROM web_companion_upload_sessions
       WHERE id = $1`,
      [sessionId],
    );
    return result.rows[0] ? this.mapSession(result.rows[0]) : null;
  }

  async updateSessionStatus(input: { sessionId: string; status: any; closedAt?: Date }): Promise<void> {
    await this.db.query(
      `UPDATE web_companion_upload_sessions
       SET status = $1, closed_at = $2, updated_at = now()
       WHERE id = $3`,
      [input.status, input.closedAt || null, input.sessionId],
    );
  }

  async countUploadItemsBySession(sessionId: string): Promise<number> {
    const result = await this.db.query(
      `SELECT COUNT(*) as count
       FROM web_companion_upload_items
       WHERE session_id = $1`,
      [sessionId],
    );
    return parseInt(String(result.rows[0]?.count ?? "0"), 10);
  }

  async getUploadItemsBySession(sessionId: string): Promise<UploadItem[]> {
    const result = await this.db.query(
      `SELECT id, session_id, asset_id, client_file_id, original_filename, safe_filename,
              content_type, size_bytes, provider, bucket, object_key, status,
              remote_etag, local_path, hash_sha256, error_code, error_message,
              created_at, updated_at, committed_at, ready_at
       FROM web_companion_upload_items
       WHERE session_id = $1
       ORDER BY created_at ASC`,
      [sessionId],
    );
    return result.rows.map((row) => this.mapUploadItem(row));
  }

  async getUploadItemById(uploadItemId: string): Promise<UploadItem | null> {
    const result = await this.db.query(
      `SELECT id, session_id, asset_id, client_file_id, original_filename, safe_filename,
              content_type, size_bytes, provider, bucket, object_key, status,
              remote_etag, local_path, hash_sha256, error_code, error_message,
              created_at, updated_at, committed_at, ready_at
       FROM web_companion_upload_items
       WHERE id = $1`,
      [uploadItemId],
    );
    return result.rows[0] ? this.mapUploadItem(result.rows[0]) : null;
  }

  async createUploadItemWithAsset(input: CreateUploadItemWithAssetInput): Promise<UploadItem> {
    return this.db.transaction(async (client) => {
      await client.query(
        `INSERT INTO assets (id, child_id, type, title, original_filename, content_type, size_bytes, storage_provider, storage_status, license)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
        [input.assetId, input.childId, "photo", input.originalFilename, input.originalFilename, input.contentType, input.sizeBytes, input.provider, "pending", "user_uploaded"],
      );
      await client.query(
        `INSERT INTO web_companion_upload_items
         (id, session_id, asset_id, client_file_id, original_filename, safe_filename,
          content_type, size_bytes, provider, bucket, object_key, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)`,
        [
          input.uploadItemId,
          input.sessionId,
          input.assetId,
          input.clientFileId,
          input.originalFilename,
          input.safeFilename,
          input.contentType,
          input.sizeBytes,
          input.provider,
          input.bucket,
          input.objectKey,
          input.status,
        ],
      );
      return {
        id: input.uploadItemId,
        sessionId: input.sessionId,
        assetId: input.assetId,
        clientFileId: input.clientFileId,
        originalFilename: input.originalFilename,
        safeFilename: input.safeFilename,
        contentType: input.contentType,
        sizeBytes: input.sizeBytes,
        provider: input.provider,
        bucket: input.bucket,
        objectKey: input.objectKey,
        status: input.status,
        remoteEtag: null,
        localPath: null,
        hashSha256: null,
        errorCode: null,
        errorMessage: null,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
    });
  }

  async updateUploadItemStatus(input: { uploadItemId: string; status: any; updates: UpdateUploadItemInput }): Promise<UploadItem | null> {
    await this.db.query(
      `UPDATE web_companion_upload_items
       SET status = $1, updated_at = now()
       WHERE id = $2`,
      [input.status, input.uploadItemId],
    );
    return this.getUploadItemById(input.uploadItemId);
  }

  async commitUploadItemIfNotCommitted(input: { uploadItemId: string; status: any; updates: UpdateUploadItemInput }): Promise<UploadItem | null> {
    const result = await this.db.query(
      `UPDATE web_companion_upload_items
       SET status = $1, size_bytes = $2, content_type = $3, remote_etag = $4, committed_at = $5, updated_at = now()
       WHERE id = $6 AND committed_at IS NULL AND status = 'uploading'`,
      [
        input.status,
        input.updates.sizeBytes ?? null,
        input.updates.contentType ?? null,
        input.updates.remoteEtag ?? null,
        input.updates.committedAt ?? null,
        input.uploadItemId,
      ],
    );

    if ((result.rowCount ?? 0) === 0) {
      return null;
    }
    return this.getUploadItemById(input.uploadItemId);
  }

  private mapSession(row: any): UploadSession {
    return {
      id: row.id,
      childId: row.childId ?? row.child_id,
      tokenHash: row.tokenHash ?? row.token_hash,
      status: row.status,
      expiresAt: new Date(row.expiresAt ?? row.expires_at),
      maxItems: row.maxItems ?? row.max_items,
      createdAt: new Date(row.createdAt ?? row.created_at),
      closedAt: row.closedAt || row.closed_at ? new Date(row.closedAt ?? row.closed_at) : undefined,
      lastSeenAt: row.lastSeenAt || row.last_seen_at ? new Date(row.lastSeenAt ?? row.last_seen_at) : undefined,
    };
  }

  private mapUploadItem(row: any): UploadItem {
    return {
      id: row.id,
      sessionId: row.sessionId ?? row.session_id,
      assetId: row.assetId ?? row.asset_id,
      clientFileId: row.clientFileId ?? row.client_file_id,
      originalFilename: row.originalFilename ?? row.original_filename,
      safeFilename: row.safeFilename ?? row.safe_filename,
      contentType: row.contentType ?? row.content_type,
      sizeBytes: Number(row.sizeBytes ?? row.size_bytes),
      provider: row.provider,
      bucket: row.bucket,
      objectKey: row.objectKey ?? row.object_key,
      status: row.status,
      remoteEtag: row.remoteEtag ?? row.remote_etag,
      localPath: row.localPath ?? row.local_path,
      hashSha256: row.hashSha256 ?? row.hash_sha256,
      errorCode: row.errorCode ?? row.error_code,
      errorMessage: row.errorMessage ?? row.error_message,
      createdAt: new Date(row.createdAt ?? row.created_at),
      updatedAt: new Date(row.updatedAt ?? row.updated_at),
      committedAt: row.committedAt || row.committed_at ? new Date(row.committedAt ?? row.committed_at) : undefined,
      readyAt: row.readyAt || row.ready_at ? new Date(row.readyAt ?? row.ready_at) : undefined,
    };
  }
}

describe("WebCompanionService", () => {
  let service: WebCompanionService;
  let mockAppConfig: AppConfigService;
  let mockDb: QueryBackedDb;
  let mockDataset: DatasetService;

  const mockChildId = "child-test-001";
  const mockSessionId = "session_test_123";
  const mockToken = "a".repeat(64);
  const mockTokenHash = crypto.createHash("sha256").update(mockToken).digest("hex");

  beforeEach(() => {
    mockAppConfig = {
      config: {
        sidecar: {
          webCompanionBaseUrl: "http://localhost:3000",
        },
        supabaseStorage: {
          bucket: "test-bucket",
        },
      },
    } as any;

    mockDb = {
      query: mock.fn(async () => ({ rows: [] })),
      transaction: async <T>(callback: (client: { query: typeof mockDb.query }) => Promise<T>): Promise<T> => {
        return callback({ query: mockDb.query });
      },
    } as any;

    mockDataset = {
      getChild: mock.fn(async (id: string) => ({
        id,
        displayName: "Test Child",
      })),
    } as any;

    service = new WebCompanionService(mockAppConfig, new QueryBackedWebCompanionRepository(mockDb as any), mockDataset);
  });

  describe("createSession", () => {
    test("should create a new session with default values", async () => {
      const request: CreateSessionRequest = {
        childId: mockChildId,
      };

      mockDb.query = mock.fn(async (sql: string) => {
        if (sql.includes("INSERT INTO web_companion_upload_sessions")) {
          return { rows: [] };
        }
        return { rows: [] };
      });

      const response = await service.createSession(request);

      assert.ok(response.sessionId);
      assert.ok(response.token);
      assert.equal(response.token.length, 64);
      assert.ok(response.webUrl.includes(response.sessionId));
      assert.ok(response.webUrl.includes(response.token));
      assert.ok(response.webUrl.includes("/trusted-upload?"));
      assert.equal(response.maxItems, DEFAULT_CONFIG.MAX_ITEMS_PER_SESSION);
      assert.ok(new Date(response.expiresAt) > new Date());
    });

    test("should create session with custom expiry and max items", async () => {
      const request: CreateSessionRequest = {
        childId: mockChildId,
        expiresInMinutes: 60,
        maxItems: 50,
      };

      mockDb.query = mock.fn(async () => ({ rows: [] }));

      const response = await service.createSession(request);

      assert.equal(response.maxItems, 50);
      const expiresAt = new Date(response.expiresAt);
      const expectedExpiry = new Date(Date.now() + 60 * 60 * 1000);
      assert.ok(Math.abs(expiresAt.getTime() - expectedExpiry.getTime()) < 5000);
    });

    test("should throw error if child does not exist", async () => {
      mockDataset.getChild = mock.fn(async () => null);
      mockDataset.getChildById = mock.fn(async () => null);

      const request: CreateSessionRequest = {
        childId: "invalid-child",
      };

      await assert.rejects(
        async () => service.createSession(request),
        (err: any) => {
          assert.ok(err.message.includes("not found"));
          return true;
        }
      );
    });

    test("should hash token before storing", async () => {
      const request: CreateSessionRequest = {
        childId: mockChildId,
      };

      let storedTokenHash: string | undefined;
      mockDb.query = mock.fn(async (sql: string, params?: any[]) => {
        if (sql.includes("INSERT INTO web_companion_upload_sessions") && params) {
          storedTokenHash = params[2]; // tokenHash is 3rd param
        }
        return { rows: [] };
      });

      const response = await service.createSession(request);
      const expectedHash = crypto.createHash("sha256").update(response.token).digest("hex");

      assert.ok(storedTokenHash);
      assert.equal(storedTokenHash, expectedHash);
      assert.notEqual(storedTokenHash, response.token);
    });
  });

  describe("getSessionSummary", () => {
    test("should return session summary without token", async () => {
      const mockSession: UploadSession = {
        id: mockSessionId,
        childId: mockChildId,
        tokenHash: mockTokenHash,
        status: UploadSessionStatus.ACTIVE,
        expiresAt: new Date(Date.now() + 3600000),
        maxItems: 200,
        createdAt: new Date(),
      };

      mockDb.query = mock.fn(async (sql: string) => {
        if (sql.includes("SELECT") && sql.includes("web_companion_upload_sessions")) {
          return {
            rows: [{
              id: mockSession.id,
              child_id: mockSession.childId,
              token_hash: mockSession.tokenHash,
              status: mockSession.status,
              expires_at: mockSession.expiresAt.toISOString(),
              max_items: mockSession.maxItems,
              created_at: mockSession.createdAt.toISOString(),
              closed_at: null,
              last_seen_at: null,
            }]
          };
        }
        if (sql.includes("COUNT") && sql.includes("web_companion_upload_items")) {
          return { rows: [{ count: "5" }] };
        }
        return { rows: [] };
      });

      const summary = await service.getSessionSummary(mockSessionId);

      assert.equal(summary.sessionId, mockSessionId);
      assert.equal(summary.status, UploadSessionStatus.ACTIVE);
      assert.equal(summary.child.id, mockChildId);
      assert.equal(summary.maxItems, 200);
      assert.equal(summary.usedItems, 5);
    });

    test("should validate token if provided", async () => {
      const mockSession: UploadSession = {
        id: mockSessionId,
        childId: mockChildId,
        tokenHash: mockTokenHash,
        status: UploadSessionStatus.ACTIVE,
        expiresAt: new Date(Date.now() + 3600000),
        maxItems: 200,
        createdAt: new Date(),
      };

      mockDb.query = mock.fn(async () => ({ rows: [mockSession] }));

      await assert.rejects(
        async () => service.getSessionSummary(mockSessionId, "invalid-token"),
        (err: any) => {
          assert.ok(err.message.includes("Invalid token"));
          return true;
        }
      );
    });

    test("should throw error if session not found", async () => {
      mockDb.query = mock.fn(async () => ({ rows: [] }));

      await assert.rejects(
        async () => service.getSessionSummary("non-existent"),
        (err: any) => {
          assert.ok(err.message.includes("not found"));
          return true;
        }
      );
    });

    test("should throw error if session expired", async () => {
      const expiredSession: UploadSession = {
        id: mockSessionId,
        childId: mockChildId,
        tokenHash: mockTokenHash,
        status: UploadSessionStatus.EXPIRED,
        expiresAt: new Date(Date.now() - 3600000),
        maxItems: 200,
        createdAt: new Date(),
      };

      mockDb.query = mock.fn(async () => ({ rows: [expiredSession] }));

      await assert.rejects(
        async () => service.getSessionSummary(mockSessionId),
        (err: any) => {
          assert.ok(err.message.includes("expired"));
          return true;
        }
      );
    });
  });

  describe("createUploadItems", () => {
    test("should create upload items with generated IDs and object keys", async () => {
      const mockSession: UploadSession = {
        id: mockSessionId,
        childId: mockChildId,
        tokenHash: mockTokenHash,
        status: UploadSessionStatus.ACTIVE,
        expiresAt: new Date(Date.now() + 3600000),
        maxItems: 200,
        createdAt: new Date(),
      };

      mockDb.query = mock.fn(async (sql: string) => {
        if (sql.includes("SELECT") && sql.includes("web_companion_upload_sessions")) {
          return {
            rows: [{
              id: mockSession.id,
              child_id: mockSession.childId,
              token_hash: mockSession.tokenHash,
              status: mockSession.status,
              expires_at: mockSession.expiresAt.toISOString(),
              max_items: mockSession.maxItems,
              created_at: mockSession.createdAt.toISOString(),
              closed_at: null,
              last_seen_at: null,
            }]
          };
        }
        if (sql.includes("COUNT")) {
          return { rows: [{ count: "0" }] };
        }
        if (sql.includes("INSERT INTO assets")) {
          return { rows: [{ id: "asset-123" }] };
        }
        if (sql.includes("INSERT INTO web_companion_upload_items")) {
          return { rows: [] };
        }
        return { rows: [] };
      });

      const request: CreateUploadItemsRequest = {
        token: mockToken,
        files: [
          {
            clientFileId: "file-1",
            filename: "photo.jpg",
            contentType: "image/jpeg",
            sizeBytes: 1024000,
          },
        ],
        provider: StorageProvider.LAN,
      };

      const response = await service.createUploadItems(mockSessionId, request);

      assert.equal(response.items.length, 1);
      assert.ok(response.items[0].uploadItemId);
      assert.ok(response.items[0].assetId);
      assert.ok(response.items[0].objectKey);
      assert.equal(response.items[0].status, UploadItemStatus.PENDING);
      assert.equal(response.items[0].signedUpload, undefined);
    });

    test("should reject if session is closed", async () => {
      const closedSession: UploadSession = {
        id: mockSessionId,
        childId: mockChildId,
        tokenHash: mockTokenHash,
        status: UploadSessionStatus.CLOSED,
        expiresAt: new Date(Date.now() + 3600000),
        maxItems: 200,
        createdAt: new Date(),
        closedAt: new Date(),
      };

      mockDb.query = mock.fn(async (sql: string) => {
        if (sql.includes("SELECT") && sql.includes("web_companion_upload_sessions")) {
          return {
            rows: [{
              id: closedSession.id,
              child_id: closedSession.childId,
              token_hash: closedSession.tokenHash,
              status: closedSession.status,
              expires_at: closedSession.expiresAt.toISOString(),
              max_items: closedSession.maxItems,
              created_at: closedSession.createdAt.toISOString(),
              closed_at: closedSession.closedAt?.toISOString(),
              last_seen_at: null,
            }]
          };
        }
        return { rows: [] };
      });

      const request: CreateUploadItemsRequest = {
        token: mockToken,
        files: [{ clientFileId: "f1", filename: "a.jpg", contentType: "image/jpeg", sizeBytes: 1000 }],
        provider: StorageProvider.SUPABASE,
      };

      await assert.rejects(
        async () => service.createUploadItems(mockSessionId, request),
        (err: any) => {
          assert.ok(err.message.includes("closed"));
          return true;
        }
      );
    });

    test("should reject if exceeds max items limit", async () => {
      const mockSession: UploadSession = {
        id: mockSessionId,
        childId: mockChildId,
        tokenHash: mockTokenHash,
        status: UploadSessionStatus.ACTIVE,
        expiresAt: new Date(Date.now() + 3600000),
        maxItems: 5,
        createdAt: new Date(),
      };

      mockDb.query = mock.fn(async (sql: string) => {
        if (sql.includes("SELECT") && sql.includes("web_companion_upload_sessions")) {
          return {
            rows: [{
              id: mockSession.id,
              child_id: mockSession.childId,
              token_hash: mockSession.tokenHash,
              status: mockSession.status,
              expires_at: mockSession.expiresAt.toISOString(),
              max_items: mockSession.maxItems,
              created_at: mockSession.createdAt.toISOString(),
              closed_at: null,
              last_seen_at: null,
            }]
          };
        }
        if (sql.includes("COUNT")) {
          return { rows: [{ count: "5" }] };
        }
        return { rows: [] };
      });

      const request: CreateUploadItemsRequest = {
        token: mockToken,
        files: [{ clientFileId: "f1", filename: "a.jpg", contentType: "image/jpeg", sizeBytes: 1000 }],
        provider: StorageProvider.SUPABASE,
      };

      await assert.rejects(
        async () => service.createUploadItems(mockSessionId, request),
        (err: any) => {
          assert.ok(err.message.includes("limit"));
          return true;
        }
      );
    });
  });

  describe("commitUploadItem", () => {
    test("should mark upload item as uploaded_remote", async () => {
      const mockItem: UploadItem = {
        id: "item-123",
        sessionId: mockSessionId,
        assetId: "asset-123",
        clientFileId: "file-1",
        originalFilename: "photo.jpg",
        safeFilename: "photo.jpg",
        contentType: "image/jpeg",
        sizeBytes: 1024000,
        provider: StorageProvider.SUPABASE,
        bucket: "test-bucket",
        objectKey: "uploads/session_test_123/photo.jpg",
        status: UploadItemStatus.UPLOADING,
        remoteEtag: null,
        localPath: null,
        hashSha256: null,
        errorCode: null,
        errorMessage: null,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      const mockSession: UploadSession = {
        id: mockSessionId,
        childId: mockChildId,
        tokenHash: mockTokenHash,
        status: UploadSessionStatus.ACTIVE,
        expiresAt: new Date(Date.now() + 3600000),
        maxItems: 200,
        createdAt: new Date(),
      };

      let queryCount = 0;
      mockDb.query = mock.fn(async (sql: string) => {
        if (sql.includes("SELECT") && sql.includes("web_companion_upload_sessions")) {
          return {
            rows: [{
              id: mockSession.id,
              child_id: mockSession.childId,
              token_hash: mockSession.tokenHash,
              status: mockSession.status,
              expires_at: mockSession.expiresAt.toISOString(),
              max_items: mockSession.maxItems,
              created_at: mockSession.createdAt.toISOString(),
              closed_at: null,
              last_seen_at: null,
            }]
          };
        }
        if (sql.includes("SELECT") && sql.includes("web_companion_upload_items")) {
          queryCount++;
          // 第一次查询返回原始状态，第二次查询（UPDATE后的getUploadItemById）返回更新后状态
          const status = queryCount === 1 ? mockItem.status : UploadItemStatus.UPLOADED_REMOTE;
          return {
            rows: [{
              id: mockItem.id,
              session_id: mockItem.sessionId,
              asset_id: mockItem.assetId,
              client_file_id: mockItem.clientFileId,
              original_filename: mockItem.originalFilename,
              safe_filename: mockItem.safeFilename,
              content_type: mockItem.contentType,
              size_bytes: mockItem.sizeBytes,
              provider: mockItem.provider,
              bucket: mockItem.bucket,
              object_key: mockItem.objectKey,
              status: status,
              remote_etag: mockItem.remoteEtag,
              local_path: mockItem.localPath,
              hash_sha256: mockItem.hashSha256,
              error_code: mockItem.errorCode,
              error_message: mockItem.errorMessage,
              created_at: mockItem.createdAt.toISOString(),
              updated_at: mockItem.updatedAt.toISOString(),
              committed_at: null,
              ready_at: null,
            }]
          };
        }
        if (sql.includes("UPDATE web_companion_upload_items")) {
          return { rows: [], rowCount: 1 };
        }
        return { rows: [] };
      });

      const request: CommitUploadItemRequest = {
        token: mockToken,
        objectKey: mockItem.objectKey,
        sizeBytes: 1024000,
        contentType: "image/jpeg",
      };

      const response = await service.commitUploadItem(mockSessionId, mockItem.id, request);

      assert.equal(response.uploadItemId, mockItem.id);
      assert.equal(response.status, UploadItemStatus.UPLOADED_REMOTE);
    });

    test("should reject if object key mismatch", async () => {
      const mockItem: UploadItem = {
        id: "item-123",
        sessionId: mockSessionId,
        assetId: "asset-123",
        clientFileId: null,
        originalFilename: "photo.jpg",
        safeFilename: "photo.jpg",
        contentType: "image/jpeg",
        sizeBytes: 1024000,
        provider: StorageProvider.SUPABASE,
        bucket: "test-bucket",
        objectKey: "uploads/session_test_123/photo.jpg",
        status: UploadItemStatus.UPLOADING,
        remoteEtag: null,
        localPath: null,
        hashSha256: null,
        errorCode: null,
        errorMessage: null,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      const mockSession: UploadSession = {
        id: mockSessionId,
        childId: mockChildId,
        tokenHash: mockTokenHash,
        status: UploadSessionStatus.ACTIVE,
        expiresAt: new Date(Date.now() + 3600000),
        maxItems: 200,
        createdAt: new Date(),
      };

      mockDb.query = mock.fn(async (sql: string) => {
        if (sql.includes("SELECT") && sql.includes("web_companion_upload_sessions")) {
          return {
            rows: [{
              id: mockSession.id,
              child_id: mockSession.childId,
              token_hash: mockSession.tokenHash,
              status: mockSession.status,
              expires_at: mockSession.expiresAt.toISOString(),
              max_items: mockSession.maxItems,
              created_at: mockSession.createdAt.toISOString(),
              closed_at: null,
              last_seen_at: null,
            }]
          };
        }
        if (sql.includes("SELECT") && sql.includes("web_companion_upload_items")) {
          return {
            rows: [{
              id: mockItem.id,
              session_id: mockItem.sessionId,
              asset_id: mockItem.assetId,
              client_file_id: mockItem.clientFileId,
              original_filename: mockItem.originalFilename,
              safe_filename: mockItem.safeFilename,
              content_type: mockItem.contentType,
              size_bytes: mockItem.sizeBytes,
              provider: mockItem.provider,
              bucket: mockItem.bucket,
              object_key: mockItem.objectKey,
              status: mockItem.status,
              remote_etag: mockItem.remoteEtag,
              local_path: mockItem.localPath,
              hash_sha256: mockItem.hashSha256,
              error_code: mockItem.errorCode,
              error_message: mockItem.errorMessage,
              created_at: mockItem.createdAt.toISOString(),
              updated_at: mockItem.updatedAt.toISOString(),
              committed_at: null,
              ready_at: null,
            }]
          };
        }
        return { rows: [] };
      });

      const request: CommitUploadItemRequest = {
        token: mockToken,
        objectKey: "wrong/path/photo.jpg",
        sizeBytes: 1024000,
        contentType: "image/jpeg",
      };

      await assert.rejects(
        async () => service.commitUploadItem(mockSessionId, mockItem.id, request),
        (err: any) => {
          assert.ok(err.message.includes("mismatch"));
          return true;
        }
      );
    });
  });

  describe("closeSession", () => {
    test("should close an active session", async () => {
      const mockSession: UploadSession = {
        id: mockSessionId,
        childId: mockChildId,
        tokenHash: mockTokenHash,
        status: UploadSessionStatus.ACTIVE,
        expiresAt: new Date(Date.now() + 3600000),
        maxItems: 200,
        createdAt: new Date(),
      };

      mockDb.query = mock.fn(async (sql: string) => {
        if (sql.includes("SELECT") && sql.includes("web_companion_upload_sessions")) {
          return {
            rows: [{
              id: mockSession.id,
              child_id: mockSession.childId,
              token_hash: mockSession.tokenHash,
              status: mockSession.status,
              expires_at: mockSession.expiresAt.toISOString(),
              max_items: mockSession.maxItems,
              created_at: mockSession.createdAt.toISOString(),
              closed_at: null,
              last_seen_at: null,
            }]
          };
        }
        if (sql.includes("UPDATE web_companion_upload_sessions")) {
          return { rows: [{ ...mockSession, status: UploadSessionStatus.CLOSED }] };
        }
        return { rows: [] };
      });

      await service.closeSession(mockSessionId, { token: mockToken });

      // Should not throw
      assert.ok(true);
    });

    test("should treat already closed session as idempotent", async () => {
      const closedSession: UploadSession = {
        id: mockSessionId,
        childId: mockChildId,
        tokenHash: mockTokenHash,
        status: UploadSessionStatus.CLOSED,
        expiresAt: new Date(Date.now() + 3600000),
        maxItems: 200,
        createdAt: new Date(),
        closedAt: new Date(),
      };

      mockDb.query = mock.fn(async (sql: string) => {
        if (sql.includes("SELECT") && sql.includes("web_companion_upload_sessions")) {
          return {
            rows: [{
              id: closedSession.id,
              child_id: closedSession.childId,
              token_hash: closedSession.tokenHash,
              status: closedSession.status,
              expires_at: closedSession.expiresAt.toISOString(),
              max_items: closedSession.maxItems,
              created_at: closedSession.createdAt.toISOString(),
              closed_at: closedSession.closedAt?.toISOString(),
              last_seen_at: null,
            }]
          };
        }
        return { rows: [] };
      });

      await service.closeSession(mockSessionId, { token: mockToken });
      assert.equal((mockDb.query as any).mock.callCount(), 1);
    });
  });
});
