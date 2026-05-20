import fs from "node:fs/promises";
import path from "node:path";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

import { Agent, OpenAIProvider, Runner, run, shellTool } from '@openai/agents';
import type { Shell, ShellResult, ShellToolLocalSkill, Tool } from '@openai/agents';
import OpenAI from 'openai';
import { renderBookHtml, type BookOutput, type BookPage } from "./book.ts";

const execFileAsync = promisify(execFile);

type AgentConfigDto = {
  baseUrl?: string;
  model: string;
  temperature?: number;
  maxTokens?: number;
  systemPrompt?: string;
  toolsEnabled: string[];
};

type AgentConfig = {
  baseUrl: string;
  apiKey: string;
  model: string;
  temperature?: number;
  maxTokens?: number;
  systemPrompt?: string;
  toolsEnabled?: string[];
};

type AgentResult = {
  ok: boolean;
  runner: string;
  bookPath?: string;
  htmlPath?: string;
  message?: string;
  warning?: string;
};

// Allow dependency injection for testing
export interface AgentSDKDependencies {
  Agent: typeof Agent;
  run: typeof run;
  Runner?: typeof Runner;
  OpenAIProvider?: typeof OpenAIProvider;
}

export interface OpenAIAgentRunnerConfig {
  apiKey?: string;
  baseURL?: string;
  model: string;
  temperature?: number;
  maxTokens?: number;
  systemPrompt?: string;
  tools?: Array<{
    name: string;
    description: string;
    parameters?: Record<string, any>;
  }>;
  localSkills?: ShellToolLocalSkill[];
  shell?: Shell;
}

export interface AgentRunInput {
  childId: string;
  bookId?: string;
  assets: Array<{
    id: string;
    title: string;
    type: string;
    filePath: string;
    description?: string;
    metadata?: Record<string, any>;
  }>;
  instructions?: string;
  template?: string;
  outputFormat?: 'json' | 'html' | 'markdown';
}

export interface AgentRunOutput {
  success: boolean;
  bookData?: {
    title: string;
    content: string;
    pages: Array<{
      title: string;
      content: string;
      assets: string[];
    }>;
    metadata: Record<string, any>;
  };
  error?: string;
  executionLog: string[];
  tokensUsed?: number;
  duration?: number;
}

export interface UnifiedAgentRunner {
  run(input: AgentRunInput): Promise<AgentRunOutput>;
  cancel?(): Promise<void>;
  getStatus?(): 'idle' | 'running' | 'completed' | 'failed' | 'cancelled';
}

export class OpenAISDKAgentRunner implements UnifiedAgentRunner {
  private openai?: OpenAI;
  private readonly config: OpenAIAgentRunnerConfig;
  private readonly dependencies: AgentSDKDependencies;
  private status: 'idle' | 'running' | 'completed' | 'failed' | 'cancelled' = 'idle';
  private agent?: Agent;
  private runner?: Runner;
  private abortController?: AbortController;

  constructor(config: OpenAIAgentRunnerConfig, dependencies?: AgentSDKDependencies) {
    this.config = config;
    this.dependencies = dependencies || { Agent, run, Runner, OpenAIProvider };
  }

  async generateBook(input: {
    workspacePath: string;
    child: { name: string };
    assets: Array<{
      id: string;
      title: string;
      type: string;
      description?: string;
      thumbnailPath?: string;
      imagePath?: string;
    }>;
  }, config: AgentConfig): Promise<AgentResult> {
    const runner = new OpenAISDKAgentRunner({
      apiKey: config.apiKey,
      baseURL: config.baseUrl,
      model: config.model,
      temperature: config.temperature ?? this.config.temperature,
      maxTokens: config.maxTokens ?? this.config.maxTokens,
      systemPrompt: config.systemPrompt ?? this.config.systemPrompt,
      tools: this.config.tools,
      localSkills: this.config.localSkills,
      shell: this.config.shell,
    }, this.dependencies);

    const result = await runner.run({
      childId: input.child.name,
      assets: input.assets.map((asset) => ({
        id: asset.id,
        title: asset.title,
        type: asset.type,
        filePath: asset.imagePath || asset.thumbnailPath || "",
        description: asset.description,
      })),
      outputFormat: "json",
    });

    if (!result.success || !result.bookData) {
      return { ok: false, runner: "openai-agents", message: result.error || "OpenAI Agents SDK runner failed." };
    }

    const contentPages: BookPage[] = result.bookData.pages.map((page) => ({
      // Keep output schema valid even when the model omits/returns unknown asset refs.
      // Fallback to the first selected asset so preview/export can proceed.
      assetId: resolvePageAssetId(page.assets, input.assets),
      kind: "artwork" as const,
      title: page.title,
      text: page.content,
    }));
    const normalizedPages = ensureBookBoundaryPages({
      pages: contentPages,
      title: result.bookData.title,
      childName: input.child.name,
      fallbackAssetId: input.assets[0]?.id,
    });

    const book: BookOutput = {
      metadata: {
        title: result.bookData.title,
        childName: input.child.name,
        ...result.bookData.metadata,
      },
      pages: normalizedPages,
    };
    const outputDir = path.join(input.workspacePath, "output");
    await fs.mkdir(outputDir, { recursive: true });
    const bookPath = path.join(outputDir, "book.json");
    const htmlPath = path.join(outputDir, "book.html");
    const outputAssets = input.assets.map((asset) => ({
      ...asset,
      imagePath: toOutputRelativePath(asset.imagePath),
      thumbnailPath: toOutputRelativePath(asset.thumbnailPath),
    }));
    await fs.writeFile(bookPath, JSON.stringify(book, null, 2));
    await fs.writeFile(htmlPath, renderBookHtml(book, outputAssets));
    return { ok: true, runner: "openai-agents", bookPath, htmlPath };
  }

