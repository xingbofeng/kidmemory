import { z } from "zod";
import type { components } from "@kidmemory/protocol/generated/sidecar/ts";

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

export type UpdateAssetDto = components["schemas"]["UpdateAssetRequestDto"];
