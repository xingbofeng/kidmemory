import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { FakeExecutor } from "../../src/index.ts";
import { collectEnvironmentCheck } from "../../scripts/check-env.ts";
import { resolveProviderHealthcheckWorkspace } from "../../scripts/check-provider.ts";
import { runDemoVerification } from "../../scripts/verify-demo.ts";
import {
  assertOpenAIApiKeyConfigured,
  assertOpenAIProviderEnvValid,
  assertRequiredOutputFiles,
  assertStorybookOutputContract,
  createRuntimeProviderConfigFromEnv,
  createWorkspaceRuntime,
  formatDemoRunFailure,
  loadEnvFile,
  prepareDemoWorkspace,
  readDemoMaxTurnsFromEnv,
  readRuntimeExecutorKindFromEnv,
  readProviderChatHealthcheckTimeoutMs,
  readProviderHealthcheckTimeoutMs,
  recordDemoRunResult,
  recordDemoRunResultAndAssertOutputs,
  requireStringArg,
  runProviderChatHealthcheck,
  runProviderSandboxHealthcheck,
  runWorkspaceDemo,
} from "../../scripts/lib.ts";

test("createWorkspaceRuntime persists session and log jsonl files under .kidmemory", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-script-runtime-"));
  const runtime = createWorkspaceRuntime({
    workspaceDir,
    executor: new FakeExecutor(async ({ workspaceDir: runWorkspaceDir }) => {
      await fs.mkdir(path.join(runWorkspaceDir, "output"), { recursive: true });
      await fs.writeFile(path.join(runWorkspaceDir, "output", "artifact.txt"), "artifact");
      return { ok: true };
    }),
  });

  const result = await runtime.run({ workspaceDir, prompt: "persist logs", sessionId: "script_session" });

  assert.equal(result.ok, true);
  assert.equal(
    (await fs.readFile(path.join(workspaceDir, ".kidmemory", "sessions", "script_session.jsonl"), "utf8")).includes(
      "agent.run.finished",
    ),
    true,
  );
  assert.equal(
    (await fs.readFile(path.join(workspaceDir, ".kidmemory", "logs", "events.jsonl"), "utf8")).includes("agent.run.finished"),
    true,
  );
});

test("createRuntimeProviderConfigFromEnv maps OpenAI demo environment", () => {
  assert.deepEqual(
    createRuntimeProviderConfigFromEnv({
      OPENAI_API_KEY: "test-key",
      OPENAI_BASE_URL: "https://api.example.test/v1",
      OPENAI_MODEL: "gpt-5.1",
      OPENAI_USE_RESPONSES: "false",
    }),
    {
      apiKey: "test-key",
      baseURL: "https://api.example.test/v1",
      model: "gpt-5.1",
      useResponses: false,
    },
  );
  assert.deepEqual(createRuntimeProviderConfigFromEnv({}), {});
});

test("createRuntimeProviderConfigFromEnv ignores legacy OpenRouter environment when OpenAI config is present", () => {
  assert.deepEqual(
    createRuntimeProviderConfigFromEnv({
      OPENAI_API_KEY: "openai-key",
      OPENAI_BASE_URL: "https://openai.example.test/v1",
      OPENAI_MODEL: "openai/model",
      OPENROUTER_API_KEY: "router-key",
      OPENROUTER_BASE_URL: "https://openrouter.example.test/api/v1",
      OPENROUTER_MODEL: "router/model",
    }),
    {
      apiKey: "openai-key",
      baseURL: "https://openai.example.test/v1",
      model: "openai/model",
    },
  );
});

test("createRuntimeProviderConfigFromEnv ignores blank OpenAI demo environment values", () => {
  assert.deepEqual(
    createRuntimeProviderConfigFromEnv({
      OPENAI_API_KEY: "   ",
      OPENAI_BASE_URL: "\t",
      OPENAI_MODEL: "\n",
    }),
    {},
  );
});

test("readDemoMaxTurnsFromEnv reads safe demo max turn values", () => {
  assert.equal(readDemoMaxTurnsFromEnv({}), 30);
  assert.equal(readDemoMaxTurnsFromEnv({ AGENT_RUNTIME_MAX_TURNS: "40" }), 40);
  assert.equal(readDemoMaxTurnsFromEnv({ AGENT_RUNTIME_MAX_TURNS: "0" }), 30);
  assert.equal(readDemoMaxTurnsFromEnv({ AGENT_RUNTIME_MAX_TURNS: "not-number" }), 30);
});

