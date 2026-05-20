import { Agent, OpenAIProvider, Runner } from "@openai/agents";
import OpenAI from "openai";

import { Inject, Injectable } from "@nestjs/common";
import type { CreationPlan, CreationStep } from "@kidmemory/protocol";

import { AgentConfigApplicationService } from "../agent-config/application/agent-config-application.service.ts";
import type { AgentConfig } from "../agent-config/domain/agent-config.entity.ts";
import type { CreateCreationPlanDto } from "./dto/creation.dto.ts";

export type CreationPlanningResult =
  | {
      ok: true;
      summary: string;
      skillName: string;
      steps: CreationStep[];
      requirements: string[];
    }
  | {
      ok: false;
      code: string;
      message: string;
    };

@Injectable()
export class CreationPlanningService {
  constructor(
    @Inject(AgentConfigApplicationService)
    private readonly agentConfigService: Pick<
      AgentConfigApplicationService,
      "getDefaultConfig" | "getDecryptedApiKey"
    >,
  ) {}

  async createPlan(
    input: CreateCreationPlanDto,
  ): Promise<CreationPlanningResult> {
    const configResult = await this.resolveAgentConfig();
    if (configResult.ok === false) {
      return {
        ok: false,
        code: configResult.code,
        message: configResult.message,
      };
    }

    try {
      const agent = new Agent({
        name: "kidmemory-creation-planner",
        model: configResult.config.model,
        instructions: buildPlanningInstructions(),
        tools: [],
        handoffs: [],
        modelSettings: {
          temperature: configResult.config.temperature ?? 0.4,
          maxTokens: Math.min(configResult.config.maxTokens ?? 2000, 3000),
        },
      });
      const runner = new Runner({
        modelProvider: new OpenAIProvider({
          openAIClient: new OpenAI({
            apiKey: configResult.config.apiKey,
            baseURL: configResult.config.baseUrl,
          }),
          useResponses: configResult.config.useResponses,
        }),
        tracingDisabled: true,
      });
      const result = await runner.run(agent, buildPlanningPrompt(input));
      return parsePlanningResult(result);
    } catch (error) {
      return {
        ok: false,
        code: "OPENAI_AGENT_PLAN_FAILED",
        message: formatOpenAIAgentPlanningError(error),
      };
    }
  }

  private async resolveAgentConfig(): Promise<
    | {
        ok: true;
        config: {
          apiKey: string;
          baseUrl: string;
          model: string;
          temperature: number;
          maxTokens: number;
          useResponses: boolean;
        };
      }
    | { ok: false; code: string; message: string }
  > {
    const config = await this.agentConfigService.getDefaultConfig();
    if (!config) {
      return {
        ok: false,
        code: "OPENAI_AGENT_CONFIG_MISSING",
        message: "No default agent configuration is configured.",
      };
    }
    if (config.provider !== "openai" && config.provider !== "custom") {
      return {
        ok: false,
        code: "OPENAI_AGENT_PROVIDER_UNSUPPORTED",
        message: `Default agent provider '${config.provider}' is not supported by the OpenAI Agents SDK runner.`,
      };
    }

    let apiKey: string | null;
    try {
      apiKey = await this.agentConfigService.getDecryptedApiKey(config.id);
    } catch (error) {
      return {
        ok: false,
        code: "OPENAI_AGENT_KEY_UNAVAILABLE",
        message:
          error instanceof Error
            ? error.message
            : "Failed to decrypt default agent API key.",
      };
    }
    if (!apiKey) {
      return {
        ok: false,
        code: "OPENAI_AGENT_KEY_MISSING",
        message: "Default agent configuration does not have a usable API key.",
      };
    }

    return {
      ok: true,
      config: {
        apiKey,
        baseUrl: normalizeAgentBaseUrl(config),
        model: config.model,
        temperature: config.temperature,
        maxTokens: config.maxTokens,
        useResponses: config.provider === "openai",
      },
    };
  }
}

function buildPlanningInstructions() {
  return [
    "You are KidMemory's creation planning agent.",
    "Return only valid JSON, without Markdown fences.",
    "Create a concise executable plan for the requested creation type.",
    "Use only existing KidMemory capabilities: KidMemory storybook, KidMemory memory book, Hyperframes memoir video.",
    "Do not invent non-existing skills.",
    "The JSON schema is:",
    '{"summary":"string","skillName":"string","steps":[{"stepId":"compose|plan|generate|review|publish","label":"string","detail":"string"}],"requirements":["string"]}',
  ].join("\n");
}

