import { z } from "zod";
import type { components } from "@kidmemory/protocol/generated/sidecar/ts";

export const ImportSampleDtoSchema = z
  .object({
    persist: z.boolean().optional(),
  })
  .strict();

export type ImportSampleDto = components["schemas"]["ImportSampleRequestDto"];
