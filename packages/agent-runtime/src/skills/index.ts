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

  const agenticTools = getAgenticSkillTools({ skills: result.skills, skillMode: "active" });
  const handlers = createSkillHandlers({
    skills: result.skills,
    skillMode: "active",
  });

  return agenticTools
    .filter((tool) => typeof handlers[tool.name] === "function")
    .map((tool) => createSkillDeckAgentTool(tool, async (input) => {
      const validatedInput = validateSkillDeckToolInput(tool.name, normalizeSkillDeckToolInput(tool.name, input, result.skills));
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

function normalizeSkillDeckToolInput(
  toolName: string,
  input: unknown,
  skills: AgenticSkill[],
): unknown {
  if (toolName !== "read_skill" && toolName !== "get_skill_info") return input;
  if (!input || typeof input !== "object" || !("ref" in input)) return input;
  const ref = (input as Record<string, unknown>).ref;
  if (typeof ref !== "string" || !ref.startsWith("use_skill_")) return input;
  const matched = skills.find((skill) => toUseSkillToolName(skill) === ref);
  return matched ? { ...input, ref: matched.id } : input;
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
  execute: AgentTool["execute"],
): AgentTool {
  return {
    id: tool.name,
    name: tool.name,
    description: tool.description,
    source: "skill-deck",
    inputSchema: tool.inputSchema,
    risk: tool.name === "run_skill_shell" ? "high" : "low",
    execute,
  };
}
