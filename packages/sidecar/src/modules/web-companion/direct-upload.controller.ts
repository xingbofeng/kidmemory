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

import { Body, Controller, Get, Inject, Param, Post, Query } from "@nestjs/common";
import { ApiBody, ApiQuery, ApiResponse } from "@nestjs/swagger";

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

const directUploadSessionResponseSchema = {
  type: "object",
  required: [
    "sessionId",
    "childId",
    "bucket",
    "sessionPath",
    "supabaseUrl",
    "anonKey",
    "publicUrl",
    "recommendedClientLimit",
    "expiresAtHintSeconds",
    "token",
  ],
  properties: {
    sessionId: { type: "string" },
    childId: { type: "string" },
    bucket: { type: "string" },
    sessionPath: { type: "string" },
    supabaseUrl: { type: "string" },
    anonKey: { type: "string" },
    publicUrl: { type: "string" },
    recommendedClientLimit: { type: "number" },
    expiresAtHintSeconds: { type: "number" },
    token: { type: "string" },
  },
};

const directUploadConfigResponseSchema = {
  type: "object",
  required: ["supabaseUrl", "anonKey", "bucket", "recommendedClientLimit"],
  properties: {
    supabaseUrl: { type: "string" },
    anonKey: { type: "string" },
    bucket: { type: "string" },
    recommendedClientLimit: { type: "number" },
  },
};

const directUploadRemoteObjectSchema = {
  type: "object",
  required: ["objectKey", "size", "contentType", "lastModified"],
  properties: {
    objectKey: { type: "string" },
    size: { type: "number" },
    contentType: { type: "string" },
    lastModified: { type: "string" },
  },
};

const listDirectUploadObjectsResponseSchema = {
  type: "object",
  required: ["sessionId", "bucket", "objects"],
  properties: {
    sessionId: { type: "string" },
    bucket: { type: "string" },
    objects: { type: "array", items: directUploadRemoteObjectSchema },
  },
};

const pullbackDirectUploadResponseSchema = {
  type: "object",
  required: ["sessionId", "results"],
  properties: {
    sessionId: { type: "string" },
    results: {
      type: "array",
      items: {
        type: "object",
        required: ["objectKey", "status"],
        properties: {
          objectKey: { type: "string" },
          status: { type: "string", enum: ["ready", "failed"] },
          errorCode: { type: "string", nullable: true },
          errorMessage: { type: "string", nullable: true },
        },
      },
    },
  },
};

const directUploadStatusResponseSchema = {
  type: "object",
  required: ["sessionId", "items", "summary"],
  properties: {
    sessionId: { type: "string" },
    items: {
      type: "array",
      items: {
        type: "object",
        required: ["objectKey", "status"],
        properties: {
          objectKey: { type: "string" },
          status: { type: "string" },
          errorCode: { type: "string", nullable: true },
          errorMessage: { type: "string", nullable: true },
        },
      },
    },
    summary: {
      type: "object",
      required: ["pending_remote", "downloading", "ready", "failed"],
      properties: {
        pending_remote: { type: "number" },
        downloading: { type: "number" },
        ready: { type: "number" },
        failed: { type: "number" },
      },
    },
  },
};

export class DirectUploadController {
  private readonly service: DirectUploadService;

  constructor(service: DirectUploadService) {
    this.service = service;
  }

  createSession(
    body: CreateDirectUploadSessionRequest,
  ): Promise<CreateDirectUploadSessionResponse> {
    return this.service.createSession(body);
  }

  listObjects(sessionId: string, token: string): Promise<ListDirectUploadObjectsResponse> {
    return this.service.listObjects(sessionId, token);
  }

  pullback(
    sessionId: string,
    body: PullbackDirectUploadRequest,
  ): Promise<PullbackDirectUploadResponse> {
    return this.service.pullback(sessionId, body);
  }

  getStatus(sessionId: string, token: string): Promise<GetDirectUploadStatusResponse> {
    return this.service.getStatus(sessionId, token);
  }

