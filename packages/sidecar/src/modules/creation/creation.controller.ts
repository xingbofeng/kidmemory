import { Body, Controller, Get, HttpCode, HttpException, HttpStatus, Inject, Param, Post, Res } from "@nestjs/common";
import { ApiCode } from "@kidmemory/protocol";
import type { Response } from "express";

import { parseDto } from "../../infrastructure/validation/parse-dto.ts";
import { CreationService } from "./creation.service.ts";
import {
  CreateCreationTaskDtoSchema,
  ExportCreationTaskDtoSchema,
  ShareCreationTaskDtoSchema,
} from "./dto/creation.dto.ts";

@Controller("creation/tasks")
export class CreationController {
  constructor(@Inject(CreationService) private readonly creationService: CreationService) {}

  @Post()
  async createTask(@Body() body: unknown) {
    const dto = parseDto(CreateCreationTaskDtoSchema, body, "creation/tasks");
    const result = await this.creationService.createTask(dto);
    return this.unwrap(result, "Creation task failed");
  }

  @Post(":taskId/generate")
  @HttpCode(HttpStatus.OK)
  async generateTask(@Param("taskId") taskId: string) {
    const result = await this.creationService.generateTask(taskId);
    return this.unwrap(result, "Creation generation failed");
  }

  @Get(":taskId")
  async getTask(@Param("taskId") taskId: string) {
    const result = await this.creationService.getTask(taskId);
    return this.unwrap(result, "Creation task lookup failed");
  }

  @Get(":taskId/events")
  async getEvents(@Param("taskId") taskId: string) {
    const result = await this.creationService.getEvents(taskId);
    return this.unwrap(result, "Creation events lookup failed");
  }

  @Get(":taskId/preview")
  async preview(@Param("taskId") taskId: string, @Res({ passthrough: true }) response: Response) {
    const result = await this.creationService.getPreviewHtml(taskId);
    if ("html" in result && typeof result.html === "string") {
      response.status(result.status).type("html");
      return result.html;
    }
    return this.unwrap(result as { status: number; data: { message: string } }, "Creation preview failed");
  }

  @Post(":taskId/export")
  async exportTask(@Param("taskId") taskId: string, @Body() body: unknown) {
    const dto = parseDto(ExportCreationTaskDtoSchema, body, "creation/tasks/:taskId/export");
    const result = await this.creationService.exportTask(taskId, dto);
    return this.unwrap(result, "Creation export failed");
  }

  @Post(":taskId/share")
  async shareTask(@Param("taskId") taskId: string, @Body() body: unknown) {
    const dto = parseDto(ShareCreationTaskDtoSchema, body, "creation/tasks/:taskId/share");
    const result = await this.creationService.shareTask(taskId, dto);
    return this.unwrap(result, "Creation share failed");
  }

  private unwrap<T>(result: { status: number; data: T }, fallbackMessage: string) {
    if (result.status >= 200 && result.status < 300) return result.data;
    const payload = result.data as Record<string, unknown>;
    throw new HttpException(
      {
        message: typeof payload?.message === "string" ? payload.message : fallbackMessage,
        apiCode: this.mapStatusToApiCode(result.status),
        data: payload,
      },
      result.status,
    );
  }

  private mapStatusToApiCode(status: number) {
    switch (status) {
      case HttpStatus.NOT_FOUND:
        return ApiCode.NOT_FOUND;
      case HttpStatus.BAD_REQUEST:
      case HttpStatus.UNPROCESSABLE_ENTITY:
        return ApiCode.INVALID_PARAMS;
      case HttpStatus.INTERNAL_SERVER_ERROR:
        return ApiCode.INTERNAL_ERROR;
      default:
        return ApiCode.UNKNOWN_ERROR;
    }
  }
}
