import fs from "node:fs/promises";
import path from "node:path";

import { Inject, Injectable, Optional } from "@nestjs/common";
import type {
  CreationArtifact,
  CreationEvent,
  CreationJob,
  CreationPlan,
  CreationStep,
  CreationType,
} from "@kidmemory/protocol";

import { AppConfigService } from "../../infrastructure/config/app-config.service.ts";
import type { ExportArtifact } from "../../infrastructure/dataset-state/memory-dataset-db.ts";
import { BooksService } from "../books/books.service.ts";
import { DatasetService } from "../dataset/dataset.service.ts";
import { FfmpegRepairService } from "../media/ffmpeg-repair.service.ts";
import { SkillRuntimeService } from "../skills/skill-runtime.service.ts";
import { CreationPlanningService } from "./creation-planning.service.ts";
import type {
  CreateCreationJobDto,
  CreateCreationPlanDto,
  ExportCreationJobDto,
  ShareCreationJobDto,
} from "./dto/creation.dto.ts";

type ServiceResult<T> = {
  status: number;
  data: T;
};

type CreationRecord = {
  plans: Record<string, CreationPlan>;
  jobs: Record<string, CreationJob>;
  events: Record<string, CreationEvent[]>;
  linkedBookJobs?: Record<string, string>;
};

@Injectable()
export class CreationService {
  constructor(
    @Inject(AppConfigService) private readonly config: AppConfigService,
    @Inject(BooksService) private readonly booksService: BooksService,
    @Inject(SkillRuntimeService) private readonly skillRuntime: SkillRuntimeService,
    @Optional() @Inject(FfmpegRepairService) private readonly ffmpegRepairService?: FfmpegRepairService,
    @Optional() @Inject(CreationPlanningService) private readonly planningService?: CreationPlanningService,
    @Optional() @Inject(DatasetService) private readonly datasetService?: Pick<
      DatasetService,
      "recordExportArtifact" | "enqueueExportArtifactStorageSync" | "runStorageSyncWorker" | "getExportArtifactShareMetadata"
    >,
  ) {}

