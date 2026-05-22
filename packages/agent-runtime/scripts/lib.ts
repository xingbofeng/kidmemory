import { spawn } from "node:child_process";
import fs from "node:fs/promises";
import path from "node:path";
import { URL } from "node:url";

import {
  AgentRuntime,
  FileEventSink,
  FileSessionLogStore,
  ensureAgentWorkspace,
  type AgentRuntimeError,
  type AgentEvent,
  type LoopControl,
  type AgentSessionSummary,
  type AgentTraceRef,
  type AgentExecutor,
  type AgentTool,
  type ExecutorKind,
  type RuntimeProviderConfig,
} from "../src/index.ts";

export type CliArgs = Record<string, string | boolean>;

export type ProviderChatHealthcheckResponse = {
  ok: boolean;
  status: number;
  json(): Promise<unknown>;
  text(): Promise<string>;
};

export type ProviderChatHealthcheckFetch = (
  url: string,
  init: {
    method: "POST";
    headers: Record<string, string>;
    body: string;
  },
) => Promise<ProviderChatHealthcheckResponse>;

export type ProviderChatHealthcheckResult = {
  ok: true;
  providerHost: string;
  modelConfigured: boolean;
  contentPreview: string;
};

export function parseArgs(argv = process.argv.slice(2)): CliArgs {
  const args: CliArgs = {};
  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (!value.startsWith("--")) continue;
    const key = value.slice(2);
    const next = argv[index + 1];
    if (!next || next.startsWith("--")) {
      args[key] = true;
    } else {
      args[key] = next;
      index += 1;
    }
  }
  return args;
}

export function requireStringArg(args: CliArgs, key: string): string {
  const value = args[key];
  const normalized = typeof value === "string" ? readEnvValue(value) : undefined;
  if (!normalized) {
    throw new Error(`Missing required --${key}.`);
  }
  return normalized;
}

export function packageRoot(): string {
  return path.resolve(import.meta.dirname, "..");
}

export function repoRoot(): string {
  return path.resolve(packageRoot(), "..", "..");
}

export function resolveWorkspace(workspace: string): string {
  return path.resolve(packageRoot(), workspace);
}

export async function loadDefaultEnvFile(env: Record<string, string | undefined> = process.env): Promise<boolean> {
  return loadEnvFile(path.join(repoRoot(), ".env"), env);
}

export async function loadEnvFile(filePath: string, env: Record<string, string | undefined> = process.env): Promise<boolean> {
  if (!(await pathExists(filePath))) return false;
  const content = await fs.readFile(filePath, "utf8");
  for (const line of content.split("\n")) {
    const parsed = parseEnvLine(line);
    if (!parsed) continue;
    if (env[parsed.key] === undefined) {
      env[parsed.key] = parsed.value;
    }
  }
  return true;
}

export function createWorkspaceRuntime(options: {
  workspaceDir: string;
  executor?: AgentExecutor;
  executorKind?: ExecutorKind;
  customTools?: AgentTool[];
  provider?: RuntimeProviderConfig;
  maxTurns?: number | null;
}): AgentRuntime {
  return new AgentRuntime({
    executor: options.executor,
    executorKind: options.executorKind ?? readRuntimeExecutorKindFromEnv(),
    provider: options.provider ?? createRuntimeProviderConfigFromEnv(),
    maxTurns: options.maxTurns ?? readDemoMaxTurnsFromEnv(),
    customTools: options.customTools,
    sessionLogStore: new FileSessionLogStore({
      rootDir: path.join(options.workspaceDir, ".kidmemory", "sessions"),
    }),
    eventSink: new FileEventSink({
      rootDir: path.join(options.workspaceDir, ".kidmemory", "logs"),
    }),
  });
}

export function readRuntimeExecutorKindFromEnv(env: Record<string, string | undefined> = process.env): ExecutorKind {
  const value = readEnvValue(env.AGENT_RUNTIME_EXECUTOR);
  if (!value) return "sandbox";
  if (value === "sandbox" || value === "agent") return value;
  throw new Error("AGENT_RUNTIME_EXECUTOR must be sandbox or agent.");
}

