import { z } from "zod";

export const ImportAssetsDtoSchema = z
  .object({
    childId: z.string().trim().min(1, "childId is required"),
    paths: z.array(z.string().min(1)).min(1, "paths must include at least one entry"),
    recursive: z.boolean().optional(),
  })
  .strict();

export type ImportAssetsDto = z.infer<typeof ImportAssetsDtoSchema>;
