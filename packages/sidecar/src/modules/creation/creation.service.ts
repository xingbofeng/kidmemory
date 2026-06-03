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
import {
  ensureTaskWorkspace,
  readBookJson,
  readPlanJson,
  writeTaskRequestJson,
} from "../agent-runtime/agent-runtime.workspace.ts";
import { loadValidatedBookOutput } from "../books/providers/book-output.ts";
import { exportHtmlToLongImage } from "../books/providers/long-image.ts";
import { exportHtmlToPdf, verifyPdfWithPdfJs } from "../books/providers/pdf.ts";
import { DatasetService } from "../dataset/dataset.service.ts";
import type {
  CreateCreationTaskDto,
  ExportCreationTaskDto,
  ShareCreationTaskDto,
} from "./dto/creation.dto.ts";
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
    @Inject(AgentRuntimeService)
    private readonly agentRuntime: AgentRuntimeService,
    @Inject(AppConfigService) private readonly config: AppConfigService,
    @Optional()
    @Inject(DatasetService)
    private readonly datasetService?: Pick<
      DatasetService,
      | "getAsset"
      | "recordExportArtifact"
      | "enqueueExportArtifactStorageSync"
      | "runStorageSyncWorker"
      | "getExportArtifactShareMetadata"
    >,
  ) {}

  async createTask(
    dto: CreateCreationTaskDto,
  ): Promise<ServiceResult<CreationTask | { message: string }>> {
    const taskId = `task_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
    const workspacePath = path.join(
      this.config.config.paths.workspaceDir,
      "creation-tasks",
      taskId,
    );

    await ensureTaskWorkspace({
      workspacePath,
      taskId,
      goal: dto.goal,
      assetIds: dto.assetIds,
      stage: "plan",
    });
    await writeTaskRequestJson(workspacePath, { taskId, ...dto });
    await this.writeCreationSkillFiles(workspacePath);
    await this.writeCreationInputManifest(
      {
        id: taskId,
        goal: dto.goal,
        assetIds: dto.assetIds,
      } as PrismaCreationTask,
      workspacePath,
      { recordEvent: false },
    );

    await this.prisma.creationTask.create({
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
      await this.addEvent(
        taskId,
        "error",
        planResult.error?.message ?? "Plan stage failed.",
      );
      return { status: 500, data: this.mapTask(failed) };
    }

    const planJson = await readPlanJson(workspacePath);
    if (!planJson) {
      const failed = await this.prisma.creationTask.update({
        where: { id: taskId },
        data: {
          status: "failed",
          error: {
            category: "planning",
            message:
              "Plan stage completed but output/plan.json is missing or invalid.",
          },
        },
      });
      await this.addEvent(taskId, "error", "Plan output not found.");
      return { status: 500, data: this.mapTask(failed) };
    }

    const summary =
      typeof planJson.summary === "string" ? planJson.summary : "Plan created";
    const skillName =
      typeof planJson.skillName === "string"
        ? planJson.skillName
        : this.skillNameFor(dto.creationType);
    const planSteps = this.normalizePlanSteps(planJson.steps, dto.creationType);
    const requirementItems = Array.isArray(planJson.requirements)
      ? planJson.requirements.map(String)
      : [];

    const updatedTask = await this.prisma.creationTask.update({
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

    return {
      status: 201,
      data: this.mapTask(updatedTask),
    };
  }

  async generateTask(
    taskId: string,
  ): Promise<ServiceResult<CreationTask | { message: string }>> {
    const task = await this.prisma.creationTask.findUnique({
      where: { id: taskId },
    });
    if (!task)
      return { status: 404, data: { message: "Creation task not found." } };
    if (task.status !== "ready") {
      return {
        status: 409,
        data: {
          message: `Task is in status "${task.status}", expected "ready".`,
        },
      };
    }

    const creationType = task.creationType as CreationType;
    const stage: RuntimeStage =
      creationType === "memoir_video" ? "generate_video" : "generate_book";

    await this.prisma.creationTask.update({
      where: { id: taskId },
      data: { status: "generating" },
    });
    await this.addEvent(taskId, "task", `Starting ${stage} stage.`);

    const workspacePath =
      task.workspacePath ??
      path.join(
        this.config.config.paths.workspaceDir,
        "creation-tasks",
        taskId,
      );
    await this.writeCreationInputManifest(task, workspacePath);
    const generateResult = await this.agentRuntime.runCreationStage({
      taskId,
      workspacePath,
      stage,
      creationType,
      prompt: this.buildGeneratePrompt(task, creationType, stage),
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
            message:
              generateResult.error?.message ?? "Generation stage failed.",
            code: generateResult.error?.code,
          },
        },
      });
      await this.addEvent(
        taskId,
        "error",
        generateResult.error?.message ?? "Generation stage failed.",
      );
      return { status: 500, data: this.mapTask(failed) };
    }

    if (creationType === "memoir_video") {
      const videoReady = await this.ensureMemoirVideoArtifact(
        taskId,
        workspacePath,
      );
      if (videoReady.ok !== true) {
        const failed = await this.prisma.creationTask.update({
          where: { id: taskId },
          data: {
            status: "failed",
            currentStepId: "generate",
            error: {
              category: "hyperframes",
              message: videoReady.message,
              code: "INVALID_MP4_ARTIFACT",
            },
          },
        });
        await this.addEvent(taskId, "error", videoReady.message);
        return { status: 500, data: this.mapTask(failed) };
      }
    } else {
      const bookReady = await this.ensureBookArtifact(
        taskId,
        workspacePath,
        new Set(task.assetIds),
      );
      if (bookReady.ok !== true) {
        const failed = await this.prisma.creationTask.update({
          where: { id: taskId },
          data: {
            status: "failed",
            currentStepId: "generate",
            error: {
              category: "generation",
              message: bookReady.message,
              code: "INVALID_BOOK_ARTIFACT",
            },
          },
        });
        await this.addEvent(taskId, "error", bookReady.message);
        return { status: 500, data: this.mapTask(failed) };
      }
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
      include: {
        creationArtifacts: true,
        creationEvents: { orderBy: { createdAt: "asc" } },
      },
    });
    return {
      status: 200,
      data: updated
        ? this.mapTaskWithRelations(updated)
        : this.mapTask(task, "succeeded"),
    };
  }

  private async persistGeneratedArtifacts(
    taskId: string,
    creationType: CreationType,
    workspacePath: string,
  ) {
    const outputs =
      creationType === "memoir_video"
        ? [
            {
              kind: "mp4",
              localPath: path.join(workspacePath, "output", "video.mp4"),
            },
          ]
        : [
            {
              kind: "book_json",
              localPath: path.join(workspacePath, "output", "book.json"),
            },
            {
              kind: "book_html",
              localPath: path.join(workspacePath, "output", "book.html"),
            },
          ];

    for (const output of outputs) {
      const exists = await fs
        .stat(output.localPath)
        .then((stat) => stat.isFile() && stat.size > 0)
        .catch(() => false);
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

  private async writeCreationInputManifest(
    task: PrismaCreationTask,
    workspacePath: string,
    options: { recordEvent?: boolean } = {},
  ): Promise<void> {
    const assets = [];
    for (const assetId of task.assetIds) {
      const asset = await this.datasetService
        ?.getAsset(assetId)
        .then((result) => result.asset)
        .catch(() => null);
      if (!asset) continue;
      assets.push({
        id: asset.id,
        type: asset.type,
        title: asset.title,
        description: asset.description,
        imagePath: asset.imagePath,
        thumbnailPath: asset.thumbnailPath,
        storagePath: asset.storagePath,
        capturedAt: asset.capturedAt,
      });
    }

    await fs.mkdir(path.join(workspacePath, "input"), { recursive: true });
    await fs.writeFile(
      path.join(workspacePath, "input", "assets.json"),
      `${JSON.stringify(
        {
          taskId: task.id,
          goal: task.goal,
          assetIds: task.assetIds,
          assets,
          settings: await this.readTaskSettings(workspacePath),
        },
        null,
        2,
      )}\n`,
    );
    await this.writeCreationSkillFiles(workspacePath);
    if (options.recordEvent ?? true) {
      await this.addEvent(
        task.id,
        "step",
        `Prepared ${assets.length} selected assets and KidMemory skills for generation.`,
      );
    }
  }

  private async readTaskSettings(
    workspacePath: string,
  ): Promise<Record<string, unknown>> {
    try {
      const content = await fs.readFile(
        path.join(workspacePath, "input", "task-request.json"),
        "utf8",
      );
      const parsed = JSON.parse(content) as { settings?: unknown };
      if (
        parsed.settings &&
        typeof parsed.settings === "object" &&
        !Array.isArray(parsed.settings)
      ) {
        return parsed.settings as Record<string, unknown>;
      }
    } catch {
      // Older tasks may not have request settings; renderer defaults are fine.
    }
    return {};
  }

  private async writeCreationSkillFiles(workspacePath: string): Promise<void> {
    await this.writePicturebookSkillFiles(workspacePath);
    await this.writeMemoirVideoSkillFiles(workspacePath);
  }

  private async writePicturebookSkillFiles(workspacePath: string): Promise<void> {
    const skillDir = path.join(
      workspacePath,
      ".kidmemory",
      "skills",
      "kidmemory-picturebook",
    );
    await fs.mkdir(skillDir, { recursive: true });
    await fs.writeFile(
      path.join(skillDir, "SKILL.md"),
      [
        "---",
        "name: kidmemory-picturebook",
        "description: Render KidMemory picture books and memory books from selected asset manifests into output/book.json and output/book.html.",
        "---",
        "",
        "# KidMemory Picturebook",
        "",
        "Use this skill when the task requires a storybook, memory_book, or picture book artifact.",
        "",
        "## Contract",
        "",
        "- Read the selected asset manifest from `input/assets.json`.",
        "- Before running this skill, the agent must write `work/curation.json` with metadata.title, metadata.childName, and curated pages.",
        "- `work/curation.json` pages must include cover, at least one content page, and closing page.",
        "- Render structured JSON to `output/book.json`.",
        "- Render complete HTML to `output/book.html`.",
        "- Run from the workspace root: `node .kidmemory/skills/kidmemory-picturebook/render-picturebook.mjs`.",
        "",
      ].join("\n"),
    );
    await fs.writeFile(
      path.join(skillDir, "render-picturebook.mjs"),
      this.picturebookSkillScript(),
    );
  }

  private async writeMemoirVideoSkillFiles(workspacePath: string): Promise<void> {
    const skillDir = path.join(
      workspacePath,
      ".kidmemory",
      "skills",
      "kidmemory-memoir-video",
    );
    await fs.mkdir(skillDir, { recursive: true });
    await fs.writeFile(
      path.join(skillDir, "SKILL.md"),
      [
        "---",
        "name: kidmemory-memoir-video",
        "description: Render KidMemory memoir videos from selected asset manifests into output/video.mp4.",
        "---",
        "",
        "# KidMemory Memoir Video",
        "",
        "Use this skill when the task requires a memoir_video MP4 artifact.",
        "",
        "## Contract",
        "",
        "- Read the selected asset manifest from `input/assets.json`.",
        "- Render a real MP4 to `output/video.mp4`.",
        "- Do not write placeholder text as a video artifact.",
        "- Run from the workspace root: `node .kidmemory/skills/kidmemory-memoir-video/render-memoir-video.mjs`.",
        "",
      ].join("\n"),
    );
    await fs.writeFile(
      path.join(skillDir, "render-memoir-video.mjs"),
      this.memoirVideoSkillScript(),
    );
  }

  private picturebookSkillScript(): string {
    return String.raw`import fs from "node:fs/promises";
import path from "node:path";

const workspaceDir = process.cwd();
const inputPath = path.join(workspaceDir, "input", "assets.json");
const curationPath = path.join(workspaceDir, "work", "curation.json");
const bookJsonPath = path.join(workspaceDir, "output", "book.json");
const bookHtmlPath = path.join(workspaceDir, "output", "book.html");

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function assetImagePath(asset) {
  for (const value of [asset?.imagePath, asset?.thumbnailPath, asset?.storagePath]) {
    if (typeof value === "string" && value.trim()) return value.trim();
  }
  return undefined;
}

function normalizePage(page, index, assetById) {
  const rawKind = typeof page?.kind === "string" && page.kind.trim()
    ? page.kind.trim()
    : typeof page?.type === "string" && page.type.trim()
      ? page.type.trim()
      : "artwork";
  const kind = normalizePageKind(rawKind);
  const title = typeof page?.title === "string" && page.title.trim()
    ? page.title.trim()
    : "Memory " + (index + 1);
  const text = typeof page?.text === "string" && page.text.trim()
    ? page.text.trim()
    : typeof page?.subtitle === "string" && page.subtitle.trim()
      ? page.subtitle.trim()
    : "A warm KidMemory moment.";
  const assetId = typeof page?.assetId === "string" && page.assetId.trim()
    ? page.assetId.trim()
    : undefined;
  const asset = assetId ? assetById.get(assetId) : undefined;
  const imagePath = typeof page?.imagePath === "string" && page.imagePath.trim()
    ? page.imagePath.trim()
    : assetImagePath(asset);
  return {
    kind,
    title,
    text,
    assetId,
    imagePath,
  };
}

function normalizePageKind(value) {
  if (value === "cover" || value === "closing" || value === "photo" || value === "craft" || value === "artwork") {
    return value;
  }
  if (value === "content" || value === "page" || value === "memory") return "artwork";
  return "artwork";
}

async function main() {
  const input = JSON.parse(await fs.readFile(inputPath, "utf8"));
  const curation = JSON.parse(await fs.readFile(curationPath, "utf8"));
  const assets = Array.isArray(input.assets) ? input.assets : [];
  const assetById = new Map(assets.map((asset) => [asset.id, asset]));
  const metadata = curation && typeof curation.metadata === "object" ? curation.metadata : {};
  const title = typeof metadata.title === "string" && metadata.title.trim()
    ? metadata.title.trim()
    : input.goal || "KidMemory Picture Book";
  const childName = typeof metadata.childName === "string" && metadata.childName.trim()
    ? metadata.childName.trim()
    : input.settings?.childName || "KidMemory Child";
  const curatedPages = Array.isArray(curation?.pages) ? curation.pages : [];
  if (curatedPages.length === 0) {
    throw new Error("work/curation.json must include curated pages before rendering.");
  }
  const pages = curatedPages.map((page, index) => normalizePage(page, index, assetById));
  const book = {
    metadata: {
      title,
      childName,
    },
    pages,
  };
  const htmlPages = pages.map((page) => {
    const image = page.imagePath
      ? '<img src="file://' + escapeHtml(page.imagePath) + '" alt="" />'
      : "";
    return '<section class="page"><h1>' + escapeHtml(page.title) + '</h1>' + image + '<p>' + escapeHtml(page.text) + '</p></section>';
  }).join("\n");
  const html = '<!doctype html><html><head><meta charset="utf-8"><style>body{font-family:-apple-system,BlinkMacSystemFont,sans-serif;margin:0;background:#fffaf5;color:#3f3328}.page{min-height:900px;padding:64px;page-break-after:always}h1{font-size:42px;margin:0 0 24px}p{font-size:24px;line-height:1.5}img{max-width:100%;max-height:560px;display:block;margin:24px 0;border-radius:8px;object-fit:contain}</style></head><body>' + htmlPages + '</body></html>';
  await fs.mkdir(path.join(workspaceDir, "output"), { recursive: true });
  await fs.writeFile(bookJsonPath, JSON.stringify(book, null, 2) + "\n");
  await fs.writeFile(bookHtmlPath, html);
  console.log(JSON.stringify({ ok: true, inputs: ["work/curation.json"], outputs: ["output/book.json", "output/book.html"], pageCount: pages.length }));
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
});
`;
  }

  private memoirVideoSkillScript(): string {
    return String.raw`import { execFile } from "node:child_process";
