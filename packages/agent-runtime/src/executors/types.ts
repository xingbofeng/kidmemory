import type { AgentRuntimeError } from "../core/errors.js";
import type { McpServerDefinition } from "../mcp/index.js";
import type { SkillDeckLoadResult } from "../skills/index.js";
import type { AgentTool } from "../tools/index.js";

export type ExecutorKind = "sandbox" | "agent";

export type RuntimeProviderConfig = {
  model?: string;
  baseURL?: string;
  apiKey?: string;
  useResponses?: boolean;
};

export type ExecutorRunRequest = {
  runId: string;
  sessionId: string;
  workspaceDir: string;
  prompt: string;
  maxTurns?: number | null;
  traceId?: string;
  provider?: RuntimeProviderConfig;
  skills: SkillDeckLoadResult;
  tools: AgentTool[];
  mcpServers: McpServerDefinition[];
  requiredOutputFiles?: string[];
};

export type ExecutorRunResult =
  | {
      ok: true;
      finalOutput?: string;
    }
  | {
      ok: false;
      error: AgentRuntimeError;
    };

export interface AgentExecutor {
  readonly id: string;
  run(request: ExecutorRunRequest): Promise<ExecutorRunResult>;
}
