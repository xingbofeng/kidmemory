import { Inject, Injectable } from "@nestjs/common";

import { FileJobStoreService } from "../../infrastructure/jobs/file-job-store.service.ts";
import { FileLoggerService } from "../../infrastructure/logging/file-logger.service.ts";
import { TraceContextService } from "../../infrastructure/logging/trace-context.service.ts";
import { BooksService } from "../books/books.service.ts";
import { ConfigService } from "../config/config.service.ts";
import { DatasetService } from "../dataset/dataset.service.ts";
import { HyperframesRenderService } from "../media/hyperframes-render.service.ts";
import { ImageGenerationService, isRecoverableImageFailure } from "../media/image-generation.service.ts";
import { SkillPermissionService } from "./skill-permission.service.ts";
import { SkillRegistryService } from "./skill-registry.service.ts";
import { SkillWorkspaceService } from "./skill-workspace.service.ts";

export type SkillRuntimeToolName =
  | "get_sidecar_health"
  | "get_config_status"
  | "get_indexing_status"
  | "get_recent_logs"
  | "list_children"
  | "get_child_profile"
  | "list_recent_assets"
  | "search_assets"
  | "search_assets_by_vector"
  | "get_asset_metadata"
  | "get_asset_preview"
  | "update_asset_metadata"
  | "create_book_job"
  | "get_book_job"
  | "list_book_jobs"
  | "export_book_pdf"
  | "export_book_long_image"
  | "generate_cover_image_preview"
  | "render_hyperframes_video";

export type ExecuteSkillInput = {
  skillId: string;
  tool: SkillRuntimeToolName;
  arguments?: Record<string, unknown>;
  traceId?: string;
};

@Injectable()
export class SkillRuntimeService {
  constructor(
    @Inject(SkillRegistryService) private readonly registry: SkillRegistryService,
    @Inject(SkillWorkspaceService) private readonly workspace: SkillWorkspaceService,
    @Inject(SkillPermissionService) private readonly permission: SkillPermissionService,
    @Inject(ConfigService) private readonly configService: ConfigService,
    @Inject(DatasetService) private readonly datasetService: DatasetService,
    @Inject(BooksService) private readonly booksService: BooksService,
    @Inject(FileJobStoreService) private readonly jobStore: FileJobStoreService,
    @Inject(ImageGenerationService) private readonly imageService: ImageGenerationService,
    @Inject(HyperframesRenderService) private readonly hyperframesService: HyperframesRenderService,
    @Inject(FileLoggerService) private readonly logger: FileLoggerService,
    @Inject(TraceContextService) private readonly traceContext: TraceContextService,
  ) {}

  async execute(input: ExecuteSkillInput) {
    const traceId = input.traceId?.trim()
      || this.traceContext.getTraceId()
      || `trace_${Date.now()}_${Math.random().toString(36).slice(2, 10)}`;

    await this.logger.append({
      timestamp: new Date().toISOString(),
      level: "info",
      event: "skills.runtime.execute.start",
      traceId,
      data: {
        skillId: input.skillId,
        tool: input.tool,
      },
    });

    const loadedSkill = await this.registry.loadSkill(input.skillId);
    const workspace = await this.workspace.prepare(input.skillId, traceId);
    this.permission.assertToolAllowed(input.skillId, input.tool);

    const toolResult = await this.callTool(input.tool, input.arguments ?? {}, traceId);

    await this.logger.append({
      timestamp: new Date().toISOString(),
      level: "info",
      event: "skills.runtime.execute.finish",
      traceId,
      data: {
        skillId: loadedSkill.entry.id,
        tool: input.tool,
      },
    });

    return {
      ok: true,
      skillId: loadedSkill.entry.id,
      tool: input.tool,
      source: loadedSkill.entry.source,
      entryFile: loadedSkill.entryFile,
      workspaceDir: workspace.runDir,
      traceId,
      toolResult,
    };
  }

  async listSkills() {
    return this.registry.listSkills();
  }

