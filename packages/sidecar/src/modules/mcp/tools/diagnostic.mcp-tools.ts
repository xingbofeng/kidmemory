import { Inject, Injectable } from "@nestjs/common";
import { Tool } from "@rekog/mcp-nest";
import { z } from "zod";

import { FileLoggerService } from "../../../infrastructure/logging/file-logger.service.ts";
import { ConfigService } from "../../config/config.service.ts";
import { DatasetService } from "../../dataset/dataset.service.ts";
import { HyperframesRenderService } from "../../media/hyperframes-render.service.ts";
import { ImageGenerationService, isRecoverableImageFailure } from "../../media/image-generation.service.ts";

const indexingStatusSchema = z.object({
  childId: z.string().optional(),
});

const recentLogsSchema = z.object({
  limit: z.number().int().positive().max(200).optional(),
});

const imagePreviewSchema = z.object({
  prompt: z.string(),
  provider: z.string().optional(),
  traceId: z.string().optional(),
  width: z.number().int().positive().optional(),
  height: z.number().int().positive().optional(),
  seed: z.number().int().nonnegative().optional(),
});

const hyperframesRenderSchema = z.object({
  projectId: z.string(),
  prompt: z.string().optional(),
  targetPath: z.string().optional(),
  traceId: z.string().optional(),
});

@Injectable()
export class DiagnosticMcpTools {
  constructor(
    @Inject(ConfigService) private readonly configService: ConfigService,
    @Inject(DatasetService) private readonly datasetService: DatasetService,
    @Inject(FileLoggerService) private readonly fileLogger: FileLoggerService,
    @Inject(ImageGenerationService) private readonly imageService: ImageGenerationService,
    @Inject(HyperframesRenderService) private readonly hyperframesService: HyperframesRenderService,
  ) {}

  @Tool({
    name: "get_sidecar_health",
    description: "Return current sidecar health status for diagnostics.",
    parameters: z.object({}),
  })
  async getSidecarHealth() {
    const health = this.configService.health();
    return toJson({
      status: "ok",
      server: "kidmemory-sidecar",
      health,
    });
  }

  @Tool({
    name: "get_config_status",
    description: "Return sidecar configuration and readiness status.",
    parameters: z.object({}),
  })
  async getConfigStatus() {
    return toJson(await this.configService.status());
  }

  @Tool({
    name: "get_indexing_status",
    description: "Return indexing queue and recent index status.",
    parameters: indexingStatusSchema,
  })
  async getIndexingStatus({ childId }: z.infer<typeof indexingStatusSchema>) {
    return toJson(await this.datasetService.getSearchIndexingStatus(childId));
  }

  @Tool({
    name: "get_recent_logs",
    description: "Return recent sidecar JSONL log records.",
    parameters: recentLogsSchema,
  })
  async getRecentLogs({ limit }: z.infer<typeof recentLogsSchema>) {
    return toJson({ logs: await this.fileLogger.tail(limit ?? 50) });
  }

  @Tool({
    name: "generate_cover_image_preview",
    description: "Generate preview cover image with text-only prompt through image provider.",
    parameters: imagePreviewSchema,
  })
  async generateCoverImagePreview(input: z.infer<typeof imagePreviewSchema>) {
    const result = await this.imageService.generateCoverPreview(input);
    return toJson({
      ...result,
      canSkipCoverAndContinue: isRecoverableImageFailure(result),
    });
  }

  @Tool({
    name: "render_hyperframes_video",
    description: "Render hyperframes output video and return output path or recoverable error.",
    parameters: hyperframesRenderSchema,
  })
  async renderHyperframesVideo(input: z.infer<typeof hyperframesRenderSchema>) {
    return toJson(await this.hyperframesService.render(input));
  }
}

function toJson(value: unknown) {
  return JSON.stringify(value);
}
