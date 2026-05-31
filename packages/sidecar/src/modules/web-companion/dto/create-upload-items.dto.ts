import { z } from "zod";
import type { CreateUploadItemsRequest } from "../types.ts";

const CreateUploadItemsFileSchema = z.object({
  clientFileId: z.string().min(1),
  filename: z.string().min(1),
  contentType: z.string().min(1),
  sizeBytes: z.number().int().nonnegative(),
}).strict();

export const CreateUploadItemsDtoSchema = z.object({
  token: z.string().min(1),
  provider: z.enum(["lan", "supabase"]).optional(),
  files: z.array(CreateUploadItemsFileSchema).min(1),
}).strict().superRefine((value, ctx) => {
  if (!value.files) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ["files"],
      message: "files must be provided",
    });
  }
});

export type CreateUploadItemsDto = CreateUploadItemsRequest;
