import { describe, it, mock } from "node:test";
import assert from "node:assert";
import crypto from "node:crypto";

import { WebCompanionService } from "../../../../src/modules/web-companion/web-companion.service.ts";
import { UploadItemStatus } from "../../../../src/modules/web-companion/constants.ts";
import type { WebCompanionRepository } from "../../../../src/modules/web-companion/web-companion.service.ts";
import type {
  CommitUploadItemRequest,
  CreateUploadItemWithAssetInput,
  UploadItem,
  UploadSession,
} from "../../../../src/modules/web-companion/types.ts";

type WebCompanionServiceArgs = ConstructorParameters<typeof WebCompanionService>;

const mockAppConfig: WebCompanionServiceArgs[0] = {
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

const mockDatasetService = {} as unknown as WebCompanionServiceArgs[2];

function hashToken(token: string): string {
  return crypto.createHash("sha256").update(token).digest("hex");
}

function createSession(sessionId: string, token: string): UploadSession {
  return {
    id: sessionId,
    sessionId,
    childId: "child_1",
    token,
    tokenHash: hashToken(token),
    status: "active",
    maxItems: 10,
    usedItems: 1,
    expiresAt: new Date(Date.now() + 3600000),
    createdAt: new Date(),
    updatedAt: new Date(),
  };
}

function createUploadItem(input: {
  uploadItemId: string;
  sessionId: string;
  objectKey: string;
  status: UploadItem["status"];
  committedAt: Date | null;
  sizeBytes?: number | null;
  contentType?: string | null;
}): UploadItem {
  return {
    id: input.uploadItemId,
    uploadItemId: input.uploadItemId,
    sessionId: input.sessionId,
    objectKey: input.objectKey,
    status: input.status,
    sizeBytes: input.sizeBytes ?? null,
    contentType: input.contentType ?? null,
    committedAt: input.committedAt,
    createdAt: new Date(),
    updatedAt: new Date(),
  };
}

function createRepositoryDouble(overrides: Partial<WebCompanionRepository>): WebCompanionRepository {
  return {
    insertSession: async () => undefined,
    getSessionById: async () => null,
    updateSessionStatus: async () => undefined,
    countUploadItemsBySession: async () => 0,
    getUploadItemsBySession: async () => [],
    getUploadItemById: async () => null,
    createUploadItemWithAsset: async (input: CreateUploadItemWithAssetInput) => {
      throw new Error(`unused createUploadItemWithAsset for ${input.uploadItemId}`);
    },
    updateUploadItemStatus: async () => null,
    commitUploadItemIfNotCommitted: async () => null,
    ...overrides,
  };
}

function createService(repository: WebCompanionRepository): WebCompanionService {
  return new WebCompanionService(mockAppConfig, repository, mockDatasetService);
}

function createCommitRequest(token: string, objectKey: string): CommitUploadItemRequest {
  return {
    token,
    objectKey,
    sizeBytes: 1024,
    contentType: "image/jpeg",
  };
}

describe("Upload Commit Idempotency", () => {
  it("returns idempotent result when committing already committed item", async () => {
    const sessionId = "session_123";
    const token = "token_abc";
    const uploadItemId = "item_456";
    const objectKey = "uploads/test.jpg";
    const session = createSession(sessionId, token);
    const item = createUploadItem({
      uploadItemId,
      sessionId,
      objectKey,
      status: UploadItemStatus.UPLOADED_REMOTE,
      sizeBytes: 1024,
      contentType: "image/jpeg",
      committedAt: new Date(Date.now() - 60000),
    });
    const updateUploadItemStatus = mock.fn(async () => item);
    const repository = createRepositoryDouble({
      getSessionById: mock.fn(async () => session),
      getUploadItemById: mock.fn(async () => item),
      updateUploadItemStatus,
      commitUploadItemIfNotCommitted: mock.fn(async () => null),
    });
    const service = createService(repository);
    const request = createCommitRequest(token, objectKey);

    const response1 = await service.commitUploadItem(sessionId, uploadItemId, request);
    const response2 = await service.commitUploadItem(sessionId, uploadItemId, request);

    assert.strictEqual(response1.uploadItemId, uploadItemId);
    assert.strictEqual(response1.status, UploadItemStatus.UPLOADED_REMOTE);
    assert.strictEqual(response1.idempotent, true, "Should return idempotent: true");
    assert.strictEqual(response2.uploadItemId, uploadItemId);
    assert.strictEqual(response2.idempotent, true, "Second commit should also be idempotent");
    assert.strictEqual(updateUploadItemStatus.mock.callCount(), 0, "Should not update status for idempotent commit");
  });

  it("performs normal commit for non-committed item", async () => {
    const sessionId = "session_123";
    const token = "token_abc";
    const uploadItemId = "item_456";
    const objectKey = "uploads/test.jpg";
    const session = createSession(sessionId, token);
    const item = createUploadItem({
      uploadItemId,
      sessionId,
      objectKey,
      status: UploadItemStatus.UPLOADING,
      committedAt: null,
    });
    const updatedItem = {
      ...item,
      status: UploadItemStatus.UPLOADED_REMOTE,
      sizeBytes: 1024,
      contentType: "image/jpeg",
      committedAt: new Date(),
    };
    const commitUploadItemIfNotCommitted = mock.fn(async () => updatedItem);
    const repository = createRepositoryDouble({
      getSessionById: mock.fn(async () => session),
      getUploadItemById: mock.fn(async () => item),
      updateUploadItemStatus: mock.fn(async () => updatedItem),
      commitUploadItemIfNotCommitted,
    });
    const service = createService(repository);

    const response = await service.commitUploadItem(sessionId, uploadItemId, createCommitRequest(token, objectKey));

    assert.strictEqual(response.uploadItemId, uploadItemId);
    assert.strictEqual(response.status, UploadItemStatus.UPLOADED_REMOTE);
    assert.strictEqual(response.idempotent, false, "Should return idempotent: false for first commit");
    assert.strictEqual(commitUploadItemIfNotCommitted.mock.callCount(), 1, "Should atomically commit once");
  });

  it("handles concurrent commits gracefully", async () => {
    const sessionId = "session_123";
    const token = "token_abc";
    const uploadItemId = "item_456";
    const objectKey = "uploads/test.jpg";
    const session = createSession(sessionId, token);
    const item = createUploadItem({
      uploadItemId,
      sessionId,
      objectKey,
      status: UploadItemStatus.UPLOADING,
      committedAt: null,
    });
    let getItemCallCount = 0;
    let commitCallCount = 0;
    const committedItem = () => ({
      ...item,
      status: UploadItemStatus.UPLOADED_REMOTE,
      committedAt: new Date(),
    });
    const repository = createRepositoryDouble({
      getSessionById: mock.fn(async () => session),
      getUploadItemById: mock.fn(async () => {
        getItemCallCount += 1;
        return getItemCallCount === 1 ? item : committedItem();
      }),
      updateUploadItemStatus: mock.fn(async () => committedItem()),
      commitUploadItemIfNotCommitted: mock.fn(async () => {
        commitCallCount += 1;
        return commitCallCount === 1 ? committedItem() : null;
      }),
    });
    const service = createService(repository);
    const request = createCommitRequest(token, objectKey);

    const [response1, response2] = await Promise.all([
      service.commitUploadItem(sessionId, uploadItemId, request),
      service.commitUploadItem(sessionId, uploadItemId, request),
    ]);

    assert.equal(response1.uploadItemId, uploadItemId);
    assert.equal(response2.uploadItemId, uploadItemId);
    assert.ok([response1, response2].some((response) => !response.idempotent), "At least one commit should succeed as non-idempotent");
    assert.ok([response1, response2].some((response) => response.idempotent), "At least one commit should be detected as idempotent");
  });
});
