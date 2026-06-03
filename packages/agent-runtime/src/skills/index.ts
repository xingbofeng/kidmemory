import fs from "node:fs/promises";
import { spawn } from "node:child_process";
import path from "node:path";
import { localDir, skills as sandboxSkills, type Skills } from "@openai/agents/sandbox";
import {
  createSkillHandlers,
  getAgenticSkillTools,
  scanSkills,
  toMcpTools,
  toOpenAIAgentsLocalSkills,
  toUseSkillToolName,
  validateToolArguments,
  type AgenticSkill,
  type AgenticTool,
} from "skill-deck";

import { directoryExists } from "../core/utils.js";
import type { AgentTool } from "../tools/index.js";

export type SkillDeckLoadRequest = {
  roots: string[];
};

export type OpenAIAgentsLocalSkill = {
  name: string;
  description: string;
  path: string;
};

export type McpToolDefinition = {
  name: string;
  description: string;
  inputSchema: Record<string, unknown>;
};

export type SkillDeckLoadResult = {
  roots: string[];
  skills: AgenticSkill[];
  openAIAgentsLocalSkills: OpenAIAgentsLocalSkill[];
  mcpTools: McpToolDefinition[];
};

export function toOpenAISandboxSkillCapabilities(result: SkillDeckLoadResult): Skills[] {
  if (result.openAIAgentsLocalSkills.length === 0) return [];
  return result.roots.map((root) =>
    sandboxSkills({
      lazyFrom: {
        source: localDir({ src: root }),
        index: result.openAIAgentsLocalSkills
          .filter((skill) => path.resolve(skill.path).startsWith(path.resolve(root)))
          .map((skill) => ({
            name: skill.name,
            description: skill.description,
            path: path.relative(root, skill.path).split(path.sep).join("/"),
          })),
      },
    }),
  );
}

export class SkillDeckProvider {
  async load(request: SkillDeckLoadRequest): Promise<SkillDeckLoadResult> {
    const skills = new Array<AgenticSkill>();
    for (const root of request.roots) {
      if (await directoryExists(root)) {
        skills.push(...(await scanSkills(root)));
      }
    }
    return {
      roots: [...request.roots],
      skills,
      openAIAgentsLocalSkills: toOpenAIAgentsLocalSkills(skills),
      mcpTools: toMcpTools(getAgenticSkillTools({ skills, skillMode: "active" })),
    };
  }
}

export function createSkillDeckAgentTools(result: SkillDeckLoadResult): AgentTool[] {
  if (result.skills.length === 0) return [];

  const handlerCache = new Map<string, ReturnType<typeof createSkillHandlers>>();
  const signalIds = new WeakMap<object, number>();
  let nextSignalId = 1;
  const getSignalId = (signal?: Parameters<AgentTool["execute"]>[1]["signal"]): string => {
    if (!signal) return "none";
    let id = signalIds.get(signal);
    if (!id) {
      id = nextSignalId;
      nextSignalId += 1;
      signalIds.set(signal, id);
    }
    return String(id);
  };

  const agenticTools = getAgenticSkillTools({
    skills: result.skills,
    skillMode: "active",
    includeShell: true,
    exposeSkills: result.skills.length,
  });

  return agenticTools
    .map((tool) => createSkillDeckAgentTool(tool, async (toolInput, context) => {
      if (context.signal?.aborted) {
        throw context.signal.reason instanceof Error ? context.signal.reason : new Error("Skill tool execution was aborted.");
      }
      const handlers = getHandlersForContext(
        result,
        context.workspaceDir,
        context.signal,
        handlerCache,
        getSignalId,
      );
      const validatedInput = validateSkillDeckToolInput(
        tool.name,
        normalizeSkillDeckToolInput(
          tool.name,
          toolInput,
          result.skills,
          context.workspaceDir,
        ),
      );
      if (tool.name === "run_skill_shell") {
        await validateSkillShellCommandPolicy(validatedInput, result.skills);
      }
      const handler = handlers[tool.name];
      if (!handler) {
        throw new Error(`SkillDeck handler is not available: ${tool.name}`);
      }
      const output = await handler(validatedInput);
      if (output.error) {
        throw new Error(output.error);
      }
      return {
        text: output.text,
        data: output.data,
      };
    }));
}

