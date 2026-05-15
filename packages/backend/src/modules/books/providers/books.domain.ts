import path from "node:path";

import type { AppConfig } from "../../../infrastructure/config/app-config.service.ts";
import type { DatasetStateService } from "../../../infrastructure/dataset-state/dataset-state.service.ts";
import type { FileJobStoreService } from "../../../infrastructure/jobs/file-job-store.service.ts";
import type { AgentConfigApplicationService } from "../../agent-config/application/agent-config-application.service.ts";
import type { AgentConfig as PersistedAgentConfig } from "../../agent-config/domain/agent-config.entity.ts";
import { loadValidatedBookOutput } from "./book-output.ts";
import { exportHtmlToLongImage } from "./long-image.ts";
import { exportHtmlToPdf, verifyPdfWithPdfJs } from "./pdf.ts";
import { buildSelectedAssetPayload } from "./selected-asset-payload.ts";
import { buildAgentWorkspace } from "./workspace.ts";
import type { OpenAISDKAgentRunner } from "./openai-sdk-agent-runner.ts";

type AgentConfig = {
  baseUrl: string;
  apiKey: string;
  model: string;
  temperature?: number;
  maxTokens?: number;
  systemPrompt?: string;
  toolsEnabled?: string[];
};

type BooksDependencies = {
  config: AppConfig;
  datasetState: DatasetStateService;
  jobStore: FileJobStoreService;
  agentConfigService?: Pick<AgentConfigApplicationService, "getDefaultConfig" | "getDecryptedApiKey">;
  agentRunner?: OpenAISDKAgentRunner;
  longImageRenderer?: {
    render(input: { html: string; targetPath: string; format: "png" | "jpg" }): Promise<void>;
  };
  pdfRenderer?: {
    render(html: string, targetPath: string): Promise<void>;
  };
  pdfLoader?: {
    load(pdfPath: string): Promise<{ numPages: number; firstPageRendered: boolean }>;
  };
};

