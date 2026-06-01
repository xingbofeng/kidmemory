/**
 * Web Companion 控制器
 *
 * 路由前缀: /api/web-companion
 * - POST /sessions
 * - GET  /sessions/:sessionId
 * - GET  /sessions/:sessionId/detail
 * - POST /sessions/:sessionId/items
 * - PUT  /sessions/:sessionId/items/:uploadItemId/commit
 * - POST /sessions/:sessionId/items/:uploadItemId/retry
 * - POST /sessions/:sessionId/close
 * - POST /sessions/:sessionId/submit
 *
 * 装饰器全部手动注册（避免 @ 语法在 Node strip-only 模式下报错）。
 */

import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpException,
  HttpStatus,
  Inject,
  Param,
  Post,
  Put,
  Query,
} from "@nestjs/common";
import { ApiBody, ApiQuery, ApiResponse } from "@nestjs/swagger";
import { parseDto } from "../../infrastructure/validation/parse-dto.ts";

import { WebCompanionService } from "./web-companion.service.ts";
import {
  BrowseService,
  type AssetDetailDto,
  type BookDetailDto,
  type BookSummaryDto,
  type RecentUploadDto,
  type SharedAssetDto,
  type SharedBookDto,
} from "./browse.service.ts";
import {
  ShareTokenService,
  type ShareTokenDto,
  type ShareTokenValidation,
} from "./share-token.service.ts";
import { CreateUploadItemsDtoSchema } from "./dto/create-upload-items.dto.ts";
import type {
  CreateSessionRequest,
  CreateSessionResponse,
  CreateUploadItemsRequest,
  CreateUploadItemsResponse,
  CommitUploadItemRequest,
  CommitUploadItemResponse,
  RetryUploadItemRequest,
  CloseSessionRequest,
  SessionSummaryResponse,
  SessionDetailResponse,
} from "./types.ts";

type CreateShareTokenRequestDto = Parameters<ShareTokenService["createShareToken"]>[0];
type ShareTokenValidationResponseDto = ShareTokenValidation;

const recentUploadResponseSchema = {
  type: "array",
  items: {
    type: "object",
    required: ["id", "title", "type", "childId", "createdAt", "previewUrl", "tags"],
    properties: {
      id: { type: "string" },
      title: { type: "string" },
      type: { type: "string" },
      childId: { type: "string" },
      createdAt: { type: "string" },
      previewUrl: { type: "string" },
      description: { type: "string" },
      tags: { type: "array", items: { type: "string" } },
    },
  },
};

const bookSummaryResponseSchema = {
  type: "object",
  required: ["id", "title", "childId", "createdAt", "status", "previewUrl"],
  properties: {
    id: { type: "string" },
    title: { type: "string" },
    childId: { type: "string" },
    createdAt: { type: "string" },
    status: { type: "string" },
    previewUrl: { type: "string" },
  },
};

const bookDetailResponseSchema = {
  type: "object",
  required: ["id", "title", "childId", "createdAt", "status", "previewUrl"],
  properties: {
    ...bookSummaryResponseSchema.properties,
    description: { type: "string" },
    pageCount: { type: "number" },
  },
};

const createShareTokenRequestSchema = {
  type: "object",
  required: ["resourceType"],
  properties: {
    childId: { type: "string" },
    resourceType: {
      type: "string",
      enum: ["child_assets", "specific_book", "asset_collection"],
    },
    resourceId: { type: "string" },
    expiresInHours: { type: "number" },
    maxAccessCount: { type: "number" },
    accessType: { type: "string", enum: ["read_only", "time_limited"] },
  },
};

const shareTokenResponseSchema = {
  type: "object",
  required: ["id", "token", "childId", "expiresAt", "accessType", "resourceType", "shareUrl"],
  properties: {
    id: { type: "string" },
    token: { type: "string" },
    childId: { type: "string" },
    expiresAt: { type: "string" },
    accessType: { type: "string", enum: ["read_only", "time_limited"] },
    resourceType: {
      type: "string",
      enum: ["child_assets", "specific_book", "asset_collection"],
    },
    resourceId: { type: "string" },
    maxAccessCount: { type: "number" },
    shareUrl: { type: "string" },
  },
};

