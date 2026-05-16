import fs from "node:fs/promises";
import path from "node:path";

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
    @Inject(TraceContextService) private readonly traceContext: TraceContextService,
  ) {}

  async render(input: RenderHyperframesInput) {
    const traceId = input.traceId?.trim() || this.traceContext.getTraceId();
    const command = process.env.HYPERFRAMES_RENDER_COMMAND?.trim();
    if (!command) {
      const response = {
        ok: false,
        recoverable: true,
        code: "HYPERFRAMES_NOT_CONFIGURED",
        message: "Hyperframes renderer is not configured. Set HYPERFRAMES_RENDER_COMMAND to enable rendering.",
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

    if (command === "mock-success") {
      await fs.writeFile(outputPath, "mock mp4 bytes", "utf8");
      const response = {
        ok: true,
        outputPath,
        provider: "hyperframes",
      };

      await this.logger.append({
        timestamp: new Date().toISOString(),
        level: "info",
        event: "hyperframes.render.success",
        traceId,
        data: {
          projectId: input.projectId,
          outputPath,
        },
      });

      return response;
    }

    const response = {
      ok: false,
      recoverable: true,
      code: "HYPERFRAMES_COMMAND_UNSUPPORTED",
      message: `Unsupported HYPERFRAMES_RENDER_COMMAND value: ${command}`,
    };

    await this.logger.append({
      timestamp: new Date().toISOString(),
      level: "warn",
      event: "hyperframes.render.unsupported_command",
      traceId,
      data: {
        projectId: input.projectId,
        command,
      },
    });

    return response;
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