  async createPlan(dto: CreateCreationPlanDto): Promise<ServiceResult<CreationPlan | { message: string }>> {
    const now = new Date().toISOString();
    const planned = this.planningService ? await this.planningService.createPlan(dto) : undefined;
    if (planned?.ok === false) {
      return {
        status: 500,
        data: {
          message: planned.message,
        },
      };
    }
    const planId = `plan_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
    const plan: CreationPlan = {
      planId,
      creationType: dto.creationType,
      goal: dto.goal,
      assetIds: dto.assetIds,
      summary: planned?.summary ?? this.summaryFor(dto.creationType, dto.goal, dto.assetIds.length),
      skillName: planned?.skillName ?? this.skillNameFor(dto.creationType),
      steps: planned ? this.normalizePlannedSteps(planned.steps) : this.stepsFor(dto.creationType, "pending"),
      requirements: this.requirementsFor(dto.creationType),
      requirementItems: planned?.requirements ?? this.requirementItemsFor(dto.creationType),
      status: "ready",
      createdAt: now,
      updatedAt: now,
    };

    const record = await this.readRecord();
    record.plans[planId] = plan;
    await this.writeRecord(record);

    return { status: 201, data: plan };
  }

  async createJob(dto: CreateCreationJobDto): Promise<ServiceResult<CreationJob | { message: string }>> {
    const record = await this.readRecord();
    const plan = record.plans[dto.planId];
    if (!plan || plan.status !== "ready") {
      return { status: 404, data: { message: "Creation plan not found or no longer valid." } };
    }

    const now = new Date().toISOString();
    const jobId = `creation_job_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
    const steps = this.stepsFor(plan.creationType, "pending");
    steps[0] = { ...steps[0], status: "succeeded", detail: "Plan confirmed." };
    steps[1] = { ...steps[1], status: "running", detail: this.runningDetailFor(plan.creationType) };
    let job: CreationJob = {
      jobId,
      planId: plan.planId,
      creationType: plan.creationType,
      status: "running",
      currentStepId: steps[1]?.stepId ?? null,
      steps,
      artifacts: [],
      error: null,
      createdAt: now,
      updatedAt: now,
    };

    const events = [
      this.event(jobId, "job", "Creation job accepted by the Sidecar.", now),
      this.event(jobId, "step", this.runningDetailFor(plan.creationType), now, job.currentStepId ?? undefined),
    ];

    if (plan.creationType === "memoir_video") {
      const renderResult = await this.tryRenderMemoirVideo(plan, jobId);
      if (renderResult.repairMessage) {
        events.push(this.event(jobId, "step", renderResult.repairMessage, new Date().toISOString(), "generate"));
      }
      if (renderResult.ok === true) {
        const artifact: CreationArtifact = {
          artifactId: renderResult.artifactId,
          kind: "mp4",
          jobId,
          localPath: renderResult.localPath,
          createdAt: now,
        };
        job = {
          ...job,
          status: "succeeded",
          currentStepId: "review",
          artifacts: [artifact],
          steps: job.steps.map((step) => {
            if (step.stepId === "publish") return step;
            return {
              ...step,
              status: "succeeded",
              detail: step.stepId === "generate" ? "Rendered MP4 through Hyperframes skill runtime." : step.detail,
            };
          }),
          updatedAt: new Date().toISOString(),
        };
        events.push(
          this.event(jobId, "step", `Rendered Hyperframes MP4 at ${renderResult.localPath}.`, job.updatedAt, "generate"),
        );
      } else {
        const failedAt = new Date().toISOString();
        job = {
          ...job,
          status: "failed",
          currentStepId: "generate",
          steps: job.steps.map((step) => {
            if (step.stepId !== "generate") return step;
            return {
              ...step,
              status: "failed",
              detail: renderResult.message,
            };
          }),
          error: {
            category: renderResult.category,
            message: renderResult.message,
            stepId: "generate",
            code: renderResult.code,
          },
          updatedAt: failedAt,
        };
        events.push(this.event(jobId, "error", renderResult.message, failedAt, "generate"));
      }
    } else {
      const bookResult = await this.tryCreateBookJob(plan);
      if (bookResult.ok === true) {
        record.linkedBookJobs ??= {};
        record.linkedBookJobs[jobId] = bookResult.bookJobId;
        job = {
          ...job,
          status: "succeeded",
          currentStepId: "review",
          steps: job.steps.map((step) => {
            if (step.stepId === "publish") return step;
            return {
              ...step,
              status: "succeeded",
              detail: step.stepId === "generate" ? "Generated through the existing book skill path." : step.detail,
            };
          }),
          updatedAt: new Date().toISOString(),
        };
        events.push(
          this.event(jobId, "step", `Generated book job ${bookResult.bookJobId} through BooksService.`, job.updatedAt, "generate"),
        );
      } else {
        events.push(this.event(jobId, "step", bookResult.message, now, "generate"));
      }
    }

    record.jobs[jobId] = job;
    record.events[jobId] = events;
    await this.writeRecord(record);

    return { status: 201, data: job };
  }

  async getJob(jobId: string): Promise<ServiceResult<CreationJob | { message: string }>> {
    const record = await this.readRecord();
    const job = record.jobs[jobId];
    if (!job) return { status: 404, data: { message: "Creation job not found." } };
    return { status: 200, data: job };
  }

  async getEvents(jobId: string): Promise<ServiceResult<{ events: CreationEvent[] } | { message: string }>> {
    const record = await this.readRecord();
    if (!record.jobs[jobId]) return { status: 404, data: { message: "Creation job not found." } };
    return { status: 200, data: { events: record.events[jobId] ?? [] } };
  }

  async getPreviewHtml(
    jobId: string,
  ): Promise<ServiceResult<{ message: string }> | { status: number; html: string }> {
    const record = await this.readRecord();
    const job = record.jobs[jobId];
    if (!job) return { status: 404, data: { message: "Creation job not found." } };
    if (job.creationType === "memoir_video") {
      return { status: 422, data: { message: "Memoir video jobs do not provide a PDF page preview." } };
    }

    const bookJobId = record.linkedBookJobs?.[jobId];
    if (!bookJobId) {
      return { status: 409, data: { message: "Creation preview is not available until the book draft is generated." } };
    }

    try {
      const result = await this.booksService.getPreviewHtml(bookJobId);
      if (result && typeof result === "object" && "html" in result && typeof result.html === "string") {
        return { status: result.status, html: result.html };
      }
      return {
        status: this.statusFromResult(result, 500),
        data: {
          message: this.messageFromResult(result, "BooksService preview did not return HTML."),
        },
      };
    } catch (error) {
      return {
        status: 500,
        data: { message: error instanceof Error ? error.message : "Unknown BooksService preview error." },
      };
    }
  }

