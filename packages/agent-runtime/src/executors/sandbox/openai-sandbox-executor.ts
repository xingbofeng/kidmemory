import {
  MemorySession,
  OpenAIProvider,
  Runner,
  type OpenAIProviderOptions,
  type RunConfig,
} from "@openai/agents";
import { SandboxAgent } from "@openai/agents/sandbox";
import { UnixLocalSandboxClient } from "@openai/agents/sandbox/local";

import { toOpenAIAgentsMcpTools } from "../../mcp/index.js";
import { toOpenAIAgentsTool } from "../../tools/index.js";
import { diagnoseOpenAISandboxError } from "../provider-diagnostics.js";
import type { AgentExecutor, ExecutorRunRequest, ExecutorRunResult, RuntimeProviderConfig } from "../types.js";
import { createOpenAISandboxRuntimeCapabilities } from "./capabilities.js";
import { createOpenAISandboxManifest } from "./manifest.js";
import { configureOpenAITracingForProvider, shouldDisableOpenAITracing } from "./tracing.js";

export class OpenAISandboxExecutor implements AgentExecutor {
  readonly id = "openai-sandbox";
  private readonly sessions = new Map<string, MemorySession>();

  async run(request: ExecutorRunRequest): Promise<ExecutorRunResult> {
    try {
      configureOpenAITracingForProvider(request.provider);
      const agent = new SandboxAgent({
        name: "KidMemory Agent Runtime",
        model: request.provider?.model,
        instructions: [
          "You are running inside a KidMemory controlled workspace.",
          "First inspect .kidmemory/runtime.md if it exists.",
          "Use input/ as read-only context, work/ for scratch, and output/ for final artifacts.",
          "Do not edit .kidmemory/ directly.",
        ].join("\n"),
        defaultManifest: {
          ...createOpenAISandboxManifest(request.workspaceDir),
        },
        capabilities: createOpenAISandboxRuntimeCapabilities(request.skills, {
          useResponses: request.provider?.useResponses,
        }),
        tools: [
          ...request.tools.map((agentTool) =>
            toOpenAIAgentsTool(agentTool, {
              workspaceDir: request.workspaceDir,
              runId: request.runId,
              traceId: request.traceId,
            }),
          ),
          ...toOpenAIAgentsMcpTools(request.mcpServers),
        ],
      });
      const runner = new Runner({
        ...createOpenAIRunnerConfig(request.provider),
        tracingDisabled: shouldDisableOpenAITracing(request.provider),
        traceIncludeSensitiveData: false,
        traceId: request.traceId,
        groupId: request.sessionId,
      });
      const result = await runner.run(agent, request.prompt, {
        session: this.sessionFor(request.sessionId),
        maxTurns: request.maxTurns,
        sandbox: {
          client: new UnixLocalSandboxClient(),
        },
      });
      return {
        ok: true,
        finalOutput: result.finalOutput ?? "",
      };
    } catch (error) {
      return {
        ok: false,
        error: diagnoseOpenAISandboxError(error, request.provider),
      };
    }
  }

  private sessionFor(sessionId: string): MemorySession {
    const existing = this.sessions.get(sessionId);
    if (existing) return existing;
    const session = new MemorySession({ sessionId });
    this.sessions.set(sessionId, session);
    return session;
  }
}

export function toOpenAIProviderOptions(provider?: RuntimeProviderConfig): OpenAIProviderOptions | undefined {
  if (!provider?.apiKey && !provider?.baseURL) return undefined;
  return {
    apiKey: provider.apiKey,
    baseURL: provider.baseURL,
    cacheResponsesWebSocketModels: false,
    useResponses: provider.useResponses,
  };
}

export function createOpenAIRunnerConfig(provider?: RuntimeProviderConfig): Partial<RunConfig> {
  const providerOptions = toOpenAIProviderOptions(provider);
  return providerOptions
    ? {
        modelProvider: new OpenAIProvider(providerOptions),
      }
    : {};
}
