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
  const value = readObjectValue(input, "path");
  return typeof value === "string" && value.trim().length > 0 ? value : fallback;
}

export function readNumber(input: unknown, key: string, fallback: number): number {
  const value = readObjectValue(input, key);
  const parsed = typeof value === "number" ? value : Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
}

export function readString(input: unknown, key: string, fallback = ""): string {
  const value = readObjectValue(input, key);
  return typeof value === "string" ? value : String(value ?? fallback);
}

export function readOptionalString(input: unknown, key: string): string | undefined {
  const value = readObjectValue(input, key);
  if (typeof value !== "string") return undefined;
  const normalized = value.trim();
  return normalized.length > 0 ? normalized : undefined;
}

export function readRequiredString(input: unknown, key: string, errorMessage: string): string {
  const value = readOptionalString(input, key);
  if (!value) {
    throw new Error(errorMessage);
  }
  return value;
}

export function readBoolean(input: unknown, key: string, fallback = false): boolean {
  const value = readObjectValue(input, key);
  return typeof value === "boolean" ? value : fallback;
}

export function readStringArray(input: unknown, key: string): string[] {
  const value = readObjectValue(input, key);
  return Array.isArray(value) ? value.map((item) => String(item)) : [];
}

export function readOptionalNumber(input: unknown, key: string): number | undefined {
  const value = readObjectValue(input, key);
  if (typeof value === "number" && Number.isFinite(value)) return value;
  if (typeof value === "string") {
    const parsed = Number.parseFloat(value);
    return Number.isFinite(parsed) ? parsed : undefined;
  }
  return undefined;
}

function readObjectValue(input: unknown, key: string): unknown {
  if (!input || typeof input !== "object" || !(key in input)) return undefined;
  return (input as Record<string, unknown>)[key];
}

export function isIgnoredWorkspaceRelativePath(relativePath: string): boolean {
  const normalized = normalizeRelativePath(relativePath);
  for (const ignored of DEFAULT_IGNORED_DIRECTORIES) {
    if (normalized === ignored || normalized.startsWith(`${ignored}/`)) return true;
  }
  return false;
}