const shareTokenValidationResponseSchema = {
  type: "object",
  required: ["isValid"],
  properties: {
    isValid: { type: "boolean" },
    error: { type: "string" },
    shareToken: {
      type: "object",
      required: ["id", "childId", "resourceType", "accessType"],
      properties: {
        id: { type: "string" },
        childId: { type: "string" },
        resourceType: {
          type: "string",
          enum: ["child_assets", "specific_book", "asset_collection"],
        },
        resourceId: { type: "string" },
        accessType: { type: "string", enum: ["read_only", "time_limited"] },
      },
    },
  },
};

const sharedAssetResponseSchema = {
  type: "object",
  required: ["id", "title", "type", "createdAt", "previewUrl"],
  properties: {
    id: { type: "string" },
    title: { type: "string" },
    type: { type: "string" },
    createdAt: { type: "string" },
    previewUrl: { type: "string" },
  },
};

const sharedBookResponseSchema = {
  type: "object",
  required: ["id", "title", "createdAt", "status", "previewUrl"],
  properties: {
    id: { type: "string" },
    title: { type: "string" },
    createdAt: { type: "string" },
    status: { type: "string" },
    description: { type: "string" },
    previewUrl: { type: "string" },
    pageCount: { type: "number" },
  },
};

const sessionSummaryResponseSchema = {
  type: "object",
  required: ["sessionId", "status", "child", "expiresAt", "maxItems", "usedItems", "providers"],
  properties: {
    sessionId: { type: "string" },
    status: { type: "string" },
    child: {
      type: "object",
      required: ["id", "displayName"],
      properties: {
        id: { type: "string" },
        displayName: { type: "string" },
      },
    },
    expiresAt: { type: "string" },
    maxItems: { type: "number" },
    usedItems: { type: "number" },
    providers: { type: "object", additionalProperties: true },
  },
};

const signedUploadTargetSchema = {
  type: "object",
  required: ["method", "url", "expiresAt", "headers"],
  properties: {
    method: { type: "string", enum: ["PUT"] },
    url: { type: "string" },
    expiresAt: { type: "string" },
    headers: { type: "object", additionalProperties: { type: "string" } },
  },
};

const uploadItemResponseSchema = {
  type: "object",
  required: ["clientFileId", "uploadItemId", "assetId", "objectKey", "status"],
  properties: {
    clientFileId: { type: "string" },
    uploadItemId: { type: "string" },
    assetId: { type: "string" },
    objectKey: { type: "string" },
    status: { type: "string" },
    signedUpload: signedUploadTargetSchema,
  },
};

const uploadItemDetailSchema = {
  type: "object",
  required: ["uploadItemId", "assetId", "filename", "status", "provider", "objectKey", "createdAt", "updatedAt"],
  properties: {
    uploadItemId: { type: "string" },
    assetId: { type: "string" },
    filename: { type: "string" },
    status: { type: "string" },
    provider: { type: "string" },
    objectKey: { type: "string" },
    errorCode: { type: "string" },
    createdAt: { type: "string" },
    updatedAt: { type: "string" },
  },
};

const createSessionRequestSchema = {
  type: "object",
  required: ["childId"],
  properties: {
    childId: { type: "string" },
    expiresInMinutes: { type: "number" },
    maxItems: { type: "number" },
    preferredProviders: { type: "array", items: { type: "string" } },
  },
};

const createSessionResponseSchema = {
  type: "object",
  required: ["sessionId", "token", "webUrl", "expiresAt", "maxItems"],
  properties: {
    sessionId: { type: "string" },
    token: { type: "string" },
    webUrl: { type: "string" },
    expiresAt: { type: "string" },
    maxItems: { type: "number" },
  },
};

const createUploadItemsRequestSchema = {
  type: "object",
  required: ["token", "files"],
  properties: {
    token: { type: "string" },
    provider: { type: "string" },
    files: {
      type: "array",
      items: {
        type: "object",
        required: ["clientFileId", "filename", "contentType", "sizeBytes"],
        properties: {
          clientFileId: { type: "string" },
          filename: { type: "string" },
          contentType: { type: "string" },
          sizeBytes: { type: "number" },
        },
      },
    },
  },
};

