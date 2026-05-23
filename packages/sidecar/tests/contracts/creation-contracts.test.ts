import "reflect-metadata";

import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { Module, type INestApplication } from "@nestjs/common";
import { NestFactory } from "@nestjs/core";

import { ApiResponseInterceptor } from "../../src/infrastructure/http/api-response.interceptor.ts";
import { GlobalExceptionFilter } from "../../src/infrastructure/http/global-exception.filter.ts";
import { AppConfigService } from "../../src/infrastructure/config/app-config.service.ts";
import { PrismaService } from "../../src/infrastructure/database/prisma.service.ts";
import { AgentRuntimeService } from "../../src/modules/agent-runtime/agent-runtime.service.ts";
import { CreationController } from "../../src/modules/creation/creation.controller.ts";
import { CreationService } from "../../src/modules/creation/creation.service.ts";
import { DatasetService } from "../../src/modules/dataset/dataset.service.ts";
import { assertObject, assertString, requestJson } from "./backend-contract-client.ts";

type TestServer = {
  app: INestApplication;
  baseUrl: string;
};

class CreationContractTestModule {}

const taskStore = new Map<string, Record<string, unknown>>();
const eventStore: Array<Record<string, unknown>> = [];
const artifactStore: Array<Record<string, unknown>> = [];

function resetStores() {
  taskStore.clear();
  eventStore.length = 0;
  artifactStore.length = 0;
}

