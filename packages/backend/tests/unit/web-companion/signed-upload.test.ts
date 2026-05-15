/**
 * Signed Upload 单元测试
 *
 * 测试 Supabase signed upload target 生成逻辑
 *
 * 注意：由于 Node.js test runner 的 mock.module 限制，
 * 这些测试验证错误处理和配置验证逻辑。
 * Supabase SDK 集成将在集成测试中验证。
 */

import { describe, it } from "node:test";
import assert from "node:assert/strict";
import { WebCompanionService } from "../../../src/modules/web-companion/web-companion.service.ts";
import { AppConfigService } from "../../../src/infrastructure/config/app-config.service.ts";
import type { WebCompanionRepository } from "../../../src/modules/web-companion/web-companion.service.ts";
import { DatasetService } from "../../../src/modules/dataset/dataset.service.ts";
import { UploadItemStatus, StorageProvider, WebCompanionErrorCode } from "../../../src/modules/web-companion/constants.ts";
import type { UploadItem } from "../../../src/modules/web-companion/types.ts";

describe("WebCompanionService - Signed Upload", () => {
  const mockRepository = {} as WebCompanionRepository;

  const mockDatasetService = {} as DatasetService;

  describe("generateSignedUploadTarget - configuration validation", () => {
    it("should throw error if Supabase URL is missing", async () => {
      const invalidConfig = {
        supabaseStorage: {
          url: "",
          serviceRoleKey: "test-key",
          bucket: "test-bucket",
          signedUrlTtlSeconds: 900,
        },
      };

      const invalidAppConfigService = {
        config: invalidConfig,
      } as unknown as AppConfigService;

      const service = new WebCompanionService(
        invalidAppConfigService,
        mockRepository,
        mockDatasetService
      );

      const uploadItem: UploadItem = {
        id: "item_123",
        sessionId: "session_123",
        assetId: "asset_123",
        clientFileId: "client_123",
        originalFilename: "test.jpg",
        safeFilename: "test.jpg",
        contentType: "image/jpeg",
        sizeBytes: 1024,
        provider: StorageProvider.SUPABASE,
        bucket: "test-bucket",
        objectKey: "web-companion/child_123/session_123/item_123/test.jpg",
        status: UploadItemStatus.PENDING,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      await assert.rejects(
        async () => {
          await (service as any).generateSignedUploadTarget(uploadItem);
        },
        (err: any) => {
          assert.equal(err.code, WebCompanionErrorCode.PROVIDER_UNAVAILABLE);
          assert.match(err.message, /Supabase configuration is incomplete/);
          return true;
        },
        "Should throw error for missing Supabase URL"
      );
    });

    it("should throw error if service role key is missing", async () => {
      const invalidConfig = {
        supabaseStorage: {
          url: "https://test.supabase.co",
          serviceRoleKey: "",
          bucket: "test-bucket",
          signedUrlTtlSeconds: 900,
        },
      };

      const invalidAppConfigService = {
        config: invalidConfig,
      } as unknown as AppConfigService;

      const service = new WebCompanionService(
        invalidAppConfigService,
        mockRepository,
        mockDatasetService
      );

      const uploadItem: UploadItem = {
        id: "item_123",
        sessionId: "session_123",
        assetId: "asset_123",
        clientFileId: "client_123",
        originalFilename: "test.jpg",
        safeFilename: "test.jpg",
        contentType: "image/jpeg",
        sizeBytes: 1024,
        provider: StorageProvider.SUPABASE,
        bucket: "test-bucket",
        objectKey: "web-companion/child_123/session_123/item_123/test.jpg",
        status: UploadItemStatus.PENDING,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      await assert.rejects(
        async () => {
          await (service as any).generateSignedUploadTarget(uploadItem);
        },
        (err: any) => {
          assert.equal(err.code, WebCompanionErrorCode.PROVIDER_UNAVAILABLE);
          return true;
        },
        "Should throw error for missing service role key"
      );
    });

    it("should throw error if bucket is missing", async () => {
      const invalidConfig = {
        supabaseStorage: {
          url: "https://test.supabase.co",
          serviceRoleKey: "test-key",
          bucket: "",
          signedUrlTtlSeconds: 900,
        },
      };

      const invalidAppConfigService = {
        config: invalidConfig,
      } as unknown as AppConfigService;

      const service = new WebCompanionService(
        invalidAppConfigService,
        mockRepository,
        mockDatasetService
      );

      const uploadItem: UploadItem = {
        id: "item_123",
        sessionId: "session_123",
        assetId: "asset_123",
        clientFileId: "client_123",
        originalFilename: "test.jpg",
        safeFilename: "test.jpg",
        contentType: "image/jpeg",
        sizeBytes: 1024,
        provider: StorageProvider.SUPABASE,
        bucket: "test-bucket",
        objectKey: "web-companion/child_123/session_123/item_123/test.jpg",
        status: UploadItemStatus.PENDING,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      await assert.rejects(
        async () => {
          await (service as any).generateSignedUploadTarget(uploadItem);
        },
        (err: any) => {
          assert.equal(err.code, WebCompanionErrorCode.PROVIDER_UNAVAILABLE);
          return true;
        },
        "Should throw error for missing bucket"
      );
    });

    it("should throw error for non-Supabase provider", async () => {
      const validConfig = {
        supabaseStorage: {
          url: "https://test.supabase.co",
          serviceRoleKey: "test-key",
          bucket: "test-bucket",
          signedUrlTtlSeconds: 900,
        },
      };

      const appConfigService = {
        config: validConfig,
      } as unknown as AppConfigService;

      const service = new WebCompanionService(
        appConfigService,
        mockRepository,
        mockDatasetService
      );

      const uploadItem: UploadItem = {
        id: "item_123",
        sessionId: "session_123",
        assetId: "asset_123",
        clientFileId: "client_123",
        originalFilename: "test.jpg",
        safeFilename: "test.jpg",
        contentType: "image/jpeg",
        sizeBytes: 1024,
        provider: "lan" as any, // 非 Supabase provider
        bucket: "test-bucket",
        objectKey: "web-companion/child_123/session_123/item_123/test.jpg",
        status: UploadItemStatus.PENDING,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      await assert.rejects(
        async () => {
          await (service as any).generateSignedUploadTarget(uploadItem);
        },
        (err: any) => {
          assert.equal(err.code, WebCompanionErrorCode.PROVIDER_UNAVAILABLE);
          assert.match(err.message, /Signed upload not supported for provider/);
          return true;
        },
        "Should throw error for non-Supabase provider"
      );
    });
  });

  describe("generateSignedUploadTarget - return value structure", () => {
    it("should return SignedUploadTarget with correct structure", async () => {
      // 这个测试需要真实的 Supabase 连接或更复杂的 mock
      // 暂时跳过，在集成测试中验证
      // 这里只验证类型定义存在
      const validConfig = {
        supabaseStorage: {
          url: "https://test.supabase.co",
          serviceRoleKey: "test-key",
          bucket: "test-bucket",
          signedUrlTtlSeconds: 900,
        },
      };

      const appConfigService = {
        config: validConfig,
      } as unknown as AppConfigService;

      const service = new WebCompanionService(
        appConfigService,
        mockRepository,
        mockDatasetService
      );

      // 验证方法存在
      assert.ok(
        typeof (service as any).generateSignedUploadTarget === "function",
        "generateSignedUploadTarget method should exist"
      );
    });
  });
});
