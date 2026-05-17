import { z } from "zod";
import type { components } from "@kidmemory/protocol/generated/sidecar/ts";

export const CreateBookJobDtoSchema = z
  .object({
    childId: z.string().trim().min(1).optional(),
    assetIds: z.array(z.string().min(1)).optional(),
    title: z.string().optional(),
    theme: z.string().optional(),
    coverPolicy: z.enum(["auto", "skip"]).optional(),
  })
  .strict();

export type CreateBookJobDto = components["schemas"]["CreateBookJobRequestDto"];