export function createRuntimeProviderConfigFromEnv(env: Record<string, string | undefined> = process.env): RuntimeProviderConfig {
  const config: RuntimeProviderConfig = {};
  const model = readEnvValue(env.OPENAI_MODEL);
  const baseURL = readEnvValue(env.OPENAI_BASE_URL);
  const apiKey = readEnvValue(env.OPENAI_API_KEY);
  const useResponses = readOptionalBooleanEnvValue(env.OPENAI_USE_RESPONSES);
  if (model) config.model = model;
  if (baseURL) config.baseURL = baseURL;
  if (apiKey) config.apiKey = apiKey;
  if (typeof useResponses === "boolean") config.useResponses = useResponses;
  return config;
}

export function readEnvValue(value: string | undefined): string | undefined {
  const normalized = value?.trim();
  return normalized && normalized.length > 0 ? normalized : undefined;
}

export function readOptionalBooleanEnvValue(value: string | undefined): boolean | undefined {
  const normalized = readEnvValue(value)?.toLowerCase();
  if (!normalized) return undefined;
  if (["1", "true", "yes", "on"].includes(normalized)) return true;
  if (["0", "false", "no", "off"].includes(normalized)) return false;
  return undefined;
}

export function readDemoMaxTurnsFromEnv(env: Record<string, string | undefined> = process.env): number {
  const parsed = Number.parseInt(readEnvValue(env.AGENT_RUNTIME_MAX_TURNS) ?? "", 10);
  return Number.isFinite(parsed) && parsed >= 1 ? Math.min(parsed, 100) : 30;
}

export function assertOpenAIApiKeyConfigured(env: Record<string, string | undefined> = process.env): void {
  if (!readEnvValue(env.OPENAI_API_KEY)) {
    throw new Error("OPENAI_API_KEY is required to run the SandboxAgent demo.");
  }
}

export function assertOpenAIProviderEnvValid(env: Record<string, string | undefined> = process.env): void {
  assertOpenAIApiKeyConfigured(env);
  const baseURL = readEnvValue(env.OPENAI_BASE_URL);
  if (baseURL && !isValidUrl(baseURL)) {
    throw new Error("OPENAI_BASE_URL must be a valid URL.");
  }
}

export type WorkspaceInspection = {
  artifacts: string[];
  events: {
    count: number;
    logPath?: string;
  };
  sessions: Array<{
    filePath: string;
    eventCount: number;
    sessionId: string;
    summary: AgentSessionSummary;
    loopControl?: LoopControl;
  }>;
  traces: AgentTraceRef[];
};

export async function collectWorkspaceInspection(workspaceDir: string): Promise<WorkspaceInspection> {
  const outputDir = path.join(workspaceDir, "output");
  const sessionsDir = path.join(workspaceDir, ".kidmemory", "sessions");
  const logsDir = path.join(workspaceDir, ".kidmemory", "logs");
  const artifacts = await listRelativeFiles(outputDir, workspaceDir);
  const sessionFiles = (await listRelativeFiles(sessionsDir, workspaceDir)).filter((filePath) => filePath.endsWith(".jsonl"));
  const sessions = new Array<WorkspaceInspection["sessions"][number]>();
  for (const filePath of sessionFiles) {
    const events = parseJsonLines<AgentEvent>(await fs.readFile(path.join(workspaceDir, filePath), "utf8"));
    const sessionId = path.basename(filePath, ".jsonl");
    sessions.push({
      filePath,
      eventCount: events.length,
      sessionId,
      summary: summarizeSessionEvents(sessionId, events),
      loopControl: extractLoopControl(events),
    });
  }
  const logPath = path.join(logsDir, "events.jsonl");
  const logEvents = (await pathExists(logPath)) ? parseJsonLines<AgentEvent>(await fs.readFile(logPath, "utf8")) : [];
  return {
    artifacts,
    events: {
      count: logEvents.length,
      logPath: (await pathExists(logPath)) ? path.relative(workspaceDir, logPath).split(path.sep).join("/") : undefined,
    },
    sessions,
    traces: await readTraceRefs(sessionsDir),
  };
}

