import { z } from "zod";

export const RunSearchIndexerDtoSchema = z
  .object({
    limit: z.number().int().positive().max(10_000).optional(),
    now: z.string().optional(),
  })
  .strict();

export type RunSearchIndexerDto = z.infer<typeof RunSearchIndexerDtoSchema>;
