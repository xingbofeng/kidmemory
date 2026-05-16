/**
 * 数据归属问题验证测试
 *
 * 验证以下问题：
 * 1. assets.child_id 必须使用 session.childId
 * 2. pullback import 必须使用 session.childId
 * 3. DatasetService.importAsset 方法不存在，应该使用 importAssets
 */

import { strict as assert } from "node:assert";
import { test, describe } from "node:test";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { WebCompanionService } from "../../../../src/modules/web-companion/web-companion.service.ts";
import type { CreateUploadItemWithAssetInput, WebCompanionRepository } from "../../../../src/modules/web-companion/web-companion.service.ts";
import { DatasetService } from "../../../../src/modules/dataset/dataset.service.ts";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

describe("Web Companion Data Attribution Issues", () => {

  test("should detect missing importAsset method in DatasetService", () => {
    // 验证 DatasetService 没有 importAsset 方法（单数）
    const datasetService = new DatasetService({} as any, {} as any);

    // 检查方法是否存在
    const hasImportAsset = typeof (datasetService as any).importAsset === 'function';
    const hasImportAssets = typeof datasetService.importAssets === 'function';

    // importAsset（单数）不应该存在
    assert.equal(hasImportAsset, false,
      'DatasetService should not have importAsset method (singular)');

    // importAssets（复数）应该存在
    assert.equal(hasImportAssets, true,
      'DatasetService should have importAssets method (plural)');
  });

  test("should detect Web Companion service calling non-existent importAsset method", () => {
    // 读取 Web Companion 服务源码
    const servicePath = path.join(__dirname, '../../../src/modules/web-companion/web-companion.service.ts');
    const serviceSource = fs.readFileSync(servicePath, 'utf8');

    // 检查是否调用了不存在的 importAsset 方法
    const callsImportAsset = serviceSource.includes('this.datasetService.importAsset(');

    if (callsImportAsset) {
      assert.fail('Web Companion service calls non-existent DatasetService.importAsset method');
    }
  });

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

    // Mock 配置和数据集服务
    const mockConfig = {
      config: {
        sidecar: {
          webCompanionBaseUrl: 'http://localhost:3001'
        },
        supabaseStorage: {
          bucket: 'test-bucket'
        }
      },
      getWebCompanionConfig: () => ({
        baseUrl: 'http://localhost:3000',
        sessionTtlMinutes: 60,
        maxItemsPerSession: 10,
        maxFileSizeBytes: 10 * 1024 * 1024,
        allowedContentTypes: ['image/jpeg', 'image/png'],
      })
    };

    const mockDatasetService = {
      getChild: async (childId: string) => ({ child: { id: childId, name: 'Test Child' } }),
      importAssets: async (input: any) => ({ ok: true, imported: [], skipped: [], failed: [] })
    };

    const service = new WebCompanionService(mockConfig as any, mockRepository, mockDatasetService as any);

    // 创建会话
    const sessionResponse = await service.createSession({
      childId: 'test-child-123',
      expiresInMinutes: 60,
      maxItems: 10,
    });

    // 验证会话创建成功，使用了正确的 childId
    assert.ok(sessionResponse.sessionId, 'Session should be created successfully');
    assert.ok(sessionResponse.token, 'Session should have a token');

    // 创建上传项 - 这应该在 assets 表中插入记录，使用正确的 child_id
    const uploadResponse = await service.createUploadItems(sessionResponse.sessionId, {
      token: sessionResponse.token,
      files: [{
        clientFileId: 'file1',
        filename: 'test.jpg',
        contentType: 'image/jpeg',
        sizeBytes: 1024
      }],
      provider: 'lan' as any
    });

    // 验证上传项创建成功
    assert.ok(uploadResponse.items.length > 0, 'Upload items should be created');
    assert.equal(uploadResponse.items[0].clientFileId, 'file1', 'Upload item should have correct client file ID');
  });
});