export function createBooksService(dependencies: BooksDependencies) {
  return {
    async createJob(body: Record<string, any>) {
      const datasetDb = await dependencies.datasetState.current();
      const selectedIds = Array.isArray(body.assetIds) ? body.assetIds : [];
      const payload = await buildSelectedAssetPayload(datasetDb, selectedIds);
      if (payload.assets.length === 0) {
        return { status: 422, data: { ok: false, message: "Select at least one asset before starting generation." } };
      }
      const children = await datasetDb.getChildren();
      const child = (typeof body.childId === "string" ? children.find((candidate: any) => candidate.id === body.childId) : undefined)
        || children[0]
        || { id: "sample-child-001", name: "澄澄" };
      const jobId = `job_${Date.now()}`;
      const workspace = await buildAgentWorkspace({ workspaceRoot: dependencies.config.paths.workspaceDir, jobId, child: child as any, assets: payload.assets, secrets: {} });
      const runnerInput = { workspacePath: workspace.path, child, assets: workspace.inputAssets as any };

      if (!dependencies.agentRunner) {
        return { status: 500, data: { ok: false, message: "OpenAI Agents SDK runner is not configured." } };
      }
      const agentConfigResult = await resolveDefaultAgentConfig(dependencies);
      if (agentConfigResult.ok === false) return { status: 400, data: { ok: false, message: agentConfigResult.message } };
      const agentConfig = agentConfigResult.config;
      const runner = await dependencies.agentRunner.generateBook(runnerInput, agentConfig);

      const job = await dependencies.jobStore.save({
        id: jobId,
        status: runner.ok ? "generated" : "failed",
        workspacePath: workspace.path,
        runner,
        selectedAssetIds: selectedIds
      });
      return { status: runner.ok ? 200 : 500, data: job };
    },
    async getJob(id: string) {
      return await dependencies.jobStore.get(id) || { ok: false, message: "Job not found" };
    },
    async getPreviewHtml(id: string) {
      const job = await dependencies.jobStore.get(id);
      if (!job?.workspacePath) return { status: 404, data: { ok: false, message: "Job not found" } };
      const pairedOutput = await loadValidatedBookOutput(job.workspacePath, new Set(job.selectedAssetIds));
      if (!pairedOutput.ok) return { status: 422, data: pairedOutput };
      return { status: 200, html: pairedOutput.html };
    },
    async exportPdf(id: string, body: Record<string, any> = {}) {
      const job = await dependencies.jobStore.get(id);
      if (!job?.workspacePath) return { status: 404, data: { ok: false, message: "Job not found" } };
      const pairedOutput = await loadValidatedBookOutput(job.workspacePath, new Set(job.selectedAssetIds));
      if (!pairedOutput.ok) return { status: 422, data: pairedOutput };
      const pdfPathResult = resolveExportTargetPath({
        jobId: job.id,
        exportDir: dependencies.config.paths.exportDir,
        targetPath: typeof body.targetPath === "string" ? body.targetPath : undefined,
        extension: ".pdf",
      });
      if (!pdfPathResult.ok) return exportPathErrorResponse(pdfPathResult as Extract<ResolveExportTargetResult, { ok: false }>);
      const pdfPath = pdfPathResult.path;
      const exported = await exportHtmlToPdf(pairedOutput.html, pdfPath, dependencies.pdfRenderer);
      const verified = exported.ok ? await verifyPdfWithPdfJs(pdfPath, pairedOutput.book.pages.length, dependencies.pdfLoader) : undefined;
      let artifact;
      if (exported.ok) {
        const db = await dependencies.datasetState.activatePersistent();
        artifact = await db.upsertExportArtifact?.({
          id: `artifact_${job.id}_pdf_${Date.now()}`,
          jobId: job.id,
          kind: "pdf",
          localPath: pdfPath,
          storageProvider: "local",
          storageStatus: "local_only",
        });
      }
      if (exported.ok) await dependencies.jobStore.save({ ...job, status: "exported" });
      return { status: exported.ok ? 200 : 500, data: { exported, verified, artifact } };
    },
    async exportLongImage(id: string, body: Record<string, any> = {}) {
      const job = await dependencies.jobStore.get(id);
      if (!job?.workspacePath) return { status: 404, data: { ok: false, message: "Job not found" } };
      const pairedOutput = await loadValidatedBookOutput(job.workspacePath, new Set(job.selectedAssetIds));
      if (!pairedOutput.ok) return { status: 422, data: pairedOutput };
      const format = normalizeLongImageFormat(body.format);
      const imagePathResult = resolveExportTargetPath({
        jobId: job.id,
        exportDir: dependencies.config.paths.exportDir,
        targetPath: typeof body.targetPath === "string" ? body.targetPath : undefined,
        extension: format === "jpg" ? ".jpg" : ".png",
        normalizeExtension: (targetPath) => targetPath.replace(/\.jpeg$/i, ".jpg"),
        acceptsExtension: /\.(png|jpe?g)$/i,
      });
      if (!imagePathResult.ok) return exportPathErrorResponse(imagePathResult as Extract<ResolveExportTargetResult, { ok: false }>);
      const imagePath = imagePathResult.path;
      const exported = await exportHtmlToLongImage({
        html: pairedOutput.html,
        targetPath: imagePath,
        format,
        renderer: dependencies.longImageRenderer,
      });
      if (!exported.ok) {
        return { status: 500, data: { exported } };
      }
      const db = await dependencies.datasetState.activatePersistent();
      const artifact = await db.upsertExportArtifact?.({
        id: `artifact_${job.id}_${format}_${Date.now()}`,
        jobId: job.id,
        kind: format === "jpg" ? "long_image_jpg" : "long_image_png",
        localPath: imagePath,
        storageProvider: "local",
        storageStatus: "local_only",
      });
      await dependencies.jobStore.save({ ...job, status: "exported" });
      return { status: 200, data: { exported, artifact } };
    },
  };
}

type ResolveAgentConfigResult =
  | { ok: true; config: AgentConfig }
  | { ok: false; message: string };

async function resolveDefaultAgentConfig(dependencies: BooksDependencies): Promise<ResolveAgentConfigResult> {
  const service = dependencies.agentConfigService;
  if (!service) {
    return { ok: false, message: "Default agent configuration service is not available." };
  }
  const config = await service.getDefaultConfig();
  if (!config) {
    return { ok: false, message: "No default agent configuration is configured." };
  }
  if (config.provider !== "openai" && config.provider !== "custom") {
    return { ok: false, message: `Default agent provider '${config.provider}' is not supported by the OpenAI Agents SDK runner.` };
  }
  const apiKey = await service.getDecryptedApiKey(config.id);
  if (!apiKey) {
    return { ok: false, message: "Default agent configuration does not have a usable API key." };
  }
  return {
    ok: true,
    config: {
      baseUrl: normalizeAgentBaseUrl(config),
      apiKey,
      model: config.model,
      temperature: config.temperature,
      maxTokens: config.maxTokens,
      systemPrompt: config.systemPrompt,
      toolsEnabled: config.toolsEnabled,
    },
  };
}

