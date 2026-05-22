import fs from "node:fs/promises";

import type { AgentTool } from "../index.js";
import { readToolPath, resolveReadableWorkspacePath } from "./path-policy.js";

export function createListFilesTool(options: { workspaceDir: string }): AgentTool {
  return {
    id: "list_files",
    name: "List Files",
    description: "List files under a workspace-relative directory.",
    source: "workspace",
    inputSchema: {
      type: "object",
      properties: {
        path: { type: "string" },
      },
      additionalProperties: false,
    },
    risk: "low",
    execute: async (input) => {
      const resolved = resolveReadableWorkspacePath(options.workspaceDir, readToolPath(input));
      const entries = await fs.readdir(resolved.absolutePath, { withFileTypes: true });
      return {
        path: resolved.relativePath,
        entries: entries.map((entry) => ({
          name: entry.name,
          type: entry.isDirectory() ? "directory" : "file",
        })).sort((left, right) => left.name.localeCompare(right.name)),
      };
    },
  };
}
