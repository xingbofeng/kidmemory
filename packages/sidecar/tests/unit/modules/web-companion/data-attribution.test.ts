/**
 * 数据归属行为测试：assets.child_id 必须使用 session.childId。
 */

import { strict as assert } from "node:assert";
import { test, describe } from "node:test";

import { WebCompanionService } from "../../../../src/modules/web-companion/web-companion.service.ts";
import type { CreateUploadItemWithAssetInput, WebCompanionRepository } from "../../../../src/modules/web-companion/web-companion.service.ts";
import type { AppConfigService } from "../../../../src/infrastructure/config/app-config.service.ts";
import type { DatasetService } from "../../../../src/modules/dataset/dataset.service.ts";
import { StorageProvider } from "../../../../src/modules/web-companion/constants.ts";

describe("Web Companion Data Attribution", () => {
  test("should verify assets are created with correct child_id from session", async () => {
    let storedSession: Awaited<ReturnType<WebCompanionRepository["getSessionById"]>>;
    const mockRepository: WebCompanionRepository = {
      async insertSession(session) {
        storedSession = {
          ...session,
          createdAt: new Date(),
        };
      },
      async getSessionById() {
        return storedSession || null;
      },
      async updateSessionStatus() {},
      async countUploadItemsBySession() {
        return 0;
      },
      async getUploadItemsBySession() {
        return [];
      },
      async getUploadItemById() {
        return null;
      },
      async createUploadItemWithAsset(input: CreateUploadItemWithAssetInput) {
        assert.equal(input.childId, 'test-child-123',
          'Assets child_id should match session.childId');
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
      },
      async updateUploadItemStatus() {
        return null;
      },
    };

    const mockConfig = {
      config: {
        sidecar: {
          webCompanionBaseUrl: "http://localhost:3001",
        },
        supabaseStorage: {
          bucket: "test-bucket",
        },
      },
      getWebCompanionConfig: () => ({
        baseUrl: "http://localhost:3000",
        sessionTtlMinutes: 60,
        maxItemsPerSession: 10,
        maxFileSizeBytes: 10 * 1024 * 1024,
        allowedContentTypes: ["image/jpeg", "image/png"],
      }),
    } as AppConfigService;

    const mockDatasetService = {
      getChild: async (childId: string) => ({ child: { id: childId, name: "Test Child" } }),
      importAssets: async () => ({ ok: true, imported: [], skipped: [], failed: [] }),
    } as DatasetService;

    const service = new WebCompanionService(mockConfig, mockRepository, mockDatasetService);

    const sessionResponse = await service.createSession({
      childId: "test-child-123",
      expiresInMinutes: 60,
      maxItems: 10,
    });

    assert.ok(sessionResponse.sessionId, "Session should be created successfully");
    assert.ok(sessionResponse.token, "Session should have a token");

    const uploadResponse = await service.createUploadItems(sessionResponse.sessionId, {
      token: sessionResponse.token,
      files: [{
        clientFileId: "file1",
        filename: "test.jpg",
        contentType: "image/jpeg",
        sizeBytes: 1024,
      }],
      provider: StorageProvider.LAN,
    });

    assert.ok(uploadResponse.items.length > 0, "Upload items should be created");
    assert.equal(uploadResponse.items[0].clientFileId, "file1", "Upload item should have correct client file ID");
  });
});
