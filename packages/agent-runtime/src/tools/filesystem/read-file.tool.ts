import fs from "node:fs/promises";

import type { AgentTool } from "../index.js";
import { readNumber, readToolPath, resolveReadableWorkspacePath } from "./path-policy.js";

const DEFAULT_LINE_LIMIT = 2_000;

export function createReadFileTool(options: { workspaceDir: string }): AgentTool {
  return {
    id: "read_file",
    name: "Read File",
    description: "Read a UTF-8 file from the workspace. Use offset and limit for large files.",
    source: "workspace",
    inputSchema: {
      type: "object",
      properties: {
        path: { type: "string" },
        offset: { type: "number" },
        limit: { type: "number" },
      },
      required: ["path"],
      additionalProperties: false,
    },
    risk: "low",
    execute: async (input) => {
      const resolved = resolveReadableWorkspacePath(options.workspaceDir, readToolPath(input));
      const offset = Math.max(0, Math.floor(readNumber(input, "offset", 0)));
      const limit = Math.max(1, Math.floor(readNumber(input, "limit", DEFAULT_LINE_LIMIT)));
      const content = await fs.readFile(resolved.absolutePath, "utf8");
      const lines = content.split(/\r?\n/);
      const selected = lines.slice(offset, offset + limit);
      return {
        path: resolved.relativePath,
        offset,
        limit,
        totalLines: lines.length,
        truncated: offset + selected.length < lines.length,
        content: selected.map((line, index) => `${offset + index + 1}\t${line}`).join("\n"),
      };
    },
  };
}