  getSessionConfig(
    sessionId: string,
    token: string,
  ): Promise<{ supabaseUrl: string; anonKey: string; bucket: string; recommendedClientLimit: number }> {
    return this.service.getSessionConfig(sessionId, token);
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
ApiBody({
  schema: {
    type: "object",
    required: ["childId"],
    properties: { childId: { type: "string" } },
  },
})(DirectUploadController.prototype, "createSession", Object.getOwnPropertyDescriptor(DirectUploadController.prototype, "createSession")!);
ApiResponse({ status: 201, schema: directUploadSessionResponseSchema })(
  DirectUploadController.prototype,
  "createSession",
  Object.getOwnPropertyDescriptor(DirectUploadController.prototype, "createSession")!,
);

Get("sessions/:sessionId/objects")(
  DirectUploadController.prototype,
  "listObjects",
  Object.getOwnPropertyDescriptor(DirectUploadController.prototype, "listObjects")!,
);
Param("sessionId")(DirectUploadController.prototype, "listObjects", 0);
Query("token")(DirectUploadController.prototype, "listObjects", 1);
ApiQuery({ name: "token", required: true, type: String })(
  DirectUploadController.prototype,
  "listObjects",
  Object.getOwnPropertyDescriptor(DirectUploadController.prototype, "listObjects")!,
);
ApiResponse({ status: 200, schema: listDirectUploadObjectsResponseSchema })(
  DirectUploadController.prototype,
  "listObjects",
  Object.getOwnPropertyDescriptor(DirectUploadController.prototype, "listObjects")!,
);

Post("sessions/:sessionId/pullback")(
  DirectUploadController.prototype,
  "pullback",
  Object.getOwnPropertyDescriptor(DirectUploadController.prototype, "pullback")!,
);
Param("sessionId")(DirectUploadController.prototype, "pullback", 0);
Body()(DirectUploadController.prototype, "pullback", 1);
ApiBody({
  schema: {
    type: "object",
    required: ["token"],
    properties: {
      token: { type: "string" },
      objectKeys: { type: "array", items: { type: "string" } },
    },
  },
})(DirectUploadController.prototype, "pullback", Object.getOwnPropertyDescriptor(DirectUploadController.prototype, "pullback")!);
ApiResponse({ status: 201, schema: pullbackDirectUploadResponseSchema })(
  DirectUploadController.prototype,
  "pullback",
  Object.getOwnPropertyDescriptor(DirectUploadController.prototype, "pullback")!,
);

Get("sessions/:sessionId/status")(
  DirectUploadController.prototype,
  "getStatus",
  Object.getOwnPropertyDescriptor(DirectUploadController.prototype, "getStatus")!,
);
Param("sessionId")(DirectUploadController.prototype, "getStatus", 0);
Query("token")(DirectUploadController.prototype, "getStatus", 1);
ApiQuery({ name: "token", required: true, type: String })(
  DirectUploadController.prototype,
  "getStatus",
  Object.getOwnPropertyDescriptor(DirectUploadController.prototype, "getStatus")!,
);
ApiResponse({ status: 200, schema: directUploadStatusResponseSchema })(
  DirectUploadController.prototype,
  "getStatus",
  Object.getOwnPropertyDescriptor(DirectUploadController.prototype, "getStatus")!,
);

Get("sessions/:sessionId/config")(
  DirectUploadController.prototype,
  "getSessionConfig",
  Object.getOwnPropertyDescriptor(DirectUploadController.prototype, "getSessionConfig")!,
);
Param("sessionId")(DirectUploadController.prototype, "getSessionConfig", 0);
Query("token")(DirectUploadController.prototype, "getSessionConfig", 1);
ApiQuery({ name: "token", required: true, type: String })(
  DirectUploadController.prototype,
  "getSessionConfig",
  Object.getOwnPropertyDescriptor(DirectUploadController.prototype, "getSessionConfig")!,
);
ApiResponse({ status: 200, schema: directUploadConfigResponseSchema })(
  DirectUploadController.prototype,
  "getSessionConfig",
  Object.getOwnPropertyDescriptor(DirectUploadController.prototype, "getSessionConfig")!,
);