export async function prepareDemoWorkspace(options: {
  workspaceDir: string;
  notes: string;
  assets: Record<string, string>;
  forceRuntimeInstructions?: boolean;
}): Promise<void> {
  await ensureAgentWorkspace({
    workspaceDir: options.workspaceDir,
    forceRuntimeInstructions: options.forceRuntimeInstructions,
  });
  await cleanDir(path.join(options.workspaceDir, "work"));
  await cleanDir(path.join(options.workspaceDir, "output"));
  await cleanDir(path.join(options.workspaceDir, ".kidmemory", "sessions"));
  await cleanDir(path.join(options.workspaceDir, ".kidmemory", "logs"));
  await cleanDir(path.join(options.workspaceDir, "input", "assets"));
  await fs.mkdir(path.join(options.workspaceDir, "input", "assets"), { recursive: true });
  await fs.writeFile(path.join(options.workspaceDir, "input", "notes.md"), options.notes);
  for (const [fileName, content] of Object.entries(options.assets)) {
    await fs.writeFile(path.join(options.workspaceDir, "input", "assets", fileName), content);
  }
}

export async function pathExists(filePath: string): Promise<boolean> {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}

export async function assertFile(filePath: string): Promise<void> {
  const stat = await fs.stat(filePath);
  if (!stat.isFile() || stat.size === 0) {
    throw new Error(`Expected non-empty file: ${filePath}`);
  }
}

export async function assertRequiredOutputFiles(workspaceDir: string, relativePaths: string[]): Promise<void> {
  const missing = new Array<string>();
  for (const relativePath of relativePaths) {
    try {
      await assertFile(path.join(workspaceDir, relativePath));
    } catch {
      missing.push(relativePath);
    }
  }
  if (missing.length === 0) return;

  const existing = await listRelativeFiles(path.join(workspaceDir, "output"), workspaceDir);
  throw new Error(
    [
      `Missing required output files: ${missing.join(", ")}`,
      `Existing output artifacts: ${existing.length > 0 ? existing.join(", ") : "(none)"}`,
    ].join("\n"),
  );
}

export async function assertStorybookOutputContract(workspaceDir: string): Promise<void> {
  const bookPath = path.join(workspaceDir, "output", "book.json");
  let parsed: unknown;
  try {
    parsed = JSON.parse(await fs.readFile(bookPath, "utf8"));
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown JSON parse error.";
    throw new Error(`Invalid storybook output: output/book.json must be strict JSON. ${message}`);
  }

  if (!isRecord(parsed)) {
    throw new Error("Invalid storybook output: output/book.json must be a JSON object.");
  }
  if (typeof parsed.title !== "string" || parsed.title.trim().length === 0) {
    throw new Error("Invalid storybook output: output/book.json must include a non-empty title.");
  }
  if (!Array.isArray(parsed.pages) || parsed.pages.length !== 4) {
    throw new Error("Invalid storybook output: output/book.json must include exactly 4 pages.");
  }

  parsed.pages.forEach((page, index) => {
    if (!isRecord(page)) {
      throw new Error(`Invalid storybook output: page ${index + 1} must be a JSON object.`);
    }
    if (typeof page.page !== "number") {
      throw new Error(`Invalid storybook output: page ${index + 1} must include numeric page.`);
    }
    if (typeof page.text !== "string" || page.text.trim().length === 0) {
      throw new Error(`Invalid storybook output: page ${index + 1} must include non-empty text.`);
    }
    if (typeof page.visualPrompt !== "string" || page.visualPrompt.trim().length === 0) {
      throw new Error(`Invalid storybook output: page ${index + 1} must include non-empty visualPrompt.`);
    }
  });
}

