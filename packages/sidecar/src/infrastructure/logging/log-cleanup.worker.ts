import fs from "node:fs/promises";
import path from "node:path";

import { Inject, Injectable } from "@nestjs/common";

import { AppConfigService } from "../config/app-config.service.ts";

@Injectable()
export class LogCleanupWorker {
  constructor(@Inject(AppConfigService) private readonly config: AppConfigService) {}

  async cleanup(retainDays = 7) {
    const thresholdDays = Math.max(Math.floor(retainDays), 1);
    const logsDir = path.join(this.config.config.paths.dataDir, "logs", "sidecar");
    await fs.mkdir(logsDir, { recursive: true });

    const files = await fs.readdir(logsDir);
    const now = Date.now();
    const ttlMs = thresholdDays * 24 * 60 * 60 * 1000;

    let deleted = 0;
    for (const fileName of files) {
      if (!fileName.endsWith(".jsonl")) {
        continue;
      }

      const fullPath = path.join(logsDir, fileName);
      const stats = await fs.stat(fullPath);
      if (now - stats.mtimeMs > ttlMs) {
        await fs.unlink(fullPath);
        deleted += 1;
      }
    }

    return { deleted, retainDays: thresholdDays };
  }
}
