import fs from "node:fs/promises";
import path from "node:path";
import OpenAI from "openai";

import type { AgentTool } from "../../tools/index.js";
import type {
  AgentExecutor,
  ExecutorRunRequest,
  ExecutorRunResult,
  RuntimeAbortSignal,
  RuntimeProviderConfig,
} from "../types.js";

type ChatMessage = {
  role: "system" | "user" | "assistant";
  content: string;
};

type ChatClient = {
  chat: {
    completions: {
      create(input: unknown, options?: unknown): Promise<{ choices?: Array<{ message?: { content?: string | null } }> }>;
    };
  };
};

type ToolCall = {
  tool: string;
  input?: unknown;
};

type AgentLoopResponse = {
  toolCalls?: ToolCall[];
  final?: string;
};

export class OpenAICompatibleAgentLoopExecutor implements AgentExecutor {
  readonly id = "openai-compatible-agent-loop";

  private readonly client?: ChatClient;

  constructor(options: { client?: ChatClient } = {}) {
    this.client = options.client;
  }

  async run(request: ExecutorRunRequest): Promise<ExecutorRunResult> {
    const provider = request.provider ?? {};
    if (!provider.model || !provider.apiKey) {
      return this.fail("AGENT_LOOP_PROVIDER_NOT_CONFIGURED", "OpenAI-compatible agent loop requires model and API key.");
    }

    try {
      const client = this.client ?? this.createClient(provider);
      const maxTurns = Math.max(1, request.maxTurns ?? 20);
      const messages: ChatMessage[] = [
        { role: "system", content: this.systemPrompt(request) },
        { role: "user", content: request.prompt },
      ];
      let supportsJsonResponseFormat = true;

      for (let turn = 0; turn < maxTurns; turn += 1) {
        this.throwIfAborted(request.signal);
        const completion = await this.createCompletion(client, {
          model: provider.model,
          messages,
          temperature: 0.2,
          ...(supportsJsonResponseFormat ? { response_format: { type: "json_object" } } : {}),
        }, request.signal).catch(async (error) => {
          if (supportsJsonResponseFormat && this.isUnsupportedResponseFormatError(error)) {
            supportsJsonResponseFormat = false;
            return this.createCompletion(client, {
              model: provider.model,
              messages,
              temperature: 0.2,
            }, request.signal);
          }
          throw error;
        });
        const content = completion.choices?.[0]?.message?.content;
        if (!content) return this.fail("AGENT_LOOP_EMPTY_RESPONSE", "Model returned an empty agent-loop response.");
        messages.push({ role: "assistant", content });

        const parsed = this.parseResponse(content);
        if (!parsed.ok) {
          messages.push({
            role: "user",
            content: JSON.stringify({
              error: "invalid_agent_loop_response",
              message: parsed.message,
              requiredShape: {
                toolCalls: [{ tool: "read_skill", input: { ref: "skill-name" } }],
                final: "short completion summary",
              },
            }),
          });
          continue;
        }
        const response = parsed.response;
        if (response.toolCalls?.length) {
          for (const toolCall of response.toolCalls) {
            const toolResult = await this.executeToolForLoop(request, toolCall);
            messages.push({
              role: "user",
              content: JSON.stringify(toolResult),
            });
          }
          continue;
        }

        if (response.final) {
          const missing = await this.missingRequiredOutputFiles(request);
          if (missing.length > 0) {
            messages.push({
              role: "user",
              content: JSON.stringify({
                error: "required_output_files_missing",
                message: `Missing required output files: ${missing.join(", ")}`,
                instruction:
                  "Continue using tools until every required output file exists and is non-empty. Do not return final yet.",
              }),
            });
            continue;
          }
          return { ok: true, finalOutput: response.final };
        }

        messages.push({
          role: "user",
          content: "You must return either toolCalls or final in the required JSON shape.",
        });
      }

      return this.fail("AGENT_LOOP_MAX_TURNS", `Agent loop exceeded ${maxTurns} turns.`);
    } catch (error) {
      return this.fail(
        "AGENT_LOOP_FAILED",
        error instanceof Error ? error.message : "OpenAI-compatible agent loop failed.",
      );
    }
  }

