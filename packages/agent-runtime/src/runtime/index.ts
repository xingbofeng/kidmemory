import fs from "node:fs/promises";
import path from "node:path";

import { ArtifactScanner, type AgentArtifact } from "../artifacts/index.js";
import type { AgentRuntimeError, AgentTraceRef } from "../core/errors.js";
import { isRuntimeErrorCategory } from "../core/errors.js";
import {
  AgentEventBus,
  MemoryEventSink,
  MemorySessionLogStore,
  createEvent,
  findLastEvent,
  summarizeEvents,
  type AgentEvent,
  type AgentEventSink,
  type AgentEventSummary,
  type AgentSessionLogStore,
  type AgentSessionSummary,
} from "../events/index.js";
import {
  FakeExecutor,
  OpenAIAgentExecutor,
  OpenAISandboxExecutor,
  type AgentExecutor,
  type ExecutorKind,
  type RuntimeProviderConfig,
} from "../executors/index.js";
import type { McpServerDefinition } from "../mcp/index.js";
import { SkillDeckProvider, createSkillDeckAgentTools, type SkillDeckLoadResult } from "../skills/index.js";
import { createPollinationsStorybookImageTool, createWorkspaceAgentTools, type AgentTool, type RuntimePolicy } from "../tools/index.js";
import { discoverSkillRoots, ensureAgentWorkspace } from "../workspace/index.js";

export type AgentRunRequest = {
  workspaceDir: string;
  prompt: string;
  maxTurns?: number | null;
  requiredOutputFiles?: string[];
  goal?: AgentGoalInput;
  sessionId?: string;
  traceId?: string;
  metadata?: Record<string, unknown>;
};

export type AgentGoalInput = {
  objective: string;
  completionCriteria?: string[];
  evidence?: string[];
  metadata?: Record<string, unknown>;
};

export type AgentGoal = {
  goalId: string;
  objective: string;
  completionCriteria: string[];
  evidence: string[];
  metadata?: Record<string, unknown>;
};

export type LoopControlDecision = "continue" | "complete" | "pause" | "block" | "fail";

export type LoopControl = {
  decision: LoopControlDecision;
  reason: string;
};

export type AgentRunSuccess = {
  ok: true;
  runId: string;
  sessionId: string;
  status: "succeeded";
  goal: AgentGoal;
  loopControl: LoopControl;
  artifacts: AgentArtifact[];
  eventSummary: AgentEventSummary;
  trace?: AgentTraceRef;
  summary?: string;
};

export type AgentRunFailure = {
  ok: false;
  runId: string;
  sessionId: string;
  status: "failed";
  goal: AgentGoal;
  loopControl: LoopControl;
  error: AgentRuntimeError;
  artifacts: AgentArtifact[];
  eventSummary: AgentEventSummary;
  trace?: AgentTraceRef;
};

export type AgentRunResult = AgentRunSuccess | AgentRunFailure;

export type RuntimeTracingConfig = {
  provider: "openai-agents";
  enabled?: boolean;
  groupBy?: "session" | "run";
};

export type AgentRuntimeOptions = {
  executor?: AgentExecutor;
  executorKind?: ExecutorKind;
  provider?: RuntimeProviderConfig;
  eventSink?: AgentEventSink;
  sessionLogStore?: AgentSessionLogStore;
  tracing?: RuntimeTracingConfig;
  policy?: RuntimePolicy;
  maxTurns?: number | null;
  builtinTools?: RuntimeBuiltinToolsConfig;
  customTools?: AgentTool[];
  mcpServers?: McpServerDefinition[];
  skillRoots?: string[];
  middleware?: AgentMiddleware[];
};

export type RuntimeBuiltinToolsConfig = {
  pollinations?: boolean;
};

export type AgentRunMiddlewareContext = {
  runId: string;
  sessionId: string;
  workspaceDir: string;
  prompt: string;
  goal: AgentGoal;
  traceId?: string;
};

