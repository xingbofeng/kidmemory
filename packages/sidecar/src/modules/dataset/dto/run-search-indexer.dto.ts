import { z } from "zod";
import type { components } from "@kidmemory/protocol/generated/sidecar/ts";

export const RunSearchIndexerDtoSchema = z
  .object({
    limit: z.number().int().positive().max(10_000).optional(),
    now: z.string().optional(),
  })
  .strict();

export type RunSearchIndexerDto = components["schemas"]["RunSearchIndexerRequestDto"];
