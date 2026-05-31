import "reflect-metadata";

import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { CreationService } from "../../../../src/modules/creation/creation.service.ts";

type JsonObject = Record<string, unknown>;

type TaskInput = JsonObject & {
  id: string;
  creationType?: string;
  goal?: string;
  assetIds?: string[];
  status?: string;
  workspacePath?: string;
  steps?: string;
  requirementItems?: string[];
  createdAt?: Date;
  updatedAt?: Date;
  currentStepId?: string | null;
  summary?: string;
  skillName?: string;
  error?: unknown;
};

type TaskRecord = TaskInput & {
  assetIds: string[];
  requirementItems: string[];
  steps: string;
  createdAt: Date;
  updatedAt: Date;
};

type ArtifactInput = JsonObject & {
  id: string;
  taskId: string;
  kind: string;
  localPath?: string | null;
  shareId?: string | null;
  shareUrl?: string | null;
  createdAt?: Date;
};

type ArtifactRecord = ArtifactInput & {
  createdAt: Date;
};

type EventInput = JsonObject & {
  id: string;
  taskId: string;
  type: string;
  message: string;
  stepId?: string | null;
  createdAt?: Date;
};

type EventRecord = EventInput & {
  createdAt: Date;
};

type CreationServiceArgs = ConstructorParameters<typeof CreationService>;

type AgentRuntimeDouble = {
  runCreationStage(input: { stage: string; workspacePath: string }): Promise<{
    ok: boolean;
    error?: {
      category: string;
      message: string;
      code?: string;
    };
  }>;
};

function createPrismaStub(initialTasks: TaskRecord[] = []) {
  const tasks = new Map<string, TaskRecord>();
  const artifacts: ArtifactRecord[] = [];
  const events: EventRecord[] = [];

  for (const task of initialTasks) {
    tasks.set(task.id, {
      createdAt: new Date("2026-05-23T00:00:00.000Z"),
      updatedAt: new Date("2026-05-23T00:00:00.000Z"),
      assetIds: [],
      requirementItems: [],
      steps: "[]",
      ...task,
    });
  }

  return {
    stores: { tasks, artifacts, events },
    prisma: {
      creationTask: {
        async create(options: { data: TaskInput }) {
          const record = {
            ...options.data,
            createdAt: new Date("2026-05-23T00:00:00.000Z"),
            updatedAt: new Date("2026-05-23T00:00:00.000Z"),
            assetIds: options.data.assetIds ?? [],
            steps: options.data.steps ?? "[]",
            requirementItems: options.data.requirementItems ?? [],
          };
          tasks.set(record.id, record);
          return record;
        },
        async findUnique(options: { where: { id: string }; include?: Record<string, unknown> }) {
          const record = tasks.get(options.where.id);
          if (!record) return null;
          return {
            ...record,
            creationArtifacts: options.include?.creationArtifacts
              ? artifacts.filter((artifact) => artifact.taskId === options.where.id)
              : undefined,
            creationEvents: options.include?.creationEvents
              ? events.filter((event) => event.taskId === options.where.id)
              : undefined,
          };
        },
        async update(options: { where: { id: string }; data: Partial<TaskInput> }) {
          const existing = tasks.get(options.where.id);
          assert.ok(existing, `missing task ${options.where.id}`);
          const updated = {
            ...existing,
            ...options.data,
            updatedAt: new Date("2026-05-23T00:00:01.000Z"),
          };
          tasks.set(options.where.id, updated);
          return updated;
        },
      },
      creationEvent: {
        async create(options: { data: EventInput }) {
          const record = { ...options.data, createdAt: new Date("2026-05-23T00:00:00.000Z") };
          events.push(record);
          return record;
        },
        async findMany(options: { where: { taskId: string } }) {
          return events.filter((event) => event.taskId === options.where.taskId);
        },
      },
      creationArtifact: {
        async create(options: { data: ArtifactInput }) {
          const record = { ...options.data, createdAt: new Date("2026-05-23T00:00:00.000Z") };
          artifacts.push(record);
          return record;
        },
      },
    },
  };
}

function createService(input: {
  workspaceDir: string;
  exportDir: string;
  prisma: ReturnType<typeof createPrismaStub>["prisma"];
  agentRuntime?: AgentRuntimeDouble;
}) {
  const agentRuntime = input.agentRuntime ?? { async runCreationStage() { return { ok: true }; } };
  const config = {
    config: {
      paths: {
        workspaceDir: input.workspaceDir,
        exportDir: input.exportDir,
      },
    },
  };
  return new CreationService(
    input.prisma as unknown as CreationServiceArgs[0],
    agentRuntime as unknown as CreationServiceArgs[1],
    config as unknown as CreationServiceArgs[2],
  );
}