test("readRuntimeExecutorKindFromEnv defaults to sandbox and accepts agent", () => {
  assert.equal(readRuntimeExecutorKindFromEnv({}), "sandbox");
  assert.equal(readRuntimeExecutorKindFromEnv({ AGENT_RUNTIME_EXECUTOR: " sandbox " }), "sandbox");
  assert.equal(readRuntimeExecutorKindFromEnv({ AGENT_RUNTIME_EXECUTOR: " agent " }), "agent");
  assert.throws(
    () => readRuntimeExecutorKindFromEnv({ AGENT_RUNTIME_EXECUTOR: "compatible" }),
    /AGENT_RUNTIME_EXECUTOR must be sandbox or agent/,
  );
});

test("readProviderHealthcheckTimeoutMs reads bounded provider healthcheck timeout values", () => {
  assert.equal(readProviderHealthcheckTimeoutMs({}), 120_000);
  assert.equal(readProviderHealthcheckTimeoutMs({ AGENT_RUNTIME_PROVIDER_CHECK_TIMEOUT_MS: "5000" }), 5000);
  assert.equal(readProviderHealthcheckTimeoutMs({ AGENT_RUNTIME_PROVIDER_CHECK_TIMEOUT_MS: "0" }), 120_000);
  assert.equal(readProviderHealthcheckTimeoutMs({ AGENT_RUNTIME_PROVIDER_CHECK_TIMEOUT_MS: "999999999" }), 600_000);
});

test("readProviderChatHealthcheckTimeoutMs reads bounded provider chat timeout values", () => {
  assert.equal(readProviderChatHealthcheckTimeoutMs({}), 30_000);
  assert.equal(readProviderChatHealthcheckTimeoutMs({ AGENT_RUNTIME_MODEL_CHECK_TIMEOUT_MS: "5000" }), 5000);
  assert.equal(readProviderChatHealthcheckTimeoutMs({ AGENT_RUNTIME_MODEL_CHECK_TIMEOUT_MS: "0" }), 30_000);
  assert.equal(readProviderChatHealthcheckTimeoutMs({ AGENT_RUNTIME_MODEL_CHECK_TIMEOUT_MS: "999999999" }), 120_000);
});

test("loadEnvFile reads dotenv values without overriding existing environment", async () => {
  const envPath = path.join(await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-env-file-")), ".env");
  await fs.writeFile(
    envPath,
    [
      "OPENAI_API_KEY=file-key",
      "OPENAI_BASE_URL=https://api.example.test/v1",
      "OPENAI_MODEL=\"gpt-5.1\"",
      "EXISTING=from-file",
      "COMMENTED=value # keep inline comment outside quotes",
    ].join("\n"),
  );
  const env = {
    EXISTING: "from-process",
  };

  const loaded = await loadEnvFile(envPath, env);

  assert.equal(loaded, true);
  assert.equal(env.OPENAI_API_KEY, "file-key");
  assert.equal(env.OPENAI_BASE_URL, "https://api.example.test/v1");
  assert.equal(env.OPENAI_MODEL, "gpt-5.1");
  assert.equal(env.EXISTING, "from-process");
  assert.equal(env.COMMENTED, "value");
});

test("requireStringArg rejects blank CLI argument values", () => {
  assert.throws(() => requireStringArg({ workspace: "   " }, "workspace"), /Missing required --workspace/);
  assert.throws(() => requireStringArg({ prompt: "\n" }, "prompt"), /Missing required --prompt/);
});

test("assertOpenAIApiKeyConfigured rejects missing and blank API keys", () => {
  assert.throws(() => assertOpenAIApiKeyConfigured({}), /OPENAI_API_KEY is required/);
  assert.throws(() => assertOpenAIApiKeyConfigured({ OPENAI_API_KEY: "   " }), /OPENAI_API_KEY is required/);
  assert.doesNotThrow(() => assertOpenAIApiKeyConfigured({ OPENAI_API_KEY: "test-key" }));
});

test("assertOpenAIProviderEnvValid rejects invalid base URL without leaking its value", () => {
  assert.throws(
    () =>
      assertOpenAIProviderEnvValid({
        OPENAI_API_KEY: "test-key",
        OPENAI_BASE_URL: "not a url with secret-host",
      }),
    (error) => {
      assert.equal(error instanceof Error, true);
      const message = error instanceof Error ? error.message : "";
      assert.match(message, /OPENAI_BASE_URL must be a valid URL/);
      assert.equal(message.includes("not a url with secret-host"), false);
      return true;
    },
  );
  assert.doesNotThrow(() => assertOpenAIProviderEnvValid({ OPENAI_API_KEY: "test-key" }));
});

test("prepareDemoWorkspace replaces input assets without deleting workspace skills", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-prepare-workspace-"));
  const skillPath = path.join(workspaceDir, ".kidmemory", "skills", "demo-skill", "SKILL.md");
  await fs.mkdir(path.dirname(skillPath), { recursive: true });
  await fs.writeFile(skillPath, "# Demo Skill\n");
  await fs.mkdir(path.join(workspaceDir, "input", "assets"), { recursive: true });
  await fs.writeFile(path.join(workspaceDir, "input", "assets", "stale.txt"), "stale");

  await prepareDemoWorkspace({
    workspaceDir,
    notes: "fresh notes",
    assets: {
      "fresh.txt": "fresh",
    },
  });

  assert.equal(await fs.readFile(skillPath, "utf8"), "# Demo Skill\n");
  assert.equal(await fs.readFile(path.join(workspaceDir, "input", "assets", "fresh.txt"), "utf8"), "fresh");
  await assert.rejects(fs.access(path.join(workspaceDir, "input", "assets", "stale.txt")));
});

