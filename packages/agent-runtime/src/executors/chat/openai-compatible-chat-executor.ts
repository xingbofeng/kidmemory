import fs from "node:fs/promises";
import path from "node:path";

import OpenAI from "openai";

import type { AgentExecutor, ExecutorRunRequest, ExecutorRunResult, RuntimeProviderConfig } from "../types.js";

type ChatClient = {
  chat: {
    completions: {
      create(input: unknown): Promise<{ choices?: Array<{ message?: { content?: string | null } }> }>;
    };
  };
};

export class OpenAICompatibleChatExecutor implements AgentExecutor {
  readonly id = "openai-compatible-chat";

  private readonly client?: ChatClient;

  constructor(options: { client?: ChatClient } = {}) {
    this.client = options.client;
  }

  async run(request: ExecutorRunRequest): Promise<ExecutorRunResult> {
    const requiredOutputFiles = request.requiredOutputFiles ?? [];
    if (requiredOutputFiles.length === 0) {
      return this.fail("CHAT_EXECUTOR_REQUIRES_OUTPUTS", "OpenAI-compatible chat executor requires explicit output files.");
    }

    const provider = request.provider ?? {};
    if (!provider.model || !provider.apiKey) {
      return this.fail("CHAT_PROVIDER_NOT_CONFIGURED", "OpenAI-compatible chat provider requires model and API key.");
    }

    try {
      const client = this.client ?? this.createClient(provider);
      const completion = await client.chat.completions.create({
        model: provider.model,
        messages: [
          { role: "system", content: this.systemPrompt(requiredOutputFiles) },
          { role: "user", content: request.prompt },
        ],
        temperature: 0.2,
      });
      const content = completion.choices?.[0]?.message?.content;
      if (!content) return this.fail("CHAT_EMPTY_RESPONSE", "Model returned an empty artifact response.");
      const files = this.parseFiles(content);
      for (const requiredPath of requiredOutputFiles) {
        const file = files.find((candidate) => candidate.path === requiredPath);
        if (!file) return this.fail("CHAT_MISSING_REQUIRED_OUTPUT", `Model response did not include ${requiredPath}.`);
        await this.writeRequiredFile(request.workspaceDir, requiredPath, file.content);
      }
      return { ok: true, finalOutput: content };
    } catch (error) {
      return this.fail("CHAT_EXECUTOR_FAILED", error instanceof Error ? error.message : "OpenAI-compatible chat executor failed.");
    }
  }

  private createClient(provider: RuntimeProviderConfig): ChatClient {
    return new OpenAI({
      apiKey: provider.apiKey,
      baseURL: provider.baseURL,
    });
  }

  private systemPrompt(requiredOutputFiles: string[]): string {
    return [
      "You generate KidMemory workspace artifacts.",
      "Return only strict JSON with this shape: {\"files\":[{\"path\":\"output/file.ext\",\"content\":\"file contents\"}]}",
      "Do not wrap the JSON in markdown fences.",
      `Required files: ${requiredOutputFiles.join(", ")}`,
      "For output/plan.json, content must be JSON with summary, skillName, steps, and requirements.",
      "For output/book.json, content must be JSON with metadata.title, metadata.childName, and pages.",
      "For output/book.html, content must be complete HTML.",
    ].join("\n");
  }

  private parseFiles(content: string): Array<{ path: string; content: string }> {
    const trimmed = content.trim().replace(/^```(?:json)?\s*/i, "").replace(/\s*```$/i, "");
    const parsed = JSON.parse(trimmed) as { files?: Array<{ path?: unknown; content?: unknown }> };
    if (!Array.isArray(parsed.files)) throw new Error("Artifact response must include files array.");
    return parsed.files.map((file) => {
      if (typeof file.path !== "string" || typeof file.content !== "string") {
        throw new Error("Each artifact file must include string path and content.");
      }
      return { path: file.path, content: file.content };
    });
  }

  private async writeRequiredFile(workspaceDir: string, relativePath: string, content: string) {
    if (path.isAbsolute(relativePath) || relativePath.includes("..")) {
      throw new Error(`Unsafe output path: ${relativePath}`);
    }
    const outputPath = path.resolve(workspaceDir, relativePath);
    const workspaceRoot = path.resolve(workspaceDir);
    if (!outputPath.startsWith(`${workspaceRoot}${path.sep}`)) {
      throw new Error(`Output path escapes workspace: ${relativePath}`);
    }
    await fs.mkdir(path.dirname(outputPath), { recursive: true });
    await fs.writeFile(outputPath, content);
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
