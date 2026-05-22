import type { AgentTool } from "../index.js";
import { createEditFileTool } from "./edit-file.tool.js";
import { createListFilesTool } from "./list-files.tool.js";
import { createReadFileTool } from "./read-file.tool.js";
import { createRunCommandTool } from "./run-command.tool.js";
import { createSearchFilesTool } from "./search-files.tool.js";
import { createWriteFileTool } from "./write-file.tool.js";

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
