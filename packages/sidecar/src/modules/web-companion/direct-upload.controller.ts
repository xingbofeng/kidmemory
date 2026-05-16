/**
 * Web Companion Supabase Direct Upload controller.
 *
 * 路由（与 trusted upload 隔离，挂在 `/web-companion/direct-upload/*` 命名空间）：
 *   POST   /web-companion/direct-upload/sessions
 *   GET    /web-companion/direct-upload/sessions/:sessionId/objects
 *   POST   /web-companion/direct-upload/sessions/:sessionId/pullback
 *   GET    /web-companion/direct-upload/sessions/:sessionId/status
 *   GET    /web-companion/direct-upload/sessions/:sessionId/config
 */

import { Body, Controller, Get, Inject, Param, Post } from "@nestjs/common";

import { DirectUploadService } from "./direct-upload.service.ts";
import type {
  CreateDirectUploadSessionRequest,
  CreateDirectUploadSessionResponse,
} from "./dto/create-direct-upload-session.dto.ts";
import type { ListDirectUploadObjectsResponse } from "./dto/list-direct-upload-objects.dto.ts";
import type {
  PullbackDirectUploadRequest,
  PullbackDirectUploadResponse,
} from "./dto/pullback-direct-upload.dto.ts";
import type { GetDirectUploadStatusResponse } from "./dto/get-direct-upload-status.dto.ts";

export class DirectUploadController {
  private readonly service: DirectUploadService;

  constructor(service: DirectUploadService) {
    this.service = service;
  }

  createSession(
    body: CreateDirectUploadSessionRequest,
  ): Promise<CreateDirectUploadSessionResponse> {
    return this.service.createSession(body || { childId: "" });
  }

  listObjects(sessionId: string): Promise<ListDirectUploadObjectsResponse> {
    return this.service.listObjects(sessionId);
  }

  pullback(
    sessionId: string,
    body: PullbackDirectUploadRequest,
  ): Promise<PullbackDirectUploadResponse> {
    return this.service.pullback(sessionId, body || {});
  }

  getStatus(sessionId: string): Promise<GetDirectUploadStatusResponse> {
    return this.service.getStatus(sessionId);
  }

  getSessionConfig(
    sessionId: string,
  ): Promise<{ supabaseUrl: string; anonKey: string; bucket: string; recommendedClientLimit: number }> {
    return this.service.getSessionConfig(sessionId);
  }
}

// ---- Nest 装饰器手动注册 (与 web-companion.controller.ts 保持一致风格) ------

Inject(DirectUploadService)(DirectUploadController, undefined, 0);
Controller("api/web-companion/direct-upload")(DirectUploadController);

Post("sessions")(
  DirectUploadController.prototype,
  "createSession",
  Object.getOwnPropertyDescriptor(DirectUploadController.prototype, "createSession")!,
);
Body()(DirectUploadController.prototype, "createSession", 0);

Get("sessions/:sessionId/objects")(
  DirectUploadController.prototype,
  "listObjects",
  Object.getOwnPropertyDescriptor(DirectUploadController.prototype, "listObjects")!,
);
Param("sessionId")(DirectUploadController.prototype, "listObjects", 0);

Post("sessions/:sessionId/pullback")(
  DirectUploadController.prototype,
  "pullback",
  Object.getOwnPropertyDescriptor(DirectUploadController.prototype, "pullback")!,
);
Param("sessionId")(DirectUploadController.prototype, "pullback", 0);
Body()(DirectUploadController.prototype, "pullback", 1);

Get("sessions/:sessionId/status")(
  DirectUploadController.prototype,
  "getStatus",
  Object.getOwnPropertyDescriptor(DirectUploadController.prototype, "getStatus")!,
);
Param("sessionId")(DirectUploadController.prototype, "getStatus", 0);

Get("sessions/:sessionId/config")(
  DirectUploadController.prototype,
  "getSessionConfig",
  Object.getOwnPropertyDescriptor(DirectUploadController.prototype, "getSessionConfig")!,
);
Param("sessionId")(DirectUploadController.prototype, "getSessionConfig", 0);
