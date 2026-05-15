import { Body, Controller, Get, Inject, Param, Post, Res } from "@nestjs/common";

import { parseDto } from "../../infrastructure/validation/parse-dto.ts";
import { BooksService } from "./books.service.ts";
import { CreateBookJobDtoSchema, type CreateBookJobDto } from "./dto/create-book-job.dto.ts";

type RouteResponse = any;

export class BooksController {
  private readonly booksService: BooksService;

  constructor(booksService: BooksService) {
    this.booksService = booksService;
  }

  async createJob(body: unknown, response: RouteResponse) {
    const dto = parseDto<CreateBookJobDto>(CreateBookJobDtoSchema, body, "books/jobs");
    return sendRouteResult(response, await this.booksService.createJob(dto));
  }
  getJob(id: string) { return this.booksService.getJob(id); }
  async preview(id: string, response: RouteResponse) { return sendRouteResult(response, await this.booksService.getPreviewHtml(id)); }
  async exportPdf(id: string, body: Record<string, any>, response: RouteResponse) { return sendRouteResult(response, await this.booksService.exportPdf(id, body)); }
  async exportLongImage(id: string, body: Record<string, any>, response: RouteResponse) { return sendRouteResult(response, await this.booksService.exportLongImage(id, body)); }
}

function sendRouteResult(response: RouteResponse, result: { status: number; data?: unknown; html?: string }) {
  if (typeof result.html === "string") {
    return response.status(result.status).type("html").send(result.html);
  }
  return response.status(result.status).json(result.data);
}

Inject(BooksService)(BooksController, undefined as any, 0);
Controller("books")(BooksController);
Post("jobs")(BooksController.prototype, "createJob", Object.getOwnPropertyDescriptor(BooksController.prototype, "createJob")!);
Body()(BooksController.prototype, "createJob", 0);
Res()(BooksController.prototype, "createJob", 1);
Get("jobs/:id")(BooksController.prototype, "getJob", Object.getOwnPropertyDescriptor(BooksController.prototype, "getJob")!);
Param("id")(BooksController.prototype, "getJob", 0);
Get("jobs/:id/preview")(BooksController.prototype, "preview", Object.getOwnPropertyDescriptor(BooksController.prototype, "preview")!);
Param("id")(BooksController.prototype, "preview", 0);
Res()(BooksController.prototype, "preview", 1);
Post("jobs/:id/export/pdf")(BooksController.prototype, "exportPdf", Object.getOwnPropertyDescriptor(BooksController.prototype, "exportPdf")!);
Param("id")(BooksController.prototype, "exportPdf", 0);
Body()(BooksController.prototype, "exportPdf", 1);
Res()(BooksController.prototype, "exportPdf", 2);
Post("jobs/:id/export/long-image")(BooksController.prototype, "exportLongImage", Object.getOwnPropertyDescriptor(BooksController.prototype, "exportLongImage")!);
Param("id")(BooksController.prototype, "exportLongImage", 0);
Body()(BooksController.prototype, "exportLongImage", 1);
Res()(BooksController.prototype, "exportLongImage", 2);
