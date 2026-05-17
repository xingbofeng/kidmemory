import { z } from "zod";
import type { components } from "@kidmemory/protocol/generated/sidecar/ts";

export const UpdatePathsDtoSchema = z
  .object({
    rootDir: z.string().optional(),
    dataDir: z.string().optional(),
    workspaceDir: z.string().optional(),
    exportDir: z.string().optional(),
  })
  .strict();

export type UpdatePathsDto = components["schemas"]["PathsConfigRequestDto"];
