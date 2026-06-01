/**
 * Web Companion 控制器单元测试
 * 严格按照 TDD 方式验证 API 端点
 */

import { strict as assert } from "node:assert";
import { test, describe, beforeEach } from "node:test";

import { WebCompanionController } from "../../../../src/modules/web-companion/web-companion.controller.ts";
import { StorageProvider, WebCompanionErrorCode } from "../../../../src/modules/web-companion/constants.ts";
import {
  createUnusedBrowseService,
  createUnusedShareTokenService,
} from "./controller-test-doubles.ts";

import type {
  CreateSessionRequest,
  CreateSessionResponse,
  CreateUploadItemsRequest,
  CommitUploadItemRequest,
  RetryUploadItemRequest,
  CloseSessionRequest,
  SessionSummaryResponse,
  SessionDetailResponse,
} from "../../../../src/modules/web-companion/types.ts";

type AsyncSpy<Args extends readonly unknown[], Result> = ((...args: Args) => Promise<Result>) & {
  calls: Args[];
  callCount(): number;
  setImplementation(next: (...args: Args) => Promise<Result> | Result): void;
};

function createAsyncSpy<Args extends readonly unknown[], Result>(): AsyncSpy<Args, Result> {
  let implementation = async (): Promise<Result> => {
    throw new Error("Mock implementation missing");
  };
  const calls: Args[] = [];
  const spy = async (...args: Args): Promise<Result> => {
    calls.push(args);
    return implementation(...args);
  };
  return Object.assign(spy, {
    calls,
    callCount() {
      return calls.length;
    },
    setImplementation(next: (...args: Args) => Promise<Result> | Result) {
      implementation = async (...args: Args) => next(...args);
    },
  });
}

type ControllerArgs = ConstructorParameters<typeof WebCompanionController>;
type WebCompanionServicePort = ControllerArgs[0];
type MockWebCompanionService = {
  createSession: AsyncSpy<Parameters<WebCompanionServicePort["createSession"]>, Awaited<ReturnType<WebCompanionServicePort["createSession"]>>>;
  getSessionSummary: AsyncSpy<Parameters<WebCompanionServicePort["getSessionSummary"]>, Awaited<ReturnType<WebCompanionServicePort["getSessionSummary"]>>>;
  getSessionDetail: AsyncSpy<Parameters<WebCompanionServicePort["getSessionDetail"]>, Awaited<ReturnType<WebCompanionServicePort["getSessionDetail"]>>>;
  createUploadItems: AsyncSpy<Parameters<WebCompanionServicePort["createUploadItems"]>, Awaited<ReturnType<WebCompanionServicePort["createUploadItems"]>>>;
  commitUploadItem: AsyncSpy<Parameters<WebCompanionServicePort["commitUploadItem"]>, Awaited<ReturnType<WebCompanionServicePort["commitUploadItem"]>>>;
  retryUploadItem: AsyncSpy<Parameters<WebCompanionServicePort["retryUploadItem"]>, Awaited<ReturnType<WebCompanionServicePort["retryUploadItem"]>>>;
  closeSession: AsyncSpy<Parameters<WebCompanionServicePort["closeSession"]>, Awaited<ReturnType<WebCompanionServicePort["closeSession"]>>>;
};

function createWebCompanionError(code: string, message: string) {
  return Object.assign(new Error(message), { code });
}

function assertHttpError(
  error: unknown,
  expectedStatus: number,
  expectedCode: string,
  expectedMessage: string,
) {
  assert.ok(error instanceof Error);
  const httpError = error as Error & {
    status?: number;
    response?: { code?: string; message?: string };
  };
  assert.equal(httpError.status, expectedStatus);
  assert.equal(httpError.response?.code, expectedCode);
  assert.match(httpError.response?.message ?? "", new RegExp(expectedMessage));
  return true;
}