const createUploadItemsResponseSchema = {
  type: "object",
  required: ["items"],
  properties: {
    items: { type: "array", items: uploadItemResponseSchema },
  },
};

const commitUploadItemRequestSchema = {
  type: "object",
  required: ["token", "objectKey"],
  properties: {
    token: { type: "string" },
    objectKey: { type: "string" },
    sizeBytes: { type: "number" },
    contentType: { type: "string" },
    remoteEtag: { type: "string" },
  },
};

const commitUploadItemResponseSchema = {
  type: "object",
  required: ["uploadItemId", "status"],
  properties: {
    uploadItemId: { type: "string" },
    status: { type: "string" },
    idempotent: { type: "boolean" },
  },
};

const sessionDetailResponseSchema = {
  type: "object",
  required: ["sessionId", "items"],
  properties: {
    sessionId: { type: "string" },
    items: { type: "array", items: uploadItemDetailSchema },
  },
};

const tokenRequestSchema = {
  type: "object",
  required: ["token"],
  properties: { token: { type: "string" } },
};

const successResponseSchema = {
  type: "object",
  required: ["success"],
  properties: { success: { type: "boolean" } },
};

type WebCompanionControllerService = Pick<
  WebCompanionService,
  | "createSession"
  | "getSessionSummary"
  | "getSessionDetail"
  | "createUploadItems"
  | "commitUploadItem"
  | "retryUploadItem"
  | "closeSession"
>;

type BrowseControllerService = Pick<
  BrowseService,
  | "getRecentUploads"
  | "getAssetDetails"
  | "getBooksList"
  | "getBookDetails"
  | "getSharedAssets"
  | "getSharedBook"
>;

type ShareTokenControllerService = Pick<
  ShareTokenService,
  "createShareToken" | "revokeShareToken" | "validateShareToken"
>;

export class WebCompanionController {
  private readonly webCompanionService: WebCompanionControllerService;
  private readonly browseService: BrowseControllerService;
  private readonly shareTokenService: ShareTokenControllerService;

  constructor(
    webCompanionService: WebCompanionControllerService,
    browseService: BrowseControllerService,
    shareTokenService: ShareTokenControllerService,
  ) {
    this.webCompanionService = webCompanionService;
    this.browseService = browseService;
    this.shareTokenService = shareTokenService;
  }

  async createSession(request: CreateSessionRequest): Promise<CreateSessionResponse> {
    try {
      return await this.webCompanionService.createSession(request);
    } catch (error) {
      this.handleError(error);
    }
  }

  async getSessionSummary(sessionId: string, token?: string): Promise<SessionSummaryResponse> {
    try {
      if (!token) {
        throw Object.assign(new Error("Authorization token required"), {
          code: "TOKEN_REQUIRED",
        });
      }
      return await this.webCompanionService.getSessionSummary(sessionId, token);
    } catch (error) {
      this.handleError(error);
    }
  }

  async getSessionDetail(sessionId: string, token?: string): Promise<SessionDetailResponse> {
    try {
      if (!token) {
        throw Object.assign(new Error("Authorization token required"), {
          code: "TOKEN_REQUIRED",
        });
      }
      return await this.webCompanionService.getSessionDetail(sessionId, token);
    } catch (error) {
      this.handleError(error);
    }
  }

  async createUploadItems(
    sessionId: string,
    request: unknown,
  ): Promise<CreateUploadItemsResponse> {
    try {
      const dto = parseDto(
        CreateUploadItemsDtoSchema,
        request,
        "api/web-companion/sessions/:sessionId/items",
      );
      return await this.webCompanionService.createUploadItems(sessionId, {
        token: dto.token,
        provider: dto.provider ?? "supabase",
        files: dto.files,
      } as CreateUploadItemsRequest);
    } catch (error) {
      this.handleError(error);
    }
  }

  async commitUploadItem(
    sessionId: string,
    uploadItemId: string,
    request: CommitUploadItemRequest,
  ): Promise<CommitUploadItemResponse> {
    try {
      return await this.webCompanionService.commitUploadItem(sessionId, uploadItemId, request);
    } catch (error) {
      this.handleError(error);
    }
  }

