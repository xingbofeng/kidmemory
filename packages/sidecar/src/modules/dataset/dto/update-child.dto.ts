import { z } from "zod";

export const UpdateChildDtoSchema = z
  .object({
    name: z.string().trim().min(1, "name is required").optional(),
    birthday: z.string().trim().optional(),
    notes: z.string().optional(),
    metadata: z.record(z.string(), z.unknown()).optional(),
  })
  .strict()
  .refine((value) => Object.keys(value).length > 0, {
    message: "At least one field must be provided",
  });

export type UpdateChildDto = z.infer<typeof UpdateChildDtoSchema>;
