import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { AgentRuntime, FakeExecutor, type AgentMiddleware, type AgentTool } from "../../src/index.ts";

test("AgentRuntime creates a default goal and records a complete loop decision", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-goal-"));
  const runtime = new AgentRuntime({
    executor: new FakeExecutor(async ({ workspaceDir: runWorkspaceDir }) => {
      await fs.mkdir(path.join(runWorkspaceDir, "output"), { recursive: true });
      await fs.writeFile(path.join(runWorkspaceDir, "output", "book.json"), "{}");
      return { ok: true };
    }),
  });

  const result = await runtime.run({ workspaceDir, prompt: "生成一本绘本" });

  assert.equal(result.ok, true);
  assert.equal(result.goal.objective, "生成一本绘本");
  assert.equal(result.loopControl.decision, "complete");
  assert.equal(result.loopControl.reason, "executor_succeeded");
});

test("AgentRuntime runs middleware around run, tool calls, artifacts, and errors", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-middleware-"));
  const calls = new Array<string>();
  const tool: AgentTool = {
    id: "write_summary",
    name: "Write Summary",
    description: "Writes a summary",
    source: "custom",
    inputSchema: {},
    risk: "low",
    execute: async (_input, context) => {
      await fs.mkdir(path.join(context.workspaceDir, "output"), { recursive: true });
      await fs.writeFile(path.join(context.workspaceDir, "output", "summary.txt"), "summary");
      return { ok: true };
    },
  };
  const middleware: AgentMiddleware = {
    beforeRun: async () => {
      calls.push("beforeRun");
    },
    beforeToolCall: async ({ tool: calledTool }) => {
      calls.push(`beforeToolCall:${calledTool.id}`);
    },
    afterToolCall: async ({ tool: calledTool }) => {
      calls.push(`afterToolCall:${calledTool.id}`);
    },
    afterArtifactScan: async ({ artifacts }) => {
      calls.push(`afterArtifactScan:${artifacts.length}`);
    },
    onError: async ({ error }) => {
      calls.push(`onError:${error.code}`);
    },
  };
  const runtime = new AgentRuntime({
    customTools: [tool],
    middleware: [middleware],
    executor: new FakeExecutor(async ({ tools, workspaceDir: runWorkspaceDir }) => {
      await tools[0].execute({}, { workspaceDir: runWorkspaceDir });
      return {
        ok: false,
        error: {
          category: "generation",
          code: "AFTER_TOOL_FAILURE",
          message: "failed after tool",
        },
      };
    }),
  });

  const result = await runtime.run({ workspaceDir, prompt: "run with middleware" });

  assert.equal(result.ok, false);
  assert.deepEqual(calls, [
    "beforeRun",
    "beforeToolCall:write_summary",
    "afterToolCall:write_summary",
    "afterArtifactScan:1",
    "onError:AFTER_TOOL_FAILURE",
  ]);
});