  private createClient(provider: RuntimeProviderConfig): ChatClient {
    return new OpenAI({
      apiKey: provider.apiKey,
      baseURL: provider.baseURL,
    });
  }

  private createCompletion(
    client: ChatClient,
    input: unknown,
    signal?: RuntimeAbortSignal,
  ): Promise<{ choices?: Array<{ message?: { content?: string | null } }> }> {
    return client.chat.completions.create(input, { signal });
  }

  private systemPrompt(request: ExecutorRunRequest): string {
    return [
      "You are a KidMemory agent loop. You must complete tasks by choosing and using available tools.",
      "Do not directly invent final artifacts in chat. Use skill-deck skills and workspace tools.",
      "For picture books, memory books, memoir videos, and other creative artifacts, first inspect or activate the relevant local skill, then execute its documented command or write outputs through tools.",
      "If output/plan.json is required, create it with write_file as valid JSON containing summary, skillName, steps, and requirements.",
      "If output/book.json and output/book.html are required, use a picturebook skill and its documented shell command.",
      "If output/video.mp4 is required, use a memoir video or HyperFrames skill and its documented shell command.",
      `Required output files: ${(request.requiredOutputFiles ?? []).join(", ") || "(none)"}`,
      "",
      "Available skills:",
      ...request.skills.skills.map((skill) => `- ${skill.name}: ${skill.description}`),
      "",
      "Available tools:",
      ...request.tools.map((tool) => this.describeTool(tool)),
      "",
      "Respond only as JSON with one of these shapes:",
      "{\"toolCalls\":[{\"tool\":\"read_skill\",\"input\":{\"ref\":\"skill-name\"}}]}",
      "{\"final\":\"short completion summary\"}",
      "Use multiple toolCalls only when their order does not matter. For dependent steps, call one tool at a time.",
      "Before final, make sure every required output file exists under output/.",
    ].join("\n");
  }

  private describeTool(tool: AgentTool): string {
    return `- ${tool.id} (${tool.source}, ${tool.risk}): ${tool.description}; inputSchema=${JSON.stringify(tool.inputSchema)}`;
  }

  private parseResponse(
    content: string,
  ): { ok: true; response: AgentLoopResponse } | { ok: false; message: string } {
    try {
      const parsed = JSON.parse(this.extractJsonObject(content)) as AgentLoopResponse;
      if (parsed.toolCalls !== undefined && !Array.isArray(parsed.toolCalls)) {
        return { ok: false, message: "Agent response toolCalls must be an array." };
      }
      if (parsed.final !== undefined && typeof parsed.final !== "string") {
        return { ok: false, message: "Agent response final must be a string." };
      }
      for (const [index, toolCall] of (parsed.toolCalls ?? []).entries()) {
        if (!toolCall || typeof toolCall !== "object" || Array.isArray(toolCall)) {
          return { ok: false, message: `Agent response toolCalls[${index}] must be an object.` };
        }
        if (typeof (toolCall as ToolCall).tool !== "string" || !(toolCall as ToolCall).tool.trim()) {
          return { ok: false, message: `Agent response toolCalls[${index}].tool must be a non-empty string.` };
        }
      }
      return { ok: true, response: parsed };
    } catch (error) {
      return {
        ok: false,
        message: error instanceof Error ? error.message : "Agent response did not include a JSON object.",
      };
    }
  }

  private extractJsonObject(content: string): string {
    const fenced = content.match(/```(?:json)?\s*([\s\S]*?)\s*```/i);
    const candidate = (fenced?.[1] ?? content).trim();
    if (candidate.startsWith("{") && candidate.endsWith("}")) return candidate;
    const start = candidate.indexOf("{");
    const end = candidate.lastIndexOf("}");
    if (start === -1 || end <= start) {
      throw new Error("Agent response did not include a JSON object.");
    }
    return candidate.slice(start, end + 1);
  }