function getHandlersForContext(
  result: SkillDeckLoadResult,
  workspaceDir: string,
  signal: Parameters<AgentTool["execute"]>[1]["signal"] | undefined,
  handlerCache: Map<string, ReturnType<typeof createSkillHandlers>>,
  getSignalId: (signal?: Parameters<AgentTool["execute"]>[1]["signal"]) => string,
): ReturnType<typeof createSkillHandlers> {
  const cacheKey = `${path.resolve(workspaceDir)}:${getSignalId(signal)}`;
  const cached = handlerCache.get(cacheKey);
  if (cached) return cached;

  const handlers = createSkillHandlers({
    skills: result.skills,
    skillMode: "active",
    exposeSkills: result.skills.length,
    runShell: createAbortableLocalShellRunner(signal, {
      inheritEnv: false,
      timeoutMs: 120000,
      maxOutputLength: 20000,
    }),
    security: {
      allowedRoots: [workspaceDir],
      defaultCwd: workspaceDir,
      timeoutMs: 120000,
      maxOutputLength: 20000,
      env: {
        PATH: process.env.PATH ?? "",
        TMPDIR: process.env.TMPDIR ?? "/tmp",
      },
    },
  });
  handlerCache.set(cacheKey, handlers);
  return handlers;
}

function createAbortableLocalShellRunner(
  signal: Parameters<AgentTool["execute"]>[1]["signal"] | undefined,
  defaults: {
    shell?: string;
    timeoutMs?: number;
    maxOutputLength?: number;
    inheritEnv?: boolean;
  },
) {
  return async (input: {
    command: string;
    cwd?: string;
    shell?: string;
    timeoutMs?: number;
    maxOutputLength?: number;
    env?: Record<string, string>;
    inheritEnv?: boolean;
  }) => {
    const timeoutMs = input.timeoutMs ?? defaults.timeoutMs ?? 30000;
    const maxOutputLength = input.maxOutputLength ?? defaults.maxOutputLength ?? 8000;
    const inheritEnv = input.inheritEnv ?? defaults.inheritEnv ?? false;
    const shell = input.shell ?? defaults.shell ?? "/bin/bash";
    const startedAt = Date.now();

    return new Promise<{
      stdout: string;
      stderr: string;
      exitCode: number | null;
      timedOut?: boolean;
      truncated?: boolean;
      durationMs?: number;
    }>((resolve, reject) => {
      if (signal?.aborted) {
        reject(abortError(signal));
        return;
      }

      const child = spawn(shell, ["-lc", input.command], {
        cwd: input.cwd,
        env: inheritEnv ? { ...process.env, ...(input.env ?? {}) } : { ...(input.env ?? {}) },
        detached: true,
      });
      let stdout = "";
      let stderr = "";
      let timedOut = false;
      let settled = false;

      const killChildGroup = (killSignal: NodeJS.Signals = "SIGKILL") => {
        try {
          if (child.pid) {
            process.kill(-child.pid, killSignal);
            return;
          }
        } catch {
          // Fall back to killing the child directly if process group kill is unavailable.
        }
        child.kill(killSignal);
      };
      const cleanup = () => {
        clearTimeout(timer);
        signal?.removeEventListener?.("abort", onAbort);
      };
      const settle = (callback: () => void) => {
        if (settled) return;
        settled = true;
        cleanup();
        callback();
      };
      const onAbort = () => {
        killChildGroup();
        settle(() => reject(abortError(signal)));
      };
      const timer = setTimeout(() => {
        timedOut = true;
        killChildGroup();
      }, timeoutMs);

      signal?.addEventListener?.("abort", onAbort, { once: true });
      child.stdout.on("data", (chunk) => {
        stdout += chunk.toString("utf8");
      });
      child.stderr.on("data", (chunk) => {
        stderr += chunk.toString("utf8");
      });
      child.on("error", (error) => {
        settle(() =>
          resolve({
            stdout: "",
            stderr: error.message,
            exitCode: 127,
            timedOut,
            truncated: false,
            durationMs: Date.now() - startedAt,
          }),
        );
      });
      child.on("close", (exitCode) => {
        settle(() => {
          const out = truncate(stripAnsi(stdout), maxOutputLength);
          const err = truncate(stripAnsi(stderr), maxOutputLength);
          resolve({
            stdout: out.text,
            stderr: err.text,
            exitCode,
            timedOut,
            truncated: out.truncated || err.truncated,
            durationMs: Date.now() - startedAt,
          });
        });
      });
    });
  };
}

