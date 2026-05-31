import { describe, it, mock } from "node:test";
import assert from "node:assert";
import crypto from "node:crypto";

import { WebCompanionService } from "../../../../src/modules/web-companion/web-companion.service.ts";
import { UploadItemStatus } from "../../../../src/modules/web-companion/constants.ts";
import type { WebCompanionRepository } from "../../../../src/modules/web-companion/web-companion.service.ts";
import type {
  CreateUploadItemWithAssetInput,
  UploadItem,
  UploadSession,
} from "../../../../src/modules/web-companion/types.ts";

type WebCompanionServiceArgs = ConstructorParameters<typeof WebCompanionService>;
type PullbackWorkerSurface = {
  startPullbackProcess(item: UploadItem): Promise<void>;
};

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
  readyAt?: Date;
}): UploadItem {
  return {
    id: input.uploadItemId,
    uploadItemId: input.uploadItemId,
    sessionId: input.sessionId,
    objectKey: input.objectKey,
    status: input.status,
    sizeBytes: 1024,
    contentType: "image/jpeg",
    committedAt: input.committedAt,
    readyAt: input.readyAt,
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

function pullbackWorker(service: WebCompanionService): PullbackWorkerSurface["startPullbackProcess"] {
  return (service as unknown as PullbackWorkerSurface).startPullbackProcess.bind(service);
}

describe("Pullback Idempotency", () => {
  it("does not update status when item is already pulling_local", async () => {
    const sessionId = "session_123";
    const token = "token_abc";
    const uploadItemId = "item_456";
    const objectKey = "uploads/test.jpg";
    const item = createUploadItem({
      uploadItemId,
      sessionId,
      objectKey,
      status: UploadItemStatus.PULLING_LOCAL,
      committedAt: new Date(Date.now() - 60000),
    });
    const updateUploadItemStatus = mock.fn(async () => item);
    const repository = createRepositoryDouble({
      getSessionById: mock.fn(async () => createSession(sessionId, token)),
      getUploadItemById: mock.fn(async () => item),
      updateUploadItemStatus,
    });

    await pullbackWorker(createService(repository))(item);

    assert.strictEqual(updateUploadItemStatus.mock.callCount(), 0, "Should not update status when already pulling_local");
  });

  it("does not update status when item is already ready", async () => {
    const sessionId = "session_123";
    const token = "token_abc";
    const uploadItemId = "item_456";
    const objectKey = "uploads/test.jpg";
    const item = createUploadItem({
      uploadItemId,
      sessionId,
      objectKey,
      status: UploadItemStatus.READY,
      committedAt: new Date(Date.now() - 120000),
      readyAt: new Date(Date.now() - 60000),
    });
    const updateUploadItemStatus = mock.fn(async () => item);
    const repository = createRepositoryDouble({
      getSessionById: mock.fn(async () => createSession(sessionId, token)),
      getUploadItemById: mock.fn(async () => item),
      updateUploadItemStatus,
    });

    await pullbackWorker(createService(repository))(item);

    assert.strictEqual(updateUploadItemStatus.mock.callCount(), 0, "Should not update status when already ready");
  });

  it("attempts pullback for uploaded_remote items", async () => {
    const sessionId = "session_123";
    const token = "token_abc";
    const uploadItemId = "item_456";
    const objectKey = "uploads/test.jpg";
    const item = createUploadItem({
      uploadItemId,
      sessionId,
      objectKey,
      status: UploadItemStatus.UPLOADED_REMOTE,
      committedAt: new Date(Date.now() - 10000),
    });
    const updateUploadItemStatus = mock.fn(async () => ({
      ...item,
      status: UploadItemStatus.PULLING_LOCAL,
    }));
    const repository = createRepositoryDouble({
      getSessionById: mock.fn(async () => createSession(sessionId, token)),
      getUploadItemById: mock.fn(async () => item),
      updateUploadItemStatus,
    });

    await pullbackWorker(createService(repository))(item).catch(() => undefined);

    assert.ok(updateUploadItemStatus.mock.callCount() >= 1, "Should update status to pulling_local for uploaded_remote items");
  });

  it("handles concurrent pullback attempts gracefully", async () => {
    const sessionId = "session_123";
    const token = "token_abc";
    const uploadItemId = "item_456";
    const objectKey = "uploads/test.jpg";
    const item = createUploadItem({
      uploadItemId,
      sessionId,
      objectKey,
      status: UploadItemStatus.UPLOADED_REMOTE,
      committedAt: new Date(Date.now() - 10000),
    });
    let hasBeenUpdated = false;
    const repository = createRepositoryDouble({
      getSessionById: mock.fn(async () => createSession(sessionId, token)),
      getUploadItemById: mock.fn(async () => item),
      updateUploadItemStatus: mock.fn(async () => {
        if (hasBeenUpdated) {
          throw new Error("Item already being processed");
        }
        hasBeenUpdated = true;
        return {
          ...item,
          status: UploadItemStatus.PULLING_LOCAL,
        };
      }),
    });
    const startPullback = pullbackWorker(createService(repository));

    const results = await Promise.allSettled([
      startPullback(item).catch((error: unknown) => error),
      startPullback(item).catch((error: unknown) => error),
    ]);

    assert.equal(results.length, 2);
    assert.equal(hasBeenUpdated, true, "At least one pullback should have updated the status");
  });
});