test("assertRequiredOutputFiles reports missing required files with existing artifacts", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-required-output-"));
  await fs.mkdir(path.join(workspaceDir, "output"), { recursive: true });
  await fs.writeFile(path.join(workspaceDir, "output", "book.json"), "{}");
  await fs.writeFile(path.join(workspaceDir, "output", "draft.txt"), "draft");

  await assert.rejects(
    assertRequiredOutputFiles(workspaceDir, ["output/book.json", "output/book.html"]),
    (error) => {
      assert.equal(error instanceof Error, true);
      const message = error instanceof Error ? error.message : "";
      assert.match(message, /Missing required output files/);
      assert.match(message, /output\/book\.html/);
      assert.match(message, /Existing output artifacts/);
      assert.match(message, /output\/book\.json/);
      assert.match(message, /output\/draft\.txt/);
      return true;
    },
  );
});

test("assertStorybookOutputContract rejects invalid JSON", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-storybook-contract-invalid-json-"));
  await fs.mkdir(path.join(workspaceDir, "output"), { recursive: true });
  await fs.writeFile(path.join(workspaceDir, "output", "book.json"), '{"title":"bad","pages":["unterminated]');

  await assert.rejects(assertStorybookOutputContract(workspaceDir), /must be strict JSON/);
});

test("assertStorybookOutputContract requires exactly four structured pages", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-storybook-contract-pages-"));
  await fs.mkdir(path.join(workspaceDir, "output"), { recursive: true });
  await fs.writeFile(
    path.join(workspaceDir, "output", "book.json"),
    JSON.stringify({
      title: "星星小车",
      pages: [
        {
          page: 1,
          text: "第一页",
          visualPrompt: "A warm childlike illustration.",
        },
      ],
    }),
  );

  await assert.rejects(assertStorybookOutputContract(workspaceDir), /exactly 4 pages/);
});

test("assertStorybookOutputContract accepts a valid four-page storybook", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-storybook-contract-valid-"));
  await fs.mkdir(path.join(workspaceDir, "output"), { recursive: true });
  await fs.writeFile(
    path.join(workspaceDir, "output", "book.json"),
    JSON.stringify({
      title: "星星小车",
      pages: Array.from({ length: 4 }, (_, index) => ({
        page: index + 1,
        text: `第 ${index + 1} 页`,
        visualPrompt: "A warm childlike illustration.",
      })),
    }),
  );

  await assert.doesNotReject(assertStorybookOutputContract(workspaceDir));
});