function buildPlanningPrompt(input: CreateCreationPlanDto) {
  return JSON.stringify(
    {
      goal: input.goal,
      creationType: input.creationType,
      assetIds: input.assetIds,
      constraints: {
        output: input.creationType === "memoir_video" ? "MP4 video" : "PDF",
        mustUseExistingSkills: true,
        mainStages: ["compose", "plan", "generate", "review", "publish"],
      },
    },
    null,
    2,
  );
}

function parsePlanningResult(result: unknown): CreationPlanningResult {
  const content = extractAgentText(result);
  if (!content) {
    return {
      ok: false,
      code: "OPENAI_AGENT_PLAN_EMPTY",
      message: "OpenAI Agents SDK returned an empty planning response.",
    };
  }
  try {
    const parsed = JSON.parse(stripJsonFence(content)) as Partial<CreationPlan>;
    const summary =
      typeof parsed.summary === "string" ? parsed.summary.trim() : "";
    const skillName =
      typeof parsed.skillName === "string" ? parsed.skillName.trim() : "";
    const steps = normalizePlanSteps(parsed.steps);
    const requirements = Array.isArray(parsed.requirements)
      ? parsed.requirements.map((item) => `${item}`.trim()).filter(Boolean)
      : [];
    if (!summary || !skillName || steps.length === 0) {
      return {
        ok: false,
        code: "OPENAI_AGENT_PLAN_INVALID",
        message: "OpenAI Agents SDK returned an incomplete creation plan.",
      };
    }
    return { ok: true, summary, skillName, steps, requirements };
  } catch (error) {
    return {
      ok: false,
      code: "OPENAI_AGENT_PLAN_PARSE_FAILED",
      message:
        error instanceof Error
          ? error.message
          : "OpenAI Agents SDK planning response was not valid JSON.",
    };
  }
}

function extractAgentText(result: unknown) {
  if (!result || typeof result !== "object") return "";
  const direct = (result as { finalOutput?: unknown }).finalOutput;
  if (typeof direct === "string") return direct;
  const messages = (result as { messages?: unknown }).messages;
  if (!Array.isArray(messages)) return "";
  const assistant = messages
    .filter((message) => (message as { role?: unknown }).role === "assistant")
    .pop();
  const content = (assistant as { content?: unknown } | undefined)?.content;
  return typeof content === "string" ? content : "";
}

function stripJsonFence(content: string) {
  const trimmed = content.trim();
  const match = trimmed.match(/^```(?:json)?\s*([\s\S]*?)\s*```$/);
  return match?.[1] ?? trimmed;
}

function normalizePlanSteps(value: unknown): CreationStep[] {
  if (!Array.isArray(value)) return [];
  const steps: Array<CreationStep | undefined> = value.map((item) => {
    if (!item || typeof item !== "object") return undefined;
    const record = item as Record<string, unknown>;
    const stepId =
      typeof record.stepId === "string" ? record.stepId.trim() : "";
    const label = typeof record.label === "string" ? record.label.trim() : "";
    const detail =
      typeof record.detail === "string" ? record.detail.trim() : undefined;
    if (!stepId || !label) return undefined;
    return {
      stepId,
      label,
      status: "pending" as const,
      detail,
    };
  });
  return steps.filter((step): step is CreationStep => Boolean(step));
}

function normalizeAgentBaseUrl(config: AgentConfig) {
  if (config.baseUrl) return config.baseUrl;
  return config.provider === "openai" ? "https://api.openai.com/v1" : "";
}

export function formatOpenAIAgentPlanningError(error: unknown) {
  const fallback = "OpenAI Agents SDK runner failed while planning.";
  if (!(error instanceof Error)) return fallback;

  const rawMessage = error.message.trim();
  if (!rawMessage) return fallback;

  const statusMatch = rawMessage.match(/\b(4\d\d|5\d\d)\b/);
  const looksLikeHtml = /<html|<!doctype html|<\/body>|<\/center>/i.test(
    rawMessage,
  );
  if (looksLikeHtml) {
    const status = statusMatch ? ` HTTP ${statusMatch[1]}` : "";
    return `OpenAI Agents SDK planning request failed with${status}. The configured OpenAI-compatible endpoint may not support the Responses API required by the Agents SDK.`;
  }

  if (/responses?/i.test(rawMessage) && statusMatch) {
    return `OpenAI Agents SDK planning request failed with HTTP ${statusMatch[1]}. Check that the configured endpoint supports the Responses API.`;
  }

  return rawMessage.length > 300
    ? `${rawMessage.slice(0, 300)}...`
    : rawMessage;
}