  static fromAgentConfig(agentConfig: AgentConfigDto, apiKey: string, dependencies?: AgentSDKDependencies): OpenAISDKAgentRunner {
    return new OpenAISDKAgentRunner({
      apiKey,
      baseURL: agentConfig.baseUrl,
      model: agentConfig.model,
      temperature: agentConfig.temperature,
      maxTokens: agentConfig.maxTokens,
      systemPrompt: agentConfig.systemPrompt,
      tools: []
    }, dependencies);
  }

  async run(input: AgentRunInput): Promise<AgentRunOutput> {
    this.status = 'running';
    this.abortController = new AbortController();

    const startTime = Date.now();
    const executionLog: string[] = [];

    try {
      if (!this.config.apiKey) {
        throw new Error("OpenAI API key is required for the OpenAI Agents SDK runner.");
      }

      executionLog.push(`Starting OpenAI Agents SDK run for child ${input.childId}`);
      executionLog.push(`Assets provided: ${input.assets.length}`);

      // Create the agent with instructions and tools
      this.agent = new this.dependencies.Agent({
        name: `kidmemory-book-agent-${input.childId}`,
        model: this.config.model,
        instructions: this.buildAgentInstructions(input),
        tools: this.buildAgentTools(input, executionLog),
        handoffs: [],
        modelSettings: {
          temperature: this.config.temperature || 0.7,
          maxTokens: this.config.maxTokens || 4000,
        },
      });

      executionLog.push(`Created agent with model ${this.config.model}`);

      // Prepare the initial message
      const initialMessage = this.buildInitialMessage(input);
      executionLog.push(`Initial message length: ${initialMessage.length} characters`);

      // Run the agent using the run function
      const RunnerCtor = this.dependencies.Runner || Runner;
      const OpenAIProviderCtor = this.dependencies.OpenAIProvider || OpenAIProvider;
      this.runner = new RunnerCtor({
        modelProvider: new OpenAIProviderCtor({ openAIClient: this.getOpenAIClient() }),
        tracingDisabled: true,
      });
      const result = this.dependencies.Runner
        ? await this.runner.run(this.agent, initialMessage, this.abortController ? { signal: this.abortController.signal } : undefined)
        : await this.dependencies.run(this.agent, initialMessage, this.abortController ? { signal: this.abortController.signal } : undefined);

      executionLog.push(`Agent run completed`);

      // Process the results
      const bookData = await this.processAgentResponse(result, input, executionLog);

      const duration = Date.now() - startTime;
      this.status = 'completed';

      return {
        success: true,
        bookData,
        executionLog,
        tokensUsed: getTotalTokens(result),
        duration
      };

    } catch (error) {
      this.status = 'failed';
      const duration = Date.now() - startTime;

      if (error instanceof Error && error.name === 'AbortError') {
        this.status = 'cancelled';
        executionLog.push('Agent run was cancelled');
        return {
          success: false,
          error: 'Agent run was cancelled',
          executionLog,
          duration
        };
      }

      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      if (shouldFallbackToChatCompletions(error)) {
        executionLog.push("OpenAI Agents SDK path failed with a compatibility error; chat.completions fallback is recommended.");
      }
      executionLog.push(`Error: ${errorMessage}`);

      return {
        success: false,
        error: errorMessage,
        executionLog,
        duration
      };
    }
  }

  async cancel(): Promise<void> {
    if (this.abortController) {
      this.abortController.abort();
      this.status = 'cancelled';
    }

    // Clean up agent and runner resources
    if (this.runner) {
      this.runner = undefined;
    }

    if (this.agent) {
      this.agent = undefined;
    }
  }

  getStatus(): 'idle' | 'running' | 'completed' | 'failed' | 'cancelled' {
    return this.status;
  }

