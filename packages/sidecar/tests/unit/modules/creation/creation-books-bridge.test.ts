import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";

import { formatOpenAIAgentPlanningError } from "../../../../src/modules/creation/creation-planning.service.ts";
import { CreationService } from "../../../../src/modules/creation/creation.service.ts";

test("creation service bridges storybook jobs to existing BooksService PDF generation and export", async () => {
  const root = await fs.mkdtemp(
    path.join(os.tmpdir(), "kidmemory-creation-books-"),
  );
  const exportDir = path.join(root, "exports");
  const dataDir = path.join(root, "data");
  const exportedPdfPath = path.join(exportDir, "storybook.pdf");
  const calls: Array<{ method: string; body?: unknown; jobId?: string }> = [];
  const shareCalls: Array<{ method: string; input?: any }> = [];
  const datasetService = {
    async recordExportArtifact(input: any) {
      shareCalls.push({ method: "recordExportArtifact", input });
      return input;
    },
    async enqueueExportArtifactStorageSync(input: any) {
      shareCalls.push({ method: "enqueueExportArtifactStorageSync", input });
      return { enqueued: true, jobId: "storage-sync-1" };
    },
    async runStorageSyncWorker(input: any) {
      shareCalls.push({ method: "runStorageSyncWorker", input });
      return { processed: 1, succeeded: 1, retried: 0, failed: 0, skipped: 0 };
    },
    async getExportArtifactShareMetadata(artifactId: string) {
      shareCalls.push({
        method: "getExportArtifactShareMetadata",
        input: { artifactId },
      });
      return {
        ok: true,
        url: `https://signed.example.test/${artifactId}?token=abc`,
        text: "KidMemory 作品集",
      };
    },
  };
  const booksService = {
    async createJob(body: Record<string, unknown>) {
      calls.push({ method: "createJob", body });
      return {
        status: 200,
        data: {
          id: "book_job_1",
          status: "generated",
          selectedAssetIds: body.assetIds,
        },
      };
    },
    async exportPdf(jobId: string, body: Record<string, unknown>) {
      calls.push({ method: "exportPdf", jobId, body });
      await fs.mkdir(exportDir, { recursive: true });
      await fs.writeFile(exportedPdfPath, "%PDF-1.7\n% KidMemory test\n");
      return {
        status: 200,
        data: {
          exported: { ok: true, path: exportedPdfPath },
          artifact: {
            id: "artifact_book_pdf",
            kind: "pdf",
            localPath: exportedPdfPath,
            storageStatus: "local_only",
          },
        },
      };
    },
    async getPreviewHtml(jobId: string) {
      calls.push({ method: "getPreviewHtml", jobId });
      return {
        status: 200,
        html: `<html><body>preview for ${jobId}</body></html>`,
      };
    },
  };
  const service = new CreationService(
    {
      config: {
        paths: {
          dataDir,
          exportDir,
          workspaceDir: path.join(root, "workspace"),
        },
        sidecar: {
          webCompanionBaseUrl: "http://localhost:3001",
        },
      },
    } as any,
    booksService as any,
    {
      execute: async () => ({ ok: false, code: "UNUSED", message: "not used" }),
    } as any,
    undefined,
    undefined,
    datasetService as any,
  );

  const plan = await service.createPlan({
    goal: "为春游照片做一本绘本",
    creationType: "storybook",
    assetIds: ["asset-1", "asset-2"],
  });
  assert.equal(plan.status, 201);
  assert.ok("planId" in plan.data);

  const created = await service.createJob({ planId: plan.data.planId });
  assert.equal(created.status, 201);
  assert.ok("jobId" in created.data);
  assert.equal(created.data.status, "succeeded");
  assert.equal(created.data.currentStepId, "review");
  assert.equal(calls[0]?.method, "createJob");
  assert.deepEqual((calls[0]?.body as any).assetIds, ["asset-1", "asset-2"]);

  const exported = await service.exportJob(created.data.jobId, {
    target: "pdf",
    targetPath: exportedPdfPath,
  });
  assert.equal(exported.status, 201);
  assert.ok("artifactId" in exported.data);
  assert.equal(exported.data.artifactId, "artifact_book_pdf");
  assert.equal(exported.data.kind, "pdf");
  assert.equal(exported.data.localPath, exportedPdfPath);
  assert.equal(calls[1]?.method, "exportPdf");
  assert.equal(calls[1]?.jobId, "book_job_1");

  const stored = await service.getJob(created.data.jobId);
  assert.equal(stored.status, 200);
  assert.ok("artifacts" in stored.data);
  assert.equal(stored.data.status, "exported");
  assert.equal(stored.data.artifacts[0]?.localPath, exportedPdfPath);

  const preview = await service.getPreviewHtml(created.data.jobId);
  assert.equal(preview.status, 200);
  assert.ok("html" in preview);
  assert.match(preview.html, /preview for book_job_1/);
  assert.equal(calls[2]?.method, "getPreviewHtml");
  assert.equal(calls[2]?.jobId, "book_job_1");

  const shared = await service.shareJob(created.data.jobId, {
    artifactId: exported.data.artifactId,
  });
  assert.equal(shared.status, 201);
  assert.ok("shareUrl" in shared.data);
  assert.equal(shared.data.shareId, "artifact_book_pdf");
  assert.equal(
    shared.data.shareUrl,
    "https://signed.example.test/artifact_book_pdf?token=abc",
  );
  assert.equal(shareCalls[0]?.method, "recordExportArtifact");
  assert.equal(shareCalls[0]?.input.kind, "pdf");
  assert.equal(shareCalls[0]?.input.localPath, exportedPdfPath);
  assert.equal(shareCalls[1]?.method, "enqueueExportArtifactStorageSync");
  assert.equal(shareCalls[1]?.input.childId, "creation-storybook");
});