function normalizeAgentBaseUrl(config: PersistedAgentConfig) {
  if (config.baseUrl) return config.baseUrl;
  return config.provider === "openai" ? "https://api.openai.com/v1" : "";
}

type ResolveExportPdfPathInput = {
  jobId: string;
  exportDir: string;
  targetPath?: string;
  cwd?: string;
};

export function resolveExportPdfPath(input: ResolveExportPdfPathInput) {
  const resolved = resolveExportTargetPath({ ...input, extension: ".pdf" });
  if (!resolved.ok) throw new ExportPathError((resolved as Extract<ResolveExportTargetResult, { ok: false }>).message);
  return resolved.path;
}

type ResolveExportLongImagePathInput = {
  jobId: string;
  exportDir: string;
  format: "png" | "jpg";
  targetPath?: string;
  cwd?: string;
};

export function resolveExportLongImagePath(input: ResolveExportLongImagePathInput) {
  const extension = input.format === "jpg" ? ".jpg" : ".png";
  const resolved = resolveExportTargetPath({
    ...input,
    extension,
    normalizeExtension: (targetPath) => targetPath.replace(/\.jpeg$/i, ".jpg"),
    acceptsExtension: /\.(png|jpe?g)$/i,
  });
  if (!resolved.ok) throw new ExportPathError((resolved as Extract<ResolveExportTargetResult, { ok: false }>).message);
  return resolved.path;
}

function normalizeLongImageFormat(value: unknown): "png" | "jpg" {
  const normalized = String(value || "png").trim().toLowerCase();
  return normalized === "jpg" || normalized === "jpeg" ? "jpg" : "png";
}

type ResolveExportTargetInput = {
  jobId: string;
  exportDir: string;
  targetPath?: string;
  cwd?: string;
  extension: string;
  acceptsExtension?: RegExp;
  normalizeExtension?: (targetPath: string) => string;
};

type ResolveExportTargetResult =
  | { ok: true; path: string }
  | { ok: false; code: "EXPORT_PATH_OUTSIDE_EXPORT_DIR"; message: string };

export class ExportPathError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "ExportPathError";
  }
}

function resolveExportTargetPath(input: ResolveExportTargetInput): ResolveExportTargetResult {
  const cwd = input.cwd ?? process.cwd();
  const exportDir = resolveExportDirectory(input.exportDir, cwd);
  const cleanedTarget = (input.targetPath ?? "").trim();
  const targetPath = cleanedTarget.length > 0
    ? withExpectedExtension(path.resolve(cwd, cleanedTarget), input)
    : path.join(exportDir, `${input.jobId}${input.extension}`);
  const normalizedTarget = input.normalizeExtension ? input.normalizeExtension(targetPath) : targetPath;

  if (!isInsideDirectory(exportDir, normalizedTarget)) {
    return {
      ok: false,
      code: "EXPORT_PATH_OUTSIDE_EXPORT_DIR",
      message: "Export targetPath must stay inside the configured export directory.",
    };
  }
  return { ok: true, path: normalizedTarget };
}

function resolveExportDirectory(exportDir: string, cwd: string) {
  return path.resolve(cwd, exportDir);
}

function withExpectedExtension(targetPath: string, input: ResolveExportTargetInput) {
  const acceptsExtension = input.acceptsExtension ?? new RegExp(`${escapeRegExp(input.extension)}$`, "i");
  return acceptsExtension.test(targetPath) ? targetPath : `${targetPath}${input.extension}`;
}

function isInsideDirectory(directoryPath: string, targetPath: string) {
  const relative = path.relative(directoryPath, targetPath);
  return relative === "" || (!relative.startsWith("..") && !path.isAbsolute(relative));
}

function exportPathErrorResponse(error: Extract<ResolveExportTargetResult, { ok: false }>) {
  return {
    status: 400,
    data: {
      ok: false,
      code: error.code,
      message: error.message,
    },
  };
}

function escapeRegExp(value: string) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}
