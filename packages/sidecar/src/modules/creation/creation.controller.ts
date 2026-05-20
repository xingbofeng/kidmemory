import { Body, Controller, Get, HttpException, HttpStatus, Inject, Param, Post, Res } from "@nestjs/common";
import { ApiCode } from "@kidmemory/protocol";
import type { Response } from "express";

import { parseDto } from "../../infrastructure/validation/parse-dto.ts";
import { CreationService } from "./creation.service.ts";
import {
  CreateCreationJobDtoSchema,
  CreateCreationPlanDtoSchema,
  ExportCreationJobDtoSchema,
  ShareCreationJobDtoSchema,
} from "./dto/creation.dto.ts";

@Controller("creation/jobs")
export class CreationController {
  constructor(@Inject(CreationService) private readonly creationService: CreationService) {}

  @Post("plan")
  async createPlan(@Body() body: unknown) {
    const dto = parseDto(CreateCreationPlanDtoSchema, body, "creation/jobs/plan");
    const result = await this.creationService.createPlan(dto);
    return this.unwrap(result, "Creation plan failed");
  }

  @Post()
  async createJob(@Body() body: unknown) {
    const dto = parseDto(CreateCreationJobDtoSchema, body, "creation/jobs");
    const result = await this.creationService.createJob(dto);
    return this.unwrap(result, "Creation job failed");
  }

  @Get(":jobId/events")
  async getEvents(@Param("jobId") jobId: string) {
    const result = await this.creationService.getEvents(jobId);
    return this.unwrap(result, "Creation events lookup failed");
  }

  @Get(":jobId/preview")
  async preview(@Param("jobId") jobId: string, @Res({ passthrough: true }) response: Response) {
    const result = await this.creationService.getPreviewHtml(jobId);
    if ("html" in result && typeof result.html === "string") {
      response.status(result.status).type("html");
      return result.html;
    }
    return this.unwrap(result as { status: number; data: { message: string } }, "Creation preview failed");
  }

  @Get(":jobId")
  async getJob(@Param("jobId") jobId: string) {
    const result = await this.creationService.getJob(jobId);
    return this.unwrap(result, "Creation job lookup failed");
  }

  @Post(":jobId/export")
  async exportJob(@Param("jobId") jobId: string, @Body() body: unknown) {
    const dto = parseDto(ExportCreationJobDtoSchema, body, "creation/jobs/:jobId/export");
    const result = await this.creationService.exportJob(jobId, dto);
    return this.unwrap(result, "Creation export failed");
  }

  @Post(":jobId/share")
  async shareJob(@Param("jobId") jobId: string, @Body() body: unknown) {
    const dto = parseDto(ShareCreationJobDtoSchema, body, "creation/jobs/:jobId/share");
    const result = await this.creationService.shareJob(jobId, dto);
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
