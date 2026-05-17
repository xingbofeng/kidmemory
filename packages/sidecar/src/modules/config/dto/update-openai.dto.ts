import { z } from "zod";
import type { components } from "@kidmemory/protocol/generated/sidecar/ts";

export const UpdateOpenAIDtoSchema = z
  .object({
    baseUrl: z.string().optional(),
    apiKey: z.string().optional(),
    model: z.string().optional(),
  })
  .strict();

export type UpdateOpenAIDto = components["schemas"]["OpenAiConfigRequestDto"];