  private getOpenAIClient(): OpenAI {
    if (!this.config.apiKey) {
      throw new Error("OpenAI API key is required to run the OpenAI Agents SDK runner.");
    }
    this.openai ??= new OpenAI({
      apiKey: this.config.apiKey,
      baseURL: this.config.baseURL,
    });
    return this.openai;
  }

  private buildAgentInstructions(input: AgentRunInput): string {
    let instructions = this.config.systemPrompt || `你是一个专业的儿童成长记录书创作助手。`;

    instructions += `

## 任务目标
为孩子 ${input.childId} 创作一本个性化的成长记录书。

## 创作要求
1. **内容风格**: 温馨、有趣、适合儿童阅读
2. **语言特点**: 简洁易懂、富有想象力、积极向上
3. **结构安排**: 合理的章节划分，每页内容适中
4. **素材运用**: 充分利用提供的图片和描述信息
5. **个性化**: 体现孩子的独特性格和成长历程

## 输出格式
请严格按照以下JSON格式输出：

\`\`\`json
{
  "title": "书籍标题",
  "content": "整体内容描述",
  "pages": [
    {
      "title": "页面标题",
      "content": "页面正文内容",
      "assets": ["asset_id_1", "asset_id_2"]
    }
  ],
  "metadata": {
    "theme": "主题",
    "ageGroup": "适合年龄",
    "pageCount": 页数,
    "createdAt": "创建时间"
  }
}
\`\`\``;

    if (input.instructions) {
      instructions += `\n\n## 特殊要求\n${input.instructions}`;
    }

    return instructions;
  }

  private buildAgentTools(input: AgentRunInput, executionLog: string[]): Tool[] {
    const tools: Tool[] = [...(this.config.tools || []) as Tool[]];

    if (this.config.localSkills && this.config.localSkills.length > 0) {
      tools.push(shellTool({
        shell: this.config.shell ?? new LocalCommandShell(),
        environment: {
          type: "local",
          skills: this.config.localSkills,
        },
        needsApproval: async () => false,
      }));
    }

    executionLog.push(`Built ${tools.length} agent tools`);
    return tools;
  }

  private buildInitialMessage(input: AgentRunInput): string {
    let message = `请为孩子创作一本个性化的成长记录书。`;

    if (input.bookId) {
      message += `这是对现有书籍 ${input.bookId} 的更新。`;
    }

    // Add asset information
    if (input.assets.length > 0) {
      message += '\n\n## 可用素材\n\n';
      for (const asset of input.assets) {
        message += `### ${asset.title} (ID: ${asset.id})\n`;
        message += `- 类型: ${asset.type}\n`;
        message += `- 文件: ${asset.filePath}\n`;
        if (asset.description) {
          message += `- 描述: ${asset.description}\n`;
        }
        if (asset.metadata) {
          message += `- 元数据: ${JSON.stringify(asset.metadata)}\n`;
        }
        message += '\n';
      }
    }

    // Add template information
    if (input.template) {
      message += `\n\n## 模板要求\n${input.template}`;
    }

    return message;
  }

  private async processAgentResponse(
    result: any,
    input: AgentRunInput,
    executionLog: string[]
  ): Promise<AgentRunOutput['bookData']> {
    // Get the final messages from the result
    const finalOutput = typeof result.finalOutput === "string" ? result.finalOutput : undefined;
    if (finalOutput) {
      executionLog.push(`Processing final output from agent result`);
      return parseBookData(finalOutput, input, this.config.model, executionLog);
    }

    const messages = result.messages || [];
    executionLog.push(`Processing ${messages.length} messages from agent result`);

    // Find the last assistant message
    const lastAssistantMessage = messages
      .filter((msg: any) => msg.role === 'assistant')
      .pop();

    if (!lastAssistantMessage) {
      throw new Error('No assistant response found in agent result');
    }

    const content = lastAssistantMessage.content;
    if (!content || content.length === 0) {
      throw new Error('Empty response content from agent');
    }

    executionLog.push(`Response content length: ${content.length} characters`);

    return parseBookData(content, input, this.config.model, executionLog);
  }

}

class LocalCommandShell implements Shell {
  async run(action: { commands: string[]; timeoutMs?: number; maxOutputLength?: number }): Promise<ShellResult> {
    const output: ShellResult["output"] = [];
    for (const command of action.commands) {
      const result = await runShellCommand(command, action.timeoutMs);
      output.push(truncateShellOutput(result, action.maxOutputLength));
    }
    return {
      output,
      maxOutputLength: action.maxOutputLength,
    };
  }
}