test("createTask returns the persisted error when planning fails", async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-creation-service-"));
  const { prisma } = createPrismaStub();
  const service = createService({
    workspaceDir: path.join(dir, "workspace"),
    exportDir: path.join(dir, "exports"),
    prisma,
    agentRuntime: {
      async runCreationStage() {
        return {
          ok: false,
          error: {
            category: "planning",
            message: "planner failed",
            code: "PLAN_FAILED",
          },
        };
      },
    },
  });

  const result = await service.createTask({
    creationType: "storybook",
    goal: "make a book",
    assetIds: ["asset-1"],
  });

  assert.equal(result.status, 500);
  assert.equal("error" in result.data && result.data.error?.message, "planner failed");
  assert.equal("error" in result.data && result.data.error?.code, "PLAN_FAILED");
});

test("exportTask renders a generated book HTML task to a real PDF file", async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-creation-export-"));
  const workspacePath = path.join(dir, "workspace", "task-1");
  const exportPath = path.join(dir, "exports", "task-1.pdf");
  await fs.mkdir(path.join(workspacePath, "output"), { recursive: true });
  await fs.writeFile(
    path.join(workspacePath, "output", "book.html"),
    "<html><body><section class=\"page\"><h1>Cover</h1></section><section class=\"page\"><h1>Page</h1></section><section class=\"page\"><h1>End</h1></section></body></html>",
  );
  await fs.writeFile(
    path.join(workspacePath, "output", "book.json"),
    JSON.stringify({
      metadata: { title: "Task Book", childName: "Kid" },
      pages: [
        { kind: "cover", title: "Cover", text: "Start" },
        { kind: "artwork", title: "Page", text: "Middle", assetId: "asset-1" },
        { kind: "closing", title: "End", text: "Done" },
      ],
    }),
  );

  const { prisma } = createPrismaStub([
    {
      id: "task-1",
      creationType: "storybook",
      goal: "make a book",
      assetIds: ["asset-1"],
      status: "succeeded",
      workspacePath,
      steps: JSON.stringify([]),
    },
  ]);
  const service = createService({
    workspaceDir: path.join(dir, "workspace"),
    exportDir: path.join(dir, "exports"),
    prisma,
  });

  const result = await service.exportTask("task-1", { target: "pdf", targetPath: exportPath });

  assert.equal(result.status, 201);
  const bytes = await fs.readFile(exportPath);
  assert.equal(bytes.subarray(0, 5).toString("utf8"), "%PDF-");
});

test("generateTask persists generated book artifacts from the task workspace", async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-creation-generate-"));
  const workspacePath = path.join(dir, "workspace", "task-1");
  const { prisma, stores } = createPrismaStub([
    {
      id: "task-1",
      creationType: "storybook",
      goal: "make a book",
      assetIds: ["asset-1"],
      status: "ready",
      workspacePath,
      steps: JSON.stringify([]),
    },
  ]);
  const stageCalls: Array<{ stage: string; workspacePath: string }> = [];
  const service = createService({
    workspaceDir: path.join(dir, "workspace"),
    exportDir: path.join(dir, "exports"),
    prisma,
    agentRuntime: {
      async runCreationStage(input: { stage: string; workspacePath: string }) {
        stageCalls.push({ stage: input.stage, workspacePath: input.workspacePath });
        await fs.mkdir(path.join(input.workspacePath, "output"), { recursive: true });
        await fs.writeFile(
          path.join(input.workspacePath, "output", "book.json"),
          JSON.stringify({
            metadata: { title: "Generated Task Book", childName: "Kid" },
            pages: [
              { kind: "cover", title: "Cover", text: "Start" },
              { kind: "artwork", title: "Page", text: "Middle", assetId: "asset-1" },
              { kind: "closing", title: "End", text: "Done" },
            ],
          }),
        );
        await fs.writeFile(path.join(input.workspacePath, "output", "book.html"), "<html><body>Generated Task Book</body></html>");
        return { ok: true };
      },
    },
  });

  const result = await service.generateTask("task-1");
  const detail = await service.getTask("task-1");

  assert.equal(result.status, 200);
  assert.deepEqual(stageCalls, [{ stage: "generate_book", workspacePath }]);
  assert.equal(stores.artifacts.length, 2);
  assert.deepEqual(stores.artifacts.map((artifact) => artifact.localPath).sort(), [
    path.join(workspacePath, "output", "book.html"),
    path.join(workspacePath, "output", "book.json"),
  ]);
  assert.equal(detail.status, 200);
  assert.equal("artifacts" in detail.data && detail.data.artifacts.length, 2);
});
