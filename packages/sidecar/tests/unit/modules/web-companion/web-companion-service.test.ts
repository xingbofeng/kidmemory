import assert from "node:assert/strict";
import crypto from "node:crypto";
import { beforeEach, describe, test } from "node:test";

import {
  DEFAULT_CONFIG,
  StorageProvider,
  UploadItemStatus,
  UploadSessionStatus,
} from "../../../../src/modules/web-companion/constants.ts";
import {
  WebCompanionService,
  type CreateUploadItemWithAssetInput,
  type UpdateUploadItemInput,
  type WebCompanionRepository,
} from "../../../../src/modules/web-companion/web-companion.service.ts";
import type {
  CommitUploadItemRequest,
  CreateSessionRequest,
  CreateUploadItemsRequest,
  UploadItem,
  UploadSession,
} from "../../../../src/modules/web-companion/types.ts";

type WebCompanionServiceArgs = ConstructorParameters<typeof WebCompanionService>;

const mockChildId = "child-test-001";
const mockSessionId = "session_test_123";
const mockToken = "a".repeat(64);
const mockTokenHash = crypto.createHash("sha256").update(mockToken).digest("hex");

class MemoryWebCompanionRepository implements WebCompanionRepository {
  readonly sessions = new Map<string, UploadSession>();
  readonly items = new Map<string, UploadItem>();

  async insertSession(session: Omit<UploadSession, "createdAt">): Promise<void> {
    this.sessions.set(session.id, { ...session, createdAt: new Date() });
  }

  async getSessionById(sessionId: string): Promise<UploadSession | null> {
    return this.sessions.get(sessionId) ?? null;
  }

  async updateSessionStatus(input: {
    sessionId: string;
    status: UploadSession["status"];
    closedAt?: Date;
  }): Promise<void> {
    const session = this.sessions.get(input.sessionId);
    if (!session) return;
    this.sessions.set(input.sessionId, {
      ...session,
      status: input.status,
      closedAt: input.closedAt,
    });
  }

  async countUploadItemsBySession(sessionId: string): Promise<number> {
    return this.listItems(sessionId).length;
  }

  async getUploadItemsBySession(sessionId: string): Promise<UploadItem[]> {
    return this.listItems(sessionId);
  }

  async getUploadItemById(uploadItemId: string): Promise<UploadItem | null> {
    return this.items.get(uploadItemId) ?? null;
  }