export type AgentToolMiddlewareContext = AgentRunMiddlewareContext & {
  tool: AgentTool;
  input?: unknown;
  output?: unknown;
};

export type AgentArtifactMiddlewareContext = AgentRunMiddlewareContext & {
  artifacts: AgentArtifact[];
};

export type AgentErrorMiddlewareContext = AgentRunMiddlewareContext & {
  error: AgentRuntimeError;
};

export type AgentMiddleware = {
  beforeRun?(context: AgentRunMiddlewareContext): Promise<void> | void;
  beforeToolCall?(context: AgentToolMiddlewareContext): Promise<void> | void;
  afterToolCall?(context: AgentToolMiddlewareContext): Promise<void> | void;
  afterArtifactScan?(context: AgentArtifactMiddlewareContext): Promise<void> | void;
  onError?(context: AgentErrorMiddlewareContext): Promise<void> | void;
};

export class AgentRuntime {
  private readonly executor: AgentExecutor;
  private readonly executorKind: ExecutorKind;
  private readonly provider?: RuntimeProviderConfig;
  private readonly eventSink: AgentEventSink;
  private readonly sessionLogStore: AgentSessionLogStore;
  private readonly tracing: Required<RuntimeTracingConfig>;
  private readonly policy: RuntimePolicy;
  private readonly maxTurns?: number | null;
  private readonly builtinTools: Required<RuntimeBuiltinToolsConfig>;
  private readonly customTools: AgentTool[];
  private readonly mcpServers: McpServerDefinition[];
  private readonly skillRoots?: string[];
  private readonly middleware: AgentMiddleware[];

  constructor(options: AgentRuntimeOptions = {}) {
    this.executorKind = options.executorKind ?? "sandbox";
    this.executor = options.executor ?? createDefaultExecutor(this.executorKind);
    this.provider = options.provider;
    this.eventSink = options.eventSink ?? new MemoryEventSink();
    this.sessionLogStore = options.sessionLogStore ?? new MemorySessionLogStore();
    this.tracing = {
      provider: "openai-agents",
      enabled: true,
      groupBy: "session",
      ...options.tracing,
    };
    this.policy = options.policy ?? {};
    this.maxTurns = options.maxTurns;
    this.builtinTools = {
      pollinations: options.builtinTools?.pollinations ?? true,
    };
    this.customTools = options.customTools ?? [];
    this.mcpServers = options.mcpServers ?? [];
    this.skillRoots = options.skillRoots;
    this.middleware = options.middleware ?? [];
  }

  executorIdForTesting(): string {
    return this.executor.id;
  }

