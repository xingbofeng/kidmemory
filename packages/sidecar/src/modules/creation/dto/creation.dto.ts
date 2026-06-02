import { z } from "zod";

export const CreationTypeSchema = z.enum([
  "storybook",
  "memory_book",
  "memoir_video",
]);

export const CreateCreationTaskDtoSchema = z
  .object({
    creationType: CreationTypeSchema,
    goal: z.string().trim().min(1),
    assetIds: z.array(z.string().trim().min(1)).min(1),
    settings: z.record(z.string(), z.unknown()).optional(),
  })
  .strict();

export const GenerateCreationTaskDtoSchema = z.object({}).strict().optional();

export const ExportCreationTaskDtoSchema = z
  .object({
    target: z.enum(["pdf", "mp4", "long_image_png", "long_image_jpg"]),
    targetPath: z.string().trim().min(1).optional(),
  })
  .strict();

export const ShareCreationTaskDtoSchema = z
  .object({
    artifactId: z.string().trim().min(1),
  })
  .strict();

export type CreateCreationTaskDto = z.infer<typeof CreateCreationTaskDtoSchema>;
export type GenerateCreationTaskDto = z.infer<
  typeof GenerateCreationTaskDtoSchema
>;
export type ExportCreationTaskDto = z.infer<typeof ExportCreationTaskDtoSchema>;
export type ShareCreationTaskDto = z.infer<typeof ShareCreationTaskDtoSchema>;
