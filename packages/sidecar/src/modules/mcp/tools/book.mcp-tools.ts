import { Inject, Injectable } from "@nestjs/common";
import { Tool } from "@rekog/mcp-nest";
import { z } from "zod";

import { FileJobStoreService } from "../../../infrastructure/jobs/file-job-store.service.ts";
import { BooksService } from "../../books/books.service.ts";

const createBookJobSchema = z.object({
  childId: z.string().optional(),
  assetIds: z.array(z.string()).optional(),
  style: z.string().optional(),
  brief: z.string().optional(),
});

const jobIdSchema = z.object({
  jobId: z.string(),
});

const exportBookSchema = z.object({
  jobId: z.string(),
  body: z.record(z.string(), z.unknown()).optional(),
});

@Injectable()
export class BookMcpTools {
  constructor(
    @Inject(BooksService) private readonly booksService: BooksService,
    @Inject(FileJobStoreService) private readonly jobStore: FileJobStoreService,
  ) {}

  @Tool({
    name: "create_book_job",
    description: "Create a new book generation job from selected child/assets.",
    parameters: createBookJobSchema,
  })
  async createBookJob(input: z.infer<typeof createBookJobSchema>) {
    return toJson(await this.booksService.createJob(input));
  }

  @Tool({
    name: "get_book_job",
    description: "Get one book generation job by jobId.",
    parameters: jobIdSchema,
  })
  async getBookJob({ jobId }: z.infer<typeof jobIdSchema>) {
    return toJson(await this.booksService.getJob(jobId));
  }

  @Tool({
    name: "list_book_jobs",
    description: "List all stored book generation jobs.",
    parameters: z.object({}),
  })
  async listBookJobs() {
    return toJson({ jobs: await this.jobStore.list() });
  }

  @Tool({
    name: "export_book_pdf",
    description: "Export a generated job as PDF.",
    parameters: exportBookSchema,
  })
  async exportBookPdf({ jobId, body }: z.infer<typeof exportBookSchema>) {
    return toJson(await this.booksService.exportPdf(jobId, body ?? {}));
  }

  @Tool({
    name: "export_book_long_image",
    description: "Export a generated job as long image (PNG/JPG).",
    parameters: exportBookSchema,
  })
  async exportBookLongImage({ jobId, body }: z.infer<typeof exportBookSchema>) {
    return toJson(await this.booksService.exportLongImage(jobId, body ?? {}));
  }
}

function toJson(value: unknown) {
  return JSON.stringify(value);
}