test("recordDemoRunResultAndAssertOutputs writes latest result before reporting missing outputs", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-demo-record-"));
  await fs.mkdir(path.join(workspaceDir, ".kidmemory", "sessions"), { recursive: true });
  await fs.mkdir(path.join(workspaceDir, "output"), { recursive: true });

  await assert.rejects(
    recordDemoRunResultAndAssertOutputs({
      workspaceDir,
      sessionId: "session_missing_output",
      result: {
        ok: true,
        runId: "run_missing_output",
      },
      requiredOutputFiles: ["output/book.json"],
    }),
    /Missing required output files/,
  );

  const latestPath = path.join(workspaceDir, ".kidmemory", "sessions", "session_missing_output.latest.json");
  const latest = JSON.parse(await fs.readFile(latestPath, "utf8")) as { runId?: string };
  assert.equal(latest.runId, "run_missing_output");
});

test("runWorkspaceDemo passes required output files into runtime and records SDK failures", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-demo-runtime-required-"));
  const runtime = createWorkspaceRuntime({
    workspaceDir,
    executor: new FakeExecutor(async () => ({ ok: true, finalOutput: "claimed success" })),
  });

  await assert.rejects(
    runWorkspaceDemo({
      workspaceDir,
      prompt: "生成绘本",
      requiredOutputFiles: ["output/book.json"],
      runtime,
    }),
    /REQUIRED_OUTPUT_FILES_MISSING/,
  );

  const latestFiles = await fs.readdir(path.join(workspaceDir, ".kidmemory", "sessions"));
  const latestPath = latestFiles.find((fileName) => fileName.endsWith(".latest.json"));
  assert.equal(typeof latestPath, "string");
  const latest = JSON.parse(await fs.readFile(path.join(workspaceDir, ".kidmemory", "sessions", latestPath ?? ""), "utf8")) as {
    ok?: boolean;
    error?: { code?: string };
  };
  assert.equal(latest.ok, false);
  assert.equal(latest.error?.code, "REQUIRED_OUTPUT_FILES_MISSING");
});

test("runProviderSandboxHealthcheck verifies the provider can create sandbox output files", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-provider-healthcheck-"));
  const runtime = createWorkspaceRuntime({
    workspaceDir,
    executor: new FakeExecutor(async ({ workspaceDir: runWorkspaceDir }) => {
      await fs.mkdir(path.join(runWorkspaceDir, "output"), { recursive: true });
      await fs.writeFile(path.join(runWorkspaceDir, "output", "healthcheck.txt"), "ok");
      return { ok: true, finalOutput: "healthcheck complete" };
    }),
  });

  const result = await runProviderSandboxHealthcheck({ workspaceDir, runtime });

  assert.equal(result.ok, true);
  assert.equal(result.artifacts.some((artifact) => artifact.localPath === "output/healthcheck.txt"), true);
});

test("runProviderChatHealthcheck verifies a basic OpenAI-compatible chat completion", async () => {
  const requests = new Array<{ url: string; body: unknown; authorization?: string }>();

  const result = await runProviderChatHealthcheck({
    env: {
      OPENAI_API_KEY: "secret-key",
      OPENAI_BASE_URL: "https://api.example.test/v1",
      OPENAI_MODEL: "demo-model",
    },
    fetchImpl: async (url, init) => {
      requests.push({
        url,
        body: JSON.parse(init.body),
        authorization: init.headers.authorization,
      });
      return {
        ok: true,
        status: 200,
        json: async () => ({
          choices: [
            {
              message: {
                content: "ok",
              },
            },
          ],
        }),
        text: async () => "",
      };
    },
  });

  assert.equal(result.ok, true);
  assert.equal(result.providerHost, "api.example.test");
  assert.equal(result.modelConfigured, true);
  assert.equal(requests[0]?.url, "https://api.example.test/v1/chat/completions");
  assert.deepEqual(requests[0]?.body, {
    model: "demo-model",
    messages: [{ role: "user", content: "Reply with exactly: ok" }],
    temperature: 0,
    max_tokens: 128,
  });
  assert.equal(requests[0]?.authorization, "Bearer secret-key");
});

test("runProviderChatHealthcheck rejects missing model before making a request", async () => {
  let called = false;

  await assert.rejects(
    runProviderChatHealthcheck({
      env: {
        OPENAI_API_KEY: "secret-key",
        OPENAI_BASE_URL: "https://api.example.test/v1",
      },
      fetchImpl: async () => {
        called = true;
        throw new Error("should not be called");
      },
    }),
    /OPENAI_MODEL is required/,
  );

  assert.equal(called, false);
});

