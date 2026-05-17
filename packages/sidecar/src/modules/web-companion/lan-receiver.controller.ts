/**
 * LAN Receiver 控制器
 *
 * 路由前缀: /api/web-companion/lan
 * - GET  /discover
 * - POST /pair
 * - POST /sessions/:sessionId/upload
 * - GET  /sessions/:sessionId/status
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
  Query,
  UploadedFiles,
  UseInterceptors,
} from "@nestjs/common";
import { FilesInterceptor } from "@nestjs/platform-express";

import { LanReceiverService } from "./lan-receiver.service.ts";
import type {
  LanUploadFile,
  LanDiscoveryResponse,
  LanPairRequest,
  LanPairResponse,
  LanUploadResponse,
  LanSessionStatusResponse,
  NetworkDiscoveryOptions,
  NetworkDiscoveryResult,
} from "./lan-receiver.types.ts";
import { LanReceiverErrorCode } from "./lan-receiver.types.ts";

export class LanReceiverController {
  private readonly lanReceiverService: LanReceiverService;

  constructor(lanReceiverService: LanReceiverService) {
    this.lanReceiverService = lanReceiverService;
  }

  /**
   * 设备发现端点
   * GET /api/web-companion/lan/discover
   */
  async discover(): Promise<LanDiscoveryResponse> {
    try {
      return await this.lanReceiverService.getDiscoveryInfo();
    } catch (error) {
      this.handleError(error);
    }
  }

  /**
   * 设备配对端点
   * POST /api/web-companion/lan/pair
   */
  async pair(request: LanPairRequest): Promise<LanPairResponse> {
    try {
      return await this.lanReceiverService.handlePairRequest(request);
    } catch (error) {
      this.handleError(error);
    }
  }

  /**
   * 局域网直传上传端点
   * POST /api/web-companion/lan/sessions/:sessionId/upload
   */
  async upload(
    sessionId: string,
    token: string,
    files: LanUploadFile[],
  ): Promise<LanUploadResponse> {
    try {
      if (!files || files.length === 0) {
        throw new HttpException(
          { code: "NO_FILES", message: "No files provided" },
          HttpStatus.BAD_REQUEST,
        );
      }

      return await this.lanReceiverService.handleDirectUpload(sessionId, token, files);
    } catch (error) {
      this.handleError(error);
    }
  }

  /**
   * 会话状态端点
   * GET /api/web-companion/lan/sessions/:sessionId/status
   */
  async getSessionStatus(
    sessionId: string,
    token: string,
  ): Promise<LanSessionStatusResponse> {
    try {
      return await this.lanReceiverService.getLanSessionStatus(sessionId, token);
    } catch (error) {
      this.handleError(error);
    }
  }

  /**
   * 网络设备发现端点
   * GET /api/web-companion/lan/devices
   */
  async discoverDevices(
    timeout?: number,
    serviceType?: string,
  ): Promise<NetworkDiscoveryResult> {
    try {
      const options: NetworkDiscoveryOptions = {
        timeout: timeout || 5000,
        serviceType,
      };

      return await this.lanReceiverService.discoverLanDevices(options);
    } catch (error) {
      this.handleError(error);
    }
  }

  private handleError(error: unknown): never {
    if (error instanceof HttpException) throw error;

    const code = error instanceof Error ? (error as Error & { code?: string }).code : undefined;
    const message = error instanceof Error ? error.message : "An unexpected error occurred";

    switch (code) {
      case LanReceiverErrorCode.DEVICE_NOT_FOUND:
      case LanReceiverErrorCode.SESSION_NOT_FOUND:
        throw new HttpException({ code, message }, HttpStatus.NOT_FOUND);

      case LanReceiverErrorCode.SESSION_EXPIRED:
      case LanReceiverErrorCode.TOKEN_INVALID:
      case LanReceiverErrorCode.PAIRING_FAILED:
        throw new HttpException({ code, message }, HttpStatus.UNAUTHORIZED);

      case LanReceiverErrorCode.UPLOAD_LIMIT_EXCEEDED:
      case LanReceiverErrorCode.FILE_TYPE_NOT_SUPPORTED:
      case LanReceiverErrorCode.FILE_SIZE_EXCEEDED:
        throw new HttpException({ code, message }, HttpStatus.BAD_REQUEST);

      case LanReceiverErrorCode.NETWORK_TIMEOUT:
      case LanReceiverErrorCode.DISCOVERY_TIMEOUT:
        throw new HttpException({ code, message }, HttpStatus.REQUEST_TIMEOUT);

      case LanReceiverErrorCode.NETWORK_ERROR:
      case LanReceiverErrorCode.CONNECTION_INTERRUPTED:
      case LanReceiverErrorCode.MDNS_RESOLUTION_FAILED:
        throw new HttpException({ code, message }, HttpStatus.SERVICE_UNAVAILABLE);

      default:
        throw new HttpException(
          { code: "INTERNAL_ERROR", message },
          HttpStatus.INTERNAL_SERVER_ERROR,
        );
    }
  }
}

// ---- 手动注册 NestJS 装饰器（避免 @ 语法）----

Inject(LanReceiverService)(LanReceiverController, undefined, 0);
Controller("api/web-companion/lan")(LanReceiverController);

const proto = LanReceiverController.prototype;
const desc = (m: string) => Object.getOwnPropertyDescriptor(proto, m)!;

// GET /discover
Get("discover")(proto, "discover", desc("discover"));

// POST /pair
Post("pair")(proto, "pair", desc("pair"));
HttpCode(HttpStatus.CREATED)(proto, "pair", desc("pair"));
Body()(proto, "pair", 0);

// POST /sessions/:sessionId/upload
Post("sessions/:sessionId/upload")(proto, "upload", desc("upload"));
HttpCode(HttpStatus.CREATED)(proto, "upload", desc("upload"));
Param("sessionId")(proto, "upload", 0);
Query("token")(proto, "upload", 1);
UseInterceptors(FilesInterceptor("files", 20))(proto, "upload", desc("upload"));
UploadedFiles()(proto, "upload", 2);

// GET /sessions/:sessionId/status
Get("sessions/:sessionId/status")(proto, "getSessionStatus", desc("getSessionStatus"));
Param("sessionId")(proto, "getSessionStatus", 0);
Query("token")(proto, "getSessionStatus", 1);

// GET /devices
Get("devices")(proto, "discoverDevices", desc("discoverDevices"));
Query("timeout")(proto, "discoverDevices", 0);
Query("serviceType")(proto, "discoverDevices", 1);