  async retryUploadItem(
    sessionId: string,
    uploadItemId: string,
    request: RetryUploadItemRequest,
  ): Promise<CommitUploadItemResponse> {
    try {
      return await this.webCompanionService.retryUploadItem(sessionId, uploadItemId, request);
    } catch (error) {
      this.handleError(error);
    }
  }

  async closeSession(
    sessionId: string,
    request: CloseSessionRequest,
  ): Promise<{ success: boolean }> {
    try {
      await this.webCompanionService.closeSession(sessionId, request);
      return { success: true };
    } catch (error) {
      this.handleError(error);
    }
  }

  async submitSession(
    sessionId: string,
    request: CloseSessionRequest,
  ): Promise<{ success: boolean }> {
    return this.closeSession(sessionId, request);
  }

  async getRecentUploads(
    sessionId: string,
    token?: string,
    limit?: string,
  ): Promise<RecentUploadDto[]> {
    try {
      if (!token) {
        throw tokenRequiredError();
      }

      const parsedLimit = limit ? parseInt(limit, 10) : undefined;
      return await this.browseService.getRecentUploads({
        sessionId,
        token,
        limit: parsedLimit,
      });
    } catch (error) {
      this.handleBrowseError(error);
    }
  }

  async getAssetDetails(
    sessionId: string,
    assetId: string,
    token?: string,
  ): Promise<AssetDetailDto> {
    try {
      if (!token) {
        throw tokenRequiredError();
      }

      return await this.browseService.getAssetDetails({
        sessionId,
        token,
        assetId,
      });
    } catch (error) {
      this.handleBrowseError(error);
    }
  }

  async getBooksList(
    sessionId: string,
    token?: string,
    childId?: string,
  ): Promise<BookSummaryDto[]> {
    try {
      if (!token) {
        throw tokenRequiredError();
      }

      return await this.browseService.getBooksList({
        sessionId,
        token,
        childId,
      });
    } catch (error) {
      this.handleBrowseError(error);
    }
  }

  async getBookDetails(
    sessionId: string,
    bookId: string,
    token?: string,
  ): Promise<BookDetailDto> {
    try {
      if (!token) {
        throw tokenRequiredError();
      }

      return await this.browseService.getBookDetails({
        sessionId,
        token,
        bookId,
      });
    } catch (error) {
      this.handleBrowseError(error);
    }
  }

  async createShareToken(
    sessionId: string,
    request: CreateShareTokenRequestDto,
    token?: string,
  ): Promise<ShareTokenDto> {
    try {
      if (!token) {
        throw tokenRequiredError();
      }

      return await this.shareTokenService.createShareToken({
        sessionId,
        sessionToken: token,
        ...request,
      });
    } catch (error) {
      this.handleShareError(error);
    }
  }

  async revokeShareToken(
    sessionId: string,
    shareTokenId: string,
    token?: string,
  ): Promise<{ success: boolean }> {
    try {
      if (!token) {
        throw tokenRequiredError();
      }

      await this.shareTokenService.revokeShareToken(shareTokenId, sessionId, token);
      return { success: true };
    } catch (error) {
      this.handleShareError(error);
    }
  }

  async accessSharedContent(
    shareToken: string,
    clientIp?: string,
    userAgent?: string,
  ): Promise<ShareTokenValidationResponseDto> {
    try {
      return await this.shareTokenService.validateShareToken({
        token: shareToken,
        clientIp,
        userAgent,
      });
    } catch (error) {
      this.handleShareError(error);
    }
  }

  async getSharedAssets(
    shareToken: string,
    limit?: string,
  ): Promise<SharedAssetDto[]> {
    try {
      const parsedLimit = limit ? parseInt(limit, 10) : undefined;
      return await this.browseService.getSharedAssets({
        shareToken,
        limit: parsedLimit,
      });
    } catch (error) {
      this.handleShareError(error);
    }
  }

  async getSharedBook(
    shareToken: string,
    bookId?: string,
  ): Promise<SharedBookDto> {
    try {
      return await this.browseService.getSharedBook({
        shareToken,
        bookId,
      });
    } catch (error) {
      this.handleShareError(error);
    }
  }