  async exportJob(
    jobId: string,
    dto: ExportCreationJobDto,
  ): Promise<ServiceResult<CreationArtifact | { message: string }>> {
    const record = await this.readRecord();
    const job = record.jobs[jobId];
    if (!job) return { status: 404, data: { message: "Creation job not found." } };
    if (dto.target === "mp4" && job.creationType !== "memoir_video") {
      return { status: 422, data: { message: "Only memoir_video jobs can export MP4 artifacts." } };
    }
    if (dto.target === "pdf" && job.creationType === "memoir_video") {
      return { status: 422, data: { message: "Memoir video jobs export MP4 artifacts." } };
    }

    const now = new Date().toISOString();
    if (dto.target === "mp4" && job.creationType === "memoir_video") {
      const existingMp4 = job.artifacts.find((artifact) => artifact.kind === "mp4" && artifact.localPath);
      if (!existingMp4) {
        return {
          status: 409,
          data: { message: "MP4 artifact is not available. Resolve the Hyperframes generation failure and regenerate first." },
        };
      }
      const nextJob = this.withTerminalStep({
        ...job,
        status: "exported",
        updatedAt: now,
      });
      record.jobs[jobId] = nextJob;
      record.events[jobId] = [
        ...(record.events[jobId] ?? []),
        this.event(jobId, "export", `Prepared MP4 export from ${existingMp4.localPath}.`, now),
      ];
      await this.writeRecord(record);

      return { status: 201, data: existingMp4 };
    }

    if (dto.target === "pdf" && job.creationType !== "memoir_video") {
      const bookJobId = record.linkedBookJobs?.[jobId];
      if (bookJobId) {
        const exported = await this.tryExportBookPdf(bookJobId, dto.targetPath);
        if (exported.ok === false) {
          return {
            status: 500,
            data: { message: exported.message },
          };
        }
        const artifact: CreationArtifact = {
          artifactId: exported.artifactId,
          kind: "pdf",
          jobId,
          localPath: exported.localPath,
          createdAt: now,
        };
        const nextJob = this.withTerminalStep({
          ...job,
          status: "exported",
          artifacts: [...job.artifacts, artifact],
          updatedAt: now,
        });
        record.jobs[jobId] = nextJob;
        record.events[jobId] = [
          ...(record.events[jobId] ?? []),
          this.event(jobId, "export", `Exported PDF through BooksService job ${bookJobId}.`, now),
        ];
        await this.writeRecord(record);

        return { status: 201, data: artifact };
      }
    }

    const artifact: CreationArtifact = {
      artifactId: `artifact_${jobId}_${dto.target}_${Date.now()}`,
      kind: dto.target,
      jobId,
      localPath: dto.targetPath ?? path.join(this.config.config.paths.exportDir, `${jobId}.${dto.target}`),
      createdAt: now,
    };
    const nextJob = this.withTerminalStep({
      ...job,
      status: "exported",
      artifacts: [...job.artifacts, artifact],
      updatedAt: now,
    });
    record.jobs[jobId] = nextJob;
    record.events[jobId] = [
      ...(record.events[jobId] ?? []),
      this.event(jobId, "export", `Exported ${dto.target.toUpperCase()} artifact metadata.`, now),
    ];
    await this.writeRecord(record);

    return { status: 201, data: artifact };
  }