describe("WebCompanionController", () => {
  let controller: WebCompanionController;
  let mockService: MockWebCompanionService;

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
    webUrl: `http://localhost:3000/app?sessionId=${mockSessionId}&token=${mockToken}`,
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
      createSession: createAsyncSpy(),
      getSessionSummary: createAsyncSpy(),
      getSessionDetail: createAsyncSpy(),
      createUploadItems: createAsyncSpy(),
      commitUploadItem: createAsyncSpy(),
      retryUploadItem: createAsyncSpy(),
      closeSession: createAsyncSpy(),
    };

    controller = new WebCompanionController(
      mockService,
      createUnusedBrowseService(),
      createUnusedShareTokenService(),
    );
  });

  describe("POST /sessions", () => {
    test("should create a new session successfully", async () => {
      mockService.createSession.setImplementation(async () => mockCreateSessionResponse);

      const result = await controller.createSession(mockCreateSessionRequest);

      assert.deepEqual(result, mockCreateSessionResponse);
      assert.equal(mockService.createSession.callCount(), 1);
      assert.deepEqual(mockService.createSession.calls[0][0], mockCreateSessionRequest);
    });

    test("should handle service errors", async () => {
      mockService.createSession.setImplementation(async () => {
        throw createWebCompanionError(WebCompanionErrorCode.SESSION_NOT_FOUND, "Child not found");
      });

      await assert.rejects(
        async () => controller.createSession(mockCreateSessionRequest),
        (error: unknown) =>
          assertHttpError(error, 404, WebCompanionErrorCode.SESSION_NOT_FOUND, "Child not found"),
      );
    });

    test("should handle unexpected errors", async () => {
      mockService.createSession.setImplementation(async () => {
        throw new Error("Database connection failed");
      });

      await assert.rejects(
        async () => controller.createSession(mockCreateSessionRequest),
        (error: unknown) =>
          assertHttpError(error, 500, "INTERNAL_ERROR", "Database connection failed"),
      );
    });
  });

  describe("GET /sessions/:sessionId", () => {
    test("should get session summary successfully", async () => {
      mockService.getSessionSummary.setImplementation(async () => mockSessionSummaryResponse);

      const result = await controller.getSessionSummary(mockSessionId);

      assert.deepEqual(result, mockSessionSummaryResponse);
      assert.equal(mockService.getSessionSummary.callCount(), 1);
      assert.equal(mockService.getSessionSummary.calls[0][0], mockSessionId);
    });

    test("should handle session not found", async () => {
      mockService.getSessionSummary.setImplementation(async () => {
        throw createWebCompanionError(WebCompanionErrorCode.SESSION_NOT_FOUND, "Session not found");
      });

      await assert.rejects(
        async () => controller.getSessionSummary("invalid-session"),
        (error: unknown) =>
          assertHttpError(error, 404, WebCompanionErrorCode.SESSION_NOT_FOUND, "Session not found"),
      );
    });
  });

  describe("GET /sessions/:sessionId/detail", () => {
    test("should get session detail with token", async () => {
      const mockDetailResponse: SessionDetailResponse = {
        sessionId: mockSessionId,
        items: [],
      };

      mockService.getSessionDetail.setImplementation(async () => mockDetailResponse);

      const result = await controller.getSessionDetail(mockSessionId, mockToken);

      assert.deepEqual(result, mockDetailResponse);
      assert.equal(mockService.getSessionDetail.callCount(), 1);
      assert.equal(mockService.getSessionDetail.calls[0][0], mockSessionId);
      assert.equal(mockService.getSessionDetail.calls[0][1], mockToken);
    });

    test("should handle invalid token", async () => {
      mockService.getSessionDetail.setImplementation(async () => {
        throw createWebCompanionError(WebCompanionErrorCode.TOKEN_INVALID, "Invalid token");
      });

      await assert.rejects(
        async () => controller.getSessionDetail(mockSessionId, "invalid-token"),
        (error: unknown) =>
          assertHttpError(error, 401, WebCompanionErrorCode.TOKEN_INVALID, "Invalid token"),
      );
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

      mockService.createUploadItems.setImplementation(async () => mockResponse);

      const result = await controller.createUploadItems(mockSessionId, request);

      assert.deepEqual(result, mockResponse);
      assert.equal(mockService.createUploadItems.callCount(), 1);
      assert.equal(mockService.createUploadItems.calls[0][0], mockSessionId);
      assert.deepEqual(mockService.createUploadItems.calls[0][1], request);
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

      mockService.commitUploadItem.setImplementation(async () => mockResponse);

      const result = await controller.commitUploadItem(mockSessionId, "item_123", request);

      assert.deepEqual(result, mockResponse);
      assert.equal(mockService.commitUploadItem.callCount(), 1);
      assert.equal(mockService.commitUploadItem.calls[0][0], mockSessionId);
      assert.equal(mockService.commitUploadItem.calls[0][1], "item_123");
      assert.deepEqual(mockService.commitUploadItem.calls[0][2], request);
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

      mockService.retryUploadItem.setImplementation(async () => mockResponse);

      const result = await controller.retryUploadItem(mockSessionId, "item_123", request);

      assert.deepEqual(result, mockResponse);
      assert.equal(mockService.retryUploadItem.callCount(), 1);
      assert.equal(mockService.retryUploadItem.calls[0][0], mockSessionId);
      assert.equal(mockService.retryUploadItem.calls[0][1], "item_123");
      assert.deepEqual(mockService.retryUploadItem.calls[0][2], request);
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

      mockService.closeSession.setImplementation(async () => undefined);

      const result = await controller.closeSession(mockSessionId, request);

      assert.deepEqual(result, mockResponse);
      assert.equal(mockService.closeSession.callCount(), 1);
      assert.equal(mockService.closeSession.calls[0][0], mockSessionId);
      assert.deepEqual(mockService.closeSession.calls[0][1], request);
    });
  });

  describe("Error Handling", () => {
    test("should handle service throwing errors", async () => {
      mockService.createSession.setImplementation(() => {
        throw new Error("Service error");
      });

      await assert.rejects(
        async () => controller.createSession(mockCreateSessionRequest),
        (error: unknown) =>
          assertHttpError(error, 500, "INTERNAL_ERROR", "Service error"),
      );
    });

    test("should handle async service errors", async () => {
      mockService.getSessionSummary.setImplementation(async () => {
        throw new Error("Async service error");
      });

      await assert.rejects(
        async () => controller.getSessionSummary(mockSessionId),
        (error: unknown) =>
          assertHttpError(error, 500, "INTERNAL_ERROR", "Async service error"),
      );
    });
  });
});