  private handleError(error: unknown): never {
    if (error instanceof HttpException) throw error;

    const code = error instanceof Error ? (error as Error & { code?: string }).code : undefined;
    const message = error instanceof Error ? error.message : "An unexpected error occurred";

    switch (code) {
      case "SESSION_NOT_FOUND":
      case "UPLOAD_ITEM_NOT_FOUND":
        throw new HttpException({ code, message }, HttpStatus.NOT_FOUND);
      case "TOKEN_INVALID":
      case "TOKEN_REQUIRED":
      case "SESSION_EXPIRED":
      case "SESSION_CLOSED":
        throw new HttpException({ code, message }, HttpStatus.UNAUTHORIZED);
      case "ITEM_LIMIT_EXCEEDED":
      case "FILE_TOO_LARGE":
      case "FILE_TYPE_UNSUPPORTED":
      case "OBJECT_KEY_MISMATCH":
      case "COMMIT_CONFLICT":
        throw new HttpException({ code, message }, HttpStatus.BAD_REQUEST);
      case "PROVIDER_UNAVAILABLE":
      case "SIGNED_UPLOAD_UNAVAILABLE":
        throw new HttpException({ code, message }, HttpStatus.SERVICE_UNAVAILABLE);
    }

    throw new HttpException(
      { code: "INTERNAL_ERROR", message },
      HttpStatus.INTERNAL_SERVER_ERROR,
    );
  }

  private handleBrowseError(error: unknown): never {
    this.handleShareError(error);
  }

  private handleShareError(error: unknown): never {
    if (error instanceof HttpException) throw error;

    const code = error instanceof Error ? (error as Error & { code?: string }).code : undefined;
    const message = error instanceof Error ? error.message : "An unexpected error occurred";

    if (code === "TOKEN_REQUIRED" || message.includes('Authorization token required')) {
      throw new HttpException(
        { code: "TOKEN_REQUIRED", message },
        HttpStatus.UNAUTHORIZED,
      );
    }

    if (message.includes('Session not found') || message.includes('token invalid')) {
      throw new HttpException(
        { error: 'unauthorized', message },
        HttpStatus.UNAUTHORIZED
      );
    }

    if (message.includes('Session expired') || message.includes('Session not active')) {
      throw new HttpException(
        { error: 'session_expired', message },
        HttpStatus.UNAUTHORIZED
      );
    }

    if (message.includes('Cannot create share token') || message.includes('access denied')) {
      throw new HttpException(
        { error: 'forbidden', message },
        HttpStatus.FORBIDDEN
      );
    }

    if (message.includes('not found')) {
      throw new HttpException(
        { error: 'not_found', message },
        HttpStatus.NOT_FOUND
      );
    }

    throw new HttpException(
      { error: 'internal_error', message },
      HttpStatus.INTERNAL_SERVER_ERROR
    );
  }
}

function tokenRequiredError(): Error & { code: string } {
  return Object.assign(new Error("Authorization token required"), {
    code: "TOKEN_REQUIRED",
  });
}

// ---- 手动注册 NestJS 装饰器（避免 @ 语法）----

Inject(WebCompanionService)(WebCompanionController, undefined, 0);
Inject(BrowseService)(WebCompanionController, undefined, 1);
Inject(ShareTokenService)(WebCompanionController, undefined, 2);
Controller("api/web-companion")(WebCompanionController);

const proto = WebCompanionController.prototype;
const desc = (m: string) => Object.getOwnPropertyDescriptor(proto, m)!;

Post("sessions")(proto, "createSession", desc("createSession"));
HttpCode(HttpStatus.CREATED)(proto, "createSession", desc("createSession"));
Body()(proto, "createSession", 0);
ApiBody({ schema: createSessionRequestSchema })(proto, "createSession", desc("createSession"));
ApiResponse({ status: 201, schema: createSessionResponseSchema })(proto, "createSession", desc("createSession"));

