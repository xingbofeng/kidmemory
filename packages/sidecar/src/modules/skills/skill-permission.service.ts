import path from "node:path";

import { Inject, Injectable } from "@nestjs/common";

import { SkillLoaderService } from "./skill-loader.service.ts";

const DEFAULT_ALLOWED_TOOLS_BY_SKILL: Record<string, Set<string>> = {
  "picturebook-maker": new Set([
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
  ]),
  hyperframes: new Set([
    "render_hyperframes_video",
    "get_recent_logs",
  ]),
};

@Injectable()
export class SkillPermissionService {
  constructor(@Inject(SkillLoaderService) private readonly loader: SkillLoaderService) {}

  assertToolAllowed(skillId: string, toolName: string) {
    const allowed = DEFAULT_ALLOWED_TOOLS_BY_SKILL[skillId];
    if (!allowed || !allowed.has(toolName)) {
      throw new Error(`Skill tool access denied: skill=${skillId}, tool=${toolName}`);
    }
  }

  assertFilePathAllowed(filePath: string, workspaceRoot: string) {
    const normalized = path.resolve(filePath);
    const skillsRoot = this.loader.getSkillsRootDir();
    const normalizedWorkspace = path.resolve(workspaceRoot);

    if (normalized.startsWith(skillsRoot) || normalized.startsWith(normalizedWorkspace)) {
      return;
    }

    throw new Error(`Skill file access denied: ${filePath}`);
  }
}
