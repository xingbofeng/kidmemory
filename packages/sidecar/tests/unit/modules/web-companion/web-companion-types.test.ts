import { strict as assert } from "node:assert";
import { test, describe } from "node:test";

import type {
  CreateSessionRequest,
  CreateUploadItemsRequest,
  CommitUploadItemRequest,
  CreateSessionResponse,
  SessionSummaryResponse,
  UploadItemResponse,
  UploadSession,
  UploadItem,
  WebCompanionConfig,
} from "../../../../src/modules/web-companion/types.ts";

import {
  UploadSessionStatus,
  UploadItemStatus,
  StorageProvider,
  WebCompanionErrorCode,
} from "../../../../src/modules/web-companion/constants.ts";

describe("Web Companion Types", () => {
  describe("Request DTOs", () => {
    test("CreateSessionRequest should have correct structure", () => {
      const request: CreateSessionRequest = {
        childId: "child-123",
        expiresInMinutes: 180,
        maxItems: 100,
        preferredProviders: [StorageProvider.LAN, StorageProvider.SUPABASE],
      };

      assert.equal(typeof request.childId, "string");
      assert.equal(typeof request.expiresInMinutes, "number");
      assert.equal(typeof request.maxItems, "number");
      assert(Array.isArray(request.preferredProviders));
    });

    test("CreateUploadItemsRequest should have correct structure", () => {
      const request: CreateUploadItemsRequest = {
        token: "session-token-123",
        files: [
          {
            clientFileId: "file-1",
            filename: "photo.jpg",
            contentType: "image/jpeg",
            sizeBytes: 1024000,
          },
        ],
        provider: StorageProvider.SUPABASE,
      };

      assert.equal(typeof request.token, "string");
      assert(Array.isArray(request.files));
      assert.equal(request.files.length, 1);
      assert.equal(typeof request.files[0].clientFileId, "string");
      assert.equal(typeof request.files[0].filename, "string");
      assert.equal(typeof request.files[0].contentType, "string");
      assert.equal(typeof request.files[0].sizeBytes, "number");
      assert.equal(request.provider, StorageProvider.SUPABASE);
    });

    test("CommitUploadItemRequest should have correct structure", () => {
      const request: CommitUploadItemRequest = {
        token: "session-token-123",
        objectKey: "uploads/child-123/asset-456.jpg",
        sizeBytes: 1024000,
        contentType: "image/jpeg",
        remoteEtag: "etag-123",
      };

      assert.equal(typeof request.token, "string");
      assert.equal(typeof request.objectKey, "string");
      assert.equal(typeof request.sizeBytes, "number");
      assert.equal(typeof request.contentType, "string");
      assert.equal(typeof request.remoteEtag, "string");
    });
  });

  describe("Response DTOs", () => {
    test("CreateSessionResponse should have correct structure", () => {
      const response: CreateSessionResponse = {
        sessionId: "session-123",
        token: "token-456",
        webUrl: "https://app.example.com/upload?token=token-456",
        expiresAt: "2024-01-01T12:00:00Z",
        maxItems: 200,
      };

      assert.equal(typeof response.sessionId, "string");
      assert.equal(typeof response.token, "string");
      assert.equal(typeof response.webUrl, "string");
      assert.equal(typeof response.expiresAt, "string");
      assert.equal(typeof response.maxItems, "number");
    });

    test("SessionSummaryResponse should have correct structure", () => {
      const response: SessionSummaryResponse = {
        sessionId: "session-123",
        status: UploadSessionStatus.ACTIVE,
        child: {
          id: "child-123",
          displayName: "Alice",
        },
        expiresAt: "2024-01-01T12:00:00Z",
        maxItems: 200,
        usedItems: 5,
        providers: {
          lan: {
            available: true,
            endpoint: "http://192.168.1.100:3001",
          },
          supabase: {
            available: true,
          },
        },
      };

      assert.equal(typeof response.sessionId, "string");
      assert.equal(response.status, UploadSessionStatus.ACTIVE);
      assert.equal(typeof response.child.id, "string");
      assert.equal(typeof response.child.displayName, "string");
      assert.equal(typeof response.expiresAt, "string");
      assert.equal(typeof response.maxItems, "number");
      assert.equal(typeof response.usedItems, "number");
      assert.equal(typeof response.providers, "object");
    });

    test("UploadItemResponse should have correct structure", () => {
      const response: UploadItemResponse = {
        clientFileId: "file-1",
        uploadItemId: "item-123",
        assetId: "asset-456",
        objectKey: "uploads/child-123/asset-456.jpg",
        status: UploadItemStatus.SIGNING,
        signedUpload: {
          method: "PUT",
          url: "https://storage.example.com/upload-url",
          expiresAt: "2024-01-01T12:30:00Z",
          headers: {
            "Content-Type": "image/jpeg",
            "Authorization": "Bearer token",
          },
        },
      };

      assert.equal(typeof response.clientFileId, "string");
      assert.equal(typeof response.uploadItemId, "string");
      assert.equal(typeof response.assetId, "string");
      assert.equal(typeof response.objectKey, "string");
      assert.equal(response.status, UploadItemStatus.SIGNING);
      assert.equal(response.signedUpload?.method, "PUT");
      assert.equal(typeof response.signedUpload?.url, "string");
      assert.equal(typeof response.signedUpload?.expiresAt, "string");
      assert.equal(typeof response.signedUpload?.headers, "object");
    });
  });

  describe("Data Models", () => {
    test("UploadSession should have correct structure", () => {
      const session: UploadSession = {
        id: "session-123",
        childId: "child-456",
        tokenHash: "hash-789",
        status: UploadSessionStatus.ACTIVE,
        expiresAt: new Date("2024-01-01T12:00:00Z"),
        maxItems: 200,
        createdAt: new Date("2024-01-01T09:00:00Z"),
        closedAt: undefined,
        lastSeenAt: new Date("2024-01-01T10:00:00Z"),
      };

      assert.equal(typeof session.id, "string");
      assert.equal(typeof session.childId, "string");
      assert.equal(typeof session.tokenHash, "string");
      assert.equal(session.status, UploadSessionStatus.ACTIVE);
      assert(session.expiresAt instanceof Date);
      assert.equal(typeof session.maxItems, "number");
      assert(session.createdAt instanceof Date);
      assert.equal(session.closedAt, undefined);
      assert(session.lastSeenAt instanceof Date);
    });

    test("UploadItem should have correct structure", () => {
      const item: UploadItem = {
        id: "item-123",
        sessionId: "session-456",
        assetId: "asset-789",
        clientFileId: "file-1",
        originalFilename: "photo.jpg",
        safeFilename: "photo_safe.jpg",
        contentType: "image/jpeg",
        sizeBytes: 1024000,
        provider: StorageProvider.SUPABASE,
        bucket: "uploads",
        objectKey: "uploads/child-123/asset-789.jpg",
        status: UploadItemStatus.UPLOADING,
        remoteEtag: "etag-123",
        localPath: "/local/path/asset-789.jpg",
        hashSha256: "sha256-hash",
        errorCode: undefined,
        errorMessage: undefined,
        createdAt: new Date("2024-01-01T09:00:00Z"),
        updatedAt: new Date("2024-01-01T10:00:00Z"),
        committedAt: new Date("2024-01-01T10:30:00Z"),
        readyAt: undefined,
      };

      assert.equal(typeof item.id, "string");
      assert.equal(typeof item.sessionId, "string");
      assert.equal(typeof item.assetId, "string");
      assert.equal(typeof item.clientFileId, "string");
      assert.equal(typeof item.originalFilename, "string");
      assert.equal(typeof item.safeFilename, "string");
      assert.equal(typeof item.contentType, "string");
      assert.equal(typeof item.sizeBytes, "number");
      assert.equal(item.provider, StorageProvider.SUPABASE);
      assert.equal(typeof item.bucket, "string");
      assert.equal(typeof item.objectKey, "string");
      assert.equal(item.status, UploadItemStatus.UPLOADING);
      assert.equal(typeof item.remoteEtag, "string");
      assert.equal(typeof item.localPath, "string");
      assert.equal(typeof item.hashSha256, "string");
      assert.equal(item.errorCode, undefined);
      assert.equal(item.errorMessage, undefined);
      assert(item.createdAt instanceof Date);
      assert(item.updatedAt instanceof Date);
      assert(item.committedAt instanceof Date);
      assert.equal(item.readyAt, undefined);
    });
  });

  describe("Configuration", () => {
    test("WebCompanionConfig should have correct structure", () => {
      const config: WebCompanionConfig = {
        baseUrl: "https://api.example.com",
        sessionTtlMinutes: 180,
        maxItemsPerSession: 200,
        maxFileSizeBytes: 50 * 1024 * 1024,
        allowedContentTypes: ["image/jpeg", "image/png"],
        supabase: {
          url: "https://project.supabase.co",
          serviceRoleKey: "service-role-key",
          uploadBucket: "uploads",
        },
        lan: {
          host: "192.168.1.100",
          port: 3001,
        },
      };

      assert.equal(typeof config.baseUrl, "string");
      assert.equal(typeof config.sessionTtlMinutes, "number");
      assert.equal(typeof config.maxItemsPerSession, "number");
      assert.equal(typeof config.maxFileSizeBytes, "number");
      assert(Array.isArray(config.allowedContentTypes));
      assert.equal(typeof config.supabase?.url, "string");
      assert.equal(typeof config.supabase?.serviceRoleKey, "string");
      assert.equal(typeof config.supabase?.uploadBucket, "string");
      assert.equal(typeof config.lan?.host, "string");
      assert.equal(typeof config.lan?.port, "number");
    });
  });

  describe("Type Compatibility", () => {
    test("enum values should be compatible with string literals", () => {
      // 测试枚举值可以赋值给字符串字面量类型
      const sessionStatus: "active" | "closed" | "expired" = UploadSessionStatus.ACTIVE;
      const itemStatus: "pending" | "ready" = UploadItemStatus.PENDING;
      const provider: "lan" | "supabase" = StorageProvider.LAN;

      assert.equal(sessionStatus, "active");
      assert.equal(itemStatus, "pending");
      assert.equal(provider, "lan");
    });

    test("error codes should be string constants", () => {
      const errorCode: string = WebCompanionErrorCode.SESSION_NOT_FOUND;
      assert.equal(typeof errorCode, "string");
      assert.equal(errorCode, "SESSION_NOT_FOUND");
    });

    test("optional fields should work correctly", () => {
      // 测试可选字段
      const minimalRequest: CreateSessionRequest = {
        childId: "child-123",
      };

      const minimalItem: Partial<UploadItem> = {
        id: "item-123",
        sessionId: "session-456",
        assetId: "asset-789",
        originalFilename: "photo.jpg",
        safeFilename: "photo_safe.jpg",
        contentType: "image/jpeg",
        sizeBytes: 1024000,
        provider: StorageProvider.LAN,
        objectKey: "uploads/photo.jpg",
        status: UploadItemStatus.PENDING,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      assert.equal(typeof minimalRequest.childId, "string");
      assert.equal(minimalRequest.expiresInMinutes, undefined);
      assert.equal(typeof minimalItem.id, "string");
      assert.equal(minimalItem.clientFileId, undefined);
    });
  });

  describe("Error Response Structure", () => {
    test("ErrorResponse should have correct structure", () => {
      const errorResponse = {
        error: {
          code: WebCompanionErrorCode.SESSION_NOT_FOUND,
          message: "Session not found",
          details: {
            sessionId: "session-123",
            timestamp: "2024-01-01T12:00:00Z",
          },
        },
      };

      assert.equal(typeof errorResponse.error.code, "string");
      assert.equal(typeof errorResponse.error.message, "string");
      assert.equal(typeof errorResponse.error.details, "object");
      assert.equal(errorResponse.error.code, "SESSION_NOT_FOUND");
    });
  });
});