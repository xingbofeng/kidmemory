import { z } from "zod";

export const DeleteAssetsBatchDtoSchema = z
  .object({
    ids: z.array(z.string().trim().min(1)).min(1, "ids must include at least one asset id"),
  })
  .strict();

export type DeleteAssetsBatchDto = z.infer<typeof DeleteAssetsBatchDtoSchema>;