Module({
  controllers: [CreationController],
  providers: [
    CreationService,
    {
      provide: PrismaService,
      useValue: {
        creationTask: {
          async create(options: Record<string, unknown>) {
            const data = (options.data ?? options) as Record<string, unknown>;
            const record = { ...data, createdAt: new Date(), updatedAt: new Date() };
            taskStore.set(data.id as string, record);
            return record;
          },
          async findUnique({ where }: Record<string, unknown>) {
            const record = taskStore.get(where.id as string);
            if (!record) return null;
            return {
              ...record,
              creationArtifacts: artifactStore.filter((a: any) => a.taskId === where.id),
              creationEvents: eventStore.filter((e: any) => e.taskId === where.id),
            };
          },
          async update({ where, data }: Record<string, unknown>) {
            const existing = taskStore.get(where.id as string) ?? {};
            const updated = { ...existing, ...(data as Record<string, unknown> ?? {}), updatedAt: new Date() };
            taskStore.set(where.id as string, updated);
            return updated;
          },
        },
        creationEvent: {
          async create(options: Record<string, unknown>) {
            const data = (options.data ?? options) as Record<string, unknown>;
            const record = { ...data, createdAt: new Date() };
            eventStore.push(record);
            return record;
          },
          async findMany({ where }: Record<string, unknown>) {
            return eventStore.filter((e: any) => e.taskId === where.taskId);
          },
        },
        creationArtifact: {
          async create(options: Record<string, unknown>) {
            const data = (options.data ?? options) as Record<string, unknown>;
            const record = { ...data, createdAt: new Date() };
            artifactStore.push(record);
            return record;
          },
        },
      },
    },
    {
      provide: AgentRuntimeService,
      useValue: {
        async runCreationStage(input: Record<string, unknown>) {
          const workspacePath = input.workspacePath as string;
          await fs.mkdir(path.join(workspacePath, "output"), { recursive: true });
          if (input.stage === "generate_book") {
            await fs.writeFile(
              path.join(workspacePath, "output", "book.json"),
              JSON.stringify({
                metadata: { title: "Contract Generated Book", childName: "Kid" },
                pages: [
                  { kind: "cover", title: "Cover", text: "Start" },
                  { kind: "artwork", title: "Page", text: "Middle", assetId: "asset_contract_001" },
                  { kind: "closing", title: "End", text: "Done" },
                ],
              }),
            );
            await fs.writeFile(path.join(workspacePath, "output", "book.html"), "<html><body>Contract Generated Book</body></html>");
            return { ok: true, runId: `run_contract_${Date.now()}`, sessionId: `session_contract_${Date.now()}` };
          }
          await fs.writeFile(
            path.join(workspacePath, "output", "plan.json"),
            JSON.stringify({
              summary: "Contract plan for storybook",
              skillName: "KidMemory storybook",
              steps: [
                { stepId: "compose", label: "Compose selected assets", detail: "Contract planning step." },
                { stepId: "generate", label: "Generate PDF draft", detail: "Contract generation step." },
              ],
              requirements: ["Selected assets", "OpenAI Agent SDK configuration"],
            }),
          );
          return { ok: true, runId: `run_contract_${Date.now()}`, sessionId: `session_contract_${Date.now()}` };
        },
      },
    },
    {
      provide: AppConfigService,
      useValue: {
        config: {
          paths: {
            dataDir: ".kidmemory/contract-test-data",
            exportDir: ".kidmemory/contract-test-exports",
            workspaceDir: os.tmpdir(),
          },
          sidecar: {
            webCompanionBaseUrl: "http://localhost:3001",
          },
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

async function unwrapData(body: unknown): Promise<Record<string, unknown>> {
  assertObject(body);
  assert.equal(body.code, 0, `Expected code 0, got ${JSON.stringify(body)}`);
  assertString(body.msg);
  assertObject(body.data);
  return body.data;
}

test("creation contract: create task", async (t) => {
  resetStores();
  const { app, baseUrl } = await startCreationContractServer();
  t.after(async () => { await app.close(); });

  const createResponse = await requestJson(baseUrl, "/creation/tasks", {
    method: "POST",
    body: JSON.stringify({
      goal: "为本周手工作品做一本睡前故事绘本",
      creationType: "storybook",
      assetIds: ["asset_contract_001", "asset_contract_002"],
    }),
  });
  assert.equal(createResponse.status, 201, `Expected 201, got body: ${JSON.stringify(createResponse.body)}`);
  const created = await unwrapData(createResponse.body);
  assertString(created.taskId, `Expected taskId in ${JSON.stringify(created)}`);
  assert.equal(created.creationType, "storybook");
  assert.equal(created.status, "ready");
  assert.ok(Array.isArray(created.steps));
  assertString(created.summary);
  assertString(created.skillName);

  // Get task detail
  const detailResponse = await requestJson(baseUrl, `/creation/tasks/${created.taskId}`, { method: "GET" });
  assert.equal(detailResponse.status, 200, `Expected 200 for task detail, got ${JSON.stringify(detailResponse.body)}`);
  const detail = await unwrapData(detailResponse.body);
  assert.equal(detail.taskId, created.taskId);
  assert.ok("currentStepId" in detail);
  assert.ok(Array.isArray(detail.steps));
  assert.ok(Array.isArray(detail.artifacts));
  assert.ok("error" in detail);

  const generateResponse = await requestJson(baseUrl, `/creation/tasks/${created.taskId}/generate`, { method: "POST" });
  assert.equal(generateResponse.status, 200, `Expected 200 for generate, got ${JSON.stringify(generateResponse.body)}`);
  const generated = await unwrapData(generateResponse.body);
  assert.equal(generated.status, "succeeded");
  assert.ok(Array.isArray(generated.artifacts));
  assert.equal(generated.artifacts.length, 2);

  const generatedDetailResponse = await requestJson(baseUrl, `/creation/tasks/${created.taskId}`, { method: "GET" });
  const generatedDetail = await unwrapData(generatedDetailResponse.body);
  assert.ok(Array.isArray(generatedDetail.artifacts));
  assert.equal(generatedDetail.artifacts.length, 2);

  // Events
  const eventsResponse = await requestJson(baseUrl, `/creation/tasks/${created.taskId}/events`, { method: "GET" });
  assert.equal(eventsResponse.status, 200);
  const events = await unwrapData(eventsResponse.body);
  assert.ok(Array.isArray(events.events));

  // Preview is available after book generation.
  const previewResponse = await fetch(`${baseUrl}/creation/tasks/${created.taskId}/preview`);
  assert.equal(previewResponse.status, 200);

  // Old plan/job endpoints return 404
  const oldPlan = await fetch(`${baseUrl}/creation/jobs/plan`, { method: "POST" });
  assert.equal(oldPlan.status, 404);
  const oldJob = await fetch(`${baseUrl}/creation/jobs`, { method: "POST" });
  assert.equal(oldJob.status, 404);
});

test("creation contract: invalid creation type fails with 400", async (t) => {
  resetStores();
  const { app, baseUrl } = await startCreationContractServer();
  t.after(async () => { await app.close(); });

  const response = await requestJson(baseUrl, "/creation/tasks", {
    method: "POST",
    body: JSON.stringify({
      goal: "做一个相册",
      creationType: "album",
      assetIds: ["asset_contract_001"],
    }),
  });

  assert.equal(response.status, 400);
  assert.notEqual(response.body.code, 0);
});

test("creation contract: old plan/job endpoints return 404", async (t) => {
  resetStores();
  const { app, baseUrl } = await startCreationContractServer();
  t.after(async () => { await app.close(); });

  assert.equal((await fetch(`${baseUrl}/creation/jobs/plan`, { method: "POST" })).status, 404);
  assert.equal((await fetch(`${baseUrl}/creation/jobs`, { method: "POST" })).status, 404);
  assert.equal((await fetch(`${baseUrl}/creation/jobs/some-id`)).status, 404);
});