Get("sessions/:sessionId")(proto, "getSessionSummary", desc("getSessionSummary"));
ApiQuery({ name: "token", required: true, type: String })(proto, "getSessionSummary", desc("getSessionSummary"));
ApiResponse({ status: 200, schema: sessionSummaryResponseSchema })(proto, "getSessionSummary", desc("getSessionSummary"));
Param("sessionId")(proto, "getSessionSummary", 0);
Query("token")(proto, "getSessionSummary", 1);

Get("sessions/:sessionId/detail")(proto, "getSessionDetail", desc("getSessionDetail"));
ApiQuery({ name: "token", required: true, type: String })(proto, "getSessionDetail", desc("getSessionDetail"));
ApiResponse({ status: 200, schema: sessionDetailResponseSchema })(proto, "getSessionDetail", desc("getSessionDetail"));
Param("sessionId")(proto, "getSessionDetail", 0);
Query("token")(proto, "getSessionDetail", 1);

Post("sessions/:sessionId/items")(proto, "createUploadItems", desc("createUploadItems"));
HttpCode(HttpStatus.CREATED)(proto, "createUploadItems", desc("createUploadItems"));
Param("sessionId")(proto, "createUploadItems", 0);
Body()(proto, "createUploadItems", 1);
ApiBody({ schema: createUploadItemsRequestSchema })(proto, "createUploadItems", desc("createUploadItems"));
ApiResponse({ status: 201, schema: createUploadItemsResponseSchema })(proto, "createUploadItems", desc("createUploadItems"));

Put("sessions/:sessionId/items/:uploadItemId/commit")(proto, "commitUploadItem", desc("commitUploadItem"));
Param("sessionId")(proto, "commitUploadItem", 0);
Param("uploadItemId")(proto, "commitUploadItem", 1);
Body()(proto, "commitUploadItem", 2);
ApiBody({ schema: commitUploadItemRequestSchema })(proto, "commitUploadItem", desc("commitUploadItem"));
ApiResponse({ status: 200, schema: commitUploadItemResponseSchema })(proto, "commitUploadItem", desc("commitUploadItem"));

Post("sessions/:sessionId/items/:uploadItemId/retry")(proto, "retryUploadItem", desc("retryUploadItem"));
Param("sessionId")(proto, "retryUploadItem", 0);
Param("uploadItemId")(proto, "retryUploadItem", 1);
Body()(proto, "retryUploadItem", 2);
ApiBody({ schema: tokenRequestSchema })(proto, "retryUploadItem", desc("retryUploadItem"));
ApiResponse({ status: 201, schema: commitUploadItemResponseSchema })(proto, "retryUploadItem", desc("retryUploadItem"));

Post("sessions/:sessionId/close")(proto, "closeSession", desc("closeSession"));
Param("sessionId")(proto, "closeSession", 0);
Body()(proto, "closeSession", 1);
ApiBody({ schema: tokenRequestSchema })(proto, "closeSession", desc("closeSession"));
ApiResponse({ status: 201, schema: successResponseSchema })(proto, "closeSession", desc("closeSession"));

Post("sessions/:sessionId/submit")(proto, "submitSession", desc("submitSession"));
Param("sessionId")(proto, "submitSession", 0);
Body()(proto, "submitSession", 1);
ApiBody({ schema: tokenRequestSchema })(proto, "submitSession", desc("submitSession"));
ApiResponse({ status: 201, schema: successResponseSchema })(proto, "submitSession", desc("submitSession"));

Get("sessions/:sessionId/recent")(proto, "getRecentUploads", desc("getRecentUploads"));
ApiQuery({ name: "token", required: true, type: String })(proto, "getRecentUploads", desc("getRecentUploads"));
ApiQuery({ name: "limit", required: false, type: Number })(proto, "getRecentUploads", desc("getRecentUploads"));
ApiResponse({ status: 200, schema: recentUploadResponseSchema })(proto, "getRecentUploads", desc("getRecentUploads"));
Param("sessionId")(proto, "getRecentUploads", 0);
Query("token")(proto, "getRecentUploads", 1);
Query("limit")(proto, "getRecentUploads", 2);

