import { z } from "zod";

const CreateUploadItemsFileSchema = z.object({
  clientFileId: z.string().min(1),
  filename: z.string().min(1),
  contentType: z.string().min(1),
  sizeBytes: z.number().int().nonnegative(),
}).strict();

const LegacyUploadItemSchema = z.object({
  filename: z.string().min(1),
  mimeType: z.string().min(1),
  size: z.number().int().nonnegative(),
  clientFileId: z.string().min(1).optional(),
}).strict();

export const CreateUploadItemsDtoSchema = z.object({
  token: z.string().min(1),
  provider: z.enum(["lan", "supabase"]).optional(),
  files: z.array(CreateUploadItemsFileSchema).min(1).optional(),
  items: z.array(LegacyUploadItemSchema).min(1).optional(),
}).strict().superRefine((value, ctx) => {
  if (!value.files && !value.items) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ["files"],
      message: "files or items must be provided",
    });
  }
});

export type CreateUploadItemsDto = z.infer<typeof CreateUploadItemsDtoSchema>;