test("runProviderChatHealthcheck reports HTTP failures without leaking provider secrets", async () => {
  await assert.rejects(
    runProviderChatHealthcheck({
      env: {
        OPENAI_API_KEY: "secret-key",
        OPENAI_BASE_URL: "https://secret.example.test/v1",
        OPENAI_MODEL: "secret-model",
      },
      fetchImpl: async () => ({
        ok: false,
        status: 402,
        json: async () => ({
          error: {
            message: "Insufficient balance for secret-key on secret-model",
          },
        }),
        text: async () => "secret fallback",
      }),
    }),
    (error) => {
      assert.equal(error instanceof Error, true);
      const message = error instanceof Error ? error.message : "";
      assert.match(message, /PROVIDER_CHAT_HEALTHCHECK_FAILED/);
      assert.match(message, /httpStatus=402/);
      assert.match(message, /providerHost=secret\.example\.test/);
      assert.doesNotMatch(message, /secret-key|secret-model|https:\/\/secret\.example\.test\/v1/);
      return true;
    },
  );
});

test("runProviderChatHealthcheck fails fast when the provider chat healthcheck times out", async () => {
  await assert.rejects(
    runProviderChatHealthcheck({
      env: {
        OPENAI_API_KEY: "secret-key",
        OPENAI_BASE_URL: "https://api.example.test/v1",
        OPENAI_MODEL: "demo-model",
      },
      timeoutMs: 10,
      fetchImpl: async () => new Promise(() => undefined),
    }),
    /PROVIDER_CHAT_HEALTHCHECK_TIMEOUT/,
  );
});

test("runProviderSandboxHealthcheck records SDK failures for unsupported sandbox providers", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-provider-healthcheck-fail-"));
  const runtime = createWorkspaceRuntime({
    workspaceDir,
    executor: new FakeExecutor(async () => ({ ok: true, finalOutput: "claimed success without writing" })),
  });

  await assert.rejects(
    runProviderSandboxHealthcheck({ workspaceDir, runtime }),
    /REQUIRED_OUTPUT_FILES_MISSING/,
  );

  const latestFiles = await fs.readdir(path.join(workspaceDir, ".kidmemory", "sessions"));
  const latestPath = latestFiles.find((fileName) => fileName.endsWith(".latest.json"));
  assert.equal(typeof latestPath, "string");
});

test("runProviderSandboxHealthcheck fails fast when the provider healthcheck times out", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-provider-healthcheck-timeout-"));
  const runtime = createWorkspaceRuntime({
    workspaceDir,
    executor: new FakeExecutor(async () => new Promise(() => undefined)),
  });

  await assert.rejects(
    runProviderSandboxHealthcheck({ workspaceDir, runtime, timeoutMs: 10 }),
    /PROVIDER_HEALTHCHECK_TIMEOUT/,
  );
});

test("resolveProviderHealthcheckWorkspace keeps default workspace under the package root", () => {
  const workspaceDir = resolveProviderHealthcheckWorkspace({}, "fixed");

  assert.equal(workspaceDir.includes(`${path.sep}packages${path.sep}agent-runtime${path.sep}.tmp${path.sep}`), true);
  assert.equal(path.basename(workspaceDir), "provider-healthcheck-fixed");
});

test("resolveProviderHealthcheckWorkspace accepts explicit workspace arguments", () => {
  const workspaceDir = resolveProviderHealthcheckWorkspace({ workspace: "examples/provider-healthcheck" }, "fixed");

  assert.equal(workspaceDir, path.join(process.cwd(), "examples", "provider-healthcheck"));
});

test("recordDemoRunResult writes failure results for demo inspection", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-demo-failure-record-"));

  await recordDemoRunResult({
    workspaceDir,
    sessionId: "session_failed",
    result: {
      ok: false,
      runId: "run_failed",
      error: {
        code: "FAKE_FAILURE",
        message: "fake failure",
      },
    },
  });

  const latestPath = path.join(workspaceDir, ".kidmemory", "sessions", "session_failed.latest.json");
  const latest = JSON.parse(await fs.readFile(latestPath, "utf8")) as {
    ok?: boolean;
    error?: { code?: string };
  };
  assert.equal(latest.ok, false);
  assert.equal(latest.error?.code, "FAKE_FAILURE");
});