Get("sessions/:sessionId/assets/:assetId")(proto, "getAssetDetails", desc("getAssetDetails"));
ApiQuery({ name: "token", required: true, type: String })(proto, "getAssetDetails", desc("getAssetDetails"));
ApiResponse({ status: 200, schema: recentUploadResponseSchema.items })(proto, "getAssetDetails", desc("getAssetDetails"));
Param("sessionId")(proto, "getAssetDetails", 0);
Param("assetId")(proto, "getAssetDetails", 1);
Query("token")(proto, "getAssetDetails", 2);

Get("sessions/:sessionId/books")(proto, "getBooksList", desc("getBooksList"));
ApiQuery({ name: "token", required: true, type: String })(proto, "getBooksList", desc("getBooksList"));
ApiQuery({ name: "childId", required: false, type: String })(proto, "getBooksList", desc("getBooksList"));
ApiResponse({ status: 200, schema: { type: "array", items: bookSummaryResponseSchema } })(proto, "getBooksList", desc("getBooksList"));
Param("sessionId")(proto, "getBooksList", 0);
Query("token")(proto, "getBooksList", 1);
Query("childId")(proto, "getBooksList", 2);

Get("sessions/:sessionId/books/:bookId")(proto, "getBookDetails", desc("getBookDetails"));
ApiQuery({ name: "token", required: true, type: String })(proto, "getBookDetails", desc("getBookDetails"));
ApiResponse({ status: 200, schema: bookDetailResponseSchema })(proto, "getBookDetails", desc("getBookDetails"));
Param("sessionId")(proto, "getBookDetails", 0);
Param("bookId")(proto, "getBookDetails", 1);
Query("token")(proto, "getBookDetails", 2);

Post("sessions/:sessionId/share")(proto, "createShareToken", desc("createShareToken"));
HttpCode(HttpStatus.CREATED)(proto, "createShareToken", desc("createShareToken"));
ApiQuery({ name: "token", required: true, type: String })(proto, "createShareToken", desc("createShareToken"));
ApiBody({ schema: createShareTokenRequestSchema })(proto, "createShareToken", desc("createShareToken"));
ApiResponse({ status: 201, schema: shareTokenResponseSchema })(proto, "createShareToken", desc("createShareToken"));
Param("sessionId")(proto, "createShareToken", 0);
Body()(proto, "createShareToken", 1);
Query("token")(proto, "createShareToken", 2);

Post("sessions/:sessionId/share/:shareTokenId/revoke")(proto, "revokeShareToken", desc("revokeShareToken"));
ApiQuery({ name: "token", required: true, type: String })(proto, "revokeShareToken", desc("revokeShareToken"));
ApiResponse({ status: 201, schema: successResponseSchema })(proto, "revokeShareToken", desc("revokeShareToken"));
Param("sessionId")(proto, "revokeShareToken", 0);
Param("shareTokenId")(proto, "revokeShareToken", 1);
Query("token")(proto, "revokeShareToken", 2);

Get("share/:shareToken/access")(proto, "accessSharedContent", desc("accessSharedContent"));
ApiResponse({ status: 200, schema: shareTokenValidationResponseSchema })(proto, "accessSharedContent", desc("accessSharedContent"));
Param("shareToken")(proto, "accessSharedContent", 0);
Query("clientIp")(proto, "accessSharedContent", 1);
Query("userAgent")(proto, "accessSharedContent", 2);

Get("share/:shareToken/assets")(proto, "getSharedAssets", desc("getSharedAssets"));
ApiQuery({ name: "limit", required: false, type: Number })(proto, "getSharedAssets", desc("getSharedAssets"));
ApiResponse({ status: 200, schema: { type: "array", items: sharedAssetResponseSchema } })(proto, "getSharedAssets", desc("getSharedAssets"));
Param("shareToken")(proto, "getSharedAssets", 0);
Query("limit")(proto, "getSharedAssets", 1);

Get("share/:shareToken/book")(proto, "getSharedBook", desc("getSharedBook"));
ApiQuery({ name: "bookId", required: false, type: String })(proto, "getSharedBook", desc("getSharedBook"));
ApiResponse({ status: 200, schema: sharedBookResponseSchema })(proto, "getSharedBook", desc("getSharedBook"));
Param("shareToken")(proto, "getSharedBook", 0);
Query("bookId")(proto, "getSharedBook", 1);
