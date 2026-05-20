import "reflect-metadata";

import assert from "node:assert/strict";
import test from "node:test";

import { Module, type INestApplication } from "@nestjs/common";
import { NestFactory } from "@nestjs/core";

import { ApiResponseInterceptor } from "../../src/infrastructure/http/api-response.interceptor.ts";
import { GlobalExceptionFilter } from "../../src/infrastructure/http/global-exception.filter.ts";
import { AppConfigService } from "../../src/infrastructure/config/app-config.service.ts";
import { BooksService } from "../../src/modules/books/books.service.ts";
import { CreationController } from "../../src/modules/creation/creation.controller.ts";
import { CreationPlanningService } from "../../src/modules/creation/creation-planning.service.ts";
import { CreationService } from "../../src/modules/creation/creation.service.ts";
import { DatasetService } from "../../src/modules/dataset/dataset.service.ts";
import { FfmpegRepairService } from "../../src/modules/media/ffmpeg-repair.service.ts";
import { HyperframesRenderService } from "../../src/modules/media/hyperframes-render.service.ts";
import { SkillRuntimeService } from "../../src/modules/skills/skill-runtime.service.ts";
import { assertObject, assertString, requestJson } from "./backend-contract-client.ts";

type TestServer = {
  app: INestApplication;
  baseUrl: string;
};

class CreationContractTestModule {}

Module({
  controllers: [CreationController],
  providers: [
    CreationService,
    {
      provide: AppConfigService,
      useValue: {
        config: {
          paths: {
            dataDir: ".kidmemory/contract-test-data",
            exportDir: ".kidmemory/contract-test-exports",
            workspaceDir: ".kidmemory/contract-test-workspace",
          },
          sidecar: {
            webCompanionBaseUrl: "http://localhost:3001",
          },
        },
      },
    },
    {
      provide: BooksService,
      useValue: {
        async createJob(body: Record<string, unknown>) {
          return {
            status: 200,
            data: {
              id: `book_contract_${Date.now()}`,
              status: "generated",
              selectedAssetIds: body.assetIds,
            },
          };
        },
        async exportPdf(jobId: string) {
          return {
            status: 200,
            data: {
              exported: { ok: true, path: `.kidmemory/contract-test-exports/${jobId}.pdf` },
              artifact: {
                id: `artifact_${jobId}_pdf`,
                kind: "pdf",
                localPath: `.kidmemory/contract-test-exports/${jobId}.pdf`,
                storageStatus: "local_only",
              },
            },
          };
        },
        async getPreviewHtml(jobId: string) {
          return {
            status: 200,
            html: `<html><body>Contract preview for ${jobId}</body></html>`,
          };
        },
      },
    },
    {
      provide: HyperframesRenderService,
      useValue: {
        async render() {
          return {
            ok: false,
            code: "HYPERFRAMES_NOT_CONFIGURED",
            message: "Hyperframes renderer is not configured in contract tests.",
          };
        },
      },
    },
    {
      provide: SkillRuntimeService,
      useValue: {
        async execute() {
          return {
            ok: false,
            code: "SKILL_RUNTIME_NOT_USED",
            message: "Skill runtime is not used for storybook contract tests.",
          };
        },
      },
    },
    {
      provide: FfmpegRepairService,
      useValue: {
        async repair() {
          return { ok: false, code: "FFMPEG_REPAIR_SKIPPED", message: "Not used in contract tests." };
        },
      },
    },
    {
      provide: CreationPlanningService,
      useValue: {
        async createPlan(input: Record<string, unknown>) {
          return {
            ok: true,
            summary: `Contract plan for ${input.creationType}`,
            skillName: "KidMemory storybook",
            steps: [
              { stepId: "compose", label: "Compose selected assets", detail: "Contract planning step." },
              { stepId: "generate", label: "Generate PDF draft", detail: "Contract generation step." },
            ],
            requirements: ["Selected assets", "OpenAI Agent SDK configuration"],
          };
        },
      },
    },
    {
      provide: DatasetService,
      useValue: {
        async recordExportArtifact(input: Record<string, unknown>) {
          return input;
        },
        async enqueueExportArtifactStorageSync() {
          return { enqueued: true, jobId: "contract-storage-sync" };
        },
        async runStorageSyncWorker() {
          return { processed: 1, succeeded: 1, retried: 0, failed: 0, skipped: 0 };
        },
        async getExportArtifactShareMetadata(artifactId: string) {
          return {
            ok: true,
            url: `https://signed.example.test/${artifactId}?token=contract`,
            text: "KidMemory 作品集",
          };
        },
      },
    },
  ],
})(CreationContractTestModule);

