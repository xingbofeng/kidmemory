import assert from "node:assert/strict";
import fsSync from "node:fs";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { RunContext } from "@openai/agents";

import {
  AgentRuntime,
  FakeExecutor,
  createPollinationsStorybookImageTool,
  toOpenAIAgentsTool,
  type AgentTool,
} from "../../src/index.ts";

test("AgentRuntime blocks denied custom tools before executor runs", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-denied-tool-"));
  let executed = false;
  const tool: AgentTool = {
    id: "dangerous_tool",
    name: "Dangerous Tool",
    description: "Should not run",
    source: "custom",
    inputSchema: {},
    risk: "high",
    execute: async () => {
      executed = true;
      return {};
    },
  };
  const runtime = new AgentRuntime({
    customTools: [tool],
    policy: {
      tools: {
        deniedToolIds: ["dangerous_tool"],
      },
    },
    executor: new FakeExecutor(async ({ tools }) => {
      await tools[0].execute({}, { workspaceDir });
      return { ok: true };
    }),
  });

  const result = await runtime.run({ workspaceDir, prompt: "try denied tool" });

  assert.equal(result.ok, false);
  assert.equal(result.error.category, "skill");
  assert.equal(result.error.code, "TOOL_POLICY_DENIED");
  assert.equal(executed, false);
});

test("AgentRuntime passes allowed custom tools to executor and records tool events", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-allowed-tool-"));
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
  const runtime = new AgentRuntime({
    customTools: [tool],
    executor: new FakeExecutor(async ({ tools, workspaceDir }) => {
      await tools[0].execute({}, { workspaceDir });
      return { ok: true };
    }),
  });

  const result = await runtime.run({ workspaceDir, prompt: "use allowed tool", sessionId: "session_tool" });
  const events = await runtime.readSessionEvents("session_tool");

  assert.equal(result.ok, true);
  assert.equal(result.artifacts.some((artifact) => artifact.localPath === "output/summary.txt"), true);
  assert.equal(events.some((event) => event.type === "agent.tool.finished"), true);
});

test("AgentRuntime records full sanitized tool input, output, and failures", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-full-tool-log-"));
  const successTool: AgentTool = {
    id: "success_tool",
    name: "Success Tool",
    description: "Returns output",
    source: "custom",
    inputSchema: {},
    risk: "low",
    execute: async () => ({ ok: true, token: "secret-output" }),
  };
  const runtime = new AgentRuntime({
    customTools: [successTool],
    executor: new FakeExecutor(async ({ tools, workspaceDir: runWorkspaceDir }) => {
      await tools[0].execute({ apiKey: "secret-input", prompt: "cover" }, { workspaceDir: runWorkspaceDir });
      return { ok: true };
    }),
  });

  const result = await runtime.run({ workspaceDir, prompt: "log tools", sessionId: "session_full_log" });
  const events = await runtime.readSessionEvents("session_full_log");
  const started = events.find((event) => event.type === "agent.tool.started");
  const finished = events.find((event) => event.type === "agent.tool.finished");

  assert.equal(result.ok, true);
  assert.deepEqual(started?.data?.input, { apiKey: "[redacted]", prompt: "cover" });
  assert.deepEqual(finished?.data?.output, { ok: true, token: "[redacted]" });

  const failureTool: AgentTool = {
    id: "failure_tool",
    name: "Failure Tool",
    description: "Throws",
    source: "custom",
    inputSchema: {},
    risk: "low",
    execute: async () => {
      throw new Error("provider failed with token secret");
    },
  };
  const failingRuntime = new AgentRuntime({
    customTools: [failureTool],
    executor: new FakeExecutor(async ({ tools, workspaceDir: runWorkspaceDir }) => {
      await tools[0].execute({ token: "secret-input" }, { workspaceDir: runWorkspaceDir });
      return { ok: true };
    }),
  });

  const failure = await failingRuntime.run({ workspaceDir, prompt: "log failure", sessionId: "session_failure_log" });
  const failureEvents = await failingRuntime.readSessionEvents("session_failure_log");
  const failedTool = failureEvents.find((event) => event.type === "agent.tool.failed");

  assert.equal(failure.ok, false);
  assert.deepEqual(failedTool?.data?.input, { token: "[redacted]" });
  assert.match(String(failedTool?.data?.error), /provider failed/);
  assert.doesNotMatch(JSON.stringify(failureEvents), /secret-input|secret-output/);
});

test("AgentRuntime marks tools as requiring approval from runtime policy", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-approval-tool-"));
  const tool: AgentTool = {
    id: "render_video",
    name: "Render Video",
    description: "Renders a video",
    source: "custom",
    inputSchema: {},
    risk: "high",
    execute: async () => ({ ok: true }),
  };
  const runtime = new AgentRuntime({
    customTools: [tool],
    policy: {
      tools: {
        requireApprovalToolIds: ["render_video"],
      },
    },
    executor: new FakeExecutor(async ({ tools }) => {
      assert.equal(tools[0].requiresApproval, true);
      return { ok: true };
    }),
  });

  const result = await runtime.run({ workspaceDir, prompt: "render with approval" });

  assert.equal(result.ok, true);
});