  async shareJob(
    jobId: string,
    dto: ShareCreationJobDto,
  ): Promise<ServiceResult<CreationArtifact | { message: string }>> {
    const record = await this.readRecord();
    const job = record.jobs[jobId];
    if (!job) return { status: 404, data: { message: "Creation job not found." } };
    const source = job.artifacts.find((artifact) => artifact.artifactId === dto.artifactId);
    if (!source) return { status: 404, data: { message: "Creation artifact not found." } };

    const now = new Date().toISOString();
    const share = await this.createShareLink(job, source);
    if (share.ok === false) {
      return {
        status: share.status,
        data: {
          message: share.message,
        },
      };
    }
    const artifact: CreationArtifact = {
      artifactId: `artifact_${jobId}_share_${Date.now()}`,
      kind: "web_share",
      jobId,
      shareId: share.shareId,
      shareUrl: share.shareUrl,
      createdAt: now,
    };
    record.jobs[jobId] = {
      ...job,
      status: "shared",
      artifacts: [...job.artifacts, artifact],
      updatedAt: now,
    };
    record.events[jobId] = [
      ...(record.events[jobId] ?? []),
      this.event(jobId, "share", `Created Web share link for ${source.kind.toUpperCase()} through storage sync.`, now),
    ];
    await this.writeRecord(record);

    return { status: 201, data: artifact };
  }

  private async createShareLink(
    job: CreationJob,
    source: CreationArtifact,
  ): Promise<
    | { ok: true; shareId: string; shareUrl: string }
    | { ok: false; status: number; message: string }
  > {
    if (!source.localPath) {
      return {
        ok: false,
        status: 409,
        message: "Creation artifact has no local file path to share.",
      };
    }
    if (!this.datasetService) {
      return {
        ok: false,
        status: 503,
        message: "Creation share service is not available in this Sidecar runtime.",
      };
    }
    const kind = this.exportArtifactKindFor(source.kind);
    if (!kind) {
      return {
        ok: false,
        status: 422,
        message: "Only PDF and MP4 creation artifacts can be shared.",
      };
    }

    await this.datasetService.recordExportArtifact({
      id: source.artifactId,
      jobId: source.jobId,
      kind,
      localPath: source.localPath,
      storageProvider: "local",
      storageStatus: "local_only",
    });

    const enqueued = await this.datasetService.enqueueExportArtifactStorageSync({
      artifactId: source.artifactId,
      childId: this.storageChildIdFor(job),
    });
    if (!enqueued?.enqueued) {
      const reason = enqueued && "reason" in enqueued ? enqueued.reason : "unknown_error";
      return {
        ok: false,
        status: 502,
        message: `Export artifact could not be queued for storage sync: ${reason}.`,
      };
    }

    await this.datasetService.runStorageSyncWorker({ limit: 10 });
    const metadata = await this.datasetService.getExportArtifactShareMetadata(source.artifactId);
    if (!metadata.ok || !metadata.url) {
      return {
        ok: false,
        status: 502,
        message: metadata.message || "Storage share link could not be created.",
      };
    }

    return {
      ok: true,
      shareId: source.artifactId,
      shareUrl: metadata.url,
    };
  }

  private exportArtifactKindFor(kind: CreationArtifact["kind"]): ExportArtifact["kind"] | undefined {
    if (kind === "pdf" || kind === "mp4") return kind;
    return undefined;
  }

  private storageChildIdFor(job: CreationJob) {
    return `creation-${job.creationType}`;
  }

  private stepsFor(creationType: CreationType, status: CreationStep["status"]): CreationStep[] {
    const generateLabel = creationType === "memoir_video" ? "Generate MP4 with Hyperframes skill" : "Generate PDF draft";
    return [
      { stepId: "compose", label: "Compose selected assets", status },
      { stepId: "plan", label: "Confirm persisted agent plan", status },
      { stepId: "generate", label: generateLabel, status },
      { stepId: "review", label: "Review generated artifact", status },
      { stepId: "publish", label: "Export and share", status },
    ];
  }

  private normalizePlannedSteps(steps: CreationStep[]): CreationStep[] {
    return steps.map((step) => ({
      ...step,
      status: step.status ?? "pending",
    }));
  }

  private withTerminalStep(job: CreationJob): CreationJob {
    return {
      ...job,
      currentStepId: "publish",
      steps: job.steps.map((step) => ({ ...step, status: "succeeded" })),
    };
  }

  private skillNameFor(creationType: CreationType) {
    if (creationType === "memoir_video") return "Hyperframes skill";
    if (creationType === "memory_book") return "KidMemory memory book";
    return "KidMemory storybook";
  }

