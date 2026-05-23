import fs from "node:fs/promises";
import path from "node:path";

import { Inject, Injectable, Optional } from "@nestjs/common";
import { z } from "zod";
import type {
  CreationArtifact,
  CreationError,
  CreationEvent,
  CreationStep,
  CreationTask,
  CreationTaskStatus,
  CreationType,
} from "@kidmemory/protocol";

import { AppConfigService } from "../../infrastructure/config/app-config.service.ts";
import { PrismaService } from "../../infrastructure/database/prisma.service.ts";
import { AgentRuntimeService } from "../agent-runtime/agent-runtime.service.ts";
import type { RuntimeStage } from "../agent-runtime/agent-runtime.contracts.ts";
import { ensureTaskWorkspace, readBookJson, readPlanJson, writeTaskRequestJson } from "../agent-runtime/agent-runtime.workspace.ts";
import { loadValidatedBookOutput } from "../books/providers/book-output.ts";
import { exportHtmlToLongImage } from "../books/providers/long-image.ts";
import { exportHtmlToPdf, verifyPdfWithPdfJs } from "../books/providers/pdf.ts";
import { DatasetService } from "../dataset/dataset.service.ts";
import type { CreateCreationTaskDto, ExportCreationTaskDto, ShareCreationTaskDto } from "./dto/creation.dto.ts";
import type { CreationTask as PrismaCreationTask } from "@prisma/client";

type ServiceResult<T> = {
  status: number;
  data: T;
};

const creationStepSchema = z.object({
  stepId: z.string(),
  label: z.string(),
  status: z.enum(["pending", "running", "succeeded", "failed", "skipped"]),
  detail: z.string().optional(),
});

const creationErrorSchema = z.object({
  category: z.string(),
  message: z.string(),
  stepId: z.string().optional(),
  code: z.string().optional(),
});

@Injectable()
export class CreationService {
  constructor(
    @Inject(PrismaService) private readonly prisma: PrismaService,
    @Inject(AgentRuntimeService) private readonly agentRuntime: AgentRuntimeService,
    @Inject(AppConfigService) private readonly config: AppConfigService,
    @Optional() @Inject(DatasetService) private readonly datasetService?: Pick<
      DatasetService,
      "recordExportArtifact" | "enqueueExportArtifactStorageSync" | "runStorageSyncWorker" | "getExportArtifactShareMetadata"
    >,
  ) {}