test("formatDemoRunFailure includes safe provider diagnostics", () => {
  const message = formatDemoRunFailure({
    code: "PROVIDER_ENDPOINT_NOT_FOUND",
    message: "Provider endpoint returned 404.",
    details: {
      providerHost: "api.example.test",
      httpStatus: 404,
      baseURLConfigured: true,
      useResponses: false,
      recommendedAction: "use_openai_sandbox_provider_or_non_sandbox_executor",
      apiKey: "secret-key",
      rawURL: "https://api.example.test/v1",
    },
  });

  assert.match(message, /PROVIDER_ENDPOINT_NOT_FOUND: Provider endpoint returned 404/);
  assert.match(message, /providerHost=api\.example\.test/);
  assert.match(message, /httpStatus=404/);
  assert.match(message, /baseURLConfigured=true/);
  assert.match(message, /useResponses=false/);
  assert.match(message, /recommendedAction=use_openai_sandbox_provider_or_non_sandbox_executor/);
  assert.doesNotMatch(message, /secret-key|https:\/\/api\.example\.test\/v1|apiKey|rawURL/);
});

test("collectEnvironmentCheck reports missing required demo skills", async () => {
  const rootDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-env-check-"));
  const storybookWorkspace = path.join(rootDir, "storybook");
  const videoWorkspace = path.join(rootDir, "video");
  await fs.mkdir(path.join(storybookWorkspace, ".kidmemory", "skills"), { recursive: true });
  await fs.mkdir(path.join(videoWorkspace, ".kidmemory", "skills"), { recursive: true });

  const result = await collectEnvironmentCheck({
    workspaces: [
      {
        workspaceDir: storybookWorkspace,
        requiredSkills: ["kidmemory-storybook-demo-writer"],
      },
      {
        workspaceDir: videoWorkspace,
        requiredSkills: ["kidmemory-video-demo-director"],
      },
    ],
    env: {
      OPENAI_API_KEY: "test-key",
    },
  });

  assert.equal(result.ok, false);
  assert.equal(result.errors.some((error) => error.includes("kidmemory-storybook-demo-writer")), true);
  assert.equal(result.errors.some((error) => error.includes("kidmemory-video-demo-director")), true);
});

test("collectEnvironmentCheck reports missing workspace files without creating them", async () => {
  const rootDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-env-strict-"));
  const workspaceDir = path.join(rootDir, "missing-workspace");

  const result = await collectEnvironmentCheck({
    workspaces: [{ workspaceDir }],
    env: {
      OPENAI_API_KEY: "test-key",
    },
  });

  assert.equal(result.ok, false);
  assert.equal(result.errors.some((error) => error.includes("Workspace missing .kidmemory/runtime.md")), true);
  assert.equal(result.errors.some((error) => error.includes("Workspace missing .kidmemory/manifest.json")), true);
  await assert.rejects(fs.access(path.join(workspaceDir, ".kidmemory", "runtime.md")));
  await assert.rejects(fs.access(path.join(workspaceDir, ".kidmemory", "manifest.json")));
});

test("collectEnvironmentCheck reports provider config presence without leaking secrets", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-env-provider-"));
  const result = await collectEnvironmentCheck({
    workspaces: [{ workspaceDir }],
    env: {
      OPENAI_API_KEY: "secret-key",
      OPENAI_BASE_URL: "https://secret.example.test/v1",
      OPENAI_MODEL: "gpt-secret",
    },
  });
  const text = [...result.errors, ...result.messages].join("\n");

  assert.equal(text.includes("secret-key"), false);
  assert.equal(text.includes("https://secret.example.test/v1"), false);
  assert.equal(text.includes("gpt-secret"), false);
  assert.match(text, /OPENAI_API_KEY: configured/);
  assert.match(text, /OPENAI_BASE_URL: configured/);
  assert.match(text, /OPENAI_MODEL: configured/);
});