  private summaryFor(creationType: CreationType, goal: string, assetCount: number) {
    const output = creationType === "memoir_video" ? "MP4 video" : "PDF";
    return `Create a ${output} from ${assetCount} selected assets for: ${goal}`;
  }

  private requirementsFor(creationType: CreationType) {
    if (creationType === "memoir_video") {
      return {
        minAssets: 3,
        recommendedAssets: 8,
        needsCloudImage: false,
        needsHyperframes: true,
        needsFfmpeg: true,
      };
    }
    if (creationType === "memory_book") {
      return {
        minAssets: 1,
        recommendedAssets: 8,
        needsCloudImage: true,
        needsHyperframes: false,
        needsFfmpeg: false,
      };
    }
    return {
      minAssets: 1,
      recommendedAssets: 6,
      needsCloudImage: true,
      needsHyperframes: false,
      needsFfmpeg: false,
    };
  }

  private requirementItemsFor(creationType: CreationType) {
    if (creationType === "memoir_video") {
      return ["Selected assets", "Hyperframes skill runtime", "FFmpeg available or auto-repaired"];
    }
    return ["Selected assets", "OpenAI Agent SDK configuration", "Local export directory"];
  }

  private runningDetailFor(creationType: CreationType) {
    if (creationType === "memoir_video") return "Preparing video generation environment and running Hyperframes skill steps.";
    return "Preparing PDF generation through the existing book skill path.";
  }

  private async tryCreateBookJob(plan: CreationPlan): Promise<{ ok: true; bookJobId: string } | { ok: false; message: string }> {
    try {
      const result = await this.booksService.createJob({
        assetIds: plan.assetIds,
        goal: plan.goal,
      });
      const data = this.resultData(result);
      if (data && typeof data === "object" && typeof data.id === "string" && data.status !== "failed") {
        return { ok: true, bookJobId: data.id };
      }
      return { ok: false, message: this.messageFromResult(result, "BooksService did not return a generated book job.") };
    } catch (error) {
      return { ok: false, message: error instanceof Error ? error.message : "Unknown BooksService generation error." };
    }
  }

  private async tryExportBookPdf(
    bookJobId: string,
    targetPath?: string,
  ): Promise<{ ok: true; artifactId: string; localPath: string } | { ok: false; message: string }> {
    try {
      const result = await this.booksService.exportPdf(bookJobId, targetPath ? { targetPath } : {});
      const data = this.resultData(result);
      const artifact = data?.artifact;
      const exported = data?.exported;
      if (
        artifact &&
        typeof artifact === "object" &&
        typeof artifact.id === "string" &&
        typeof artifact.localPath === "string"
      ) {
        return { ok: true, artifactId: artifact.id, localPath: artifact.localPath };
      }
      if (exported && typeof exported === "object" && exported.ok === true && typeof exported.path === "string") {
        return {
          ok: true,
          artifactId: `artifact_${bookJobId}_pdf_${Date.now()}`,
          localPath: exported.path,
        };
      }
      return { ok: false, message: this.messageFromResult(result, "BooksService PDF export did not return an artifact.") };
    } catch (error) {
      return { ok: false, message: error instanceof Error ? error.message : "Unknown BooksService export error." };
    }
  }

  private async tryRenderMemoirVideo(
    plan: CreationPlan,
    jobId: string,
  ): Promise<
    | { ok: true; artifactId: string; localPath: string; repairMessage?: string }
    | { ok: false; message: string; category: "hyperframes" | "environment"; code?: string; repairMessage?: string }
  > {
    try {
      const input = {
        projectId: jobId,
        prompt: plan.goal,
      };
      const first = await this.renderMemoirVideoOnce(input, jobId);
      if (first.ok === true) return first;

      if (this.shouldRepairFfmpeg(first.code)) {
        const repaired = await this.repairFfmpeg();
        if (repaired.ok) {
          const retry = await this.renderMemoirVideoOnce(input, jobId);
          if (retry.ok === true) {
            return { ...retry, repairMessage: repaired.message };
          }
          return { ...retry, repairMessage: repaired.message };
        }
        return {
          ok: false,
          message: repaired.message,
          category: "environment",
          code: repaired.code ?? "FFMPEG_REPAIR_FAILED",
          repairMessage: repaired.message,
        };
      }

      return first;
    } catch (error) {
      return {
        ok: false,
        message: error instanceof Error ? error.message : "Unknown Hyperframes generation error.",
        category: "hyperframes",
      };
    }
  }

