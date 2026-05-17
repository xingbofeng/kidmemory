import fs from "node:fs/promises";
import path from "node:path";

import { Inject, Injectable } from "@nestjs/common";

import { AppConfigService } from "../config/app-config.service.ts";
import { redactSensitive } from "./redaction.ts";

export type FileLogLevel = "debug" | "info" | "warn" | "error";

export type FileLogEntry = {
  timestamp: string;
  level: FileLogLevel;
  event: string;
  traceId?: string;
  requestId?: string;
  data?: unknown;
};

@Injectable()
export class FileLoggerService {
  constructor(@Inject(AppConfigService) private readonly config: AppConfigService) {}

  async append(entry: FileLogEntry) {
    const payload = {
      ...entry,
      data: redactSensitive(entry.data),
    };

    const logPath = await this.ensureLogFilePath();
    await fs.appendFile(logPath, `${JSON.stringify(payload)}\n`, "utf8");
  }

  async tail(limit = 50) {
    const max = Number.isFinite(limit) ? Math.min(Math.max(Math.floor(limit), 1), 200) : 50;
    const logPath = this.currentLogFilePath();

    try {
      const content = await fs.readFile(logPath, "utf8");
      const rows = content
        .split(/\r?\n/)
        .map((line) => line.trim())
        .filter((line) => line.length > 0)
        .slice(-max);

      return rows.map((line) => parseLogLine(line)).filter((item): item is Record<string, unknown> => item != null);
    } catch (error: unknown) {
      if (isNotFoundError(error)) {
        return [];
      }
      throw error;
    }
  }

  private get logsDir() {
    return path.join(this.config.config.paths.dataDir, "logs", "sidecar");
  }

  private currentLogFilePath() {
    const day = new Date().toISOString().slice(0, 10);
    return path.join(this.logsDir, `sidecar-${day}.jsonl`);
  }

  private async ensureLogFilePath() {
    await fs.mkdir(this.logsDir, { recursive: true });
    const filePath = this.currentLogFilePath();
    await fs.appendFile(filePath, "", "utf8");
    return filePath;
  }
}

function parseLogLine(line: string) {
  try {
    const parsed = JSON.parse(line);
    return parsed && typeof parsed === "object" ? (parsed as Record<string, unknown>) : null;
  } catch {
    return null;
  }
}

function isNotFoundError(error: unknown) {
  return Boolean(
    error
      && typeof error === "object"
      && "code" in error
      && (error as { code?: string }).code === "ENOENT",
  );
}