export async function recordDemoRunResultAndAssertOutputs(options: {
  workspaceDir: string;
  sessionId: string;
  result: unknown;
  requiredOutputFiles: string[];
}): Promise<void> {
  await recordDemoRunResult({
    workspaceDir: options.workspaceDir,
    sessionId: options.sessionId,
    result: options.result,
  });
  await assertRequiredOutputFiles(options.workspaceDir, options.requiredOutputFiles);
}

export async function runWorkspaceDemo(options: {
  workspaceDir: string;
  prompt: string;
  requiredOutputFiles: string[];
  runtime?: AgentRuntime;
}) {
  const runtime = options.runtime ?? createWorkspaceRuntime({ workspaceDir: options.workspaceDir });
  const result = await runtime.run({
    workspaceDir: options.workspaceDir,
    prompt: options.prompt,
    requiredOutputFiles: options.requiredOutputFiles,
  });

  if (!result.ok) {
    await recordDemoRunResult({
      workspaceDir: options.workspaceDir,
      sessionId: result.sessionId,
      result,
    });
    throw new Error(formatDemoRunFailure(result.error));
  }

  await recordDemoRunResultAndAssertOutputs({
    workspaceDir: options.workspaceDir,
    sessionId: result.sessionId,
    result,
    requiredOutputFiles: options.requiredOutputFiles,
  });
  return result;
}

export async function runProviderSandboxHealthcheck(options: {
  workspaceDir: string;
  runtime?: AgentRuntime;
  timeoutMs?: number;
}) {
  await ensureAgentWorkspace({ workspaceDir: options.workspaceDir, forceRuntimeInstructions: true });
  await cleanDir(path.join(options.workspaceDir, "work"));
  await cleanDir(path.join(options.workspaceDir, "output"));
  await cleanDir(path.join(options.workspaceDir, ".kidmemory", "sessions"));
  await cleanDir(path.join(options.workspaceDir, ".kidmemory", "logs"));
  await fs.mkdir(path.join(options.workspaceDir, "input"), { recursive: true });
  await fs.writeFile(
    path.join(options.workspaceDir, "input", "healthcheck.md"),
    "Provider executor healthcheck. The agent must write output/healthcheck.txt with the exact text: ok\n",
  );

  return runWithTimeout(
    runWorkspaceDemo({
      workspaceDir: options.workspaceDir,
      prompt: [
        "执行 KidMemory provider executor healthcheck。",
        "读取 input/healthcheck.md。",
        "必须通过当前 executor 可用的文件系统、shell 或 workspace tool 创建 output/healthcheck.txt。",
        "文件内容必须是 exact text: ok",
        "完成前验证 output/healthcheck.txt 存在且非空。",
      ].join("\n"),
      requiredOutputFiles: ["output/healthcheck.txt"],
      runtime: options.runtime,
    }),
    options.timeoutMs,
  );
}

