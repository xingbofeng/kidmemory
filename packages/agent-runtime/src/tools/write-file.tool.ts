import fs from "node:fs/promises";
import path from "node:path";

import type { AgentTool } from "../index.js";
import { readString, readToolPath, resolveWritableWorkspacePath } from "./path-policy.js";

export function createWriteFileTool(options: { workspaceDir: string }): AgentTool {
  return {
    id: "write_file",
    name: "Write File",
    description: "Write a UTF-8 file under work/ or output/.",
    source: "workspace",
    inputSchema: {
      type: "object",
      properties: {
        path: { type: "string" },
        content: { type: "string" },
      },
      required: ["path", "content"],
      additionalProperties: false,
    },
    risk: "medium",
    execute: async (input) => {
      const content = readString(input, "content");
      const resolved = resolveWritableWorkspacePath(options.workspaceDir, readToolPath(input));
      await fs.mkdir(path.dirname(resolved.absolutePath), { recursive: true });
      await fs.writeFile(resolved.absolutePath, content, "utf8");
      return {
        ok: true,
        path: resolved.relativePath,
        bytes: Buffer.byteLength(content),
      };
    },
  };
}
