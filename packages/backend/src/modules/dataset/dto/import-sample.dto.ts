import { z } from "zod";

export const ImportSampleDtoSchema = z
  .object({
    persist: z.boolean().optional(),
  })
  .strict();

export type ImportSampleDto = z.infer<typeof ImportSampleDtoSchema>;
