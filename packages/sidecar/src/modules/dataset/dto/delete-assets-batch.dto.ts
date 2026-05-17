import { z } from "zod";
import type { components } from "@kidmemory/protocol/generated/sidecar/ts";

export const DeleteAssetsBatchDtoSchema = z
  .object({
    ids: z.array(z.string().trim().min(1)).min(1, "ids must include at least one asset id"),
  })
  .strict();

export type DeleteAssetsBatchDto = components["schemas"]["DeleteAssetsBatchRequestDto"];
