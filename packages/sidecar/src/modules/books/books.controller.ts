import { Body, Controller, Get, HttpException, HttpStatus, Inject, Param, Post, Res } from "@nestjs/common";
import type { Response } from "express";

import { parseDto } from "../../infrastructure/validation/parse-dto.ts";
import { BooksService } from "./books.service.ts";
import { CreateBookJobDtoSchema } from "./dto/create-book-job.dto.ts";
import { ApiCode } from "@kidmemory/protocol";

@Controller("books")
export class BooksController {
  constructor(@Inject(BooksService) private readonly booksService: BooksService) {}

  @Post("jobs")
  async createJob(@Body() body: unknown) {
    const dto = parseDto(CreateBookJobDtoSchema, body, "books/jobs");
    let result;
    try {
      result = await this.booksService.createJob(dto);
    } catch (error) {
      const message = error instanceof Error ? error.message : "Unknown create job error";
      throw new HttpException({ ok: false, message }, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    
    // Handle non-200 status codes by throwing exceptions with apiCode
    if (result.status !== 200) {
      const payload: any = result.data ?? {};
      const resolvedMessage =
        payload.message ||
        payload.runner?.message ||
        payload.runner?.error ||
        "Book job creation failed";
      throw new HttpException(
        {
          message: resolvedMessage,
          apiCode: this.mapStatusToApiCode(result.status),
          data: payload,
        },
        result.status,
      );
    }
    
    return result.data;
  }

  @Get("jobs")
  listJobs() {
    return this.booksService.listJobs();
  }

  @Get("jobs/:id")
  async getJob(@Param("id") id: string) {
    const result: any = await this.booksService.getJob(id);
    if (result?.ok === false && result?.message === "Job not found") {
      throw new HttpException(
        { message: "Job not found", apiCode: this.mapStatusToApiCode(404), data: result },
        HttpStatus.NOT_FOUND,
      );
    }
    return result;
  }

  @Post("jobs/:id/cancel")
  async cancelJob(@Param("id") id: string) {
    const result = await this.booksService.cancelJob(id);
    if (result.status !== 200) {
      const payload: any = result.data ?? {};
      throw new HttpException(
        {
          message: payload.message || "Book cancel failed",
          apiCode: this.mapStatusToApiCode(result.status),
          data: payload,
        },
        result.status,
      );
    }
    return result.data;
  }

  @Post("jobs/:id/retry")
  async retryJob(@Param("id") id: string) {
    const result = await this.booksService.retryJob(id);
    if (result.status !== 200) {
      const payload: any = result.data ?? {};
      throw new HttpException(
        {
          message: payload.message || "Book retry failed",
          apiCode: this.mapStatusToApiCode(result.status),
          data: payload,
        },
        result.status,
      );
    }
    return result.data;
  }

  @Get("jobs/:id/preview")
  async preview(@Param("id") id: string, @Res({ passthrough: true }) response: Response) {
    const result = await this.booksService.getPreviewHtml(id);
    
    // HTML responses should not be wrapped in JSON format
    if ('html' in result && typeof result.html === "string") {
      response.status(result.status).type("html");
      return result.html;
    }
    
    // Handle errors
    if (result.status !== 200) {
      const payload: any = result.data ?? {};
      const resolvedMessage =
        payload.message ||
        payload.exported?.message ||
        payload.verified?.message ||
        "Book preview failed";
      throw new HttpException(
        {
          message: resolvedMessage,
          apiCode: this.mapStatusToApiCode(result.status),
          data: payload,
        },
        result.status,
      );
    }
    
    return result.data;
  }

  @Post("jobs/:id/export/pdf")
  async exportPdf(@Param("id") id: string, @Body() body: Record<string, any>) {
    const result = await this.booksService.exportPdf(id, body);
    
    if (result.status !== 200) {
      const payload: any = result.data ?? {};
      const resolvedMessage =
        payload.message ||
        payload.exported?.message ||
        payload.verified?.message ||
        "Book export failed";
      throw new HttpException(
        {
          message: resolvedMessage,
          apiCode: this.mapStatusToApiCode(result.status),
          data: payload,
        },
        result.status,
      );
    }
    
    return result.data;
  }

  @Post("jobs/:id/export/long-image")
  async exportLongImage(@Param("id") id: string, @Body() body: Record<string, any>) {
    const result = await this.booksService.exportLongImage(id, body);
    
    if (result.status !== 200) {
      const payload: any = result.data ?? {};
      const resolvedMessage =
        payload.message ||
        payload.exported?.message ||
        "Long-image export failed";
      throw new HttpException(
        {
          message: resolvedMessage,
          apiCode: this.mapStatusToApiCode(result.status),
          data: payload,
        },
        result.status,
      );
    }
    
    return result.data;
  }

  private mapStatusToApiCode(status: number): number {
    switch (status) {
      case 404:
        return ApiCode.NOT_FOUND;
      case 422:
        return ApiCode.INVALID_PARAMS;
      case 500:
        return ApiCode.INTERNAL_ERROR;
      default:
        return ApiCode.UNKNOWN_ERROR;
    }
  }
}