test("creation service creates plans through the OpenAI Agents planning boundary when available", async () => {
  const root = await fs.mkdtemp(
    path.join(os.tmpdir(), "kidmemory-creation-agent-plan-"),
  );
  const planningCalls: Array<Record<string, unknown>> = [];
  const service = new CreationService(
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
        throw new Error("BooksService should not be used while planning.");
      },
      async exportPdf() {
        throw new Error("BooksService should not be used while planning.");
      },
    } as any,
    {
      execute: async () => ({ ok: false, code: "UNUSED", message: "not used" }),
    } as any,
    undefined,
    {
      async createPlan(input: Record<string, unknown>) {
        planningCalls.push(input);
        return {
          ok: true,
          summary: "Agent planned an 8-page spring outing storybook.",
          skillName: "KidMemory storybook",
          steps: [
            {
              stepId: "compose",
              label: "整理素材",
              detail: "挑选春游照片和画作",
            },
            {
              stepId: "generate",
              label: "生成绘本 PDF",
              detail: "调用现有绘本 Skill",
            },
          ],
          requirements: ["Selected assets", "OpenAI Agent SDK configuration"],
        };
      },
    } as any,
  );

  const plan = await service.createPlan({
    goal: "为春游照片做一本绘本",
    creationType: "storybook",
    assetIds: ["asset-1", "asset-2"],
  });

  assert.equal(plan.status, 201);
  assert.ok("planId" in plan.data);
  assert.equal(
    plan.data.summary,
    "Agent planned an 8-page spring outing storybook.",
  );
  assert.equal(plan.data.skillName, "KidMemory storybook");
  assert.equal(plan.data.steps[0]?.label, "整理素材");
  assert.equal(plan.data.steps[0]?.status, "pending");
  assert.deepEqual(plan.data.requirements, {
    minAssets: 1,
    recommendedAssets: 6,
    needsCloudImage: true,
    needsHyperframes: false,
    needsFfmpeg: false,
  });
  assert.deepEqual(plan.data.requirementItems, ["Selected assets", "OpenAI Agent SDK configuration"]);
  assert.deepEqual(planningCalls, [
    {
      goal: "为春游照片做一本绘本",
      creationType: "storybook",
      assetIds: ["asset-1", "asset-2"],
    },
  ]);
});

test("creation service reports Agent planning failures before persisting a plan", async () => {
  const root = await fs.mkdtemp(
    path.join(os.tmpdir(), "kidmemory-creation-agent-plan-fail-"),
  );
  const service = new CreationService(
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
    {} as any,
    {
      execute: async () => ({ ok: false, code: "UNUSED", message: "not used" }),
    } as any,
    undefined,
    {
      async createPlan() {
        return {
          ok: false,
          code: "OPENAI_AGENT_PLAN_FAILED",
          message: "OpenAI Agents SDK runner failed while planning.",
        };
      },
    } as any,
  );

  const plan = await service.createPlan({
    goal: "生成成长纪念册",
    creationType: "memory_book",
    assetIds: ["asset-1"],
  });

  assert.equal(plan.status, 500);
  assert.ok("message" in plan.data);
  assert.match(plan.data.message, /OpenAI Agents SDK runner failed/);
  const statePath = path.join(root, "data", "creation", "state.json");
  await assert.rejects(fs.readFile(statePath, "utf8"), /ENOENT/);
});

test("creation planning formats unsupported OpenAI-compatible endpoint errors for users", () => {
  const message = formatOpenAIAgentPlanningError(
    new Error(
      "404 <html>\r\n<head><title>404 Not Found</title></head>\r\n<body>\r\n<center><h1>404 Not Found</h1></center>\r\n<hr><center>openresty</center>\r\n</body>\r\n</html>",
    ),
  );

  assert.match(message, /HTTP 404/);
  assert.match(message, /Responses API/);
  assert.doesNotMatch(message, /<html/i);
  assert.doesNotMatch(message, /openresty/i);
});