  private async callTool(
    toolName: SkillRuntimeToolName,
    args: Record<string, unknown>,
    traceId: string,
  ) {
    switch (toolName) {
      case "get_sidecar_health":
        return {
          status: "ok",
          health: this.configService.health(),
        };
      case "get_config_status":
        return this.configService.status();
      case "get_indexing_status":
        return this.datasetService.getSearchIndexingStatus(asOptionalString(args.childId));
      case "get_recent_logs":
        return this.logger.tail(asOptionalNumber(args.limit) ?? 50);
      case "list_children":
        return this.datasetService.listChildren();
      case "get_child_profile":
        return this.datasetService.getChild(asRequiredString(args.childId, "childId"));
      case "list_recent_assets": {
        const childId = asOptionalString(args.childId);
        const limit = asOptionalNumber(args.limit) ?? 20;
        const result = await this.datasetService.listAssets(undefined, childId);
        return {
          assets: Array.isArray(result.assets) ? result.assets.slice(0, Math.max(1, Math.min(limit, 200))) : [],
        };
      }
      case "search_assets":
      case "search_assets_by_vector":
        return this.datasetService.searchAssets({
          childId: asRequiredString(args.childId, "childId"),
          query: asRequiredString(args.query, "query"),
          page: asOptionalNumber(args.page),
          pageSize: asOptionalNumber(args.pageSize),
          filters: {
            types: asOptionalStringArray(args.types),
            tags: asOptionalStringArray(args.tags),
            capturedFrom: asOptionalString(args.capturedFrom),
            capturedTo: asOptionalString(args.capturedTo),
          },
        });
      case "get_asset_metadata":
        return this.datasetService.getAsset(asRequiredString(args.assetId, "assetId"));
      case "get_asset_preview": {
        const assetId = asRequiredString(args.assetId, "assetId");
        return {
          assetId,
          previewPath: `/assets/${assetId}/preview`,
        };
      }
      case "update_asset_metadata": {
        const assetId = asRequiredString(args.assetId, "assetId");
        return this.datasetService.updateAsset(assetId, {
          title: asOptionalString(args.title),
          description: asOptionalString(args.description),
          tags: asOptionalStringArray(args.tags),
          capturedAt: asOptionalString(args.capturedAt),
          type: asOptionalString(args.type),
        });
      }
      case "create_book_job":
        return this.booksService.createJob(args);
      case "get_book_job":
        return this.booksService.getJob(asRequiredString(args.jobId, "jobId"));
      case "list_book_jobs":
        return {
          jobs: await this.jobStore.list(),
        };
      case "export_book_pdf": {
        const jobId = asRequiredString(args.jobId, "jobId");
        const body = asRecord(args.body);
        return this.booksService.exportPdf(jobId, body);
      }
      case "export_book_long_image": {
        const jobId = asRequiredString(args.jobId, "jobId");
        const body = asRecord(args.body);
        return this.booksService.exportLongImage(jobId, body);
      }
      case "generate_cover_image_preview": {
        const result = await this.imageService.generateCoverPreview({
          provider: asOptionalString(args.provider),
          prompt: asRequiredString(args.prompt, "prompt"),
          traceId,
          width: asOptionalNumber(args.width),
          height: asOptionalNumber(args.height),
          seed: asOptionalNumber(args.seed),
        });

        return {
          ...result,
          canSkipCoverAndContinue: isRecoverableImageFailure(result),
        };
      }
      case "render_hyperframes_video":
        return this.hyperframesService.render({
          projectId: asRequiredString(args.projectId, "projectId"),
          prompt: asOptionalString(args.prompt),
          targetPath: asOptionalString(args.targetPath),
          traceId,
        });
      default:
        throw new Error(`Unsupported runtime tool: ${toolName satisfies never}`);
    }
  }
}

function asRequiredString(value: unknown, field: string) {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`Missing required string field: ${field}`);
  }
  return value.trim();
}

function asOptionalString(value: unknown) {
  if (typeof value !== "string") {
    return undefined;
  }
  const trimmed = value.trim();
  return trimmed.length === 0 ? undefined : trimmed;
}

function asOptionalNumber(value: unknown) {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === "string") {
    const parsed = Number.parseFloat(value);
    return Number.isFinite(parsed) ? parsed : undefined;
  }
  return undefined;
}

function asOptionalStringArray(value: unknown) {
  if (!Array.isArray(value)) {
    return undefined;
  }

  const rows = value
    .map((item) => (typeof item === "string" ? item.trim() : ""))
    .filter((item) => item.length > 0);

  return rows.length > 0 ? rows : undefined;
}

function asRecord(value: unknown): Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return {};
  }
  return value as Record<string, unknown>;
}
