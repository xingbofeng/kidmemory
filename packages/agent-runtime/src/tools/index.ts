import { tool as openAIAgentsTool, type FunctionTool } from "@openai/agents";
import { createEditFileTool } from "./edit-file.tool.js";
import { createListFilesTool } from "./list-files.tool.js";
import { createReadFileTool } from "./read-file.tool.js";
import { createRunCommandTool } from "./run-command.tool.js";
import { createSearchFilesTool } from "./search-files.tool.js";
import { createWriteFileTool } from "./write-file.tool.js";

export { createPollinationsStorybookImageTool, type PollinationsStorybookImageToolOptions } from "./generate-storybook-image.tool.js";

export type AgentTool = {
  id: string;
  name: string;
  description: string;
  source: "skill-deck" | "custom" | "builtin" | "sandbox" | "workspace" | "mcp";
  inputSchema: unknown;
  outputSchema?: unknown;
  risk: "low" | "medium" | "high";
  requiresApproval?: boolean;
  execute(input: unknown, context: ToolExecutionContext): Promise<unknown>;
};

export type ToolExecutionContext = {
  workspaceDir: string;
  runId?: string;
  traceId?: string;
  signal?: {
    aborted: boolean;
    reason?: unknown;
    addEventListener?: (type: "abort", listener: () => void, options?: { once?: boolean }) => void;
    removeEventListener?: (type: "abort", listener: () => void) => void;
  };
};

type NonStrictOpenAIToolOptions = Extract<
  Parameters<typeof openAIAgentsTool>[0],
  { strict: false }
>;
type OpenAIToolParameters = NonStrictOpenAIToolOptions["parameters"];

export type RuntimePolicy = {
  tools?: ToolPolicy;
};

export type ToolPolicy = {
  allowedToolIds?: string[];
  deniedToolIds?: string[];
  requireApprovalToolIds?: string[];
  enableWorkspaceCommandTool?: boolean;
};

export function createFilesystemAgentTools(options: {
  workspaceDir: string;
  command?: {
    enabled: boolean;
    timeoutMs?: number;
    allowedCommands?: string[];
  };
}): AgentTool[] {
  const tools = [
    createListFilesTool(options),
    createReadFileTool(options),
    createWriteFileTool(options),
    createEditFileTool(options),
    createSearchFilesTool(options),
  ];

  if (options.command?.enabled) {
    tools.push(createRunCommandTool({
      workspaceDir: options.workspaceDir,
      timeoutMs: options.command.timeoutMs,
      allowedCommands: options.command.allowedCommands,
    }));
  }

  return tools;
}

export const createWorkspaceAgentTools = createFilesystemAgentTools;

export function toOpenAIAgentsTool(agentTool: AgentTool, context: ToolExecutionContext): FunctionTool {
  return openAIAgentsTool({
    name: agentTool.id,
    description: agentTool.description,
    parameters: agentTool.inputSchema as OpenAIToolParameters,
    strict: false,
    needsApproval: agentTool.requiresApproval ?? false,
    execute: async (input) => agentTool.execute(input, context),
  });
}