  async run(request: AgentRunRequest): Promise<AgentRunResult> {
    await ensureAgentWorkspace({ workspaceDir: request.workspaceDir });
    const skillRoots = await discoverSkillRoots({ workspaceDir: request.workspaceDir, skillRoots: this.skillRoots });
    const skills = await new SkillDeckProvider().load({ roots: skillRoots });
    const runId = `run_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 8)}`;
    const sessionId = request.sessionId ?? `session_${Date.now().toString(36)}`;
    const goal = createGoal(request, runId);
    const runContext: AgentRunMiddlewareContext = {
      runId,
      sessionId,
      workspaceDir: request.workspaceDir,
      prompt: request.prompt,
      goal,
      traceId: request.traceId,
    };
    const eventBus = new AgentEventBus({
      eventSink: this.eventSink,
      sessionLogStore: this.sessionLogStore,
    });
    const emitted = new Array<AgentEvent>();
    eventBus.subscribe((event) => {
      emitted.push(event);
    });
    await eventBus.publish(createEvent({
      type: "agent.run.started",
      runId,
      sessionId,
      traceId: request.traceId,
      level: "info",
      channels: ["session", "log", "stream"],
      message: "Run started",
      data: { workspaceDir: request.workspaceDir },
    }));
    await eventBus.publish(createEvent({
      type: "user.prompt",
      runId,
      sessionId,
      traceId: request.traceId,
      level: "info",
      channels: ["session"],
      message: "Prompt received",
      data: { prompt: request.prompt },
    }));
    await this.runBeforeRun(runContext);

    const tools = await this.prepareTools({ runContext, eventBus, skills, workspaceDir: request.workspaceDir });
    const policyError = this.validateToolPolicy(tools);
    if (policyError) return this.failBeforeExecutor({ request, runId, sessionId, goal, runContext, eventBus, emitted, error: policyError });

    const executorResult = await this.runExecutorSafely({
      runId,
      sessionId,
      workspaceDir: request.workspaceDir,
      prompt: request.prompt,
      maxTurns: request.maxTurns ?? this.maxTurns,
      traceId: request.traceId,
      provider: this.provider,
      skills,
      tools,
      mcpServers: this.mcpServers,
      requiredOutputFiles: request.requiredOutputFiles ?? [],
    });
    const artifacts = (await new ArtifactScanner().scan({ workspaceDir: request.workspaceDir })).artifacts;
    await this.runAfterArtifactScan({ ...runContext, artifacts });
    if (!executorResult.ok) {
      const loopControl = createLoopControl("fail", "executor_failed");
      await this.runOnError({ ...runContext, error: executorResult.error });
      await eventBus.publish(createEvent({
        type: "agent.run.failed",
        runId,
        sessionId,
        traceId: request.traceId,
        level: "error",
        channels: ["session", "log", "stream"],
        message: executorResult.error.message,
        data: { code: executorResult.error.code, category: executorResult.error.category, loopControl },
      }));
      const events = await this.eventSink.list?.({ runId });
      return {
        ok: false,
        runId,
        sessionId,
        status: "failed",
        goal,
        loopControl,
        error: executorResult.error,
        artifacts,
        eventSummary: summarizeEvents([...(events ?? []), ...emitted]),
        trace: this.traceRef(runId, sessionId, request.traceId),
      };
    }

    for (const artifact of artifacts) {
      await eventBus.publish(createEvent({
        type: "agent.artifact.detected",
        runId,
        sessionId,
        traceId: request.traceId,
        level: "info",
        channels: ["session", "log", "stream"],
        message: `Artifact detected: ${artifact.localPath}`,
        data: { artifact },
      }));
    }
    const requiredOutputError = await validateRequiredOutputFiles(
      request.workspaceDir,
      request.requiredOutputFiles ?? [],
      artifacts,
      executorResult.finalOutput,
    );
    if (requiredOutputError) {
      const loopControl = createLoopControl("fail", "required_output_files_missing");
      await this.runOnError({ ...runContext, error: requiredOutputError });
      await eventBus.publish(createEvent({
        type: "agent.run.failed",
        runId,
        sessionId,
        traceId: request.traceId,
        level: "error",
        channels: ["session", "log", "stream"],
        message: requiredOutputError.message,
        data: {
          code: requiredOutputError.code,
          category: requiredOutputError.category,
          details: requiredOutputError.details,
          loopControl,
        },
      }));
      const events = await this.eventSink.list?.({ runId });
      return {
        ok: false,
        runId,
        sessionId,
        status: "failed",
        goal,
        loopControl,
        error: requiredOutputError,
        artifacts,
        eventSummary: summarizeEvents([...(events ?? []), ...emitted]),
        trace: this.traceRef(runId, sessionId, request.traceId),
      };
    }
    const loopControl = createLoopControl("complete", "executor_succeeded");
    await eventBus.publish(createEvent({
      type: "agent.run.finished",
      runId,
      sessionId,
      traceId: request.traceId,
      level: "info",
      channels: ["session", "log", "stream"],
      message: "Run finished",
      data: { loopControl },
    }));
    const events = await this.eventSink.list?.({ runId });
    return {
      ok: true,
      runId,
      sessionId,
      status: "succeeded",
      goal,
      loopControl,
      artifacts,
      eventSummary: summarizeEvents([...(events ?? []), ...emitted]),
      trace: this.traceRef(runId, sessionId, request.traceId),
      summary: executorResult.finalOutput,
    };
  }