async function startCreationContractServer(): Promise<TestServer> {
  const app = await NestFactory.create(CreationContractTestModule, { logger: false });
  app.useGlobalFilters(new GlobalExceptionFilter());
  app.useGlobalInterceptors(new ApiResponseInterceptor());
  await app.listen(0, "127.0.0.1");
  const address = app.getHttpServer().address();
  if (!address || typeof address !== "object") {
    throw new Error("Could not determine creation contract test server address.");
  }
  return {
    app,
    baseUrl: `http://127.0.0.1:${address.port}`,
  };
}

function unwrapData(body: unknown): Record<string, unknown> {
  assertObject(body);
  assert.equal(body.code, 0);
  assertString(body.msg);
  assertObject(body.data);
  return body.data;
}

test("creation contract: plan, job detail, events, export, and share routes are registered", async (t) => {
  const { app, baseUrl } = await startCreationContractServer();
  t.after(async () => {
    await app.close();
  });

  const planResponse = await requestJson(baseUrl, "/creation/jobs/plan", {
    method: "POST",
    body: JSON.stringify({
      goal: "为本周手工作品做一本睡前故事绘本",
      creationType: "storybook",
      assetIds: ["asset_contract_001", "asset_contract_002"],
      settings: { tone: "warm" },
    }),
  });
  assert.equal(planResponse.status, 201);
  const plan = unwrapData(planResponse.body);
  assertString(plan.planId);
  assert.equal(plan.creationType, "storybook");
  assertString(plan.summary);
  assertString(plan.skillName);
  assert.ok(Array.isArray(plan.steps), "plan should include ordered steps");
  assertObject(plan.requirements);
  assert.equal(plan.requirements.minAssets, 1);
  assert.equal(plan.requirements.recommendedAssets, 6);
  assert.equal(plan.requirements.needsCloudImage, true);
  assert.equal(plan.requirements.needsHyperframes, false);
  assert.equal(plan.requirements.needsFfmpeg, false);
  assert.ok(Array.isArray(plan.requirementItems), "plan should include display requirement items");

  const createResponse = await requestJson(baseUrl, "/creation/jobs", {
    method: "POST",
    body: JSON.stringify({ planId: plan.planId }),
  });
  assert.equal(createResponse.status, 201);
  const created = unwrapData(createResponse.body);
  assertString(created.jobId);
  assert.equal(created.planId, plan.planId);
  assert.equal(created.creationType, "storybook");
  assertString(created.status);
  assert.ok(Array.isArray(created.steps), "created job should expose backend steps");

  const detailResponse = await requestJson(baseUrl, `/creation/jobs/${created.jobId}`, { method: "GET" });
  assert.equal(detailResponse.status, 200);
  const detail = unwrapData(detailResponse.body);
  assert.equal(detail.jobId, created.jobId);
  assert.equal(detail.planId, plan.planId);
  assert.equal(detail.creationType, "storybook");
  assert.ok("currentStepId" in detail, "detail should include currentStepId");
  assert.ok(Array.isArray(detail.steps), "detail should include steps");
  assert.ok(Array.isArray(detail.artifacts), "detail should include artifacts");
  assert.ok("error" in detail, "detail should include error");

  const eventsResponse = await requestJson(baseUrl, `/creation/jobs/${created.jobId}/events`, { method: "GET" });
  assert.equal(eventsResponse.status, 200);
  const events = unwrapData(eventsResponse.body);
  assert.ok(Array.isArray(events.events), "events payload should include events array");

  const previewResponse = await fetch(`${baseUrl}/creation/jobs/${created.jobId}/preview`);
  assert.equal(previewResponse.status, 200);
  assert.match(previewResponse.headers.get("content-type") ?? "", /html/);
  assert.match(await previewResponse.text(), /Contract preview/);

  const exportResponse = await requestJson(baseUrl, `/creation/jobs/${created.jobId}/export`, {
    method: "POST",
    body: JSON.stringify({ target: "pdf" }),
  });
  assert.equal(exportResponse.status, 201);
  const exported = unwrapData(exportResponse.body);
  assertString(exported.artifactId);
  assert.equal(exported.kind, "pdf");

  const shareResponse = await requestJson(baseUrl, `/creation/jobs/${created.jobId}/share`, {
    method: "POST",
    body: JSON.stringify({ artifactId: exported.artifactId }),
  });
  assert.equal(shareResponse.status, 201);
  const shared = unwrapData(shareResponse.body);
  assertString(shared.shareId);
  assertString(shared.shareUrl);
});

test("creation contract: invalid creation type fails before a plan is persisted", async (t) => {
  const { app, baseUrl } = await startCreationContractServer();
  t.after(async () => {
    await app.close();
  });

  const response = await requestJson(baseUrl, "/creation/jobs/plan", {
    method: "POST",
    body: JSON.stringify({
      goal: "做一个相册",
      creationType: "album",
      assetIds: ["asset_contract_001"],
    }),
  });

  assert.equal(response.status, 400);
  assertObject(response.body);
  assert.notEqual(response.body.code, 0);
  assertString(response.body.msg);
});