import fs from "node:fs/promises";
import path from "node:path";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);
const workspaceDir = process.cwd();
const inputPath = path.join(workspaceDir, "input", "assets.json");
const outputPath = path.join(workspaceDir, "output", "video.mp4");
const concatPath = path.join(workspaceDir, "work", "memoir-video-concat.txt");

function assetImagePath(asset) {
  for (const value of [asset?.imagePath, asset?.storagePath, asset?.thumbnailPath]) {
    if (typeof value === "string" && value.trim()) return value;
  }
  return undefined;
}

function escapeConcatPath(filePath) {
  return filePath.replaceAll("'", "'\\''");
}

async function readableImages(assets) {
  const result = [];
  for (const asset of Array.isArray(assets) ? assets : []) {
    const candidate = assetImagePath(asset);
    if (!candidate) continue;
    const exists = await fs.stat(candidate).then((stat) => stat.isFile()).catch(() => false);
    if (exists) result.push(candidate);
  }
  return result;
}

function durationPerImage(settings, imageCount) {
  const requested = settings?.targetDurationSeconds;
  const totalDuration = typeof requested === "number" && Number.isFinite(requested)
    ? Math.min(Math.max(requested, 2), 120)
    : Math.max(imageCount * 2, 4);
  return Math.max(totalDuration / imageCount, 0.5);
}