export async function runProviderChatHealthcheck(options: {
  env?: Record<string, string | undefined>;
  fetchImpl?: ProviderChatHealthcheckFetch;
  timeoutMs?: number;
} = {}): Promise<ProviderChatHealthcheckResult> {
  const env = options.env ?? process.env;
  assertOpenAIProviderEnvValid(env);
  const provider = createRuntimeProviderConfigFromEnv(env);
  const model = readEnvValue(env.OPENAI_MODEL);
  if (!model) {
    throw new Error("OPENAI_MODEL is required to run provider chat healthcheck.");
  }
  const apiKey = readEnvValue(env.OPENAI_API_KEY);
  if (!apiKey) {
    throw new Error("OPENAI_API_KEY is required to run provider chat healthcheck.");
  }
  const baseURL = provider.baseURL ?? "https://api.openai.com/v1";
  const providerHost = readUrlHost(baseURL);
  const response = await runWithTimeout(
    (options.fetchImpl ?? fetchProviderChatHealthcheck)(joinProviderUrl(baseURL, "chat/completions"), {
      method: "POST",
      headers: {
        authorization: `Bearer ${apiKey}`,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model,
        messages: [{ role: "user", content: "Reply with exactly: ok" }],
        temperature: 0,
        max_tokens: 128,
      }),
    }),
    options.timeoutMs,
    "PROVIDER_CHAT_HEALTHCHECK_TIMEOUT",
    "Provider chat healthcheck",
  );

  if (!response.ok) {
    throw new Error(
      [
        "PROVIDER_CHAT_HEALTHCHECK_FAILED: OpenAI-compatible chat completion failed.",
        `Diagnostics: providerHost=${providerHost}, httpStatus=${response.status}, modelConfigured=true`,
        `Message: ${sanitizeForCli(await readProviderErrorMessage(response), [apiKey, model, baseURL])}`,
      ].join("\n"),
    );
  }

  const content = readChatCompletionContent(await response.json());
  if (!content) {
    throw new Error(
      [
        "PROVIDER_CHAT_HEALTHCHECK_EMPTY: OpenAI-compatible chat completion returned no message content.",
        `Diagnostics: providerHost=${providerHost}, httpStatus=${response.status}, modelConfigured=true`,
      ].join("\n"),
    );
  }

  return {
    ok: true,
    providerHost,
    modelConfigured: true,
    contentPreview: content.slice(0, 80),
  };
}

export function readProviderChatHealthcheckTimeoutMs(env: Record<string, string | undefined> = process.env): number {
  const parsed = Number.parseInt(readEnvValue(env.AGENT_RUNTIME_MODEL_CHECK_TIMEOUT_MS) ?? "", 10);
  return Number.isFinite(parsed) && parsed >= 1 ? Math.min(parsed, 120_000) : 30_000;
}

export function readProviderHealthcheckTimeoutMs(env: Record<string, string | undefined> = process.env): number {
  const parsed = Number.parseInt(readEnvValue(env.AGENT_RUNTIME_PROVIDER_CHECK_TIMEOUT_MS) ?? "", 10);
  return Number.isFinite(parsed) && parsed >= 1 ? Math.min(parsed, 10 * 60 * 1000) : 120_000;
}

async function runWithTimeout<T>(
  promise: Promise<T>,
  timeoutMs: number | undefined,
  code = "PROVIDER_HEALTHCHECK_TIMEOUT",
  label = "Provider sandbox healthcheck",
): Promise<T> {
  if (!timeoutMs) return promise;
  let timeout: NodeJS.Timeout | undefined;
  try {
    return await Promise.race([
      promise,
      new Promise<T>((_, reject) => {
        timeout = setTimeout(() => {
          reject(new Error(`${code}: ${label} timed out after ${timeoutMs}ms.`));
        }, timeoutMs);
      }),
    ]);
  } finally {
    if (timeout) clearTimeout(timeout);
  }
}

async function fetchProviderChatHealthcheck(
  url: string,
  init: {
    method: "POST";
    headers: Record<string, string>;
    body: string;
  },
): Promise<ProviderChatHealthcheckResponse> {
  return globalThis.fetch(url, init);
}

function joinProviderUrl(baseURL: string, relativePath: string): string {
  const normalizedBaseURL = baseURL.endsWith("/") ? baseURL : `${baseURL}/`;
  return new URL(relativePath, normalizedBaseURL).toString();
}

function readUrlHost(url: string): string {
  try {
    return new URL(url).host;
  } catch {
    return "invalid-url";
  }
}

async function readProviderErrorMessage(response: ProviderChatHealthcheckResponse): Promise<string> {
  try {
    const payload = await response.json();
    const message = readErrorMessage(payload);
    if (message) return message;
  } catch {
    // Fall through to text body.
  }
  try {
    return await response.text();
  } catch {
    return "Provider returned an error response.";
  }
}

function readErrorMessage(payload: unknown): string | undefined {
  if (!isRecord(payload)) return undefined;
  const error = payload.error;
  if (isRecord(error) && typeof error.message === "string") return error.message;
  if (typeof payload.message === "string") return payload.message;
  return undefined;
}

