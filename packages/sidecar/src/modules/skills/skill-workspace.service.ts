import fs from "node:fs/promises";
import path from "node:path";

import { Inject, Injectable } from "@nestjs/common";

import { AppConfigService } from "../../infrastructure/config/app-config.service.ts";

@Injectable()
export class SkillWorkspaceService {
  constructor(@Inject(AppConfigService) private readonly appConfig: AppConfigService) {}

  async prepare(skillId: string, traceId?: string) {
    const runtimeRoot = path.join(this.appConfig.config.paths.workspaceDir, "skills-runtime");
    const safeSkillId = sanitize(skillId);
    const runKey = traceId ? sanitize(traceId) : `${Date.now()}`;
    const runDir = path.join(runtimeRoot, safeSkillId, runKey);

    await fs.mkdir(runDir, { recursive: true });

    return {
      runtimeRoot,
      runDir,
    };
  }
}

function sanitize(value: string) {
  return value.replace(/[^a-zA-Z0-9-_]/g, "-");
}
