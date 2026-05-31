import fs from "node:fs/promises";
import path from "node:path";

import type { AgentTool } from "../index.js";
import { isIgnoredWorkspaceRelativePath, readNumber, readString, readToolPath, resolveReadableWorkspacePath } from "./path-policy.js";

const DEFAULT_SEARCH_LIMIT = 250;

export function createSearchFilesTool(options: { workspaceDir: string }): AgentTool {
  return {
    id: "search_files",
    name: "Search Files",
    description: "Search UTF-8 files under a workspace-relative directory.",
    source: "workspace",
    inputSchema: {
      type: "object",
      properties: {
        query: { type: "string" },
        path: { type: "string" },
        limit: { type: "number" },
      },
      required: ["query"],
      additionalProperties: false,
    },
    risk: "low",
    execute: async (input) => {
      const query = readString(input, "query");
      const limit = Math.max(1, Math.floor(readNumber(input, "limit", DEFAULT_SEARCH_LIMIT)));
      const resolved = resolveReadableWorkspacePath(options.workspaceDir, readToolPath(input));
      const matches = await searchTextFiles(resolved.absolutePath, options.workspaceDir, query, limit);
      return {
        query,
        limit,
        truncated: matches.length >= limit,
        matches,
      };
    },
  };
}

async function searchTextFiles(rootDir: string, workspaceDir: string, query: string, limit: number) {
  const results: Array<{ path: string; line: number; text: string }> = [];
  await visit(rootDir, workspaceDir, query, limit, results);
  return results;
}

async function visit(
  dir: string,
  workspaceDir: string,
  query: string,
  limit: number,
  results: Array<{ path: string; line: number; text: string }>,
): Promise<void> {
  if (results.length >= limit) return;
  const entries = await fs.readdir(dir, { withFileTypes: true });
  for (const entry of entries) {
    const absolutePath = path.join(dir, entry.name);
    const relativePath = path.relative(workspaceDir, absolutePath).replaceAll(path.sep, "/");
    if (isIgnoredWorkspaceRelativePath(relativePath)) continue;
    if (entry.isDirectory()) {
      await visit(absolutePath, workspaceDir, query, limit, results);
      continue;
    }
    const content = await fs.readFile(absolutePath, "utf8").catch(() => "");
    content.split(/\r?\n/).forEach((line, index) => {
      if (results.length < limit && line.includes(query)) {
        results.push({
          path: relativePath,
          line: index + 1,
          text: line,
        });
      }
    });
  }
}
