import { Body, Controller, Get, HttpException, HttpStatus, Inject, Param, Post, Res } from "@nestjs/common";
import type { Response } from "express";

import { parseDto } from "../../infrastructure/validation/parse-dto.ts";
import { BooksService } from "./books.service.ts";
import { CreateBookJobDtoSchema, type CreateBookJobDto } from "./dto/create-book-job.dto.ts";
import { ApiCode } from "@kidmemory/protocol";

@Controller("books")
export class BooksController {
  constructor(@Inject(BooksService) private readonly booksService: BooksService) {}

  @Post("jobs")
  async createJob(@Body() body: unknown) {
    const dto = parseDto<CreateBookJobDto>(CreateBookJobDtoSchema, body, "books/jobs");
    const result = await this.booksService.createJob(dto);
    
    // Handle non-200 status codes by throwing exceptions with apiCode
    if (result.status !== 200) {
      const error: any = result.data;
      error.apiCode = this.mapStatusToApiCode(result.status);
      throw new HttpException(error, result.status);
    }
    
    return result.data;
  }

  @Get("jobs/:id")
  getJob(@Param("id") id: string) { 
    return this.booksService.getJob(id); 
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
      const error: any = result.data;
      error.apiCode = this.mapStatusToApiCode(result.status);
      throw new HttpException(error, result.status);
    }
    
    return result.data;
  }

  @Post("jobs/:id/export/pdf")
  async exportPdf(@Param("id") id: string, @Body() body: Record<string, any>) {
    const result = await this.booksService.exportPdf(id, body);
    
    if (result.status !== 200) {
      const error: any = result.data;
      error.apiCode = this.mapStatusToApiCode(result.status);
      throw new HttpException(error, result.status);
    }
    
    return result.data;
  }

  @Post("jobs/:id/export/long-image")
  async exportLongImage(@Param("id") id: string, @Body() body: Record<string, any>) {
    const result = await this.booksService.exportLongImage(id, body);
    
    if (result.status !== 200) {
      const error: any = result.data;
      error.apiCode = this.mapStatusToApiCode(result.status);
      throw new HttpException(error, result.status);
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
