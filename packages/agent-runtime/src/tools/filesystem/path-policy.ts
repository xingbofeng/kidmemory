import path from "node:path";

export const DEFAULT_IGNORED_DIRECTORIES = new Set([".git", "node_modules", "dist", ".kidmemory/sessions", ".kidmemory/logs"]);

export type ResolvedWorkspacePath = {
  relativePath: string;
  absolutePath: string;
};

export function resolveReadableWorkspacePath(workspaceDir: string, inputPath: string): ResolvedWorkspacePath {
  const resolved = resolveWorkspacePath(workspaceDir, inputPath);
  if (resolved.relativePath.startsWith(".kidmemory/sessions/") || resolved.relativePath.startsWith(".kidmemory/logs/")) {
    throw new Error("Path is not readable by the agent.");
  }
  return resolved;
}

export function resolveWritableWorkspacePath(workspaceDir: string, inputPath: string): ResolvedWorkspacePath {
  const resolved = resolveWorkspacePath(workspaceDir, inputPath);
  if (!resolved.relativePath.startsWith("work/") && !resolved.relativePath.startsWith("output/")) {
    throw new Error("Write path is not allowed. Use work/ or output/.");
  }
  return resolved;
}

export function resolveWorkspacePath(workspaceDir: string, inputPath: string): ResolvedWorkspacePath {
  const relativePath = normalizeRelativePath(inputPath);
  const absoluteWorkspaceDir = path.resolve(workspaceDir);
  const absolutePath = path.resolve(absoluteWorkspaceDir, relativePath);
  if (absolutePath !== absoluteWorkspaceDir && !absolutePath.startsWith(`${absoluteWorkspaceDir}${path.sep}`)) {
    throw new Error("Path must stay inside workspace.");
  }
  return { relativePath, absolutePath };
}

export function normalizeRelativePath(inputPath: string): string {
  const normalized = inputPath.trim().replaceAll("\\", "/").replace(/^\/+/, "");
  if (!normalized) return ".";
  return path.posix.normalize(normalized);
}

export function readToolPath(input: unknown, fallback = "."): string {
  if (!input || typeof input !== "object" || !("path" in input)) return fallback;
  const value = (input as Record<string, unknown>).path;
  return typeof value === "string" && value.trim().length > 0 ? value : fallback;
}

export function readNumber(input: unknown, key: string, fallback: number): number {
  if (!input || typeof input !== "object" || !(key in input)) return fallback;
  const value = (input as Record<string, unknown>)[key];
  const parsed = typeof value === "number" ? value : Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
}

export function isIgnoredWorkspaceRelativePath(relativePath: string): boolean {
  const normalized = normalizeRelativePath(relativePath);
  for (const ignored of DEFAULT_IGNORED_DIRECTORIES) {
    if (normalized === ignored || normalized.startsWith(`${ignored}/`)) return true;
  }
  return false;
}
