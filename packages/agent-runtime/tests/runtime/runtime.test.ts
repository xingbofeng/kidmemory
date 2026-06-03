import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {
  AgentRuntime,
  FakeExecutor,
  MemoryEventSink,
  MemorySessionLogStore,
  configureOpenAITracingForProvider,
  createOpenAISandboxManifest,
  createOpenAISandboxRuntimeCapabilities,
  diagnoseOpenAISandboxError,
  diagnoseOpenAIAgentError,
  shouldDisableOpenAITracing,
  toOpenAIProviderOptions,
} from "../../src/index.ts";

test("AgentRuntime.run prepares workspace, executes the executor, scans artifacts, and records events", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-runtime-"));
  const sessionLogStore = new MemorySessionLogStore();
  const eventSink = new MemoryEventSink();
  const runtime = new AgentRuntime({
    executor: new FakeExecutor(async ({ workspaceDir: runWorkspaceDir }) => {
      await fs.mkdir(path.join(runWorkspaceDir, "output"), { recursive: true });
      await fs.writeFile(path.join(runWorkspaceDir, "output", "book.json"), "{}");
      await fs.writeFile(path.join(runWorkspaceDir, "output", "book.html"), "<p>book</p>");
      return { ok: true, finalOutput: "created" };
    }),
    eventSink,
    sessionLogStore,
  });

  const result = await runtime.run({
    workspaceDir,
    prompt: "生成绘本",
    sessionId: "session_1",
    traceId: "trace_1",
  });

  assert.equal(result.ok, true);
  assert.equal(result.sessionId, "session_1");
  assert.equal(result.artifacts.length, 2);
  assert.equal(result.eventSummary.errors, 0);
  assert.equal(result.trace?.groupId, "session_1");
  assert.equal((await sessionLogStore.read("session_1")).some((event) => event.type === "user.prompt"), true);
  assert.equal((await eventSink.list({ runId: result.runId })).length > 0, true);
});

test("AgentRuntime.run returns a generation error when the executor fails", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-runtime-fail-"));
  const runtime = new AgentRuntime({
    executor: new FakeExecutor(async () => ({
      ok: false,
      error: {
        category: "generation",
        code: "FAKE_FAILURE",
        message: "Fake executor failed",
      },
    })),
  });

  const result = await runtime.run({ workspaceDir, prompt: "生成视频" });

  assert.equal(result.ok, false);
  assert.equal(result.error.category, "generation");
  assert.equal(result.eventSummary.errors, 1);
});

test("AgentRuntime.run fails when required output files are missing after executor success", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-runtime-required-output-"));
  const runtime = new AgentRuntime({
    executor: new FakeExecutor(async () => ({ ok: true, finalOutput: "I created the book." })),
  });

  const result = await runtime.run({
    workspaceDir,
    prompt: "生成绘本",
    sessionId: "required_output_session",
    requiredOutputFiles: ["output/book.json", "output/book.html"],
  });
  const events = await runtime.readSessionEvents("required_output_session");
  const failed = events.find((event) => event.type === "agent.run.failed");

  assert.equal(result.ok, false);
  assert.equal(result.error.category, "generation");
  assert.equal(result.error.code, "REQUIRED_OUTPUT_FILES_MISSING");
  assert.deepEqual(result.error.details?.missingOutputFiles, ["output/book.json", "output/book.html"]);
  assert.equal(result.error.details?.executorFinalOutput, "I created the book.");
  assert.deepEqual(failed?.data?.loopControl, {
    decision: "fail",
    reason: "required_output_files_missing",
  });
});

test("AgentRuntime passes provider config from initialization to the executor", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-runtime-provider-"));
  const runtime = new AgentRuntime({
    provider: {
      model: "gpt-5.1",
      baseURL: "https://api.example.test/v1",
      apiKey: "test-key",
    },
    executor: new FakeExecutor(async ({ provider }) => {
      assert.deepEqual(provider, {
        model: "gpt-5.1",
        baseURL: "https://api.example.test/v1",
        apiKey: "test-key",
      });
      return { ok: true };
    }),
  });

  const result = await runtime.run({ workspaceDir, prompt: "provider config" });

  assert.equal(result.ok, true);
});

test("AgentRuntime passes maxTurns from run request or initialization to the executor", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-runtime-max-turns-"));
  const seen = new Array<number | null | undefined>();
  const runtime = new AgentRuntime({
    maxTurns: 24,
    executor: new FakeExecutor(async ({ maxTurns }) => {
      seen.push(maxTurns);
      return { ok: true };
    }),
  });

  const first = await runtime.run({ workspaceDir, prompt: "default max turns" });
  const second = await runtime.run({ workspaceDir, prompt: "override max turns", maxTurns: 40 });

  assert.equal(first.ok, true);
  assert.equal(second.ok, true);
  assert.deepEqual(seen, [24, 40]);
});