  async createUploadItemWithAsset(input: CreateUploadItemWithAssetInput): Promise<UploadItem> {
    const item: UploadItem = {
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
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    this.items.set(item.id, item);
    return item;
  }

  async updateUploadItemStatus(input: {
    uploadItemId: string;
    status: UploadItem["status"];
    updates: UpdateUploadItemInput;
  }): Promise<UploadItem | null> {
    const item = this.items.get(input.uploadItemId);
    if (!item) return null;
    const updated: UploadItem = {
      ...item,
      ...input.updates,
      status: input.status,
      updatedAt: new Date(),
    };
    this.items.set(updated.id, updated);
    return updated;
  }

  async commitUploadItemIfNotCommitted(input: {
    uploadItemId: string;
    status: UploadItem["status"];
    updates: UpdateUploadItemInput;
  }): Promise<UploadItem | null> {
    const item = this.items.get(input.uploadItemId);
    if (!item || item.committedAt || item.status !== UploadItemStatus.UPLOADING) {
      return null;
    }

    const updated: UploadItem = {
      ...item,
      ...input.updates,
      status: input.status,
      updatedAt: new Date(),
    };
    this.items.set(updated.id, updated);
    return updated;
  }

  addSession(session: UploadSession): void {
    this.sessions.set(session.id, session);
  }

  addItem(item: UploadItem): void {
    this.items.set(item.id, item);
  }

  private listItems(sessionId: string): UploadItem[] {
    return [...this.items.values()].filter((item) => item.sessionId === sessionId);
  }
}

function createActiveSession(overrides: Partial<UploadSession> = {}): UploadSession {
  return {
    id: mockSessionId,
    childId: mockChildId,
    tokenHash: mockTokenHash,
    status: UploadSessionStatus.ACTIVE,
    expiresAt: new Date(Date.now() + 60 * 60 * 1000),
    maxItems: 200,
    createdAt: new Date(),
    ...overrides,
  };
}

function createUploadItem(overrides: Partial<UploadItem> = {}): UploadItem {
  return {
    id: "item-123",
    sessionId: mockSessionId,
    assetId: "asset-123",
    clientFileId: "file-1",
    originalFilename: "photo.jpg",
    safeFilename: "photo.jpg",
    contentType: "image/jpeg",
    sizeBytes: 1024000,
    provider: StorageProvider.LAN,
    bucket: "",
    objectKey: "web-companion/child-test-001/item-123/photo.jpg",
    status: UploadItemStatus.PENDING,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  };
}

function assertErrorIncludes(error: unknown, expectedMessage: string): boolean {
  assert.ok(error instanceof Error);
  assert.ok(error.message.includes(expectedMessage));
  return true;
}

describe("WebCompanionService", () => {
  let service: WebCompanionService;
  let repository: MemoryWebCompanionRepository;
  let appConfig: WebCompanionServiceArgs[0];
  let childLookup: (id: string) => Promise<{ id: string; displayName: string } | null>;

  beforeEach(() => {
    repository = new MemoryWebCompanionRepository();
    appConfig = {
      config: {
        sidecar: {
          port: 0,
          host: "127.0.0.1",
          webCompanionBaseUrl: "http://localhost:3000",
        },
        supabaseStorage: {
          provider: "supabase",
          url: "https://test.supabase.co",
          bucket: "test-bucket",
          serviceRoleKey: "test-service-role-key",
          anonKey: "test-anon-key",
          publicBaseUrl: "https://test.supabase.co/storage/v1/object/public/test-bucket",
          signedUrlTtlSeconds: 900,
          s3: {
            endpoint: "https://test.supabase.co/storage/v1/s3",
            region: "local",
            accessKeyId: "test-access-key",
            secretAccessKey: "test-secret-key",
          },
        },
      },
    };
    childLookup = async (id: string) => id === mockChildId
      ? { id, displayName: "Test Child" }
      : null;
    const dataset = {
      getChild: (id: string) => childLookup(id),
      getChildById: (id: string) => childLookup(id),
    } as WebCompanionServiceArgs[2];

    service = new WebCompanionService(appConfig, repository, dataset);
  });

  describe("createSession", () => {
    test("creates a new session with default values", async () => {
      const request: CreateSessionRequest = { childId: mockChildId };

      const response = await service.createSession(request);

      assert.ok(response.sessionId);
      assert.ok(response.token);
      assert.equal(response.token.length, 64);
      assert.ok(response.webUrl.includes(response.sessionId));
      assert.ok(response.webUrl.includes(response.token));
      assert.ok(response.webUrl.includes("/app?"));
      assert.equal(response.maxItems, DEFAULT_CONFIG.MAX_ITEMS_PER_SESSION);
      assert.ok(new Date(response.expiresAt) > new Date());
      assert.ok(repository.sessions.has(response.sessionId));
    });

    test("creates session with custom expiry and max items", async () => {
      const request: CreateSessionRequest = {
        childId: mockChildId,
        expiresInMinutes: 60,
        maxItems: 50,
      };

      const response = await service.createSession(request);

      assert.equal(response.maxItems, 50);
      const expiresAt = new Date(response.expiresAt);
      const expectedExpiry = new Date(Date.now() + 60 * 60 * 1000);
      assert.ok(Math.abs(expiresAt.getTime() - expectedExpiry.getTime()) < 5000);
    });

    test("rejects missing children", async () => {
      childLookup = async () => null;

      await assert.rejects(
        async () => service.createSession({ childId: "invalid-child" }),
        (error: unknown) => assertErrorIncludes(error, "not found"),
      );
    });

    test("hashes token before storing it", async () => {
      const response = await service.createSession({ childId: mockChildId });
      const stored = repository.sessions.get(response.sessionId);
      assert.ok(stored);

      const expectedHash = crypto.createHash("sha256").update(response.token).digest("hex");
      assert.equal(stored.tokenHash, expectedHash);
      assert.notEqual(stored.tokenHash, response.token);
    });
  });

  describe("getSessionSummary", () => {
    test("returns session summary with token", async () => {
      repository.addSession(createActiveSession({ maxItems: 200 }));
      for (let index = 0; index < 5; index += 1) {
        repository.addItem(createUploadItem({ id: `item-${index}` }));
      }

      const summary = await service.getSessionSummary(mockSessionId, mockToken);

      assert.equal(summary.sessionId, mockSessionId);
      assert.equal(summary.status, UploadSessionStatus.ACTIVE);
      assert.equal(summary.child.id, mockChildId);
      assert.equal(summary.child.displayName, "Test Child");
      assert.equal(summary.maxItems, 200);
      assert.equal(summary.usedItems, 5);
    });

    test("rejects missing token", async () => {
      repository.addSession(createActiveSession());

      await assert.rejects(
        async () => service.getSessionSummary(mockSessionId, ""),
        (error: unknown) => assertErrorIncludes(error, "Invalid token"),
      );
    });

    test("rejects invalid tokens when a token is provided", async () => {
      repository.addSession(createActiveSession());

      await assert.rejects(
        async () => service.getSessionSummary(mockSessionId, "invalid-token"),
        (error: unknown) => assertErrorIncludes(error, "Invalid token"),
      );
    });

    test("rejects missing sessions", async () => {
      await assert.rejects(
        async () => service.getSessionSummary("non-existent"),
        (error: unknown) => assertErrorIncludes(error, "not found"),
      );
    });

    test("rejects expired sessions", async () => {
      repository.addSession(createActiveSession({
        status: UploadSessionStatus.EXPIRED,
        expiresAt: new Date(Date.now() - 60 * 60 * 1000),
      }));

      await assert.rejects(
        async () => service.getSessionSummary(mockSessionId),
        (error: unknown) => assertErrorIncludes(error, "expired"),
      );
    });
  });

  describe("createUploadItems", () => {
    test("creates upload items with generated IDs and object keys", async () => {
      repository.addSession(createActiveSession());
      const request: CreateUploadItemsRequest = {
        token: mockToken,
        files: [{
          clientFileId: "file-1",
          filename: "photo.jpg",
          contentType: "image/jpeg",
          sizeBytes: 1024000,
        }],
        provider: StorageProvider.LAN,
      };

      const response = await service.createUploadItems(mockSessionId, request);

      assert.equal(response.items.length, 1);
      const [item] = response.items;
      assert.ok(item);
      assert.ok(item.uploadItemId);
      assert.ok(item.assetId);
      assert.ok(item.objectKey);
      assert.equal(item.status, UploadItemStatus.PENDING);
      assert.equal(item.signedUpload, undefined);
      assert.ok(repository.items.has(item.uploadItemId));
    });

    test("rejects closed sessions", async () => {
      repository.addSession(createActiveSession({
        status: UploadSessionStatus.CLOSED,
        closedAt: new Date(),
      }));
      const request: CreateUploadItemsRequest = {
        token: mockToken,
        files: [{ clientFileId: "f1", filename: "a.jpg", contentType: "image/jpeg", sizeBytes: 1000 }],
        provider: StorageProvider.SUPABASE,
      };

      await assert.rejects(
        async () => service.createUploadItems(mockSessionId, request),
        (error: unknown) => assertErrorIncludes(error, "closed"),
      );
    });

    test("rejects requests that exceed the session item limit", async () => {
      repository.addSession(createActiveSession({ maxItems: 5 }));
      for (let index = 0; index < 5; index += 1) {
        repository.addItem(createUploadItem({ id: `item-${index}` }));
      }
      const request: CreateUploadItemsRequest = {
        token: mockToken,
        files: [{ clientFileId: "f1", filename: "a.jpg", contentType: "image/jpeg", sizeBytes: 1000 }],
        provider: StorageProvider.SUPABASE,
      };

      await assert.rejects(
        async () => service.createUploadItems(mockSessionId, request),
        (error: unknown) => assertErrorIncludes(error, "limit"),
      );
    });
  });

  describe("commitUploadItem", () => {
    test("marks an uploading item as uploaded remotely", async () => {
      const item = createUploadItem({ status: UploadItemStatus.UPLOADING });
      repository.addSession(createActiveSession());
      repository.addItem(item);
      const request: CommitUploadItemRequest = {
        token: mockToken,
        objectKey: item.objectKey,
        sizeBytes: item.sizeBytes,
        contentType: item.contentType,
      };

      const response = await service.commitUploadItem(mockSessionId, item.id, request);

      assert.equal(response.uploadItemId, item.id);
      assert.equal(response.status, UploadItemStatus.UPLOADED_REMOTE);
      assert.equal(response.idempotent, false);
      const stored = repository.items.get(item.id);
      assert.ok(stored);
      assert.equal(stored.status, UploadItemStatus.UPLOADED_REMOTE);
      assert.ok(stored.committedAt);
    });

    test("rejects object key mismatches", async () => {
      const item = createUploadItem({ status: UploadItemStatus.UPLOADING });
      repository.addSession(createActiveSession());
      repository.addItem(item);
      const request: CommitUploadItemRequest = {
        token: mockToken,
        objectKey: "wrong/path/photo.jpg",
        sizeBytes: item.sizeBytes,
        contentType: item.contentType,
      };

      await assert.rejects(
        async () => service.commitUploadItem(mockSessionId, item.id, request),
        (error: unknown) => assertErrorIncludes(error, "mismatch"),
      );
    });
  });

  describe("closeSession", () => {
    test("closes an active session", async () => {
      repository.addSession(createActiveSession());

      await service.closeSession(mockSessionId, { token: mockToken });

      const stored = repository.sessions.get(mockSessionId);
      assert.ok(stored);
      assert.equal(stored.status, UploadSessionStatus.CLOSED);
      assert.ok(stored.closedAt);
    });

    test("treats already closed sessions as idempotent", async () => {
      const closedAt = new Date();
      repository.addSession(createActiveSession({
        status: UploadSessionStatus.CLOSED,
        closedAt,
      }));

      await service.closeSession(mockSessionId, { token: mockToken });

      const stored = repository.sessions.get(mockSessionId);
      assert.ok(stored);
      assert.equal(stored.status, UploadSessionStatus.CLOSED);
      assert.equal(stored.closedAt, closedAt);
    });
  });
});