  async createTask(dto: CreateCreationTaskDto): Promise<ServiceResult<CreationTask | { message: string }>> {
    const taskId = `task_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
    const workspacePath = path.join(this.config.config.paths.workspaceDir, "creation-tasks", taskId);

    await ensureTaskWorkspace({ workspacePath, taskId, goal: dto.goal, assetIds: dto.assetIds, stage: "plan" });
    await writeTaskRequestJson(workspacePath, { taskId, ...dto });

    const task = await this.prisma.creationTask.create({
      data: {
        id: taskId,
        creationType: dto.creationType,
        goal: dto.goal,
        assetIds: dto.assetIds,
        status: "planning",
        steps: JSON.stringify(this.defaultSteps(dto.creationType, "pending")),
        workspacePath,
      },
    });

    await this.addEvent(taskId, "plan", "Task created, running plan stage.");

    const planResult = await this.agentRuntime.runCreationStage({
      taskId,
      workspacePath,
      stage: "plan",
      creationType: dto.creationType,
      prompt: this.buildPlanPrompt(dto),
      traceId: `creation_${taskId}_plan`,
    });

    if (!planResult.ok) {
      const failed = await this.prisma.creationTask.update({
        where: { id: taskId },
        data: {
          status: "failed",
          error: {
            category: planResult.error?.category ?? "planning",
            message: planResult.error?.message ?? "Plan stage failed.",
            code: planResult.error?.code,
          },
        },
      });
      await this.addEvent(taskId, "error", planResult.error?.message ?? "Plan stage failed.");
      return { status: 500, data: this.mapTask(failed) };
    }

    const planJson = await readPlanJson(workspacePath);
    if (!planJson) {
      const failed = await this.prisma.creationTask.update({
        where: { id: taskId },
        data: { status: "failed", error: { category: "planning", message: "Plan stage completed but output/plan.json is missing or invalid." } },
      });
      await this.addEvent(taskId, "error", "Plan output not found.");
      return { status: 500, data: this.mapTask(failed) };
    }

    const summary = typeof planJson.summary === "string" ? planJson.summary : "Plan created";
    const skillName = typeof planJson.skillName === "string" ? planJson.skillName : this.skillNameFor(dto.creationType);
    const planSteps = this.normalizePlanSteps(planJson.steps);
    const requirementItems = Array.isArray(planJson.requirements) ? planJson.requirements.map(String) : [];

    await this.prisma.creationTask.update({
      where: { id: taskId },
      data: {
        status: "ready",
        summary,
        skillName,
        steps: JSON.stringify(planSteps),
        requirementItems,
      },
    });

    await this.addEvent(taskId, "plan", `Plan ready: ${summary}`);

    return { status: 201, data: this.mapTask({ ...task, status: "ready", summary, skillName }) };
  }

  async generateTask(taskId: string): Promise<ServiceResult<CreationTask | { message: string }>> {
    const task = await this.prisma.creationTask.findUnique({ where: { id: taskId } });
    if (!task) return { status: 404, data: { message: "Creation task not found." } };
    if (task.status !== "ready") {
      return { status: 409, data: { message: `Task is in status "${task.status}", expected "ready".` } };
    }

    const creationType = task.creationType as CreationType;
    const stage: RuntimeStage = creationType === "memoir_video" ? "generate_video" : "generate_book";

    await this.prisma.creationTask.update({ where: { id: taskId }, data: { status: "generating" } });
    await this.addEvent(taskId, "task", `Starting ${stage} stage.`);

    const workspacePath = task.workspacePath ?? path.join(this.config.config.paths.workspaceDir, "creation-tasks", taskId);
    const generateResult = await this.agentRuntime.runCreationStage({
      taskId,
      workspacePath,
      stage,
      creationType,
      prompt: task.goal,
      traceId: `creation_${taskId}_${stage}`,
    });

    if (!generateResult.ok) {
      const failed = await this.prisma.creationTask.update({
        where: { id: taskId },
        data: {
          status: "failed",
          currentStepId: "generate",
          error: {
            category: generateResult.error?.category ?? "generation",
            message: generateResult.error?.message ?? "Generation stage failed.",
            code: generateResult.error?.code,
          },
        },
      });
      await this.addEvent(taskId, "error", generateResult.error?.message ?? "Generation stage failed.");
      return { status: 500, data: this.mapTask(failed) };
    }

    await this.persistGeneratedArtifacts(taskId, creationType, workspacePath);

    await this.prisma.creationTask.update({
      where: { id: taskId },
      data: {
        status: "succeeded",
        currentStepId: "review",
      },
    });
    await this.addEvent(taskId, "task", `Generation succeeded for ${stage}.`);

    const updated = await this.prisma.creationTask.findUnique({
      where: { id: taskId },
      include: { creationArtifacts: true, creationEvents: { orderBy: { createdAt: "asc" } } },
    });
    return { status: 200, data: updated ? this.mapTaskWithRelations(updated) : this.mapTask(task, "succeeded") };
  }

  private async persistGeneratedArtifacts(taskId: string, creationType: CreationType, workspacePath: string) {
    const outputs = creationType === "memoir_video"
      ? [{ kind: "mp4", localPath: path.join(workspacePath, "output", "video.mp4") }]
      : [
          { kind: "book_json", localPath: path.join(workspacePath, "output", "book.json") },
          { kind: "book_html", localPath: path.join(workspacePath, "output", "book.html") },
        ];

    for (const output of outputs) {
      const exists = await fs.stat(output.localPath).then((stat) => stat.isFile() && stat.size > 0).catch(() => false);
      if (!exists) continue;
      await this.prisma.creationArtifact.create({
        data: {
          id: `artifact_${taskId}_${output.kind}_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`,
          taskId,
          kind: output.kind,
          localPath: output.localPath,
        },
      });
    }
  }

  async getTask(taskId: string): Promise<ServiceResult<CreationTask | { message: string }>> {
    const task = await this.prisma.creationTask.findUnique({
      where: { id: taskId },
      include: { creationArtifacts: true, creationEvents: { orderBy: { createdAt: "asc" } } },
    });
    if (!task) return { status: 404, data: { message: "Creation task not found." } };
    return { status: 200, data: this.mapTaskWithRelations(task) };
  }

  async getEvents(taskId: string): Promise<ServiceResult<{ events: CreationEvent[] } | { message: string }>> {
    const task = await this.prisma.creationTask.findUnique({ where: { id: taskId } });
    if (!task) return { status: 404, data: { message: "Creation task not found." } };

    const events = await this.prisma.creationEvent.findMany({
      where: { taskId },
      orderBy: { createdAt: "asc" },
    });

    return { status: 200, data: { events: events.map((e) => this.mapEvent(e)) } };
  }

  async getPreviewHtml(taskId: string): Promise<ServiceResult<{ message: string }> | { status: number; html: string }> {
    const task = await this.prisma.creationTask.findUnique({ where: { id: taskId } });
    if (!task) return { status: 404, data: { message: "Creation task not found." } };

    const creationType = task.creationType as CreationType;
    if (creationType === "memoir_video") {
      return { status: 422, data: { message: "Memoir video tasks do not provide an HTML page preview." } };
    }

    const workspacePath = task.workspacePath ?? "";
    const bookJson = await readBookJson(workspacePath);
    if (!bookJson || !bookJson.metadata || !bookJson.pages) {
      return { status: 409, data: { message: "Task preview is not available until the book draft is generated." } };
    }

    const title = (bookJson.metadata as Record<string, unknown>)?.title ?? "Preview";
    const pages = (bookJson.pages as Array<Record<string, unknown>>) ?? [];
    const html = this.renderPreviewHtml(title as string, pages);

    return { status: 200, html };
  }

  async exportTask(taskId: string, dto: ExportCreationTaskDto): Promise<ServiceResult<CreationArtifact | { message: string }>> {
    const task = await this.prisma.creationTask.findUnique({
      where: { id: taskId },
      include: { creationArtifacts: true },
    });
    if (!task) return { status: 404, data: { message: "Creation task not found." } };

    const creationType = task.creationType as CreationType;
    if (dto.target === "mp4" && creationType !== "memoir_video") {
      return { status: 422, data: { message: "Only memoir_video tasks can export MP4 artifacts." } };
    }
    if (dto.target !== "mp4" && creationType === "memoir_video") {
      return { status: 422, data: { message: "Memoir video tasks export MP4 artifacts." } };
    }

    const artifactId = `artifact_${taskId}_${dto.target}_${Date.now()}`;
    const localPath = dto.targetPath ?? path.join(this.config.config.paths.exportDir, `${taskId}${this.exportExtension(dto.target)}`);

    const workspacePath = task.workspacePath ?? "";
    if (dto.target === "pdf" || dto.target === "long_image_png" || dto.target === "long_image_jpg") {
      const output = await loadValidatedBookOutput(workspacePath, new Set(task.assetIds));
      if (!output.ok) {
        return { status: 422, data: { message: `Book artifact contract failed: ${output.errors.join("; ")}` } };
      }
      if (dto.target === "pdf") {
        const exported = await exportHtmlToPdf(output.html, localPath);
        if (!exported.ok) {
          return { status: 500, data: { message: exported.message ?? "PDF export failed." } };
        }
        const verified = await verifyPdfWithPdfJs(localPath, output.book.pages.length);
        if (!verified.ok) {
          return { status: 500, data: { message: verified.message ?? "PDF verification failed." } };
        }
      } else {
        const exported = await exportHtmlToLongImage({
          html: output.html,
          targetPath: localPath,
          format: dto.target === "long_image_jpg" ? "jpg" : "png",
        });
        if (!exported.ok) {
          return { status: 500, data: { message: exported.message ?? "Long image export failed." } };
        }
      }
    }

    if (dto.target === "mp4") {
      const mp4Path = path.join(workspacePath, "output", "video.mp4");
      const mp4Exists = await fs.stat(mp4Path).then((s) => s.isFile()).catch(() => false);
      if (!mp4Exists) {
        return { status: 409, data: { message: "MP4 artifact is not available. Re-run generation first." } };
      }
      try {
        await fs.mkdir(path.dirname(localPath), { recursive: true });
        await fs.cp(mp4Path, localPath);
      } catch (error) {
        const message = error instanceof Error ? error.message : "Unknown copy error";
        return { status: 500, data: { message: `Failed to export MP4 artifact: ${message}` } };
      }
    }

    const artifact = await this.prisma.creationArtifact.create({
      data: { id: artifactId, taskId, kind: dto.target, localPath },
    });

    await this.prisma.creationTask.update({
      where: { id: taskId },
      data: { status: "exported" },
    });
    await this.addEvent(taskId, "export", `Exported ${dto.target.toUpperCase()} artifact to ${localPath}.`);

    return { status: 201, data: this.mapArtifact(artifact) };
  }

  async shareTask(taskId: string, dto: ShareCreationTaskDto): Promise<ServiceResult<CreationArtifact | { message: string }>> {
    const task = await this.prisma.creationTask.findUnique({
      where: { id: taskId },
      include: { creationArtifacts: true },
    });
    if (!task) return { status: 404, data: { message: "Creation task not found." } };

    const source = task.creationArtifacts.find((a) => a.id === dto.artifactId);
    if (!source) return { status: 404, data: { message: "Creation artifact not found." } };

    if (!source.localPath) {
      return { status: 409, data: { message: "Creation artifact has no local file path to share." } };
    }
    if (!this.datasetService) {
      return { status: 503, data: { message: "Creation share service is not available in this Sidecar runtime." } };
    }

    const kind = source.kind === "pdf" || source.kind === "mp4" || source.kind === "long_image_png" || source.kind === "long_image_jpg" ? source.kind : undefined;
    if (!kind) {
      return { status: 422, data: { message: "Only PDF, MP4, and long image creation artifacts can be shared." } };
    }

    await this.datasetService.recordExportArtifact({
      id: source.id,
      jobId: taskId,
      kind,
      localPath: source.localPath,
      storageProvider: "local",
      storageStatus: "local_only",
    });

    const enqueued = await this.datasetService.enqueueExportArtifactStorageSync({
      artifactId: source.id,
      childId: `creation-${task.creationType}`,
    });

    if (!enqueued?.enqueued) {
      const reason = enqueued && "reason" in enqueued ? enqueued.reason : "unknown_error";
      return { status: 502, data: { message: `Export artifact could not be queued for storage sync: ${reason}.` } };
    }

    await this.datasetService.runStorageSyncWorker({ limit: 10 });
    const metadata = await this.datasetService.getExportArtifactShareMetadata(source.id);
    if (!metadata.ok || !metadata.url) {
      return { status: 502, data: { message: metadata.message || "Storage share link could not be created." } };
    }

    const shareArtifact = await this.prisma.creationArtifact.create({
      data: {
        id: `artifact_${taskId}_share_${Date.now()}`,
        taskId,
        kind: "web_share",
        shareId: source.id,
        shareUrl: metadata.url,
      },
    });

    await this.prisma.creationTask.update({
      where: { id: taskId },
      data: { status: "shared" },
    });
    await this.addEvent(taskId, "share", `Created Web share link for ${kind.toUpperCase()}.`);

    return { status: 201, data: this.mapArtifact(shareArtifact) };
  }

  private async addEvent(taskId: string, type: CreationEvent["type"], message: string) {
    await this.prisma.creationEvent.create({
      data: {
        id: `event_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`,
        taskId,
        type,
        message,
      },
    });
  }

  private defaultSteps(creationType: CreationType, status: CreationStep["status"]): CreationStep[] {
    const generateLabel = creationType === "memoir_video" ? "Generate MP4" : "Generate book draft";
    return [
      { stepId: "compose", label: "Compose selected assets", status },
      { stepId: "plan", label: "Confirm agent plan", status },
      { stepId: "generate", label: generateLabel, status },
      { stepId: "review", label: "Review generated artifact", status },
      { stepId: "publish", label: "Export and share", status },
    ];
  }

  private normalizePlanSteps(value: unknown): CreationStep[] {
    if (!Array.isArray(value)) return this.defaultSteps("storybook", "pending");
    return value.map((item) => {
      if (!item || typeof item !== "object") return undefined;
      const record = item as Record<string, unknown>;
      const stepId = typeof record.stepId === "string" ? record.stepId.trim() : "";
      const label = typeof record.label === "string" ? record.label.trim() : "";
      const detail = typeof record.detail === "string" ? record.detail.trim() : undefined;
      if (!stepId || !label) return undefined;
      return { stepId, label, status: "pending" as const, detail };
    }).filter(Boolean) as CreationStep[];
  }

  private buildPlanPrompt(dto: CreateCreationTaskDto): string {
    return JSON.stringify({
      goal: dto.goal,
      creationType: dto.creationType,
      assetIds: dto.assetIds,
      constraints: {
        output: dto.creationType === "memoir_video" ? "MP4 video" : "PDF",
        mainStages: ["compose", "plan", "generate", "review", "publish"],
      },
    });
  }

  private skillNameFor(creationType: CreationType): string {
    if (creationType === "memoir_video") return "Hyperframes skill";
    if (creationType === "memory_book") return "KidMemory memory book";
    return "KidMemory storybook";
  }

  private mapTask(task: Partial<PrismaCreationTask>, overrideStatus?: string): CreationTask {
    const steps = this.parseSteps(task.steps);
    const error = this.parseError(task.error);
    return {
      taskId: task.id ?? "",
      creationType: (task.creationType ?? "storybook") as CreationType,
      goal: task.goal ?? "",
      assetIds: task.assetIds ?? [],
      status: (overrideStatus ?? task.status ?? "failed") as CreationTaskStatus,
      currentStepId: task.currentStepId ?? null,
      summary: task.summary ?? undefined,
      skillName: task.skillName ?? undefined,
      steps,
      requirements: { minAssets: 1, recommendedAssets: 6, needsCloudImage: true, needsHyperframes: false, needsFfmpeg: false },
      requirementItems: task.requirementItems ?? [],
      artifacts: [],
      error,
      workspacePath: task.workspacePath ?? "",
      createdAt: task.createdAt?.toISOString?.() ?? new Date().toISOString(),
      updatedAt: task.updatedAt?.toISOString?.() ?? new Date().toISOString(),
    };
  }

  private parseSteps(raw: unknown): CreationStep[] {
    const value = typeof raw === "string" ? this.parseJson(raw) : raw;
    const parsed = z.array(creationStepSchema).safeParse(value);
    return parsed.success ? parsed.data : [];
  }

  private parseError(raw: unknown): CreationError | null {
    if (!raw) return null;
    const value = typeof raw === "string" ? this.parseJson(raw) : raw;
    const parsed = creationErrorSchema.safeParse(value);
    if (!parsed.success) return null;
    return {
      category: parsed.data.category as CreationError["category"],
      message: parsed.data.message,
      stepId: parsed.data.stepId,
      code: parsed.data.code,
    };
  }

  private parseJson(raw: string): unknown {
    try {
      return JSON.parse(raw);
    } catch {
      return undefined;
    }
  }

  private mapTaskWithRelations(task: PrismaCreationTask & { creationArtifacts?: Array<{ id: string; taskId: string; kind: string; localPath: string | null; shareId: string | null; shareUrl: string | null; createdAt: Date }>; creationEvents?: Array<{ id: string; taskId: string; stepId: string | null; type: string; message: string; createdAt: Date }> }): CreationTask {
    const result = this.mapTask(task);
    return {
      ...result,
      artifacts: (task.creationArtifacts ?? []).map((a) => this.mapArtifact(a)),
    };
  }

  private mapArtifact(a: { id: string; taskId: string; kind: string; localPath: string | null; shareId: string | null; shareUrl: string | null; createdAt: Date }): CreationArtifact {
    return {
      artifactId: a.id,
      taskId: a.taskId,
      kind: a.kind as CreationArtifact["kind"],
      localPath: a.localPath ?? undefined,
      shareId: a.shareId ?? undefined,
      shareUrl: a.shareUrl ?? undefined,
      createdAt: a.createdAt.toISOString?.() ?? new Date().toISOString(),
    };
  }

  private mapEvent(e: { id: string; taskId: string; stepId: string | null; type: string; message: string; createdAt: Date }): CreationEvent {
    return {
      eventId: e.id,
      taskId: e.taskId,
      stepId: e.stepId ?? undefined,
      type: e.type as CreationEvent["type"],
      message: e.message,
      createdAt: e.createdAt.toISOString?.() ?? new Date().toISOString(),
    };
  }

  private exportExtension(target: ExportCreationTaskDto["target"]): string {
    if (target === "mp4") return ".mp4";
    if (target === "long_image_png") return ".png";
    if (target === "long_image_jpg") return ".jpg";
    return ".pdf";
  }

  private renderPreviewHtml(title: string, pages: Array<Record<string, unknown>>): string {
    const pageHtml = pages.map((page, i) => {
      const pageTitle = page.title ?? `Page ${i + 1}`;
      const text = page.text ?? "";
      return `<div class="page"><h2>${this.escapeHtml(String(pageTitle))}</h2><p>${this.escapeHtml(String(text))}</p></div>`;
    }).join("\n");

    return `<!DOCTYPE html><html lang="zh-CN"><head><meta charset="utf-8"><title>${this.escapeHtml(title)}</title>
<style>body{font-family:sans-serif;max-width:800px;margin:0 auto;padding:20px}.page{margin-bottom:30px;padding:20px;border:1px solid #ddd;border-radius:8px}</style>
</head><body><h1>${this.escapeHtml(title)}</h1>${pageHtml}</body></html>`;
  }

  private escapeHtml(str: string): string {
    return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
  }
}