  private async executeTool(request: ExecutorRunRequest, toolCall: ToolCall): Promise<unknown> {
    this.throwIfAborted(request.signal);
    if (typeof toolCall.tool !== "string" || !toolCall.tool.trim()) {
      throw new Error("Agent tool call must include a tool id.");
    }
    const normalizedSkillTool = this.normalizeSkillToolCall(request, toolCall);
    if (normalizedSkillTool) return normalizedSkillTool.execute();

    const tool = request.tools.find((candidate) => candidate.id === toolCall.tool);
    if (!tool) throw new Error(`Agent requested unavailable tool: ${toolCall.tool}`);
    return tool.execute(toolCall.input ?? {}, {
      workspaceDir: request.workspaceDir,
      runId: request.runId,
      traceId: request.traceId,
      signal: request.signal,
    });
  }

  private async executeToolForLoop(
    request: ExecutorRunRequest,
    toolCall: ToolCall,
  ): Promise<{ toolResult: { tool: string; output: unknown } } | { toolError: { tool: string; message: string } }> {
    try {
      return {
        toolResult: {
          tool: toolCall.tool,
          output: await this.executeTool(request, toolCall),
        },
      };
    } catch (error) {
      if (request.signal?.aborted) throw error;
      return {
        toolError: {
          tool: typeof toolCall.tool === "string" ? toolCall.tool : "(invalid tool)",
          message: error instanceof Error ? error.message : "Tool execution failed.",
        },
      };
    }
  }

  private async missingRequiredOutputFiles(request: ExecutorRunRequest): Promise<string[]> {
    const missing: string[] = [];
    for (const relativePath of request.requiredOutputFiles ?? []) {
      const absolutePath = path.resolve(request.workspaceDir, relativePath);
      const workspaceRoot = path.resolve(request.workspaceDir);
      if (absolutePath !== workspaceRoot && !absolutePath.startsWith(`${workspaceRoot}${path.sep}`)) {
        missing.push(relativePath);
        continue;
      }
      const exists = await fs
        .stat(absolutePath)
        .then((stat) => stat.isFile() && stat.size > 0)
        .catch(() => false);
      if (!exists) missing.push(relativePath);
    }
    return missing;
  }

  private normalizeSkillToolCall(
    request: ExecutorRunRequest,
    toolCall: ToolCall,
  ): { execute: () => Promise<unknown> } | undefined {
    if (!toolCall.tool.startsWith("use_skill_")) return undefined;
    const readSkill = request.tools.find((candidate) => candidate.id === "read_skill");
    if (!readSkill) return undefined;
    const requestedName = toolCall.tool
      .slice("use_skill_".length)
      .replaceAll("_", "-");
    const exactSkill = request.skills.skills.find((skill) => skill.name.replaceAll("_", "-") === requestedName);
    const prefixMatches = request.skills.skills.filter((skill) => {
      const normalizedName = skill.name.replaceAll("_", "-");
      return normalizedName.startsWith(`${requestedName}-`);
    });
    const matchedSkill = exactSkill ?? (prefixMatches.length === 1 ? prefixMatches[0] : undefined);
    if (!matchedSkill) return undefined;
    return {
      execute: () =>
        readSkill.execute(
          { ref: matchedSkill.name },
          {
            workspaceDir: request.workspaceDir,
            runId: request.runId,
            traceId: request.traceId,
            signal: request.signal,
          },
        ),
    };
  }

  private isUnsupportedResponseFormatError(error: unknown): boolean {
    const text = error instanceof Error ? error.message : String(error);
    return /response_format|json_object/i.test(text) && /unsupported|unknown|invalid|not support/i.test(text);
  }

  private throwIfAborted(signal?: RuntimeAbortSignal): void {
    if (!signal?.aborted) return;
    throw signal.reason instanceof Error ? signal.reason : new Error("Agent run was aborted.");
  }

  private fail(code: string, message: string): ExecutorRunResult {
    return {
      ok: false,
      error: {
        code,
        message,
        category: "environment",
        recoverable: false,
      },
    };
  }
}
