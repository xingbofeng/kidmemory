import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";

import { CreationService } from "../../../../src/modules/creation/creation.service.ts";

function createService(
  root: string,
  skillRuntime: { execute(input: Record<string, unknown>): Promise<unknown> },
  ffmpegRepairService?: { repair(): Promise<{ ok: boolean; message: string; code?: string }> },
  datasetService?: Record<string, unknown>,
) {
  return new CreationService(
    {
      config: {
        paths: {
          dataDir: path.join(root, "data"),
          exportDir: path.join(root, "exports"),
          workspaceDir: path.join(root, "workspace"),
        },
        sidecar: {
          webCompanionBaseUrl: "http://localhost:3001",
        },
      },
    } as any,
    {
      async createJob() {
        throw new Error("BooksService should not be used for memoir_video jobs.");
      },
      async exportPdf() {
        throw new Error("BooksService should not be used for memoir_video jobs.");
      },
    } as any,
    skillRuntime as any,
    ffmpegRepairService as any,
    undefined,
    datasetService as any,
  );
}

test("creation service bridges memoir video jobs to Hyperframes MP4 generation and export", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-creation-hyperframes-"));
  const mp4Path = path.join(root, "exports", "memoir.mp4");
  const calls: Array<Record<string, unknown>> = [];
  const shareCalls: Array<{ method: string; input?: any }> = [];
  const service = createService(
    root,
    {
      async execute(input: Record<string, unknown>) {
        calls.push(input);
        await fs.mkdir(path.dirname(mp4Path), { recursive: true });
        await fs.writeFile(mp4Path, "kidmemory mp4 test");
        return {
          ok: true,
          toolResult: {
            ok: true,
            localPath: mp4Path,
          },
        };
      },
    },
    undefined,
    {
      async recordExportArtifact(input: any) {
        shareCalls.push({ method: "recordExportArtifact", input });
        return input;
      },
      async enqueueExportArtifactStorageSync(input: any) {
        shareCalls.push({ method: "enqueueExportArtifactStorageSync", input });
        return { enqueued: true, jobId: "storage-sync-mp4" };
      },
      async runStorageSyncWorker(input: any) {
        shareCalls.push({ method: "runStorageSyncWorker", input });
        return { processed: 1, succeeded: 1, retried: 0, failed: 0, skipped: 0 };
      },
      async getExportArtifactShareMetadata(artifactId: string) {
        shareCalls.push({ method: "getExportArtifactShareMetadata", input: { artifactId } });
        return {
          ok: true,
          url: `https://signed.example.test/${artifactId}.mp4?token=abc`,
          text: "KidMemory 回忆视频",
        };
      },
    },
  );

  const plan = await service.createPlan({
    goal: "把春游照片做成温暖的回忆视频",
    creationType: "memoir_video",
    assetIds: ["asset-1", "asset-2", "asset-3"],
  });
  assert.equal(plan.status, 201);
  assert.ok("planId" in plan.data);

  const created = await service.createJob({ planId: plan.data.planId });
  assert.equal(created.status, 201);
  assert.ok("jobId" in created.data);
  assert.equal(created.data.creationType, "memoir_video");
  assert.equal(created.data.status, "succeeded");
  assert.equal(created.data.currentStepId, "review");
  assert.equal(created.data.artifacts[0]?.kind, "mp4");
  assert.equal(created.data.artifacts[0]?.localPath, mp4Path);
  assert.equal(calls.length, 1);
  assert.equal(calls[0]?.skillId, "hyperframes");
  assert.equal(calls[0]?.tool, "render_hyperframes_video");
  assert.equal((calls[0]?.arguments as Record<string, unknown>)?.prompt, "把春游照片做成温暖的回忆视频");

  const exported = await service.exportJob(created.data.jobId, { target: "mp4" });
  assert.equal(exported.status, 201);
  assert.ok("artifactId" in exported.data);
  assert.equal(exported.data.kind, "mp4");
  assert.equal(exported.data.localPath, mp4Path);

  const stored = await service.getJob(created.data.jobId);
  assert.equal(stored.status, 200);
  assert.ok("status" in stored.data);
  assert.equal(stored.data.status, "exported");

  const shared = await service.shareJob(created.data.jobId, {
    artifactId: exported.data.artifactId,
  });
  assert.equal(shared.status, 201);
  assert.ok("shareUrl" in shared.data);
  assert.equal(shared.data.shareUrl, `${"https://signed.example.test/"}${exported.data.artifactId}.mp4?token=abc`);
  assert.equal(shareCalls[0]?.input.kind, "mp4");
  assert.equal(shareCalls[0]?.input.localPath, mp4Path);
  assert.equal(shareCalls[1]?.input.childId, "creation-memoir_video");
});