function concatFileContent(imagePaths, duration) {
  const lines = [];
  for (const imagePath of imagePaths) {
    lines.push("file '" + escapeConcatPath(imagePath) + "'");
    lines.push("duration " + duration.toFixed(3));
  }
  lines.push("file '" + escapeConcatPath(imagePaths[imagePaths.length - 1]) + "'");
  return lines.join("\n") + "\n";
}

async function main() {
  const input = JSON.parse(await fs.readFile(inputPath, "utf8"));
  const imagePaths = await readableImages(input.assets);
  if (imagePaths.length === 0) {
    throw new Error("No readable image assets were provided for memoir video rendering.");
  }

  await fs.mkdir(path.join(workspaceDir, "work"), { recursive: true });
  await fs.mkdir(path.dirname(outputPath), { recursive: true });
  await fs.writeFile(concatPath, concatFileContent(imagePaths, durationPerImage(input.settings, imagePaths.length)));

  const tempPath = outputPath + ".tmp-" + Date.now() + ".mp4";
  await fs.rm(tempPath, { force: true }).catch(() => undefined);
  try {
    await execFileAsync(process.env.KIDMEMORY_FFMPEG_PATH || "ffmpeg", [
      "-y",
      "-hide_banner",
      "-loglevel",
      "error",
      "-f",
      "concat",
      "-safe",
      "0",
      "-i",
      concatPath,
      "-vf",
      "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2:color=0xf9e7c8,format=yuv420p",
      "-r",
      "24",
      "-c:v",
      "libx264",
      "-pix_fmt",
      "yuv420p",
      "-movflags",
      "+faststart",
      tempPath,
    ]);
    await fs.rename(tempPath, outputPath);
  } catch (error) {
    await fs.rm(tempPath, { force: true }).catch(() => undefined);
    throw error;
  }

  console.log(JSON.stringify({ ok: true, outputPath, imageCount: imagePaths.length }));
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
});
`;
  }

  private async ensureMemoirVideoArtifact(
    taskId: string,
    workspacePath: string,
  ): Promise<{ ok: true } | { ok: false; message: string }> {
    const mp4Path = path.join(workspacePath, "output", "video.mp4");
    if (await this.isMp4File(mp4Path)) return { ok: true };

    const message =
      "Agent runtime did not produce a valid MP4 at output/video.mp4. The task is failed instead of replacing the artifact.";
    await this.addEvent(taskId, "step", message);
    return { ok: false, message };
  }

  private async ensureBookArtifact(
    taskId: string,
    workspacePath: string,
    selectedAssetIds: Set<string>,
  ): Promise<{ ok: true } | { ok: false; message: string }> {
    try {
      const output = await loadValidatedBookOutput(workspacePath, selectedAssetIds);
      if (output.ok) return { ok: true };

      const message = `Book artifact contract failed: ${output.errors.join("; ")}`;
      await this.addEvent(taskId, "step", message);
      return { ok: false, message };
    } catch (error) {
      const reason = error instanceof Error ? error.message : "Unknown validation error";
      const message = `Book artifact contract failed: ${reason}`;
      await this.addEvent(taskId, "step", message);
      return { ok: false, message };
    }
  }

  private async isMp4File(filePath: string): Promise<boolean> {
    try {
      const handle = await fs.open(filePath, "r");
      try {
        const buffer = Buffer.alloc(12);
        const { bytesRead } = await handle.read(buffer, 0, buffer.length, 0);
        return bytesRead >= 12 && buffer.subarray(4, 8).toString("ascii") === "ftyp";
      } finally {
        await handle.close();
      }
    } catch {
      return false;
    }
  }

  async getTask(
    taskId: string,
  ): Promise<ServiceResult<CreationTask | { message: string }>> {
    const task = await this.prisma.creationTask.findUnique({
      where: { id: taskId },
      include: {
        creationArtifacts: true,
        creationEvents: { orderBy: { createdAt: "asc" } },
      },
    });
    if (!task)
      return { status: 404, data: { message: "Creation task not found." } };
    return { status: 200, data: this.mapTaskWithRelations(task) };
  }

  async getEvents(
    taskId: string,
  ): Promise<ServiceResult<{ events: CreationEvent[] } | { message: string }>> {
    const task = await this.prisma.creationTask.findUnique({
      where: { id: taskId },
    });
    if (!task)
      return { status: 404, data: { message: "Creation task not found." } };

    const events = await this.prisma.creationEvent.findMany({
      where: { taskId },
      orderBy: { createdAt: "asc" },
    });

    return {
      status: 200,
      data: { events: events.map((e) => this.mapEvent(e)) },
    };
  }

  async getPreviewHtml(
    taskId: string,
  ): Promise<
    ServiceResult<{ message: string }> | { status: number; html: string }
  > {
    const task = await this.prisma.creationTask.findUnique({
      where: { id: taskId },
    });
    if (!task)
      return { status: 404, data: { message: "Creation task not found." } };

    const creationType = task.creationType as CreationType;
    if (creationType === "memoir_video") {
      return {
        status: 422,
        data: {
          message: "Memoir video tasks do not provide an HTML page preview.",
        },
      };
    }

    const workspacePath = task.workspacePath ?? "";
    const bookJson = await readBookJson(workspacePath);
    if (!bookJson || !bookJson.metadata || !bookJson.pages) {
      return {
        status: 409,
        data: {
          message:
            "Task preview is not available until the book draft is generated.",
        },
      };
    }

    const title =
      (bookJson.metadata as Record<string, unknown>)?.title ?? "Preview";
    const pages = (bookJson.pages as Array<Record<string, unknown>>) ?? [];
    const html = this.renderPreviewHtml(title as string, pages);

    return { status: 200, html };
  }

  async exportTask(
    taskId: string,
    dto: ExportCreationTaskDto,
  ): Promise<ServiceResult<CreationArtifact | { message: string }>> {
    const task = await this.prisma.creationTask.findUnique({
      where: { id: taskId },
      include: { creationArtifacts: true },
    });
    if (!task)
      return { status: 404, data: { message: "Creation task not found." } };

    const creationType = task.creationType as CreationType;
    if (dto.target === "mp4" && creationType !== "memoir_video") {
      return {
        status: 422,
        data: { message: "Only memoir_video tasks can export MP4 artifacts." },
      };
    }
    if (dto.target !== "mp4" && creationType === "memoir_video") {
      return {
        status: 422,
        data: { message: "Memoir video tasks export MP4 artifacts." },
      };
    }

    const artifactId = `artifact_${taskId}_${dto.target}_${Date.now()}`;
    const localPath =
      dto.targetPath ??
      path.join(
        this.config.config.paths.exportDir,
        `${taskId}${this.exportExtension(dto.target)}`,
      );

    const workspacePath = task.workspacePath ?? "";
    if (
      dto.target === "pdf" ||
      dto.target === "long_image_png" ||
      dto.target === "long_image_jpg"
    ) {
      const output = await loadValidatedBookOutput(
        workspacePath,
        new Set(task.assetIds),
      );
      if (!output.ok) {
        return {
          status: 422,
          data: {
            message: `Book artifact contract failed: ${output.errors.join("; ")}`,
          },
        };
      }
      if (dto.target === "pdf") {
        const exported = await exportHtmlToPdf(output.html, localPath);
        if (!exported.ok) {
          return {
            status: 500,
            data: { message: exported.message ?? "PDF export failed." },
          };
        }
        const verified = await verifyPdfWithPdfJs(
          localPath,
          output.book.pages.length,
        );
        if (!verified.ok) {
          return {
            status: 500,
            data: { message: verified.message ?? "PDF verification failed." },
          };
        }
      } else {
        const exported = await exportHtmlToLongImage({
          html: output.html,
          targetPath: localPath,
          format: dto.target === "long_image_jpg" ? "jpg" : "png",
        });
        if (!exported.ok) {
          return {
            status: 500,
            data: { message: exported.message ?? "Long image export failed." },
          };
        }
      }
    }

    if (dto.target === "mp4") {
      const mp4Path = path.join(workspacePath, "output", "video.mp4");
      if (!(await this.isMp4File(mp4Path))) {
        return {
          status: 409,
          data: {
            message:
              "MP4 artifact is not available or invalid. Re-run generation with a real video renderer first.",
          },
        };
      }
      try {
        await fs.mkdir(path.dirname(localPath), { recursive: true });
        await fs.cp(mp4Path, localPath);
      } catch (error) {
        const message =
          error instanceof Error ? error.message : "Unknown copy error";
        return {
          status: 500,
          data: { message: `Failed to export MP4 artifact: ${message}` },
        };
      }
    }

    const artifact = await this.prisma.creationArtifact.create({
      data: { id: artifactId, taskId, kind: dto.target, localPath },
    });

    await this.prisma.creationTask.update({
      where: { id: taskId },
      data: { status: "exported" },
    });
    await this.addEvent(
      taskId,
      "export",
      `Exported ${dto.target.toUpperCase()} artifact to ${localPath}.`,
    );

    return { status: 201, data: this.mapArtifact(artifact) };
  }

  async shareTask(
    taskId: string,
    dto: ShareCreationTaskDto,
  ): Promise<ServiceResult<CreationArtifact | { message: string }>> {
    const task = await this.prisma.creationTask.findUnique({
      where: { id: taskId },
      include: { creationArtifacts: true },
    });
    if (!task)
      return { status: 404, data: { message: "Creation task not found." } };

    const source = task.creationArtifacts.find((a) => a.id === dto.artifactId);
    if (!source)
      return { status: 404, data: { message: "Creation artifact not found." } };

    if (!source.localPath) {
      return {
        status: 409,
        data: { message: "Creation artifact has no local file path to share." },
      };
    }
    if (!this.datasetService) {
      return {
        status: 503,
        data: {
          message:
            "Creation share service is not available in this Sidecar runtime.",
        },
      };
    }

    const kind =
      source.kind === "pdf" ||
      source.kind === "mp4" ||
      source.kind === "long_image_png" ||
      source.kind === "long_image_jpg"
        ? source.kind
        : undefined;
    if (!kind) {
      return {
        status: 422,
        data: {
          message:
            "Only PDF, MP4, and long image creation artifacts can be shared.",
        },
      };
    }

    await this.datasetService.recordExportArtifact({
      id: source.id,
      jobId: taskId,
      kind,
      localPath: source.localPath,
      storageProvider: "local",
      storageStatus: "local_only",
    });

    const enqueued = await this.datasetService.enqueueExportArtifactStorageSync(
      {
        artifactId: source.id,
        childId: `creation-${task.creationType}`,
      },
    );

    if (!enqueued?.enqueued) {
      const reason =
        enqueued && "reason" in enqueued ? enqueued.reason : "unknown_error";
      return {
        status: 502,
        data: {
          message: `Export artifact could not be queued for storage sync: ${reason}.`,
        },
      };
    }

    await this.datasetService.runStorageSyncWorker({ limit: 10 });
    const metadata = await this.datasetService.getExportArtifactShareMetadata(
      source.id,
    );
    if (!metadata.ok || !metadata.url) {
      return {
        status: 502,
        data: {
          message:
            metadata.message || "Storage share link could not be created.",
        },
      };
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
    await this.addEvent(
      taskId,
      "share",
      `Created Web share link for ${kind.toUpperCase()}.`,
    );

    return { status: 201, data: this.mapArtifact(shareArtifact) };
  }

  private async addEvent(
    taskId: string,
    type: CreationEvent["type"],
    message: string,
  ) {
    await this.prisma.creationEvent.create({
      data: {
        id: `event_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`,
        taskId,
        type,
        message,
      },
    });
  }

  private defaultSteps(
    creationType: CreationType,
    status: CreationStep["status"],
  ): CreationStep[] {
    const generateLabel =
      creationType === "memoir_video" ? "Generate MP4" : "Generate book draft";
    return [
      { stepId: "compose", label: "Compose selected assets", status },
      { stepId: "plan", label: "Confirm agent plan", status },
      { stepId: "generate", label: generateLabel, status },
      { stepId: "review", label: "Review generated artifact", status },
      { stepId: "publish", label: "Export and share", status },
    ];
  }

  private normalizePlanSteps(value: unknown, creationType: CreationType): CreationStep[] {
    if (!Array.isArray(value)) return this.defaultSteps(creationType, "pending");
    return value
      .map((item) => {
        if (!item || typeof item !== "object") return undefined;
        const record = item as Record<string, unknown>;
        const stepId =
          typeof record.stepId === "string" ? record.stepId.trim() : "";
        const label =
          typeof record.label === "string" ? record.label.trim() : "";
        const detail =
          typeof record.detail === "string" ? record.detail.trim() : undefined;
        if (!stepId || !label) return undefined;
        return { stepId, label, status: "pending" as const, detail };
      })
      .filter(Boolean) as CreationStep[];
  }

  private buildPlanPrompt(dto: CreateCreationTaskDto): string {
    return [
      "Create the KidMemory plan for this creation task.",
      "You must use skill-deck to inspect the relevant KidMemory creation skill before writing the plan.",
      "Treat input/ as read-only. Do not write plan files to the workspace root or input/.",
      "Write exactly one plan artifact to output/plan.json using the write_file tool.",
      "The JSON must contain summary, skillName, steps, and requirements.",
      "",
      JSON.stringify(
        {
          goal: dto.goal,
          creationType: dto.creationType,
          assetIds: dto.assetIds,
          settings: dto.settings ?? {},
          constraints: {
            planOutputPath: "output/plan.json",
            finalOutput:
              dto.creationType === "memoir_video"
                ? "output/video.mp4"
                : "output/book.json and output/book.html",
            mainStages: ["compose", "plan", "generate", "review", "publish"],
          },
        },
        null,
        2,
      ),
    ].join("\n");
  }

  private buildGeneratePrompt(
    task: PrismaCreationTask,
    creationType: CreationType,
    stage: RuntimeStage,
  ): string {
    return [
      `Generate the KidMemory artifact for stage ${stage}.`,
      "Treat input/ as read-only and read input/assets.json before rendering.",
      "Use skill-deck to inspect the relevant KidMemory creation skill.",
      task.skillName
        ? `The confirmed plan selected skillName: ${task.skillName}. Use that skill unless it is unavailable.`
        : "Choose the relevant KidMemory skill from the available skill-deck skills.",
      creationType === "memoir_video"
        ? "For memoir_video, read input/assets.json and let the video skill create its own working files."
        : "For storybook and memory_book, write work/curation.json before running the skill. It must contain metadata.title, metadata.childName, and curated pages that reflect the selected assets and goal.",
      "Execute the skill's documented shell command through run_skill_shell. Do not stop after reading the skill.",
      creationType === "memoir_video"
        ? "Required final artifact: output/video.mp4."
        : "Required final artifacts: output/book.json and output/book.html.",
      "Before final, verify the required output files exist and are non-empty.",
      "",
      JSON.stringify(
        {
          goal: task.goal,
          creationType,
          assetIds: task.assetIds,
          selectedSkillName: task.skillName,
          requiredOutputs:
            creationType === "memoir_video"
              ? ["output/video.mp4"]
              : ["output/book.json", "output/book.html"],
          intermediateOutputs:
            creationType === "memoir_video"
              ? []
              : ["work/curation.json"],
        },
        null,
        2,
      ),
    ].join("\n");
  }

  private skillNameFor(creationType: CreationType): string {
    if (creationType === "memoir_video") return "kidmemory-memoir-video";
    return "kidmemory-picturebook";
  }

  private mapTask(
    task: Partial<PrismaCreationTask>,
    overrideStatus?: string,
  ): CreationTask {
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
      requirements: {
        minAssets: 1,
        recommendedAssets: 6,
        needsCloudImage: true,
        needsHyperframes: false,
        needsFfmpeg: false,
      },
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

  private mapTaskWithRelations(
    task: PrismaCreationTask & {
      creationArtifacts?: Array<{
        id: string;
        taskId: string;
        kind: string;
        localPath: string | null;
        shareId: string | null;
        shareUrl: string | null;
        createdAt: Date;
      }>;
      creationEvents?: Array<{
        id: string;
        taskId: string;
        stepId: string | null;
        type: string;
        message: string;
        createdAt: Date;
      }>;
    },
  ): CreationTask {
    const result = this.mapTask(task);
    return {
      ...result,
      artifacts: (task.creationArtifacts ?? []).map((a) => this.mapArtifact(a)),
    };
  }

  private mapArtifact(a: {
    id: string;
    taskId: string;
    kind: string;
    localPath: string | null;
    shareId: string | null;
    shareUrl: string | null;
    createdAt: Date;
  }): CreationArtifact {
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

  private mapEvent(e: {
    id: string;
    taskId: string;
    stepId: string | null;
    type: string;
    message: string;
    createdAt: Date;
  }): CreationEvent {
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

  private renderPreviewHtml(
    title: string,
    pages: Array<Record<string, unknown>>,
  ): string {
    const pageHtml = pages
      .map((page, i) => {
        const pageTitle = page.title ?? `Page ${i + 1}`;
        const text = page.text ?? "";
        return `<div class="page"><h2>${this.escapeHtml(String(pageTitle))}</h2><p>${this.escapeHtml(String(text))}</p></div>`;
      })
      .join("\n");

    return `<!DOCTYPE html><html lang="zh-CN"><head><meta charset="utf-8"><title>${this.escapeHtml(title)}</title>
<style>body{font-family:sans-serif;max-width:800px;margin:0 auto;padding:20px}.page{margin-bottom:30px;padding:20px;border:1px solid #ddd;border-radius:8px}</style>
</head><body><h1>${this.escapeHtml(title)}</h1>${pageHtml}</body></html>`;
  }

  private escapeHtml(str: string): string {
    return str
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }
}
