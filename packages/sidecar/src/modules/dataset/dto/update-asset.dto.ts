import { z } from "zod";

const AssetTagSchema = z.string().trim().min(1).max(64);

export const UpdateAssetDtoSchema = z
  .object({
    title: z.string().optional(),
    description: z.string().optional(),
    tags: z.array(AssetTagSchema).max(50).optional(),
    capturedAt: z.string().optional(),
    type: z.string().optional(),
  })
  .strict();

export type UpdateAssetDto = z.infer<typeof UpdateAssetDtoSchema>;