test("AgentRuntime passes abort signal from run request to the executor", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-runtime-signal-"));
  const signal = { aborted: false, reason: undefined };
  const seenSignals: unknown[] = [];
  const runtime = new AgentRuntime({
    executor: new FakeExecutor(async ({ signal: executorSignal }) => {
      seenSignals.push(executorSignal);
      return { ok: true };
    }),
  });

  const result = await runtime.run({ workspaceDir, prompt: "signal propagation", signal });

  assert.equal(result.ok, true);
  assert.deepEqual(seenSignals, [signal]);
});

test("AgentRuntime does not inject workspace file tools by default", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-runtime-default-tools-"));
  const runtime = new AgentRuntime({
    executor: new FakeExecutor(async ({ tools }) => {
      const toolIds = tools.map((tool) => tool.id);

      assert.equal(toolIds.includes("ls"), false);
      assert.equal(toolIds.includes("read_file"), false);
      assert.equal(toolIds.includes("write_file"), false);
      assert.equal(toolIds.includes("generate_storybook_image_with_pollinations"), true);
      return { ok: true };
    }),
  });

  const result = await runtime.run({ workspaceDir, prompt: "default tools" });

  assert.equal(result.ok, true);
});

test("toOpenAIProviderOptions maps runtime provider credentials for OpenAI Agents SDK", () => {
  assert.deepEqual(
    toOpenAIProviderOptions({
      model: "gpt-5.1",
      baseURL: "https://api.example.test/v1",
      apiKey: "test-key",
      useResponses: false,
    }),
    {
      apiKey: "test-key",
      baseURL: "https://api.example.test/v1",
      cacheResponsesWebSocketModels: false,
      useResponses: false,
    },
  );
  assert.equal(toOpenAIProviderOptions({ model: "gpt-5.1" }), undefined);
});

test("createOpenAISandboxManifest uses an absolute workspace root", () => {
  const workspaceDir = path.join(os.tmpdir(), "kidmemory-relative-workspace");
  const manifest = createOpenAISandboxManifest(workspaceDir);

  assert.equal(path.isAbsolute(manifest.root), true);
  assert.equal(manifest.root, path.resolve(workspaceDir));
  assert.deepEqual(Object.keys(manifest.entries), ["."]);
});

test("createOpenAISandboxRuntimeCapabilities preserves default sandbox capabilities and adds skills", () => {
  const capabilities = createOpenAISandboxRuntimeCapabilities({
    openAIAgentsLocalSkills: [],
    mcpTools: [],
    errors: [],
  });
  const capabilityTypes = capabilities.map((capability) => capability.type);

  assert.ok(capabilityTypes.includes("filesystem"));
  assert.ok(capabilityTypes.includes("shell"));
  assert.ok(capabilityTypes.includes("compaction"));
});

test("createOpenAISandboxRuntimeCapabilities skips sandbox skill capabilities for chat-compatible providers", () => {
  const capabilities = createOpenAISandboxRuntimeCapabilities(
    {
      roots: ["/tmp/skills"],
      skills: [],
      openAIAgentsLocalSkills: [
        {
          name: "storybook-writer",
          description: "Writes storybooks.",
          path: "/tmp/skills/storybook-writer/SKILL.md",
        },
      ],
      mcpTools: [],
    },
    { useResponses: false },
  );
  const capabilityTypes = capabilities.map((capability) => capability.type);

  assert.ok(capabilityTypes.includes("filesystem"));
  assert.ok(capabilityTypes.includes("shell"));
  assert.equal(capabilityTypes.includes("skills"), false);
});

test("shouldDisableOpenAITracing disables tracing for OpenRouter providers", () => {
  assert.equal(
    shouldDisableOpenAITracing({
      baseURL: "https://openrouter.example.test/api/v1",
      apiKey: "router-key",
    }),
    true,
  );
  assert.equal(
    shouldDisableOpenAITracing({
      baseURL: "https://api.openai.com/v1",
      apiKey: "openai-key",
    }),
    false,
  );
  assert.equal(
    shouldDisableOpenAITracing({
      baseURL: "https://api.xiaomimimo.com/v1",
      apiKey: "compatible-key",
    }),
    true,
  );
});

