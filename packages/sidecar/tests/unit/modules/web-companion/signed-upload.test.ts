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
import { WebCompanionService } from "../../../../src/modules/web-companion/web-companion.service.ts";
import type { WebCompanionRepository } from "../../../../src/modules/web-companion/web-companion.service.ts";
import type { DatasetService } from "../../../../src/modules/dataset/dataset.service.ts";
import { UploadItemStatus, StorageProvider, WebCompanionErrorCode } from "../../../../src/modules/web-companion/constants.ts";
import type { UploadItem } from "../../../../src/modules/web-companion/types.ts";

describe("WebCompanionService - Signed Upload", () => {
  const mockRepository = {} as WebCompanionRepository;

  const mockDatasetService = {} as DatasetService;

  type WebCompanionConfigSource = ConstructorParameters<typeof WebCompanionService>[0];
  type SupabaseStorageConfig = WebCompanionConfigSource["config"]["supabaseStorage"];

  function makeAppConfig(
    supabaseStorage: Partial<SupabaseStorageConfig>,
  ): WebCompanionConfigSource {
    return {
      config: {
        sidecar: {
          port: 3001,
          host: "127.0.0.1",
          webCompanionBaseUrl: "http://localhost:3001/web-companion",
        },
        supabaseStorage: {
          provider: "supabase",
          url: "https://test.supabase.co",
          serviceRoleKey: "test-key",
          anonKey: "anon-key",
          bucket: "test-bucket",
          publicBaseUrl: "https://test.supabase.co/storage/v1/object/public/test-bucket",
          signedUrlTtlSeconds: 900,
          s3: {
            endpoint: "",
            region: "",
            accessKeyId: "",
            secretAccessKey: "",
          },
          ...supabaseStorage,
        },
      },
    };
  }

  function makeService(supabaseStorage: Partial<SupabaseStorageConfig>) {
    return new WebCompanionService(
      makeAppConfig(supabaseStorage),
      mockRepository,
      mockDatasetService,
    );
  }

  function makeUploadItem(provider: UploadItem["provider"] = StorageProvider.SUPABASE): UploadItem {
    return {
      id: "item_123",
      sessionId: "session_123",
      assetId: "asset_123",
      clientFileId: "client_123",
      originalFilename: "test.jpg",
      safeFilename: "test.jpg",
      contentType: "image/jpeg",
      sizeBytes: 1024,
      provider,
      bucket: "test-bucket",
      objectKey: "web-companion/child_123/session_123/item_123/test.jpg",
      status: UploadItemStatus.PENDING,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
  }

  function assertWebCompanionError(
    error: unknown,
    code: string,
    messagePattern?: RegExp,
  ) {
    assert.ok(error instanceof Error);
    const codedError = error as Error & { code?: string };
    assert.equal(codedError.code, code);
    if (messagePattern) {
      assert.match(codedError.message, messagePattern);
    }
    return true;
  }

  describe("generateSignedUploadTarget - configuration validation", () => {
    it("should throw error if Supabase URL is missing", async () => {
      const service = makeService({ url: "" });
      const uploadItem = makeUploadItem();

      await assert.rejects(
        async () => {
          await service["generateSignedUploadTarget"](uploadItem);
        },
        (error: unknown) =>
          assertWebCompanionError(
            error,
            WebCompanionErrorCode.PROVIDER_UNAVAILABLE,
            /Object storage configuration is incomplete/,
          ),
        "Should throw error for missing Supabase URL"
      );
    });

    it("should throw error if service role key is missing", async () => {
      const service = makeService({ serviceRoleKey: "" });
      const uploadItem = makeUploadItem();

      await assert.rejects(
        async () => {
          await service["generateSignedUploadTarget"](uploadItem);
        },
        (error: unknown) =>
          assertWebCompanionError(error, WebCompanionErrorCode.PROVIDER_UNAVAILABLE),
        "Should throw error for missing service role key"
      );
    });

    it("should throw error if bucket is missing", async () => {
      const service = makeService({ bucket: "" });
      const uploadItem = makeUploadItem();

      await assert.rejects(
        async () => {
          await service["generateSignedUploadTarget"](uploadItem);
        },
        (error: unknown) =>
          assertWebCompanionError(error, WebCompanionErrorCode.PROVIDER_UNAVAILABLE),
        "Should throw error for missing bucket"
      );
    });

    it("should throw error for non-Supabase provider", async () => {
      const service = makeService({});
      const uploadItem = makeUploadItem(StorageProvider.LAN);

      await assert.rejects(
        async () => {
          await service["generateSignedUploadTarget"](uploadItem);
        },
        (error: unknown) =>
          assertWebCompanionError(
            error,
            WebCompanionErrorCode.PROVIDER_UNAVAILABLE,
            /Signed upload not supported for provider/,
          ),
        "Should throw error for non-Supabase provider"
      );
    });

    it("generates a signed upload target for COS without requiring Supabase REST credentials", async () => {
      const service = makeService({
        provider: "cos" as SupabaseStorageConfig["provider"],
        url: "",
        serviceRoleKey: "",
        anonKey: "",
        bucket: "counter-1252496948",
        s3: {
          endpoint: "https://cos.ap-guangzhou.myqcloud.com",
          region: "ap-guangzhou",
          accessKeyId: "cos-secret-id",
          secretAccessKey: "cos-secret-key",
        },
      });
      const uploadItem = {
        ...makeUploadItem("cos" as UploadItem["provider"]),
        bucket: "counter-1252496948",
        objectKey: "web-companion/child_123/session_123/item_123/test.jpg",
      };

      const target = await service["generateSignedUploadTarget"](uploadItem);

      assert.equal(target.method, "PUT");
      assert.match(target.url, /^https:\/\/counter-1252496948\.cos\.ap-guangzhou\.myqcloud\.com\/web-companion\//);
      assert.match(target.url, /q-sign-algorithm|sign=/);
      assert.equal(target.url.includes("cos-secret-key"), false);
    });
  });
});
