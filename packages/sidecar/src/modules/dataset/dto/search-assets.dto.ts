import { z } from "zod";
import type { components } from "@kidmemory/protocol/generated/sidecar/ts";

const SearchTagSchema = z.string().trim().min(1).max(64);

export const SearchAssetsDtoSchema = z
  .object({
    childId: z.string().trim().min(1, "childId is required"),
    query: z.string(),
    filters: z
      .object({
        types: z.array(z.string()).optional(),
        tags: z.array(SearchTagSchema).max(50).optional(),
        capturedFrom: z.string().optional(),
        capturedTo: z.string().optional(),
      })
      .strict()
      .optional(),
    page: z.number().int().positive().optional(),
    pageSize: z.number().int().positive().max(500).optional(),
  })
  .strict();

export type SearchAssetsDto = components["schemas"]["AssetSearchRequestDto"];