test("collectEnvironmentCheck reports provider host and response mode without leaking values", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-env-active-provider-"));
  const result = await collectEnvironmentCheck({
    workspaces: [{ workspaceDir }],
    env: {
      OPENAI_API_KEY: "secret-key",
      OPENAI_BASE_URL: "https://openrouter.example.test/api/v1",
      OPENAI_MODEL: "secret-model",
      OPENAI_USE_RESPONSES: "false",
      OPENROUTER_API_KEY: "secret-router-key",
      OPENROUTER_BASE_URL: "https://secret-router.example.test/api/v1",
      OPENROUTER_MODEL: "secret-router-model",
      OPENROUTER_USE_RESPONSES: "false",
    },
  });
  const text = [...result.errors, ...result.messages].join("\n");

  assert.match(text, /OPENAI_PROVIDER_HOST: openrouter\.example\.test/);
  assert.match(text, /OPENAI_USE_RESPONSES: false/);
  assert.doesNotMatch(text, /secret-key|secret-router-key|secret-model|secret-router-model/);
  assert.doesNotMatch(text, /https:\/\/openrouter\.example\.test\/api\/v1|https:\/\/secret-router\.example\.test\/api\/v1/);
});

test("collectEnvironmentCheck reports invalid provider base URL without leaking its value", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-env-provider-url-"));
  const result = await collectEnvironmentCheck({
    workspaces: [{ workspaceDir }],
    env: {
      OPENAI_API_KEY: "test-key",
      OPENAI_BASE_URL: "not a url with secret-host",
    },
  });
  const text = [...result.errors, ...result.messages].join("\n");

  assert.equal(result.ok, false);
  assert.equal(text.includes("not a url with secret-host"), false);
  assert.equal(result.errors.some((error) => error.includes("OPENAI_BASE_URL must be a valid URL")), true);
});

test("collectEnvironmentCheck treats blank provider environment values as missing", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-env-provider-blank-"));
  const result = await collectEnvironmentCheck({
    workspaces: [{ workspaceDir }],
    env: {
      OPENAI_API_KEY: "   ",
      OPENAI_BASE_URL: "\t",
      OPENAI_MODEL: "\n",
    },
  });
  const text = [...result.errors, ...result.messages].join("\n");

  assert.equal(result.ok, false);
  assert.match(text, /OPENAI_API_KEY is required/);
  assert.match(text, /OPENAI_API_KEY: missing/);
  assert.match(text, /OPENAI_BASE_URL: not configured/);
  assert.match(text, /OPENAI_MODEL: not configured/);
});

test("collectEnvironmentCheck requires an OpenAI model for real demo verification", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-env-provider-model-"));
  const result = await collectEnvironmentCheck({
    workspaces: [{ workspaceDir }],
    env: {
      OPENAI_API_KEY: "test-key",
      OPENAI_BASE_URL: "https://api.example.test/v1",
    },
  });
  const text = [...result.errors, ...result.messages].join("\n");

  assert.equal(result.ok, false);
  assert.match(text, /OPENAI_MODEL is required/);
  assert.match(text, /OPENAI_MODEL: not configured/);
});

test("verify-demo runs check-env before mutating demo workspaces", async () => {
  const calls = new Array<string>();

  await runDemoVerification(async (command, args) => {
    calls.push([command, ...args].join(" "));
  });

  assert.deepEqual(calls, [
    "npm run check-env",
    "npm run check-model",
    "npm run check-provider -- --workspace examples/provider-healthcheck",
    "npm run demo:prepare -- --preset storybook --workspace examples/storybook",
    "npm run demo:run -- --preset storybook --workspace examples/storybook --executor agent",
    "npm run demo:inspect -- --workspace examples/storybook",
    "npm run demo:prepare -- --preset video --workspace examples/video",
    "npm run demo:run -- --preset video --workspace examples/video --executor agent",
    "npm run demo:inspect -- --workspace examples/video",
  ]);
});

test("verify-demo inspects provider healthcheck workspace before rethrowing provider failures", async () => {
  const calls = new Array<string>();
  const providerFailure = new Error("provider unavailable");

  await assert.rejects(
    runDemoVerification(async (command, args) => {
      calls.push([command, ...args].join(" "));
      if ([command, ...args].join(" ") === "npm run check-provider -- --workspace examples/provider-healthcheck") {
        throw providerFailure;
      }
    }),
    providerFailure,
  );

  assert.deepEqual(calls, [
    "npm run check-env",
    "npm run check-model",
    "npm run check-provider -- --workspace examples/provider-healthcheck",
    "npm run demo:inspect -- --workspace examples/provider-healthcheck",
  ]);
});