async function runShellCommand(command: string, timeoutMs?: number): Promise<ShellResult["output"][number]> {
  try {
    const result = await execFileAsync("/bin/zsh", ["-lc", command], {
      timeout: timeoutMs,
      maxBuffer: 1024 * 1024,
    });
    return {
      stdout: result.stdout,
      stderr: result.stderr,
      outcome: {
        type: "exit",
        exitCode: 0,
      },
    };
  } catch (error) {
    const record = error as {
      stdout?: string | Buffer;
      stderr?: string | Buffer;
      code?: number | null;
      killed?: boolean;
    };
    return {
      stdout: String(record.stdout ?? ""),
      stderr: String(record.stderr ?? (error instanceof Error ? error.message : "")),
      outcome: record.killed
        ? { type: "timeout" }
        : { type: "exit", exitCode: typeof record.code === "number" ? record.code : 1 },
    };
  }
}

function truncateShellOutput(
  value: ShellResult["output"][number],
  maxOutputLength?: number,
): ShellResult["output"][number] {
  if (!maxOutputLength || maxOutputLength <= 0) {
    return value;
  }
  return {
    ...value,
    stdout: value.stdout.slice(0, maxOutputLength),
    stderr: value.stderr.slice(0, maxOutputLength),
  };
}

function getTotalTokens(result: any): number | undefined {
  return result?.runContext?.usage?.totalTokens ?? result?.usage?.totalTokens;
}

function shouldFallbackToChatCompletions(error: unknown) {
  const message = error instanceof Error ? error.message : String(error ?? "");
  const normalized = message.toLowerCase();
  return normalized.includes("unsupported")
    || normalized.includes("not implemented")
    || normalized.includes("invalid response format")
    || normalized.includes("chat.completions");
}

function parseBookData(
  content: string,
  input: AgentRunInput,
  model: string,
  executionLog: string[],
): AgentRunOutput['bookData'] {
  const jsonMatch = content.match(/```json\s*([\s\S]*?)\s*```/) || content.match(/^\s*(\{[\s\S]*\})\s*$/);
  if (jsonMatch) {
    try {
      const bookData = JSON.parse(jsonMatch[1]);
      executionLog.push('Successfully parsed JSON response from agent');

      if (!bookData.title || !bookData.pages || !Array.isArray(bookData.pages)) {
        throw new Error('Invalid book data structure from agent');
      }

      if (!bookData.metadata) {
        bookData.metadata = {};
      }

      bookData.metadata.generatedAt = new Date().toISOString();
      bookData.metadata.model = model;
      bookData.metadata.agentSDK = true;

      return bookData;
    } catch (parseError) {
      executionLog.push(`JSON parsing failed: ${parseError instanceof Error ? parseError.message : 'Unknown error'}`);
      executionLog.push('Falling back to text-based book structure');
      return {
        title: `${input.childId}的成长记录`,
        content,
        pages: [
          {
            title: '第一页',
            content: content.substring(0, Math.min(content.length, 1000)),
            assets: input.assets.slice(0, 3).map(asset => asset.id)
          }
        ],
        metadata: {
          generatedAt: new Date().toISOString(),
          model,
          agentSDK: true,
          fallbackGeneration: true
        }
      };
    }
  }

  executionLog.push('No JSON found in agent response, creating fallback structure');
  return {
    title: `${input.childId}的成长记录`,
    content,
    pages: [
      {
        title: '第一页',
        content: content.substring(0, Math.min(content.length, 1000)),
        assets: input.assets.slice(0, 3).map(asset => asset.id)
      }
    ],
    metadata: {
      generatedAt: new Date().toISOString(),
      model,
      agentSDK: true,
      fallbackGeneration: true
    }
  };
}

function toOutputRelativePath(value: string | undefined) {
  return typeof value === "string" && value.startsWith("input/") ? `../${value}` : value;
}

function resolvePageAssetId(
  candidateAssetIds: string[] | undefined,
  availableAssets: Array<{ id: string }>,
) {
  const availableIds = new Set(availableAssets.map((asset) => asset.id));
  const candidate = (candidateAssetIds || []).find((id) => availableIds.has(id));
  if (candidate) return candidate;
  return availableAssets[0]?.id || "";
}

function ensureBookBoundaryPages(input: {
  pages: BookPage[];
  title: string;
  childName: string;
  fallbackAssetId?: string;
}) {
  const hasCover = input.pages.some((page) => page.kind === "cover");
  const hasClosing = input.pages.some((page) => page.kind === "closing");
  const pages = [...input.pages];

  if (!hasCover) {
    pages.unshift({
      kind: "cover",
      title: input.title,
      text: `这是 ${input.childName} 的成长故事集。`,
      assetId: input.fallbackAssetId,
    });
  }
  if (!hasClosing) {
    pages.push({
      kind: "closing",
      title: "尾声",
      text: `谢谢阅读 ${input.childName} 的成长故事。`,
      assetId: input.fallbackAssetId,
    });
  }

  return pages;
}
