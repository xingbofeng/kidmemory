import { z } from "zod";

export const UpdatePathsDtoSchema = z
  .object({
    rootDir: z.string().optional(),
    dataDir: z.string().optional(),
    workspaceDir: z.string().optional(),
    exportDir: z.string().optional(),
  })
  .strict();

export type UpdatePathsDto = z.infer<typeof UpdatePathsDtoSchema>;