function abortError(signal: Parameters<AgentTool["execute"]>[1]["signal"] | undefined): Error {
  return signal?.reason instanceof Error ? signal.reason : new Error("Skill shell execution was aborted.");
}

const ANSI_REGEX = new RegExp(String.raw`\x1b\[[0-9;]*m`, "g");

function stripAnsi(input: string): string {
  return input.replace(ANSI_REGEX, "");
}

function truncate(text: string, max: number): { text: string; truncated: boolean } {
  if (text.length <= max) return { text, truncated: false };
  return { text: text.slice(0, max), truncated: true };
}

async function validateSkillShellCommandPolicy(
  input: Record<string, unknown>,
  skills: AgenticSkill[],
): Promise<void> {
  const command = typeof input.command === "string" ? input.command.trim() : "";
  const skillRef = typeof input.skillRef === "string" ? input.skillRef.trim() : "";
  const skill = skills.find(
    (candidate) =>
      candidate.id === skillRef ||
      candidate.name === skillRef ||
      toUseSkillToolName(candidate) === skillRef,
  );
  if (!skill || !command) return;

  const declaredCommands = await declaredShellCommands(skill);
  const allowed = declaredCommands.some((declared) => declared === command);
  if (!allowed) {
    throw new Error(`Shell command is not declared by skill shell policy: ${command}`);
  }
}

async function declaredShellCommands(skill: AgenticSkill): Promise<string[]> {
  const body = await fs.readFile(skill.bodyPath, "utf8").catch(() => "");
  const commands = new Set<string>();
  for (const match of body.matchAll(/`([^`\n]+)`/g)) {
    const command = match[1]?.trim();
    if (!command) continue;
    if (command.startsWith(`node .kidmemory/skills/${skill.name}/`)) {
      commands.add(command);
    }
  }
  return [...commands];
}

function normalizeSkillDeckToolInput(
  toolName: string,
  input: unknown,
  skills: AgenticSkill[],
  workspaceDir?: string,
): unknown {
  if (toolName === "run_skill_shell") {
    return normalizeSkillShellInput(input, workspaceDir);
  }
  if (toolName !== "read_skill" && toolName !== "get_skill_info") return input;
  if (!input || typeof input !== "object" || !("ref" in input)) return input;
  const ref = (input as Record<string, unknown>).ref;
  if (typeof ref !== "string" || !ref.startsWith("use_skill_")) return input;
  const matched = skills.find((skill) => toUseSkillToolName(skill) === ref);
  return matched ? { ...input, ref: matched.id } : input;
}

function normalizeSkillShellInput(input: unknown, workspaceDir?: string): unknown {
  if (!input || typeof input !== "object" || Array.isArray(input)) return input;
  const normalized = { ...(input as Record<string, unknown>) };
  if (!workspaceDir) return normalized;

  const cwd = normalized.cwd;
  if (typeof cwd !== "string" || !cwd.trim()) {
    delete normalized.cwd;
    return normalized;
  }

  const root = path.resolve(workspaceDir);
  const resolved = path.resolve(root, cwd);
  const insideRoot = resolved === root || resolved.startsWith(`${root}${path.sep}`);
  if (!insideRoot) {
    delete normalized.cwd;
    return normalized;
  }

  normalized.cwd = resolved;
  return normalized;
}

function validateSkillDeckToolInput(toolName: string, input: unknown): Record<string, unknown> {
  if (toolName.startsWith("use_skill_")) {
    return {};
  }
  const validation = validateToolArguments(toolName, input);
  if (!validation.ok) {
    throw new Error(validation.error);
  }
  return validation.args;
}

function createSkillDeckAgentTool(
  tool: AgenticTool,
  execute: (input: unknown, context: Parameters<AgentTool["execute"]>[1]) => Promise<unknown>,
): AgentTool {
  return {
    id: tool.name,
    name: tool.name,
    description: tool.description,
    source: "skill-deck",
    inputSchema: tool.inputSchema,
    risk: tool.name === "run_skill_shell" ? "high" : "low",
    execute: (input, context) => execute(input, context),
  };
}
