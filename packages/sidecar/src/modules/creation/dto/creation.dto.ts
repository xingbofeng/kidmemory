import { z } from "zod";

export const CreationTypeSchema = z.enum(["storybook", "memory_book", "memoir_video"]);

export const CreateCreationPlanDtoSchema = z
  .object({
    goal: z.string().trim().min(1),
    creationType: CreationTypeSchema,
    assetIds: z.array(z.string().trim().min(1)).min(1),
    settings: z.record(z.string(), z.unknown()).optional(),
  })
  .strict();

export const CreateCreationJobDtoSchema = z
  .object({
    planId: z.string().trim().min(1),
  })
  .strict();

export const ExportCreationJobDtoSchema = z
  .object({
    target: z.enum(["pdf", "mp4"]),
    targetPath: z.string().trim().min(1).optional(),
  })
  .strict();

export const ShareCreationJobDtoSchema = z
  .object({
    artifactId: z.string().trim().min(1),
  })
  .strict();

export type CreateCreationPlanDto = z.infer<typeof CreateCreationPlanDtoSchema>;
export type CreateCreationJobDto = z.infer<typeof CreateCreationJobDtoSchema>;
export type ExportCreationJobDto = z.infer<typeof ExportCreationJobDtoSchema>;
export type ShareCreationJobDto = z.infer<typeof ShareCreationJobDtoSchema>;