test("creation service reports Hyperframes environment failures as failed memoir video jobs", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-creation-hyperframes-fail-"));
  const service = createService(root, {
    async execute() {
      return {
        toolResult: {
          ok: false,
          recoverable: true,
          code: "HYPERFRAMES_NOT_CONFIGURED",
          message: "Hyperframes renderer is not configured. Set HYPERFRAMES_RENDER_COMMAND to enable rendering.",
        },
      };
    },
  });

  const plan = await service.createPlan({
    goal: "生成生日派对回忆视频",
    creationType: "memoir_video",
    assetIds: ["asset-1"],
  });
  assert.equal(plan.status, 201);
  assert.ok("planId" in plan.data);

  const created = await service.createJob({ planId: plan.data.planId });
  assert.equal(created.status, 201);
  assert.ok("jobId" in created.data);
  assert.equal(created.data.status, "failed");
  assert.equal(created.data.currentStepId, "generate");
  assert.equal(created.data.error?.category, "environment");
  assert.equal(created.data.error?.code, "HYPERFRAMES_NOT_CONFIGURED");
  assert.equal(created.data.steps.find((step) => step.stepId === "generate")?.status, "failed");

  const exported = await service.exportJob(created.data.jobId, { target: "mp4" });
  assert.equal(exported.status, 409);
  assert.ok("message" in exported.data);
  assert.match(exported.data.message, /MP4 artifact is not available/);
});

test("creation service auto-repairs missing FFmpeg and retries memoir video rendering once", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-creation-hyperframes-repair-"));
  const mp4Path = path.join(root, "exports", "memoir-repaired.mp4");
  const renderCalls: Array<Record<string, unknown>> = [];
  let repairCalls = 0;
  const service = createService(
    root,
    {
      async execute(input: Record<string, unknown>) {
        renderCalls.push(input);
        if (renderCalls.length === 1) {
          return {
            toolResult: {
              ok: false,
              recoverable: true,
              code: "FFMPEG_NOT_FOUND",
              message: "FFmpeg was not found on PATH.",
            },
          };
        }
        await fs.mkdir(path.dirname(mp4Path), { recursive: true });
        await fs.writeFile(mp4Path, "kidmemory repaired mp4 test");
        return {
          toolResult: {
            ok: true,
            localPath: mp4Path,
          },
        };
      },
    },
    {
      async repair() {
        repairCalls += 1;
        return { ok: true, message: "FFmpeg installed by setup runner." };
      },
    },
  );

  const plan = await service.createPlan({
    goal: "把生日照片做成回忆视频",
    creationType: "memoir_video",
    assetIds: ["asset-1", "asset-2"],
  });
  assert.equal(plan.status, 201);
  assert.ok("planId" in plan.data);

  const created = await service.createJob({ planId: plan.data.planId });
  assert.equal(created.status, 201);
  assert.ok("jobId" in created.data);
  assert.equal(created.data.status, "succeeded");
  assert.equal(created.data.artifacts[0]?.kind, "mp4");
  assert.equal(created.data.artifacts[0]?.localPath, mp4Path);
  assert.equal(renderCalls.length, 2);
  assert.equal(repairCalls, 1);

  const events = await service.getEvents(created.data.jobId);
  assert.equal(events.status, 200);
  assert.ok("events" in events.data);
  assert.ok(events.data.events.some((event) => event.message.includes("FFmpeg installed by setup runner.")));
});

test("creation service reports FFmpeg repair failure without retrying indefinitely", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-creation-hyperframes-repair-fail-"));
  let renderCalls = 0;
  let repairCalls = 0;
  const service = createService(
    root,
    {
      async execute() {
        renderCalls += 1;
        return {
          toolResult: {
            ok: false,
            recoverable: true,
            code: "FFMPEG_NOT_FOUND",
            message: "FFmpeg was not found on PATH.",
          },
        };
      },
    },
    {
      async repair() {
        repairCalls += 1;
        return {
          ok: false,
          code: "FFMPEG_REPAIR_FAILED",
          message: "Homebrew could not install FFmpeg.",
        };
      },
    },
  );

  const plan = await service.createPlan({
    goal: "生成春游回忆视频",
    creationType: "memoir_video",
    assetIds: ["asset-1"],
  });
  assert.equal(plan.status, 201);
  assert.ok("planId" in plan.data);

  const created = await service.createJob({ planId: plan.data.planId });
  assert.equal(created.status, 201);
  assert.ok("jobId" in created.data);
  assert.equal(created.data.status, "failed");
  assert.equal(created.data.error?.category, "environment");
  assert.equal(created.data.error?.code, "FFMPEG_REPAIR_FAILED");
  assert.match(created.data.error?.message ?? "", /Homebrew could not install FFmpeg/);
  assert.equal(renderCalls, 1);
  assert.equal(repairCalls, 1);
});
