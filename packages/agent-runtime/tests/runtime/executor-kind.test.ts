import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { AgentRuntime, FakeExecutor } from "../../src/index.ts";

test("AgentRuntime creates the OpenAI Agent executor when executorKind is agent", () => {
  const runtime = new AgentRuntime({ executorKind: "agent" });

  assert.equal(runtime.executorIdForTesting(), "openai-agent");
});

test("AgentRuntime injects safe workspace file tools only for the OpenAI Agent executor kind by default", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-agent-runtime-tools-"));
  const seenAgentTools = new Array<string>();
  const agentRuntime = new AgentRuntime({
    executorKind: "agent",
    executor: new FakeExecutor(async ({ tools }) => {
      seenAgentTools.push(...tools.map((tool) => tool.id));
      return { ok: true };
    }),
  });

  const seenSandboxTools = new Array<string>();
  const sandboxRuntime = new AgentRuntime({
    executorKind: "sandbox",
    executor: new FakeExecutor(async ({ tools }) => {
      seenSandboxTools.push(...tools.map((tool) => tool.id));
      return { ok: true };
    }),
  });

  await agentRuntime.run({ workspaceDir, prompt: "agent mode" });
  await sandboxRuntime.run({ workspaceDir, prompt: "sandbox mode" });

  assert.equal(seenAgentTools.includes("list_files"), true);
  assert.equal(seenAgentTools.includes("read_file"), true);
  assert.equal(seenAgentTools.includes("write_file"), true);
  assert.equal(seenAgentTools.includes("edit_file"), true);
  assert.equal(seenAgentTools.includes("search_files"), true);
  assert.equal(seenAgentTools.includes("run_command"), false);
  assert.equal(seenSandboxTools.includes("read_file"), false);
  assert.equal(seenSandboxTools.includes("write_file"), false);
  assert.equal(seenSandboxTools.includes("run_command"), false);
});
