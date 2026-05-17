import { z } from "zod";
import type { components } from "@kidmemory/protocol/generated/sidecar/ts";

export const ImportAssetsDtoSchema = z
  .object({
    childId: z.string().trim().min(1, "childId is required"),
    paths: z.array(z.string().min(1)).min(1, "paths must include at least one entry"),
    recursive: z.boolean().optional(),
  })
  .strict();

export type ImportAssetsDto = components["schemas"]["ImportAssetsRequestDto"];
