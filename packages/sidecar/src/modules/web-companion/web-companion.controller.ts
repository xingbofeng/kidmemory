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
      return await this.webCompanionService.getSessionSummary(sessionId, token);
    } catch (error) {
      this.handleError(error);
    }
  }

  async getSessionDetail(sessionId: string, token?: string): Promise<SessionDetailResponse> {
    try {
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
        throw new Error('Authorization token required');
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
        throw new Error('Authorization token required');
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
        throw new Error('Authorization token required');
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
        throw new Error('Authorization token required');
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
        throw new Error('Authorization token required');
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
        throw new Error('Authorization token required');
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

    const message = error instanceof Error ? error.message : "An unexpected error occurred";

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

    if (message.includes('Authorization token required')) {
      throw new HttpException(
        { error: 'bad_request', message },
        HttpStatus.BAD_REQUEST
      );
    }

    throw new HttpException(
      { error: 'internal_error', message },
      HttpStatus.INTERNAL_SERVER_ERROR
    );
  }
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

Get("sessions/:sessionId")(proto, "getSessionSummary", desc("getSessionSummary"));
Param("sessionId")(proto, "getSessionSummary", 0);
Query("token")(proto, "getSessionSummary", 1);

Get("sessions/:sessionId/detail")(proto, "getSessionDetail", desc("getSessionDetail"));
Param("sessionId")(proto, "getSessionDetail", 0);
Query("token")(proto, "getSessionDetail", 1);

Post("sessions/:sessionId/items")(proto, "createUploadItems", desc("createUploadItems"));
HttpCode(HttpStatus.CREATED)(proto, "createUploadItems", desc("createUploadItems"));
Param("sessionId")(proto, "createUploadItems", 0);
Body()(proto, "createUploadItems", 1);

Put("sessions/:sessionId/items/:uploadItemId/commit")(proto, "commitUploadItem", desc("commitUploadItem"));
Param("sessionId")(proto, "commitUploadItem", 0);
Param("uploadItemId")(proto, "commitUploadItem", 1);
Body()(proto, "commitUploadItem", 2);

Post("sessions/:sessionId/items/:uploadItemId/retry")(proto, "retryUploadItem", desc("retryUploadItem"));
Param("sessionId")(proto, "retryUploadItem", 0);
Param("uploadItemId")(proto, "retryUploadItem", 1);
Body()(proto, "retryUploadItem", 2);

Post("sessions/:sessionId/close")(proto, "closeSession", desc("closeSession"));
Param("sessionId")(proto, "closeSession", 0);
Body()(proto, "closeSession", 1);

Post("sessions/:sessionId/submit")(proto, "submitSession", desc("submitSession"));
Param("sessionId")(proto, "submitSession", 0);
Body()(proto, "submitSession", 1);

Get("sessions/:sessionId/recent")(proto, "getRecentUploads", desc("getRecentUploads"));
Param("sessionId")(proto, "getRecentUploads", 0);
Query("token")(proto, "getRecentUploads", 1);
Query("limit")(proto, "getRecentUploads", 2);

Get("sessions/:sessionId/assets/:assetId")(proto, "getAssetDetails", desc("getAssetDetails"));
Param("sessionId")(proto, "getAssetDetails", 0);
Param("assetId")(proto, "getAssetDetails", 1);
Query("token")(proto, "getAssetDetails", 2);

Get("sessions/:sessionId/books")(proto, "getBooksList", desc("getBooksList"));
Param("sessionId")(proto, "getBooksList", 0);
Query("token")(proto, "getBooksList", 1);
Query("childId")(proto, "getBooksList", 2);

Get("sessions/:sessionId/books/:bookId")(proto, "getBookDetails", desc("getBookDetails"));
Param("sessionId")(proto, "getBookDetails", 0);
Param("bookId")(proto, "getBookDetails", 1);
Query("token")(proto, "getBookDetails", 2);

Post("sessions/:sessionId/share")(proto, "createShareToken", desc("createShareToken"));
HttpCode(HttpStatus.CREATED)(proto, "createShareToken", desc("createShareToken"));
Param("sessionId")(proto, "createShareToken", 0);
Body()(proto, "createShareToken", 1);
Query("token")(proto, "createShareToken", 2);

Post("sessions/:sessionId/share/:shareTokenId/revoke")(proto, "revokeShareToken", desc("revokeShareToken"));
Param("sessionId")(proto, "revokeShareToken", 0);
Param("shareTokenId")(proto, "revokeShareToken", 1);
Query("token")(proto, "revokeShareToken", 2);

Get("share/:shareToken/access")(proto, "accessSharedContent", desc("accessSharedContent"));
Param("shareToken")(proto, "accessSharedContent", 0);
Query("clientIp")(proto, "accessSharedContent", 1);
Query("userAgent")(proto, "accessSharedContent", 2);

Get("share/:shareToken/assets")(proto, "getSharedAssets", desc("getSharedAssets"));
Param("shareToken")(proto, "getSharedAssets", 0);
Query("limit")(proto, "getSharedAssets", 1);

Get("share/:shareToken/book")(proto, "getSharedBook", desc("getSharedBook"));
Param("shareToken")(proto, "getSharedBook", 0);
Query("bookId")(proto, "getSharedBook", 1);
