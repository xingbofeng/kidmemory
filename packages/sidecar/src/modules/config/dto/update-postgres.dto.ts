import { z } from "zod";
import type { components } from "@kidmemory/protocol/generated/sidecar/ts";

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

export type UpdatePostgresDto = components["schemas"]["PostgresConfigRequestDto"];
