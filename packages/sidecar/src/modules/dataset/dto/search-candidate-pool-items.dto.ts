import { z } from "zod";
import type { components } from "@kidmemory/protocol/generated/sidecar/ts";

export const SearchCandidatePoolItemsDtoSchema = z
  .object({
    childId: z.string().trim().min(1, "childId is required"),
    assetIds: z.array(z.string().min(1)).min(1, "assetIds must include at least one entry"),
    sourceQuery: z.string().optional(),
  })
  .strict();

export type SearchCandidatePoolItemsDto = components["schemas"]["SearchCandidatePoolItemsRequestDto"];