  async *stream(request: AgentRunRequest): AsyncIterable<AgentEvent> {
    const result = await this.run(request);
    const sessionEvents = await this.readSessionEvents(result.sessionId);
    for (const event of sessionEvents) {
      if (event.runId === result.runId && event.channels.includes("stream")) {
        yield event;
      }
    }
  }

  async readSessionEvents(sessionId: string): Promise<AgentEvent[]> {
    return this.sessionLogStore.read(sessionId);
  }

  async getSessionSummary(sessionId: string): Promise<AgentSessionSummary | undefined> {
    const events = await this.readSessionEvents(sessionId);
    if (events.length === 0) return undefined;

    const runIds = [...new Set(events.map((event) => event.runId))];
    const failedEvent = findLastEvent(events, "agent.run.failed");
    const finishedEvent = findLastEvent(events, "agent.run.finished");
    const startedEvent = events.find((event) => event.type === "agent.run.started");
    const latestEvent = events.at(-1);
    return {
      sessionId,
      status: failedEvent ? "failed" : finishedEvent ? "succeeded" : "active",
      runIds,
      latestRunId: latestEvent?.runId,
      workspaceDir: typeof startedEvent?.data?.workspaceDir === "string" ? startedEvent.data.workspaceDir : undefined,
      artifactCount: events.filter((event) => event.type === "agent.artifact.detected").length,
      createdAt: events[0]?.timestamp,
      updatedAt: latestEvent?.timestamp,
      lastError: failedEvent
        ? {
            category: isRuntimeErrorCategory(failedEvent.data?.category) ? failedEvent.data.category : "unknown",
            code: typeof failedEvent.data?.code === "string" ? failedEvent.data.code : "SESSION_FAILED",
            message: failedEvent.message,
            recoverable: true,
          }
        : undefined,
    };
  }

  async listSkills(request: { roots?: string[] } = {}): Promise<SkillDeckLoadResult> {
    const roots = request.roots ?? this.skillRoots ?? [];
    return new SkillDeckProvider().load({ roots });
  }

  listMcpServers(): McpServerDefinition[] {
    return [...this.mcpServers];
  }

  private async failBeforeExecutor(input: {
    request: AgentRunRequest;
    runId: string;
    sessionId: string;
    goal: AgentGoal;
    runContext: AgentRunMiddlewareContext;
    eventBus: AgentEventBus;
    emitted: AgentEvent[];
    error: AgentRuntimeError;
  }): Promise<AgentRunFailure> {
    const loopControl = createLoopControl("fail", "tool_policy_failed");
    await this.runOnError({ ...input.runContext, error: input.error });
    await input.eventBus.publish(createEvent({
      type: "agent.run.failed",
      runId: input.runId,
      sessionId: input.sessionId,
      traceId: input.request.traceId,
      level: "error",
      channels: ["session", "log", "stream"],
      message: input.error.message,
      data: { code: input.error.code, category: input.error.category, loopControl },
    }));
    const events = await this.eventSink.list?.({ runId: input.runId });
    return {
      ok: false,
      runId: input.runId,
      sessionId: input.sessionId,
      status: "failed",
      goal: input.goal,
      loopControl,
      error: input.error,
      artifacts: [],
      eventSummary: summarizeEvents([...(events ?? []), ...input.emitted]),
      trace: this.traceRef(input.runId, input.sessionId, input.request.traceId),
    };
  }

