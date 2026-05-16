import { Inject, Injectable } from "@nestjs/common";
import { Tool } from "@rekog/mcp-nest";
import { z } from "zod";

import {
  SkillRuntimeService,
  type SkillRuntimeToolName,
} from "../../skills/skill-runtime.service.ts";

const runSkillTaskSchema = z.object({
  skillId: z.string(),
  tool: z.enum([
    "get_sidecar_health",
    "get_config_status",
    "get_indexing_status",
    "get_recent_logs",
    "list_children",
    "get_child_profile",
    "list_recent_assets",
    "search_assets",
    "search_assets_by_vector",
    "get_asset_metadata",
    "get_asset_preview",
    "update_asset_metadata",
    "create_book_job",
    "get_book_job",
    "list_book_jobs",
    "export_book_pdf",
    "export_book_long_image",
    "generate_cover_image_preview",
    "render_hyperframes_video",
  ]),
  arguments: z.record(z.string(), z.unknown()).optional(),
  traceId: z.string().optional(),
});

@Injectable()
export class SkillRuntimeMcpTools {
  constructor(@Inject(SkillRuntimeService) private readonly runtime: SkillRuntimeService) {}

  @Tool({
    name: "list_skills",
    description: "List registered skills available in sidecar skill runtime.",
    parameters: z.object({}),
  })
  async listSkills() {
    return toJson({ skills: await this.runtime.listSkills() });
  }

  @Tool({
    name: "run_skill_task",
    description: "Execute a controlled skill task and trigger a tool call inside runtime.",
    parameters: runSkillTaskSchema,
  })
  async runSkillTask(input: z.infer<typeof runSkillTaskSchema>) {
    try {
      return toJson(
        await this.runtime.execute({
          skillId: input.skillId,
          tool: input.tool as SkillRuntimeToolName,
          arguments: input.arguments,
          traceId: input.traceId,
        }),
      );
    } catch (error: unknown) {
      return toJson({
        ok: false,
        code: "SKILL_RUNTIME_EXECUTION_FAILED",
        message: error instanceof Error ? error.message : "Unknown skill runtime error",
      });
    }
  }
}

function toJson(value: unknown) {
  return JSON.stringify(value);
}