test("toOpenAIAgentsTool adapts AgentTool execution with workspace context", async () => {
  const toolSource = await fs.readFile(
    path.join(process.cwd(), "src", "tools", "index.ts"),
    "utf8",
  );
  const testSource = await fs.readFile(
    path.join(process.cwd(), "tests", "tools", "tools-policy.test.ts"),
    "utf8",
  );
  const forbidden = ["as", "never"].join(" ");
  assert.equal(toolSource.includes(forbidden), false);
  assert.equal(testSource.includes(forbidden), false);

  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-openai-tool-"));
  const agentTool: AgentTool = {
    id: "write_summary",
    name: "Write Summary",
    description: "Writes a summary",
    source: "custom",
    inputSchema: {
      type: "object",
      properties: {
        text: { type: "string" },
      },
      additionalProperties: false,
    },
    risk: "low",
    execute: async (input, context) => {
      const text = typeof input === "object" && input && "text" in input ? String(input.text) : "";
      await fs.mkdir(path.join(context.workspaceDir, "output"), { recursive: true });
      await fs.writeFile(path.join(context.workspaceDir, "output", "summary.txt"), text);
      return { localPath: "output/summary.txt" };
    },
  };

  const openAITool = toOpenAIAgentsTool(agentTool, { workspaceDir, runId: "run_tool" });
  const output = await openAITool.invoke(new RunContext(), JSON.stringify({ text: "hello" }));

  assert.equal(openAITool.name, "write_summary");
  assert.deepEqual(output, { localPath: "output/summary.txt" });
  assert.equal(await fs.readFile(path.join(workspaceDir, "output", "summary.txt"), "utf8"), "hello");
});

test("createPollinationsStorybookImageTool downloads text-only storybook images without leaking keys", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-pollinations-tool-"));
  const requests = new Array<{ url: string; authorization?: string }>();
  const tool = createPollinationsStorybookImageTool({
    apiKey: "secret-key",
    fetchImpl: async (url, init) => {
      requests.push({
        url: String(url),
        authorization: typeof init?.headers === "object" && init.headers !== null && "Authorization" in init.headers
          ? String((init.headers as Record<string, string>).Authorization)
          : undefined,
      });
      return new globalThis.Response(new Uint8Array([1, 2, 3]), {
        status: 200,
        headers: { "content-type": "image/png" },
      });
    },
  });

  const output = await tool.execute(
    {
      prompt: "watercolor cover for a warm child memory storybook",
      path: "output/images/cover.png",
      width: 768,
      height: 512,
      seed: 12,
    },
    { workspaceDir, runId: "run_1" },
  );

  assert.deepEqual(output, {
    ok: true,
    provider: "pollinations",
    path: "output/images/cover.png",
    width: 768,
    height: 512,
    model: "flux",
    privacyBoundary: {
      textOnly: true,
      childPhotoUpload: false,
    },
  });
  assert.equal(await fs.readFile(path.join(workspaceDir, "output/images/cover.png"), "hex"), "010203");
  assert.match(requests[0]?.url ?? "", /image\.pollinations\.ai\/prompt\//);
  assert.doesNotMatch(requests[0]?.url ?? "", /secret-key/);
  assert.equal(requests[0]?.authorization, "Bearer secret-key");
});

test("createPollinationsStorybookImageTool blocks child photo payloads and output path escapes", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-pollinations-block-"));
  const tool = createPollinationsStorybookImageTool({
    fetchImpl: async () => new globalThis.Response(new Uint8Array([1]), { status: 200 }),
  });

  await assert.rejects(
    tool.execute({ prompt: "cover", image: "base64", path: "output/cover.png" }, { workspaceDir }),
    /only accepts text prompts/i,
  );
  await assert.rejects(
    tool.execute({ prompt: "cover", path: "../cover.png" }, { workspaceDir }),
    /outside workspace|under output/i,
  );
});

test("createPollinationsStorybookImageTool reuses shared input readers", () => {
  const source = fsSync.readFileSync("src/tools/generate-storybook-image.tool.ts", "utf8");

  assert.equal(source.match(/typeof input !== "object"/g)?.length, 1);
  assert.equal(source.includes("function readRequiredStringField"), false);
  assert.equal(source.includes("function readOptionalStringField"), false);
  assert.equal(source.includes("function readOptionalNumberField"), false);
  assert.match(source, /core\/utils\.js/);
  assert.equal(source.includes("function toPosixPath"), false);
});
