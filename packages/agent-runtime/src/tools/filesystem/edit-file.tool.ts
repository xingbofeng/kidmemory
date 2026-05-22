import fs from "node:fs/promises";

import type { AgentTool } from "../index.js";
import { readToolPath, resolveWritableWorkspacePath } from "./path-policy.js";

export function createEditFileTool(options: { workspaceDir: string }): AgentTool {
  return {
    id: "edit_file",
    name: "Edit File",
    description: "Replace exact text in a workspace file under work/ or output/. Prefer this over full rewrites.",
    source: "workspace",
    inputSchema: {
      type: "object",
      properties: {
        path: { type: "string" },
        search: { type: "string" },
        replace: { type: "string" },
        replaceAll: { type: "boolean" },
      },
      required: ["path", "search", "replace"],
      additionalProperties: false,
    },
    risk: "medium",
    execute: async (input) => {
      const search = readString(input, "search");
      const replace = readString(input, "replace");
      const replaceAll = readBoolean(input, "replaceAll");
      const resolved = resolveWritableWorkspacePath(options.workspaceDir, readToolPath(input));
      const before = await fs.readFile(resolved.absolutePath, "utf8");
      const matches = before.split(search).length - 1;
      if (matches === 0) {
        throw new Error("Search text was not found.");
      }
      if (matches > 1 && !replaceAll) {
        throw new Error("Search text is not unique. Provide more context or set replaceAll.");
      }
      const after = replaceAll ? before.replaceAll(search, replace) : before.replace(search, replace);
      await fs.writeFile(resolved.absolutePath, after, "utf8");
      return {
        ok: true,
        path: resolved.relativePath,
        replacements: replaceAll ? matches : 1,
      };
    },
  };
}

function readString(input: unknown, key: string): string {
  if (!input || typeof input !== "object" || !(key in input)) return "";
  const value = (input as Record<string, unknown>)[key];
  return typeof value === "string" ? value : String(value ?? "");
}

function readBoolean(input: unknown, key: string): boolean {
  if (!input || typeof input !== "object" || !(key in input)) return false;
  return (input as Record<string, unknown>)[key] === true;
}