function readChatCompletionContent(payload: unknown): string | undefined {
  if (!isRecord(payload) || !Array.isArray(payload.choices)) return undefined;
  const firstChoice = payload.choices[0];
  if (!isRecord(firstChoice) || !isRecord(firstChoice.message)) return undefined;
  return typeof firstChoice.message.content === "string" ? firstChoice.message.content : undefined;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function sanitizeForCli(message: string, secrets: string[] = []): string {
  let sanitized = message;
  for (const secret of secrets) {
    if (!secret) continue;
    sanitized = sanitized.replaceAll(secret, "[redacted]");
  }
  return sanitized
    .replace(/https?:\/\/\S+/gi, "[url]")
    .replace(/\b(sk-[A-Za-z0-9_-]+|sk-or-[A-Za-z0-9_-]+|gsk_[A-Za-z0-9_-]+)\b/g, "[redacted]")
    .replace(/\s+/g, " ")
    .trim();
}

export async function recordDemoRunResult(options: {
  workspaceDir: string;
  sessionId: string;
  result: unknown;
}): Promise<void> {
  const latestPath = path.join(options.workspaceDir, ".kidmemory", "sessions", `${options.sessionId}.latest.json`);
  await fs.mkdir(path.dirname(latestPath), { recursive: true });
  await fs.writeFile(latestPath, `${JSON.stringify(options.result, null, 2)}\n`);
}

export function formatDemoRunFailure(error: Pick<AgentRuntimeError, "code" | "message" | "details">): string {
  const details = formatSafeErrorDetails(error.details);
  return details.length > 0
    ? `${error.code}: ${error.message}\nDiagnostics: ${details.join(", ")}`
    : `${error.code}: ${error.message}`;
}

export function runCommand(command: string, args: string[]): Promise<void> {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      cwd: packageRoot(),
      env: process.env,
      stdio: "inherit",
    });
    child.on("exit", (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`${command} ${args.join(" ")} exited with ${code ?? "unknown"}`));
      }
    });
    child.on("error", reject);
  });
}

function formatSafeErrorDetails(details: Record<string, unknown> | undefined): string[] {
  if (!details) return [];
  const allowedKeys = new Set([
    "providerType",
    "providerHost",
    "httpStatus",
    "modelConfigured",
    "baseURLConfigured",
    "useResponses",
    "recommendedAction",
  ]);
  const entries = new Array<string>();
  for (const [key, value] of Object.entries(details)) {
    if (!allowedKeys.has(key)) continue;
    if (typeof value !== "string" && typeof value !== "number" && typeof value !== "boolean") continue;
    entries.push(`${key}=${String(value)}`);
  }
  return entries;
}

export async function listRelativeFiles(rootDir: string, baseDir: string): Promise<string[]> {
  try {
    const entries = await fs.readdir(rootDir, { withFileTypes: true });
    const result = new Array<string>();
    for (const entry of entries) {
      if (entry.name.startsWith(".")) continue;
      const entryPath = path.join(rootDir, entry.name);
      if (entry.isDirectory()) {
        result.push(...(await listRelativeFiles(entryPath, baseDir)));
      } else if (entry.isFile()) {
        result.push(path.relative(baseDir, entryPath).split(path.sep).join("/"));
      }
    }
    return result.sort();
  } catch {
    return [];
  }
}

async function cleanDir(dirPath: string): Promise<void> {
  await fs.rm(dirPath, { recursive: true, force: true });
  await fs.mkdir(dirPath, { recursive: true });
  await fs.writeFile(path.join(dirPath, ".gitkeep"), "");
}

function parseJsonLines<T>(content: string): T[] {
  return content
    .split("\n")
    .filter((line) => line.trim().length > 0)
    .map((line) => JSON.parse(line) as T);
}