  private async prepareTools(input: {
    runContext: AgentRunMiddlewareContext;
    eventBus: AgentEventBus;
    skills: SkillDeckLoadResult;
    workspaceDir: string;
  }): Promise<AgentTool[]> {
    const [workspaceTools, skillTools, builtinTools, customTools] = await Promise.all([
      this.executorKind === "agent"
        ? Promise.resolve(createWorkspaceAgentTools({
            workspaceDir: input.workspaceDir,
            command: { enabled: this.policy.tools?.enableWorkspaceCommandTool ?? false },
          }))
        : Promise.resolve([]),
      Promise.resolve(createSkillDeckAgentTools(input.skills)),
      Promise.resolve(this.builtinTools.pollinations ? [createPollinationsStorybookImageTool()] : []),
      Promise.resolve(this.customTools),
    ]);

    const approvalRequired = new Set(this.policy.tools?.requireApprovalToolIds ?? []);
    return [
      ...workspaceTools,
      ...customTools,
      ...skillTools,
      ...builtinTools,
    ].map((tool) => ({
      ...tool,
      requiresApproval: tool.requiresApproval || approvalRequired.has(tool.id) || undefined,
      execute: async (toolInput, context) => {
        await this.runBeforeToolCall({ ...input.runContext, tool, input: toolInput });
        await input.eventBus.publish(createEvent({
          type: "agent.tool.started",
          runId: input.runContext.runId,
          sessionId: input.runContext.sessionId,
          traceId: input.runContext.traceId,
          level: "info",
          channels: ["session", "log", "stream"],
          message: `Tool started: ${tool.id}`,
          data: { toolId: tool.id, source: tool.source, input: toolInput },
        }));
        try {
          const output = await tool.execute(toolInput, {
            workspaceDir: context.workspaceDir,
            runId: input.runContext.runId,
            traceId: input.runContext.traceId,
          });
          await input.eventBus.publish(createEvent({
            type: "agent.tool.finished",
            runId: input.runContext.runId,
            sessionId: input.runContext.sessionId,
            traceId: input.runContext.traceId,
            level: "info",
            channels: ["session", "log", "stream"],
            message: `Tool finished: ${tool.id}`,
            data: { toolId: tool.id, source: tool.source, input: toolInput, output },
          }));
          await this.runAfterToolCall({ ...input.runContext, tool, input: toolInput, output });
          return output;
        } catch (error) {
          await input.eventBus.publish(createEvent({
            type: "agent.tool.failed",
            runId: input.runContext.runId,
            sessionId: input.runContext.sessionId,
            traceId: input.runContext.traceId,
            level: "error",
            channels: ["session", "log", "stream"],
            message: `Tool failed: ${tool.id}`,
            data: {
              toolId: tool.id,
              source: tool.source,
              input: toolInput,
              error: error instanceof Error ? error.message : "Unknown tool failure.",
            },
          }));
          throw error;
        }
      },
    }));
  }

  private async runExecutorSafely(request: Parameters<AgentExecutor["run"]>[0]) {
    try {
      return await this.executor.run(request);
    } catch (error) {
      return {
        ok: false as const,
        error: {
          category: "generation" as const,
          code: "EXECUTOR_UNHANDLED_ERROR",
          message: error instanceof Error ? error.message : "Executor failed with an unhandled error.",
          recoverable: true,
          cause: error,
        },
      };
    }
  }

  private async runBeforeRun(context: AgentRunMiddlewareContext): Promise<void> {
    await Promise.all(this.middleware.map((middleware) => middleware.beforeRun?.(context)));
  }

  private async runBeforeToolCall(context: AgentToolMiddlewareContext): Promise<void> {
    await Promise.all(this.middleware.map((middleware) => middleware.beforeToolCall?.(context)));
  }

  private async runAfterToolCall(context: AgentToolMiddlewareContext): Promise<void> {
    await Promise.all(this.middleware.map((middleware) => middleware.afterToolCall?.(context)));
  }

  private async runAfterArtifactScan(context: AgentArtifactMiddlewareContext): Promise<void> {
    await Promise.all(this.middleware.map((middleware) => middleware.afterArtifactScan?.(context)));
  }

  private async runOnError(context: AgentErrorMiddlewareContext): Promise<void> {
    await Promise.all(this.middleware.map((middleware) => middleware.onError?.(context)));
  }

