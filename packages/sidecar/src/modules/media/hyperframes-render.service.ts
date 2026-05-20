import fs from "node:fs/promises";
import path from "node:path";
import { spawn } from "node:child_process";

import { Inject, Injectable } from "@nestjs/common";

import { AppConfigService } from "../../infrastructure/config/app-config.service.ts";
import { FileLoggerService } from "../../infrastructure/logging/file-logger.service.ts";
import { TraceContextService } from "../../infrastructure/logging/trace-context.service.ts";

export type RenderHyperframesInput = {
  projectId: string;
  prompt?: string;
  traceId?: string;
  targetPath?: string;
};

@Injectable()
export class HyperframesRenderService {
  constructor(
    @Inject(AppConfigService) private readonly appConfig: AppConfigService,
    @Inject(FileLoggerService) private readonly logger: FileLoggerService,
    @Inject(TraceContextService)
    private readonly traceContext: TraceContextService,
  ) {}

  async render(input: RenderHyperframesInput) {
    const traceId = input.traceId?.trim() || this.traceContext.getTraceId();
    const command = process.env.HYPERFRAMES_RENDER_COMMAND?.trim();
    if (!command) {
      const response = {
        ok: false,
        recoverable: true,
        code: "HYPERFRAMES_NOT_CONFIGURED",
        message:
          "Hyperframes renderer is not configured. Set HYPERFRAMES_RENDER_COMMAND to enable rendering.",
      };

      await this.logger.append({
        timestamp: new Date().toISOString(),
        level: "warn",
        event: "hyperframes.render.unconfigured",
        traceId,
        data: {
          projectId: input.projectId,
        },
      });

      return response;
    }

    const outputPath = await this.resolveOutputPath(input);
    await fs.mkdir(path.dirname(outputPath), { recursive: true });

    const result = await runRenderCommand(command, {
      HYPERFRAMES_PROJECT_ID: input.projectId,
      HYPERFRAMES_PROMPT: input.prompt ?? "",
      HYPERFRAMES_OUTPUT_PATH: outputPath,
      HYPERFRAMES_TRACE_ID: traceId,
    });

    if (!result.ok) {
      const response = {
        ok: false,
        recoverable: true,
        code: "HYPERFRAMES_RENDER_FAILED",
        message: result.output || "Hyperframes renderer command failed.",
      };

      await this.logger.append({
        timestamp: new Date().toISOString(),
        level: "error",
        event: "hyperframes.render.failed",
        traceId,
        data: {
          projectId: input.projectId,
          code: response.code,
          output: response.message,
        },
      });

      return response;
    }

    const output = await inspectOutput(outputPath);
    if (output.ok === false) {
      await this.logger.append({
        timestamp: new Date().toISOString(),
        level: "error",
        event: "hyperframes.render.output_missing",
        traceId,
        data: {
          projectId: input.projectId,
          code: output.code,
          outputPath,
        },
      });

      return {
        ok: false,
        recoverable: true,
        code: output.code,
        message: output.message,
      };
    }

    await this.logger.append({
      timestamp: new Date().toISOString(),
      level: "info",
      event: "hyperframes.render.succeeded",
      traceId,
      data: {
        projectId: input.projectId,
        outputPath,
        sizeBytes: output.sizeBytes,
      },
    });

    return {
      ok: true,
      localPath: outputPath,
    };
  }

  private async resolveOutputPath(input: RenderHyperframesInput) {
    if (input.targetPath?.trim()) {
      return path.resolve(input.targetPath);
    }

    const dir = path.join(this.appConfig.config.paths.exportDir, "hyperframes");
    await fs.mkdir(dir, { recursive: true });
    return path.join(dir, `${sanitize(input.projectId)}.mp4`);
  }
}

function sanitize(value: string) {
  return value.replace(/[^a-zA-Z0-9-_]/g, "-");
}

async function runRenderCommand(command: string, env: Record<string, string>) {
  return await new Promise<{ ok: boolean; output: string }>((resolve) => {
    const child = spawn(command, [], {
      shell: true,
      env: {
        ...process.env,
        ...env,
      },
      stdio: ["ignore", "pipe", "pipe"],
    });
    const chunks: string[] = [];
    const timer = setTimeout(() => {
      child.kill("SIGTERM");
      chunks.push(
        `Timed out after ${Math.round(renderTimeoutMs() / 1000)} seconds.`,
      );
    }, renderTimeoutMs());

    child.stdout.setEncoding("utf8");
    child.stderr.setEncoding("utf8");
    child.stdout.on("data", (chunk) => chunks.push(chunk));
    child.stderr.on("data", (chunk) => chunks.push(chunk));
    child.on("error", (error) => {
      clearTimeout(timer);
      resolve({ ok: false, output: shortOutput(error.message) });
    });
    child.on("close", (code) => {
      clearTimeout(timer);
      resolve({ ok: code === 0, output: shortOutput(chunks.join("")) });
    });
  });
}

async function inspectOutput(outputPath: string) {
  try {
    const stat = await fs.stat(outputPath);
    if (stat.size <= 0) {
      return {
        ok: false as const,
        code: "HYPERFRAMES_OUTPUT_EMPTY",
        message: `Hyperframes renderer created an empty MP4 at ${outputPath}.`,
      };
    }
    return { ok: true as const, sizeBytes: stat.size };
  } catch {
    return {
      ok: false as const,
      code: "HYPERFRAMES_OUTPUT_MISSING",
      message: `Hyperframes renderer did not create the expected MP4 at ${outputPath}.`,
    };
  }
}

function renderTimeoutMs() {
  const configured = Number(process.env.HYPERFRAMES_RENDER_TIMEOUT_MS);
  return Number.isFinite(configured) && configured > 0
    ? configured
    : 10 * 60 * 1000;
}

function shortOutput(output: string) {
  return output.replace(/\s+/g, " ").trim().slice(0, 500);
}