  private async renderMemoirVideoOnce(
    input: { projectId: string; prompt: string },
    jobId: string,
  ): Promise<
    | { ok: true; artifactId: string; localPath: string }
    | { ok: false; message: string; category: "hyperframes" | "environment"; code?: string }
  > {
    const result = await this.skillRuntime.execute({
      skillId: "hyperframes",
      tool: "render_hyperframes_video",
      arguments: input,
      traceId: `creation_${jobId}`,
    });
    const data = this.resultData(result)?.toolResult ?? this.resultData(result);
    const outputPath = this.hyperframesOutputPath(data);
    if (data && typeof data === "object" && data.ok === true && outputPath) {
      return {
        ok: true,
        artifactId: `artifact_${jobId}_mp4_${Date.now()}`,
        localPath: outputPath,
      };
    }

    const code = data && typeof data === "object" && typeof data.code === "string" ? data.code : undefined;
    return {
      ok: false,
      message: this.messageFromResult(result, "Hyperframes did not return an MP4 artifact."),
      category: this.hyperframesFailureCategory(code),
      code,
    };
  }

  private async repairFfmpeg() {
    if (!this.ffmpegRepairService) {
      return {
        ok: false,
        code: "FFMPEG_REPAIR_UNAVAILABLE",
        message: "FFmpeg repair service is not available in this Sidecar runtime.",
      };
    }
    return this.ffmpegRepairService.repair();
  }

  private hyperframesOutputPath(data: unknown) {
    if (!data || typeof data !== "object") return undefined;
    const record = data as Record<string, unknown>;
    for (const key of ["localPath", "outputPath", "path"]) {
      const value = record[key];
      if (typeof value === "string" && value.trim().length > 0) return value;
    }
    const artifact = record.artifact;
    if (artifact && typeof artifact === "object") {
      const localPath = (artifact as { localPath?: unknown }).localPath;
      if (typeof localPath === "string" && localPath.trim().length > 0) return localPath;
    }
    return undefined;
  }

  private hyperframesFailureCategory(code?: string): "hyperframes" | "environment" {
    if (!code) return "hyperframes";
    return code.includes("FFMPEG") || code.includes("NOT_CONFIGURED") ? "environment" : "hyperframes";
  }

  private shouldRepairFfmpeg(code?: string) {
    return typeof code === "string" && code.includes("FFMPEG");
  }

  private resultData(result: unknown): any {
    if (result && typeof result === "object" && "data" in result) {
      return (result as { data?: unknown }).data as any;
    }
    return result as any;
  }

  private messageFromResult(result: unknown, fallback: string) {
    const data = this.resultData(result);
    if (data && typeof data === "object" && typeof data.message === "string") return data.message;
    if (data && typeof data === "object" && data.runner && typeof data.runner.message === "string") {
      return data.runner.message;
    }
    return fallback;
  }

  private statusFromResult(result: unknown, fallback: number) {
    if (result && typeof result === "object" && "status" in result) {
      const status = (result as { status?: unknown }).status;
      if (typeof status === "number") return status;
    }
    return fallback;
  }

  private event(
    jobId: string,
    type: CreationEvent["type"],
    message: string,
    createdAt: string,
    stepId?: string,
  ): CreationEvent {
    return {
      eventId: `event_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`,
      jobId,
      stepId,
      type,
      message,
      createdAt,
    };
  }

  private async readRecord(): Promise<CreationRecord> {
    try {
      const raw = await fs.readFile(this.storePath, "utf8");
      return JSON.parse(raw) as CreationRecord;
    } catch (error) {
      if (error && typeof error === "object" && "code" in error && (error as { code: string }).code === "ENOENT") {
        return { plans: {}, jobs: {}, events: {}, linkedBookJobs: {} };
      }
      throw error;
    }
  }

  private async writeRecord(record: CreationRecord) {
    await fs.mkdir(path.dirname(this.storePath), { recursive: true });
    await fs.writeFile(this.storePath, JSON.stringify(record, null, 2));
  }

  private get storePath() {
    return path.join(this.config.config.paths.dataDir, "creation", "state.json");
  }
}