  private validateToolPolicy(tools: AgentTool[]): AgentRuntimeError | undefined {
    const denied = new Set(this.policy.tools?.deniedToolIds ?? []);
    for (const tool of tools) {
      if (denied.has(tool.id)) {
        return {
          category: "skill",
          code: "TOOL_POLICY_DENIED",
          message: `Tool is denied by policy: ${tool.id}`,
          recoverable: true,
        };
      }
    }
    const allowed = this.policy.tools?.allowedToolIds;
    if (allowed && allowed.length > 0) {
      const allowedSet = new Set(allowed);
      const disallowed = tools.find((tool) => !allowedSet.has(tool.id));
      if (disallowed) {
        return {
          category: "skill",
          code: "TOOL_POLICY_DENIED",
          message: `Tool is not in allowed list: ${disallowed.id}`,
          recoverable: true,
        };
      }
    }
    return undefined;
  }

  private traceRef(runId: string, sessionId: string, traceId?: string): AgentTraceRef {
    return {
      provider: "openai-agents",
      traceId: traceId ?? runId,
      groupId: this.tracing.groupBy === "session" ? sessionId : runId,
      disabled: !this.tracing.enabled,
    };
  }
}

function createGoal(request: AgentRunRequest, runId: string): AgentGoal {
  const input = request.goal;
  return {
    goalId: `goal_${runId.slice(4)}`,
    objective: input?.objective ?? request.prompt,
    completionCriteria: input?.completionCriteria ?? ["Agent run completed without errors."],
    evidence: input?.evidence ?? [],
    metadata: input?.metadata,
  };
}

function createLoopControl(decision: LoopControlDecision, reason: string): LoopControl {
  return { decision, reason };
}

function createDefaultExecutor(kind: ExecutorKind): AgentExecutor {
  if (kind === "agent") return new OpenAIAgentExecutor();
  return new OpenAISandboxExecutor();
}

async function validateRequiredOutputFiles(
  workspaceDir: string,
  requiredOutputFiles: string[],
  artifacts: AgentArtifact[],
  executorFinalOutput?: string,
): Promise<AgentRuntimeError | undefined> {
  if (requiredOutputFiles.length === 0) return undefined;

  const missingOutputFiles = new Array<string>();
  for (const requiredOutputFile of requiredOutputFiles) {
    const relativePath = normalizeRequiredOutputPath(requiredOutputFile);
    if (!relativePath) {
      missingOutputFiles.push(requiredOutputFile);
      continue;
    }

    try {
      const stat = await fs.stat(path.join(workspaceDir, relativePath));
      if (!stat.isFile() || stat.size === 0) {
        missingOutputFiles.push(relativePath);
      }
    } catch {
      missingOutputFiles.push(relativePath);
    }
  }
  if (missingOutputFiles.length === 0) return undefined;

  return {
    category: "generation",
    code: "REQUIRED_OUTPUT_FILES_MISSING",
    message: `Required output files are missing or empty: ${missingOutputFiles.join(", ")}`,
    recoverable: true,
    details: {
      missingOutputFiles,
      existingOutputFiles: artifacts.map((artifact) => artifact.localPath),
      executorFinalOutput: truncateDiagnosticText(executorFinalOutput),
    },
  };
}

function truncateDiagnosticText(value: string | undefined): string | undefined {
  if (!value) return undefined;
  return value.length > 500 ? `${value.slice(0, 500)}...` : value;
}

function normalizeRequiredOutputPath(requiredOutputFile: string): string | undefined {
  const normalized = path.posix.normalize(requiredOutputFile.replaceAll(path.sep, "/")).replace(/^\.\//, "");
  if (normalized === "output" || !normalized.startsWith("output/") || normalized.includes("../")) return undefined;
  return normalized;
}

export { FakeExecutor, OpenAISandboxExecutor };
export type { AgentExecutor, RuntimeProviderConfig };
