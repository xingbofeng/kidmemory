import { z } from "zod";

export const UpdateOpenAIDtoSchema = z
  .object({
    baseUrl: z.string().optional(),
    apiKey: z.string().optional(),
    model: z.string().optional(),
  })
  .strict();

export type UpdateOpenAIDto = z.infer<typeof UpdateOpenAIDtoSchema>;
