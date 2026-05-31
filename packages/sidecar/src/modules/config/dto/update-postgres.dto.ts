import { z } from "zod";

export const UpdatePostgresDtoSchema = z
  .object({
    host: z.string().optional(),
    database: z.string().optional(),
    user: z.string().optional(),
    password: z.string().optional(),
    connectionUrl: z.string().optional(),
    port: z.union([z.number().int().positive().max(65_535), z.string().min(1)]).optional(),
  })
  .strict();

export type UpdatePostgresDto = z.infer<typeof UpdatePostgresDtoSchema>;
