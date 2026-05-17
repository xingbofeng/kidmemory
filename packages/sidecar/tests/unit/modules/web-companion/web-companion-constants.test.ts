import { strict as assert } from "node:assert";
import { test, describe } from "node:test";

import {
  UploadSessionStatus,
  UploadItemStatus,
  StorageProvider,
  WebCompanionErrorCode,
  SESSION_STATUS_TRANSITIONS,
  UPLOAD_ITEM_STATUS_TRANSITIONS,
  DEFAULT_CONFIG,
  isValidSessionStatusTransition,
  isValidUploadItemStatusTransition,
  canCreateUploadItems,
  isUploadItemTerminal,
  canRetryUploadItem,
} from "../../../../src/modules/web-companion/constants.ts";

describe("Web Companion Constants", () => {
  describe("Enums", () => {
    test("UploadSessionStatus should have correct values", () => {
      assert.equal(UploadSessionStatus.ACTIVE, "active");
      assert.equal(UploadSessionStatus.CLOSED, "closed");
      assert.equal(UploadSessionStatus.EXPIRED, "expired");
    });

    test("UploadItemStatus should have correct values", () => {
      assert.equal(UploadItemStatus.PENDING, "pending");
      assert.equal(UploadItemStatus.SIGNING, "signing");
      assert.equal(UploadItemStatus.UPLOADING, "uploading");
      assert.equal(UploadItemStatus.UPLOADED_REMOTE, "uploaded_remote");
      assert.equal(UploadItemStatus.PULLING_LOCAL, "pulling_local");
      assert.equal(UploadItemStatus.READY, "ready");
      assert.equal(UploadItemStatus.FAILED, "failed");
      assert.equal(UploadItemStatus.CANCELED, "canceled");
    });

    test("StorageProvider should have correct values", () => {
      assert.equal(StorageProvider.LAN, "lan");
      assert.equal(StorageProvider.SUPABASE, "supabase");
    });
  });

  describe("Error Codes", () => {
    test("should have session related error codes", () => {
      assert.equal(WebCompanionErrorCode.SESSION_NOT_FOUND, "SESSION_NOT_FOUND");
      assert.equal(WebCompanionErrorCode.SESSION_EXPIRED, "SESSION_EXPIRED");
      assert.equal(WebCompanionErrorCode.SESSION_CLOSED, "SESSION_CLOSED");
      assert.equal(WebCompanionErrorCode.TOKEN_INVALID, "TOKEN_INVALID");
    });

    test("should have upload limit error codes", () => {
      assert.equal(WebCompanionErrorCode.ITEM_LIMIT_EXCEEDED, "ITEM_LIMIT_EXCEEDED");
      assert.equal(WebCompanionErrorCode.FILE_TYPE_UNSUPPORTED, "FILE_TYPE_UNSUPPORTED");
      assert.equal(WebCompanionErrorCode.FILE_TOO_LARGE, "FILE_TOO_LARGE");
    });

    test("should have storage provider error codes", () => {
      assert.equal(WebCompanionErrorCode.PROVIDER_UNAVAILABLE, "PROVIDER_UNAVAILABLE");
      assert.equal(WebCompanionErrorCode.SIGNED_UPLOAD_UNAVAILABLE, "SIGNED_UPLOAD_UNAVAILABLE");
    });

    test("should have upload item error codes", () => {
      assert.equal(WebCompanionErrorCode.OBJECT_KEY_MISMATCH, "OBJECT_KEY_MISMATCH");
      assert.equal(WebCompanionErrorCode.UPLOAD_ITEM_NOT_FOUND, "UPLOAD_ITEM_NOT_FOUND");
      assert.equal(WebCompanionErrorCode.COMMIT_CONFLICT, "COMMIT_CONFLICT");
    });

    test("should have pullback and storage error codes", () => {
      assert.equal(WebCompanionErrorCode.PULLBACK_FAILED, "PULLBACK_FAILED");
      assert.equal(WebCompanionErrorCode.LOCAL_STORAGE_FAILED, "LOCAL_STORAGE_FAILED");
    });
  });

  describe("Session Status Transitions", () => {
    test("ACTIVE session can transition to CLOSED or EXPIRED", () => {
      const transitions = SESSION_STATUS_TRANSITIONS[UploadSessionStatus.ACTIVE];
      assert(transitions.includes(UploadSessionStatus.CLOSED));
      assert(transitions.includes(UploadSessionStatus.EXPIRED));
      assert.equal(transitions.length, 2);
    });

    test("CLOSED session can only transition to EXPIRED", () => {
      const transitions = SESSION_STATUS_TRANSITIONS[UploadSessionStatus.CLOSED];
      assert(transitions.includes(UploadSessionStatus.EXPIRED));
      assert.equal(transitions.length, 1);
    });

    test("EXPIRED session cannot transition to any state", () => {
      const transitions = SESSION_STATUS_TRANSITIONS[UploadSessionStatus.EXPIRED];
      assert.equal(transitions.length, 0);
    });

    test("isValidSessionStatusTransition should work correctly", () => {
      // Valid transitions
      assert(isValidSessionStatusTransition(UploadSessionStatus.ACTIVE, UploadSessionStatus.CLOSED));
      assert(isValidSessionStatusTransition(UploadSessionStatus.ACTIVE, UploadSessionStatus.EXPIRED));
      assert(isValidSessionStatusTransition(UploadSessionStatus.CLOSED, UploadSessionStatus.EXPIRED));

      // Invalid transitions
      assert(!isValidSessionStatusTransition(UploadSessionStatus.CLOSED, UploadSessionStatus.ACTIVE));
      assert(!isValidSessionStatusTransition(UploadSessionStatus.EXPIRED, UploadSessionStatus.ACTIVE));
      assert(!isValidSessionStatusTransition(UploadSessionStatus.EXPIRED, UploadSessionStatus.CLOSED));
    });
  });

  describe("Upload Item Status Transitions", () => {
    test("PENDING can transition to multiple states", () => {
      const transitions = UPLOAD_ITEM_STATUS_TRANSITIONS[UploadItemStatus.PENDING];
      assert(transitions.includes(UploadItemStatus.SIGNING));
      assert(transitions.includes(UploadItemStatus.UPLOADING));
      assert(transitions.includes(UploadItemStatus.READY)); // LAN direct upload
      assert(transitions.includes(UploadItemStatus.FAILED));
      assert(transitions.includes(UploadItemStatus.CANCELED));
    });

    test("SIGNING can transition to UPLOADING, FAILED, or CANCELED", () => {
      const transitions = UPLOAD_ITEM_STATUS_TRANSITIONS[UploadItemStatus.SIGNING];
      assert(transitions.includes(UploadItemStatus.UPLOADING));
      assert(transitions.includes(UploadItemStatus.FAILED));
      assert(transitions.includes(UploadItemStatus.CANCELED));
    });

    test("READY and CANCELED are terminal states", () => {
      const readyTransitions = UPLOAD_ITEM_STATUS_TRANSITIONS[UploadItemStatus.READY];
      const canceledTransitions = UPLOAD_ITEM_STATUS_TRANSITIONS[UploadItemStatus.CANCELED];
      assert.equal(readyTransitions.length, 0);
      assert.equal(canceledTransitions.length, 0);
    });

    test("FAILED can transition back to retry states", () => {
      const transitions = UPLOAD_ITEM_STATUS_TRANSITIONS[UploadItemStatus.FAILED];
      assert(transitions.includes(UploadItemStatus.PENDING));
      assert(transitions.includes(UploadItemStatus.SIGNING));
      assert(transitions.includes(UploadItemStatus.UPLOADING));
      assert(transitions.includes(UploadItemStatus.PULLING_LOCAL));
    });

    test("isValidUploadItemStatusTransition should work correctly", () => {
      // Valid transitions
      assert(isValidUploadItemStatusTransition(UploadItemStatus.PENDING, UploadItemStatus.SIGNING));
      assert(isValidUploadItemStatusTransition(UploadItemStatus.SIGNING, UploadItemStatus.UPLOADING));
      assert(isValidUploadItemStatusTransition(UploadItemStatus.UPLOADING, UploadItemStatus.UPLOADED_REMOTE));
      assert(isValidUploadItemStatusTransition(UploadItemStatus.UPLOADED_REMOTE, UploadItemStatus.PULLING_LOCAL));
      assert(isValidUploadItemStatusTransition(UploadItemStatus.PULLING_LOCAL, UploadItemStatus.READY));

      // Invalid transitions
      assert(!isValidUploadItemStatusTransition(UploadItemStatus.READY, UploadItemStatus.PENDING));
      assert(!isValidUploadItemStatusTransition(UploadItemStatus.CANCELED, UploadItemStatus.PENDING));
      assert(!isValidUploadItemStatusTransition(UploadItemStatus.UPLOADING, UploadItemStatus.SIGNING));
    });
  });

  describe("Validation Functions", () => {
    test("canCreateUploadItems should only allow ACTIVE sessions", () => {
      assert(canCreateUploadItems(UploadSessionStatus.ACTIVE));
      assert(!canCreateUploadItems(UploadSessionStatus.CLOSED));
      assert(!canCreateUploadItems(UploadSessionStatus.EXPIRED));
    });

    test("isUploadItemTerminal should identify terminal states", () => {
      assert(isUploadItemTerminal(UploadItemStatus.READY));
      assert(isUploadItemTerminal(UploadItemStatus.CANCELED));

      assert(!isUploadItemTerminal(UploadItemStatus.PENDING));
      assert(!isUploadItemTerminal(UploadItemStatus.SIGNING));
      assert(!isUploadItemTerminal(UploadItemStatus.UPLOADING));
      assert(!isUploadItemTerminal(UploadItemStatus.UPLOADED_REMOTE));
      assert(!isUploadItemTerminal(UploadItemStatus.PULLING_LOCAL));
      assert(!isUploadItemTerminal(UploadItemStatus.FAILED));
    });

    test("canRetryUploadItem should only allow FAILED items", () => {
      assert(canRetryUploadItem(UploadItemStatus.FAILED));

      assert(!canRetryUploadItem(UploadItemStatus.PENDING));
      assert(!canRetryUploadItem(UploadItemStatus.SIGNING));
      assert(!canRetryUploadItem(UploadItemStatus.UPLOADING));
      assert(!canRetryUploadItem(UploadItemStatus.UPLOADED_REMOTE));
      assert(!canRetryUploadItem(UploadItemStatus.PULLING_LOCAL));
      assert(!canRetryUploadItem(UploadItemStatus.READY));
      assert(!canRetryUploadItem(UploadItemStatus.CANCELED));
    });
  });

  describe("Default Configuration", () => {
    test("should have reasonable default values", () => {
      assert.equal(DEFAULT_CONFIG.SESSION_TTL_MINUTES, 180);
      assert.equal(DEFAULT_CONFIG.MAX_ITEMS_PER_SESSION, 200);
      assert.equal(DEFAULT_CONFIG.MAX_FILE_SIZE_BYTES, 50 * 1024 * 1024); // 50MB

      assert(Array.isArray(DEFAULT_CONFIG.ALLOWED_CONTENT_TYPES));
      assert(DEFAULT_CONFIG.ALLOWED_CONTENT_TYPES.includes("image/jpeg"));
      assert(DEFAULT_CONFIG.ALLOWED_CONTENT_TYPES.includes("image/png"));
      assert(DEFAULT_CONFIG.ALLOWED_CONTENT_TYPES.includes("image/webp"));
      assert(DEFAULT_CONFIG.ALLOWED_CONTENT_TYPES.includes("image/heic"));
      assert(DEFAULT_CONFIG.ALLOWED_CONTENT_TYPES.includes("image/heif"));
    });
  });

  describe("Status Flow Scenarios", () => {
    test("should support LAN direct upload flow", () => {
      // LAN 直传：PENDING -> READY
      assert(isValidUploadItemStatusTransition(UploadItemStatus.PENDING, UploadItemStatus.READY));
    });

    test("should support Supabase upload flow", () => {
      // Supabase 流程：PENDING -> SIGNING -> UPLOADING -> UPLOADED_REMOTE -> PULLING_LOCAL -> READY
      assert(isValidUploadItemStatusTransition(UploadItemStatus.PENDING, UploadItemStatus.SIGNING));
      assert(isValidUploadItemStatusTransition(UploadItemStatus.SIGNING, UploadItemStatus.UPLOADING));
      assert(isValidUploadItemStatusTransition(UploadItemStatus.UPLOADING, UploadItemStatus.UPLOADED_REMOTE));
      assert(isValidUploadItemStatusTransition(UploadItemStatus.UPLOADED_REMOTE, UploadItemStatus.PULLING_LOCAL));
      assert(isValidUploadItemStatusTransition(UploadItemStatus.PULLING_LOCAL, UploadItemStatus.READY));
    });

    test("should support Supabase without pullback flow", () => {
      // Supabase 无需回拉：UPLOADED_REMOTE -> READY
      assert(isValidUploadItemStatusTransition(UploadItemStatus.UPLOADED_REMOTE, UploadItemStatus.READY));
    });

    test("should support failure and retry scenarios", () => {
      // 任何状态都可以失败
      assert(isValidUploadItemStatusTransition(UploadItemStatus.SIGNING, UploadItemStatus.FAILED));
      assert(isValidUploadItemStatusTransition(UploadItemStatus.UPLOADING, UploadItemStatus.FAILED));
      assert(isValidUploadItemStatusTransition(UploadItemStatus.PULLING_LOCAL, UploadItemStatus.FAILED));

      // 失败后可以重试到不同阶段
      assert(isValidUploadItemStatusTransition(UploadItemStatus.FAILED, UploadItemStatus.PENDING));
      assert(isValidUploadItemStatusTransition(UploadItemStatus.FAILED, UploadItemStatus.SIGNING));
      assert(isValidUploadItemStatusTransition(UploadItemStatus.FAILED, UploadItemStatus.UPLOADING));
    });

    test("should support cancellation at any non-terminal state", () => {
      assert(isValidUploadItemStatusTransition(UploadItemStatus.PENDING, UploadItemStatus.CANCELED));
      assert(isValidUploadItemStatusTransition(UploadItemStatus.SIGNING, UploadItemStatus.CANCELED));
      assert(isValidUploadItemStatusTransition(UploadItemStatus.UPLOADING, UploadItemStatus.CANCELED));

      // 终态不能取消
      assert(!isValidUploadItemStatusTransition(UploadItemStatus.READY, UploadItemStatus.CANCELED));
      assert(!isValidUploadItemStatusTransition(UploadItemStatus.CANCELED, UploadItemStatus.CANCELED));
    });
  });
});