test("configureOpenAITracingForProvider disables the OpenAI trace provider for OpenRouter", () => {
  const calls = new Array<boolean>();

  configureOpenAITracingForProvider(
    {
      baseURL: "https://openrouter.example.test/api/v1",
      apiKey: "router-key",
    },
    {
      setDisabled: (disabled) => calls.push(disabled),
    },
  );
  configureOpenAITracingForProvider(
    {
      baseURL: "https://api.openai.com/v1",
      apiKey: "openai-key",
    },
    {
      setDisabled: (disabled) => calls.push(disabled),
    },
  );

  assert.deepEqual(calls, [true, false]);
});

test("diagnoseOpenAISandboxError classifies provider rate limit errors without leaking secrets", () => {
  const error = diagnoseOpenAISandboxError(
    new Error("429 Rate limit exceeded: free-models-per-day. Add 5 credits."),
    {
      baseURL: "https://openrouter.ai/api/v1",
      apiKey: "secret-router-key",
      model: "free-model",
    },
  );

  assert.equal(error.category, "environment");
  assert.equal(error.code, "PROVIDER_RATE_LIMITED");
  assert.equal(error.recoverable, true);
  assert.match(error.message, /rate limit/i);
  assert.equal(error.details?.providerHost, "openrouter.ai");
  assert.equal(error.details?.httpStatus, 429);
  assert.doesNotMatch(JSON.stringify(error), /secret-router-key|https:\/\/openrouter\.ai\/api\/v1/);
});

test("diagnoseOpenAISandboxError classifies provider balance errors without leaking secrets", () => {
  const error = diagnoseOpenAISandboxError(
    new Error("402 Insufficient account balance"),
    {
      baseURL: "https://api.example.test/v1",
      apiKey: "secret-openai-compatible-key",
      model: "compatible-model",
      useResponses: false,
    },
  );

  assert.equal(error.category, "environment");
  assert.equal(error.code, "PROVIDER_INSUFFICIENT_BALANCE");
  assert.equal(error.recoverable, true);
  assert.equal(error.details?.providerHost, "api.example.test");
  assert.equal(error.details?.httpStatus, 402);
  assert.doesNotMatch(JSON.stringify(error), /secret-openai-compatible-key|https:\/\/api\.example\.test\/v1/);
});

test("diagnoseOpenAISandboxError classifies provider endpoint errors without leaking base URL", () => {
  const error = diagnoseOpenAISandboxError(
    new Error("404 <html><head><title>404 Not Found</title></head><body>openresty</body></html>"),
    {
      baseURL: "https://api.xiaomimimo.com/v1",
      apiKey: "secret-openai-key",
      model: "mimo-v2-pro",
    },
  );

  assert.equal(error.category, "environment");
  assert.equal(error.code, "PROVIDER_ENDPOINT_NOT_FOUND");
  assert.equal(error.recoverable, true);
  assert.equal(error.details?.providerHost, "api.xiaomimimo.com");
  assert.equal(error.details?.httpStatus, 404);
  assert.doesNotMatch(JSON.stringify(error), /secret-openai-key|https:\/\/api\.xiaomimimo\.com\/v1|<html>/);
});

test("diagnoseOpenAISandboxError classifies provider bad requests with response mode details", () => {
  const error = diagnoseOpenAISandboxError(
    new Error("400 Param Incorrect"),
    {
      baseURL: "https://api.openai.com/v1",
      apiKey: "secret-key",
      model: "compatible-model",
      useResponses: false,
    },
  );

  assert.equal(error.category, "environment");
  assert.equal(error.code, "PROVIDER_BAD_REQUEST");
  assert.equal(error.recoverable, true);
  assert.equal(error.details?.httpStatus, 400);
  assert.equal(error.details?.useResponses, false);
  assert.doesNotMatch(JSON.stringify(error), /secret-key|https:\/\/api\.openai\.com\/v1/);
});

test("diagnoseOpenAISandboxError classifies compatible provider sandbox rejections", () => {
  const error = diagnoseOpenAISandboxError(
    new Error("400 Param Incorrect"),
    {
      baseURL: "https://api.groq.com/openai/v1",
      apiKey: "secret-key",
      model: "openai/gpt-oss-20b",
      useResponses: false,
    },
  );

  assert.equal(error.category, "environment");
  assert.equal(error.code, "PROVIDER_SANDBOX_UNSUPPORTED");
  assert.equal(error.recoverable, true);
  assert.match(error.message, /SandboxAgent/i);
  assert.equal(error.details?.providerHost, "api.groq.com");
  assert.equal(error.details?.httpStatus, 400);
  assert.equal(error.details?.recommendedAction, "use_openai_sandbox_provider_or_non_sandbox_executor");
  assert.doesNotMatch(JSON.stringify(error), /secret-key|https:\/\/api\.groq\.com\/openai\/v1/);
});

