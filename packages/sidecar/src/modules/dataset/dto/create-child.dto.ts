import { z } from "zod";

export const CreateChildDtoSchema = z
  .object({
    id: z.string().trim().min(1).optional(),
    name: z.string().trim().min(1, "name is required"),
    birthday: z.string().trim().min(1).optional(),
    notes: z.string().optional(),
    metadata: z.record(z.string(), z.unknown()).optional(),
  })
  .strict();

export type CreateChildDto = z.infer<typeof CreateChildDtoSchema>;
