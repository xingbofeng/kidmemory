import { z } from "zod";

export const UpdateSupabaseStorageDtoSchema = z
  .object({
    provider: z.enum(["supabase", "cos", "s3"]).optional(),
    url: z.string().optional(),
    bucket: z.string().optional(),
    serviceRoleKey: z.string().optional(),
    publicBaseUrl: z.string().optional(),
    signedUrlTtlSeconds: z
      .union([z.number().int().positive().max(86_400 * 30), z.string().min(1)])
      .optional(),
    s3Endpoint: z.string().optional(),
    s3Region: z.string().optional(),
    s3AccessKeyId: z.string().optional(),
    s3SecretAccessKey: z.string().optional(),
  })
  .strict();

export type UpdateSupabaseStorageDto = z.infer<typeof UpdateSupabaseStorageDtoSchema>;
