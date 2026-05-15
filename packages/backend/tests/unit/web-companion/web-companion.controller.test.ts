/**
 * Web Companion 控制器单元测试
 * 严格按照 TDD 方式验证 API 端点
 */

import { strict as assert } from "node:assert";
import { test, describe, beforeEach, mock } from "node:test";

import { WebCompanionController } from "../../../src/modules/web-companion/web-companion.controller.ts";
import { StorageProvider, WebCompanionErrorCode } from "../../../src/modules/web-companion/constants.ts";

import type {
  CreateSessionRequest,
  CreateSessionResponse,
  CreateUploadItemsRequest,
  CommitUploadItemRequest,
  RetryUploadItemRequest,
  CloseSessionRequest,
  SessionSummaryResponse,
  SessionDetailResponse,
  ErrorResponse,
} from "../../../src/modules/web-companion/types.ts";

describe("WebCompanionController", () => {
  let controller: WebCompanionController;
  let mockService: any;

  // Mock 数据
  const mockSessionId = "session_1234567890_abcdef12";
  const mockToken = "a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456";
  const mockChildId = "child-test-001";

  const mockCreateSessionRequest: CreateSessionRequest = {
    childId: mockChildId,
    expiresInMinutes: 60,
    maxItems: 10,
    preferredProviders: [StorageProvider.SUPABASE],
  };

  const mockCreateSessionResponse: CreateSessionResponse = {
    sessionId: mockSessionId,
    token: mockToken,
    webUrl: `http://localhost:3000/trusted-upload?sessionId=${mockSessionId}&token=${mockToken}`,
    expiresAt: new Date(Date.now() + 60 * 60 * 1000).toISOString(),
    maxItems: 10,
  };

  const mockSessionSummaryResponse: SessionSummaryResponse = {
    sessionId: mockSessionId,
    status: "active",
    child: {
      id: mockChildId,
      displayName: "测试孩子",
    },
    expiresAt: new Date(Date.now() + 60 * 60 * 1000).toISOString(),
    maxItems: 10,
    usedItems: 0,
    providers: {
      lan: { available: false },
      supabase: { available: true },
    },
  };

  beforeEach(() => {
    mockService = {
      createSession: mock.fn(),
      getSessionSummary: mock.fn(),
      getSessionDetail: mock.fn(),
      createUploadItems: mock.fn(),
      commitUploadItem: mock.fn(),
      retryUploadItem: mock.fn(),
      closeSession: mock.fn(),
    };

    controller = new WebCompanionController(mockService);
  });

  describe("POST /sessions", () => {
    test("should create a new session successfully", async () => {
      mockService.createSession.mock.mockImplementation(() =>
        Promise.resolve(mockCreateSessionResponse)
      );

      const result = await controller.createSession(mockCreateSessionRequest);

      assert.deepEqual(result, mockCreateSessionResponse);
      assert.equal(mockService.createSession.mock.callCount(), 1);
      assert.deepEqual(mockService.createSession.mock.calls[0].arguments[0], mockCreateSessionRequest);
    });

    test("should handle service errors", async () => {
      const errorResponse: ErrorResponse = {
        error: {
          code: WebCompanionErrorCode.CHILD_NOT_FOUND,
          message: "Child not found",
        },
      };

      mockService.createSession.mock.mockImplementation(() =>
        Promise.resolve(errorResponse)
      );

      const result = await controller.createSession(mockCreateSessionRequest);

      assert.deepEqual(result, errorResponse);
    });

    test("should handle unexpected errors", async () => {
      mockService.createSession.mock.mockImplementation(() =>
        Promise.reject(new Error("Database connection failed"))
      );

      await assert.rejects(
        async () => controller.createSession(mockCreateSessionRequest),
        (err: any) => {
          assert.equal(err.status, 500);
          assert.equal(err.response.code, "INTERNAL_ERROR");
          assert(err.response.message.includes("Database connection failed"));
          return true;
        }
      );
    });
  });

  describe("GET /sessions/:sessionId", () => {
    test("should get session summary successfully", async () => {
      mockService.getSessionSummary.mock.mockImplementation(() =>
        Promise.resolve(mockSessionSummaryResponse)
      );

      const result = await controller.getSessionSummary(mockSessionId);

      assert.deepEqual(result, mockSessionSummaryResponse);
      assert.equal(mockService.getSessionSummary.mock.callCount(), 1);
      assert.equal(mockService.getSessionSummary.mock.calls[0].arguments[0], mockSessionId);
    });

    test("should handle session not found", async () => {
      const errorResponse: ErrorResponse = {
        error: {
          code: WebCompanionErrorCode.SESSION_NOT_FOUND,
          message: "Session not found",
        },
      };

      mockService.getSessionSummary.mock.mockImplementation(() =>
        Promise.resolve(errorResponse)
      );

      const result = await controller.getSessionSummary("invalid-session");

      assert.deepEqual(result, errorResponse);
    });
  });

  describe("GET /sessions/:sessionId/detail", () => {
    test("should get session detail with token", async () => {
      const mockDetailResponse: SessionDetailResponse = {
        sessionId: mockSessionId,
        items: [],
      };

      mockService.getSessionDetail.mock.mockImplementation(() =>
        Promise.resolve(mockDetailResponse)
      );

      const result = await controller.getSessionDetail(mockSessionId, mockToken);

      assert.deepEqual(result, mockDetailResponse);
      assert.equal(mockService.getSessionDetail.mock.callCount(), 1);
      assert.equal(mockService.getSessionDetail.mock.calls[0].arguments[0], mockSessionId);
      assert.equal(mockService.getSessionDetail.mock.calls[0].arguments[1], mockToken);
    });

    test("should handle invalid token", async () => {
      const errorResponse: ErrorResponse = {
        error: {
          code: WebCompanionErrorCode.INVALID_TOKEN,
          message: "Invalid token",
        },
      };

      mockService.getSessionDetail.mock.mockImplementation(() =>
        Promise.resolve(errorResponse)
      );

      const result = await controller.getSessionDetail(mockSessionId, "invalid-token");

      assert.deepEqual(result, errorResponse);
    });
  });

  describe("POST /sessions/:sessionId/items", () => {
    test("should create upload items successfully", async () => {
      const request: CreateUploadItemsRequest = {
        token: mockToken,
        files: [
          {
            clientFileId: "file1",
            filename: "test.jpg",
            contentType: "image/jpeg",
            sizeBytes: 1024,
          },
        ],
        provider: StorageProvider.SUPABASE,
      };

      const mockResponse = {
        items: [
          {
            uploadItemId: "item_123",
            clientFileId: "file1",
            assetId: "asset_456",
            objectKey: "uploads/test.jpg",
            status: "pending" as const,
            signedUpload: {
              method: "PUT" as const,
              url: "https://example.com/signed-upload",
              expiresAt: new Date(Date.now() + 3600000).toISOString(),
              headers: { "Content-Type": "image/jpeg" },
            },
          },
        ],
      };

      mockService.createUploadItems.mock.mockImplementation(() =>
        Promise.resolve(mockResponse)
      );

      const result = await controller.createUploadItems(mockSessionId, request);

      assert.deepEqual(result, mockResponse);
      assert.equal(mockService.createUploadItems.mock.callCount(), 1);
      assert.equal(mockService.createUploadItems.mock.calls[0].arguments[0], mockSessionId);
      assert.deepEqual(mockService.createUploadItems.mock.calls[0].arguments[1], request);
    });
  });

  describe("PUT /sessions/:sessionId/items/:uploadItemId/commit", () => {
    test("should commit upload item successfully", async () => {
      const request: CommitUploadItemRequest = {
        token: mockToken,
        objectKey: "uploads/test.jpg",
        sizeBytes: 1024,
        contentType: "image/jpeg",
        remoteEtag: "etag123",
      };

      const mockResponse = {
        uploadItemId: "item_123",
        status: "uploaded_remote" as const,
      };

      mockService.commitUploadItem.mock.mockImplementation(() =>
        Promise.resolve(mockResponse)
      );

      const result = await controller.commitUploadItem(mockSessionId, "item_123", request);

      assert.deepEqual(result, mockResponse);
      assert.equal(mockService.commitUploadItem.mock.callCount(), 1);
      assert.equal(mockService.commitUploadItem.mock.calls[0].arguments[0], mockSessionId);
      assert.equal(mockService.commitUploadItem.mock.calls[0].arguments[1], "item_123");
      assert.deepEqual(mockService.commitUploadItem.mock.calls[0].arguments[2], request);
    });
  });

  describe("POST /sessions/:sessionId/items/:uploadItemId/retry", () => {
    test("should retry upload item successfully", async () => {
      const request: RetryUploadItemRequest = {
        token: mockToken,
      };

      const mockResponse = {
        uploadItemId: "item_123",
        status: "pending" as const,
      };

      mockService.retryUploadItem.mock.mockImplementation(() =>
        Promise.resolve(mockResponse)
      );

      const result = await controller.retryUploadItem(mockSessionId, "item_123", request);

      assert.deepEqual(result, mockResponse);
      assert.equal(mockService.retryUploadItem.mock.callCount(), 1);
      assert.equal(mockService.retryUploadItem.mock.calls[0].arguments[0], mockSessionId);
      assert.equal(mockService.retryUploadItem.mock.calls[0].arguments[1], "item_123");
      assert.deepEqual(mockService.retryUploadItem.mock.calls[0].arguments[2], request);
    });
  });

  describe("POST /sessions/:sessionId/close", () => {
    test("should close session successfully", async () => {
      const request: CloseSessionRequest = {
        token: mockToken,
      };

      const mockResponse = {
        success: true,
      };

      mockService.closeSession.mock.mockImplementation(() =>
        Promise.resolve(undefined)
      );

      const result = await controller.closeSession(mockSessionId, request);

      assert.deepEqual(result, mockResponse);
      assert.equal(mockService.closeSession.mock.callCount(), 1);
      assert.equal(mockService.closeSession.mock.calls[0].arguments[0], mockSessionId);
      assert.deepEqual(mockService.closeSession.mock.calls[0].arguments[1], request);
    });
  });

  describe("Error Handling", () => {
    test("should handle service throwing errors", async () => {
      mockService.createSession.mock.mockImplementation(() => {
        throw new Error("Service error");
      });

      await assert.rejects(
        async () => controller.createSession(mockCreateSessionRequest),
        (err: any) => {
          assert.equal(err.status, 500);
          assert.equal(err.response.code, "INTERNAL_ERROR");
          assert(err.response.message.includes("Service error"));
          return true;
        }
      );
    });

    test("should handle async service errors", async () => {
      mockService.getSessionSummary.mock.mockImplementation(async () => {
        throw new Error("Async service error");
      });

      await assert.rejects(
        async () => controller.getSessionSummary(mockSessionId),
        (err: any) => {
          assert.equal(err.status, 500);
          assert.equal(err.response.code, "INTERNAL_ERROR");
          assert(err.response.message.includes("Async service error"));
          return true;
        }
      );
    });
  });
});
