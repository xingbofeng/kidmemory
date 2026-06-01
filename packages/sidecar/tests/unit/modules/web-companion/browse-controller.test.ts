import { describe, it, beforeEach } from "node:test";
import assert from "node:assert/strict";
import { HttpException, HttpStatus } from "@nestjs/common";

import { WebCompanionController } from "../../../../src/modules/web-companion/web-companion.controller.ts";
import {
  createUnusedShareTokenService,
  createUnusedWebCompanionService,
} from "./controller-test-doubles.ts";

type ControllerArgs = ConstructorParameters<typeof WebCompanionController>;
type BrowseServicePort = ControllerArgs[1];
type RecentUploadsInput = Parameters<BrowseServicePort["getRecentUploads"]>[0];
type AssetDetailsInput = Parameters<BrowseServicePort["getAssetDetails"]>[0];
type BooksListInput = Parameters<BrowseServicePort["getBooksList"]>[0];
type BookDetailsInput = Parameters<BrowseServicePort["getBookDetails"]>[0];
type RecentUpload = Awaited<ReturnType<BrowseServicePort["getRecentUploads"]>>[number];
type AssetDetails = Awaited<ReturnType<BrowseServicePort["getAssetDetails"]>>;
type BookSummary = Awaited<ReturnType<BrowseServicePort["getBooksList"]>>[number];
type BookDetails = Awaited<ReturnType<BrowseServicePort["getBookDetails"]>>;
type SharedAsset = Awaited<ReturnType<BrowseServicePort["getSharedAssets"]>>[number];
type SharedBook = Awaited<ReturnType<BrowseServicePort["getSharedBook"]>>;

type BrowseServiceDouble = BrowseServicePort & {
  recentUploadsInputs: RecentUploadsInput[];
  assetDetailsInputs: AssetDetailsInput[];
  booksListInputs: BooksListInput[];
  bookDetailsInputs: BookDetailsInput[];
  recentUploadsError?: Error;
  assetDetailsError?: Error;
};

function createBrowseServiceDouble(): BrowseServiceDouble {
  const recentUpload: RecentUpload = {
    id: "asset_1",
    title: "Test Photo 1",
    type: "image",
    childId: "child_456",
    createdAt: "2026-05-31T00:00:00.000Z",
    previewUrl: "/assets/asset_1/preview",
  };
  const assetDetails: AssetDetails = {
    ...recentUpload,
    description: "A test photo",
    tags: [],
    metadata: {},
  };
  const bookSummary: BookSummary = {
    id: "book_1",
    title: "My Book",
    childId: "child_456",
    createdAt: "2026-05-31T00:00:00.000Z",
    status: "completed",
    previewUrl: "/api/books/book_1/preview",
  };
  const bookDetails: BookDetails = {
    ...bookSummary,
    description: "A test book",
    pageCount: 12,
  };
  const sharedAsset: SharedAsset = {
    id: "shared_asset_1",
    title: "Shared Photo",
    type: "image",
    createdAt: "2026-05-31T00:00:00.000Z",
    previewUrl: "/assets/shared_asset_1/preview",
  };
  const sharedBook: SharedBook = {
    id: "shared_book_1",
    title: "Shared Book",
    createdAt: "2026-05-31T00:00:00.000Z",
    status: "completed",
    previewUrl: "/api/books/shared_book_1/preview",
  };

  return {
    recentUploadsInputs: [],
    assetDetailsInputs: [],
    booksListInputs: [],
    bookDetailsInputs: [],
    async getRecentUploads(input) {
      this.recentUploadsInputs.push(input);
      if (this.recentUploadsError) throw this.recentUploadsError;
      return [recentUpload];
    },
    async getAssetDetails(input) {
      this.assetDetailsInputs.push(input);
      if (this.assetDetailsError) throw this.assetDetailsError;
      return assetDetails;
    },
    async getBooksList(input) {
      this.booksListInputs.push(input);
      return [bookSummary];
    },
    async getBookDetails(input) {
      this.bookDetailsInputs.push(input);
      return bookDetails;
    },
    async getSharedAssets() {
      return [sharedAsset];
    },
    async getSharedBook() {
      return sharedBook;
    },
  };
}

function assertHttpError(error: unknown, expectedStatus: number, expectedError: string) {
  assert.ok(error instanceof HttpException);
  assert.equal(error.getStatus(), expectedStatus);

  const response = error.getResponse();
  assert.equal(typeof response, "object");
  assert.notEqual(response, null);
  assert.equal((response as { error?: string; code?: string }).error ?? (response as { code?: string }).code, expectedError);
  return true;
}

describe("WebCompanionController browse endpoints", () => {
  let controller: WebCompanionController;
  let browseService: BrowseServiceDouble;

  beforeEach(() => {
    browseService = createBrowseServiceDouble();
    controller = new WebCompanionController(
      createUnusedWebCompanionService(),
      browseService,
      createUnusedShareTokenService(),
    );
  });

  describe("GET /api/web-companion/sessions/:sessionId/recent", () => {
    it("returns recent uploads through the browse service", async () => {
      const result = await controller.getRecentUploads("session_123", "valid_token", "10");

      assert.equal(result[0].id, "asset_1");
      assert.deepEqual(browseService.recentUploadsInputs, [{
        sessionId: "session_123",
        token: "valid_token",
        limit: 10,
      }]);
    });

    it("maps invalid session tokens to unauthorized", async () => {
      browseService.recentUploadsError = new Error("Session not found or token invalid");

      await assert.rejects(
        () => controller.getRecentUploads("session_123", "invalid_token"),
        (error: unknown) =>
          assertHttpError(error, HttpStatus.UNAUTHORIZED, "unauthorized"),
      );
    });

    it("requires an authorization token", async () => {
      await assert.rejects(
        () => controller.getRecentUploads("session_123"),
        (error: unknown) =>
          assertHttpError(error, HttpStatus.UNAUTHORIZED, "TOKEN_REQUIRED"),
      );
    });
  });

  describe("GET /api/web-companion/sessions/:sessionId/assets/:assetId", () => {
    it("returns asset details through the browse service", async () => {
      const result = await controller.getAssetDetails("session_123", "asset_1", "valid_token");

      assert.equal(result.id, "asset_1");
      assert.deepEqual(browseService.assetDetailsInputs, [{
        sessionId: "session_123",
        token: "valid_token",
        assetId: "asset_1",
      }]);
    });

    it("maps denied asset lookups to forbidden", async () => {
      browseService.assetDetailsError = new Error("Asset not found or access denied");

      await assert.rejects(
        () => controller.getAssetDetails("session_123", "not_found", "valid_token"),
        (error: unknown) =>
          assertHttpError(error, HttpStatus.FORBIDDEN, "forbidden"),
      );
    });
  });

  describe("GET /api/web-companion/sessions/:sessionId/books", () => {
    it("returns books through the browse service", async () => {
      const result = await controller.getBooksList("session_123", "valid_token", "child_456");

      assert.equal(result[0].id, "book_1");
      assert.deepEqual(browseService.booksListInputs, [{
        sessionId: "session_123",
        token: "valid_token",
        childId: "child_456",
      }]);
    });
  });

  describe("GET /api/web-companion/sessions/:sessionId/books/:bookId", () => {
    it("returns book details through the browse service", async () => {
      const result = await controller.getBookDetails("session_123", "book_1", "valid_token");

      assert.equal(result.id, "book_1");
      assert.deepEqual(browseService.bookDetailsInputs, [{
        sessionId: "session_123",
        token: "valid_token",
        bookId: "book_1",
      }]);
    });
  });
});