test("diagnoseOpenAIAgentError classifies compatible provider agent loop rejections", () => {
  const error = diagnoseOpenAIAgentError(new Error("400 The `reasoning_content` in the thinking mode must be passed back to the API."), {
    baseURL: "https://api.deepseek.com",
    model: "deepseek-v4-flash",
    apiKey: "sk-secret",
    useResponses: false,
  });

  assert.equal(error.category, "environment");
  assert.equal(error.code, "PROVIDER_AGENT_UNSUPPORTED");
  assert.equal(error.details?.providerHost, "api.deepseek.com");
  assert.equal(error.details?.recommendedAction, "use_provider_without_reasoning_content_or_custom_model_adapter");
  assert.doesNotMatch(error.message, /sk-secret/);
});

test("AgentRuntime discovers workspace skills during run and passes them to the executor", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-runtime-skills-"));
  const skillDir = path.join(workspaceDir, ".kidmemory", "skills", "storybook-writer");
  await fs.mkdir(skillDir, { recursive: true });
  await fs.writeFile(
    path.join(skillDir, "SKILL.md"),
    `---
name: storybook-writer
description: Writes warm storybook drafts.
---

# Storybook Writer
`,
  );
  const runtime = new AgentRuntime({
    executor: new FakeExecutor(async ({ skills, tools }) => {
      assert.equal(skills.openAIAgentsLocalSkills.some((skill) => skill.name === "storybook-writer"), true);
      assert.equal(skills.mcpTools.some((tool) => tool.name === "read_skill"), true);
      assert.equal(tools.some((tool) => tool.id === "read_skill" && tool.source === "skill-deck"), true);
      assert.equal(tools.some((tool) => tool.id.startsWith("use_skill_") && tool.source === "skill-deck"), true);
      return { ok: true };
    }),
  });

  const result = await runtime.run({ workspaceDir, prompt: "use workspace skills" });

  assert.equal(result.ok, true);
});

test("AgentRuntime.stream yields stream channel events", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-runtime-stream-"));
  const runtime = new AgentRuntime({
    executor: new FakeExecutor(async () => ({ ok: true })),
  });
  const events = new Array<string>();

  for await (const event of runtime.stream({ workspaceDir, prompt: "stream me", sessionId: "stream_session" })) {
    events.push(event.type);
  }

  assert.deepEqual(events, ["agent.run.started", "agent.run.finished"]);
});

test("AgentRuntime can summarize and read session events", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-runtime-summary-"));
  const runtime = new AgentRuntime({
    executor: new FakeExecutor(async ({ workspaceDir: runWorkspaceDir }) => {
      await fs.mkdir(path.join(runWorkspaceDir, "output"), { recursive: true });
      await fs.writeFile(path.join(runWorkspaceDir, "output", "summary.txt"), "summary");
      return { ok: true };
    }),
  });

  const result = await runtime.run({ workspaceDir, prompt: "summarize", sessionId: "summary_session" });
  const summary = await runtime.getSessionSummary("summary_session");
  const events = await runtime.readSessionEvents("summary_session");

  assert.equal(result.ok, true);
  assert.equal(summary?.sessionId, "summary_session");
  assert.equal(summary?.artifactCount, 1);
  assert.equal(events.length > 0, true);
});

test("AgentRuntime records loop control stop reasons in terminal run events", async () => {
  const successWorkspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-runtime-loop-success-"));
  const successRuntime = new AgentRuntime({
    executor: new FakeExecutor(async () => ({ ok: true })),
  });

  const successResult = await successRuntime.run({
    workspaceDir: successWorkspaceDir,
    prompt: "success",
    sessionId: "loop_success",
  });
  const successEvents = await successRuntime.readSessionEvents("loop_success");
  const finished = successEvents.find((event) => event.type === "agent.run.finished");

  assert.equal(successResult.ok, true);
  assert.deepEqual(finished?.data?.loopControl, {
    decision: "complete",
    reason: "executor_succeeded",
  });

  const failureWorkspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-runtime-loop-fail-"));
  const failureRuntime = new AgentRuntime({
    executor: new FakeExecutor(async () => ({
      ok: false,
      error: {
        category: "generation",
        code: "FAIL",
        message: "failed",
      },
    })),
  });

  const failureResult = await failureRuntime.run({
    workspaceDir: failureWorkspaceDir,
    prompt: "failure",
    sessionId: "loop_failure",
  });
  const failureEvents = await failureRuntime.readSessionEvents("loop_failure");
  const failed = failureEvents.find((event) => event.type === "agent.run.failed");

  assert.equal(failureResult.ok, false);
  assert.deepEqual(failed?.data?.loopControl, {
    decision: "fail",
    reason: "executor_failed",
  });
});
