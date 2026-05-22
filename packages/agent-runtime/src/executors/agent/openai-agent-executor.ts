import { Agent, MemorySession, Runner } from "@openai/agents";

import { toOpenAIAgentsMcpTools } from "../../mcp/index.js";
import { toOpenAIAgentsTool } from "../../tools/index.js";
import { diagnoseOpenAIAgentError } from "../provider-diagnostics.js";
import { createOpenAIRunnerConfig } from "../sandbox/openai-sandbox-executor.js";
import { configureOpenAITracingForProvider, shouldDisableOpenAITracing } from "../sandbox/tracing.js";
import type { AgentExecutor, ExecutorRunRequest, ExecutorRunResult } from "../types.js";
import { createOpenAIAgentInstructions } from "./instructions.js";

export class OpenAIAgentExecutor implements AgentExecutor {
  readonly id = "openai-agent";
  private readonly sessions = new Map<string, MemorySession>();

  async run(request: ExecutorRunRequest): Promise<ExecutorRunResult> {
    try {
      configureOpenAITracingForProvider(request.provider);
      const agent = new Agent({
        name: "KidMemory Agent Runtime",
        model: request.provider?.model,
        instructions: createOpenAIAgentInstructions(),
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
      });
      return {
        ok: true,
        finalOutput: result.finalOutput ?? "",
      };
    } catch (error) {
      return {
        ok: false,
        error: diagnoseOpenAIAgentError(error, request.provider),
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