function parseEnvLine(line: string): { key: string; value: string } | undefined {
  const trimmed = line.trim();
  if (!trimmed || trimmed.startsWith("#")) return undefined;
  const equalsIndex = trimmed.indexOf("=");
  if (equalsIndex <= 0) return undefined;
  const key = trimmed.slice(0, equalsIndex).trim();
  if (!/^[A-Za-z_][A-Za-z0-9_]*$/.test(key)) return undefined;
  const rawValue = trimmed.slice(equalsIndex + 1).trim();
  return { key, value: unquoteEnvValue(stripInlineComment(rawValue)) };
}

function stripInlineComment(value: string): string {
  let inSingleQuote = false;
  let inDoubleQuote = false;
  for (let index = 0; index < value.length; index += 1) {
    const char = value[index];
    if (char === "'" && !inDoubleQuote) inSingleQuote = !inSingleQuote;
    if (char === "\"" && !inSingleQuote) inDoubleQuote = !inDoubleQuote;
    if (char === "#" && !inSingleQuote && !inDoubleQuote && /\s/.test(value[index - 1] ?? "")) {
      return value.slice(0, index).trimEnd();
    }
  }
  return value;
}

function unquoteEnvValue(value: string): string {
  if ((value.startsWith("\"") && value.endsWith("\"")) || (value.startsWith("'") && value.endsWith("'"))) {
    return value.slice(1, -1);
  }
  return value;
}

function summarizeSessionEvents(sessionId: string, events: AgentEvent[]): AgentSessionSummary {
  const latestEvent = events.at(-1);
  const failedEvent = findLastEvent(events, "agent.run.failed");
  const finishedEvent = findLastEvent(events, "agent.run.finished");
  const startedEvent = events.find((event) => event.type === "agent.run.started");
  return {
    sessionId,
    status: failedEvent ? "failed" : finishedEvent ? "succeeded" : "active",
    runIds: [...new Set(events.map((event) => event.runId))],
    latestRunId: latestEvent?.runId,
    workspaceDir: typeof startedEvent?.data?.workspaceDir === "string" ? startedEvent.data.workspaceDir : undefined,
    artifactCount: events.filter((event) => event.type === "agent.artifact.detected").length,
    createdAt: events[0]?.timestamp,
    updatedAt: latestEvent?.timestamp,
    lastError: failedEvent
      ? {
          category: "unknown",
          code: typeof failedEvent.data?.code === "string" ? failedEvent.data.code : "SESSION_FAILED",
          message: failedEvent.message,
          recoverable: true,
        }
      : undefined,
  };
}

function findLastEvent(events: AgentEvent[], type: string): AgentEvent | undefined {
  for (let index = events.length - 1; index >= 0; index -= 1) {
    if (events[index]?.type === type) return events[index];
  }
  return undefined;
}

function extractLoopControl(events: AgentEvent[]): LoopControl | undefined {
  const terminalEvent =
    findLastEvent(events, "agent.run.finished") ??
    findLastEvent(events, "agent.run.failed");
  const loopControl = terminalEvent?.data?.loopControl;
  if (!loopControl || typeof loopControl !== "object") return undefined;
  if (!("decision" in loopControl) || !("reason" in loopControl)) return undefined;
  const decision = loopControl.decision;
  const reason = loopControl.reason;
  if (typeof decision !== "string" || typeof reason !== "string") return undefined;
  return {
    decision: decision as LoopControl["decision"],
    reason,
  };
}

async function readTraceRefs(sessionsDir: string): Promise<AgentTraceRef[]> {
  const entries = await listRelativeFiles(sessionsDir, sessionsDir);
  const traces = new Array<AgentTraceRef>();
  for (const filePath of entries.filter((entry) => entry.endsWith(".latest.json"))) {
    const parsed = JSON.parse(await fs.readFile(path.join(sessionsDir, filePath), "utf8")) as { trace?: AgentTraceRef };
    if (parsed.trace) traces.push(parsed.trace);
  }
  return traces;
}

function isValidUrl(value: string): boolean {
  try {
    new URL(value);
    return true;
  } catch {
    return false;
  }
}
