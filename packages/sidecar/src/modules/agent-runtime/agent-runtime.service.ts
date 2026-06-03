import { Injectable, Inject } from "@nestjs/common";
import {
  AgentRuntime,
  OpenAICompatibleAgentLoopExecutor,
} from "@kidmemory/agent-runtime";
import type { ExecutorKind, AgentRunRequest, AgentRunResult } from "@kidmemory/agent-runtime";

import { delay } from "../../infrastructure/time/delay.ts";
import { PrismaService } from "../../infrastructure/database/prisma.service.ts";
import { AgentConfigApplicationService } from "../agent-config/application/agent-config-application.service.ts";
import { ENCRYPTION_PORT } from "../agent-config/ports/agent-config.ports.ts";
import type { EncryptionPort } from "../agent-config/ports/agent-config.ports.ts";

import {
  REQUIRED_OUTPUT_FILES_BY_STAGE,
  STAGE_TIMEOUT_PLAN_MS,
  STAGE_TIMEOUT_GENERATE_BOOK_MS,
  STAGE_TIMEOUT_GENERATE_VIDEO_MS,
} from "./agent-runtime.contracts.ts";
import type { RunCreationStageInput, RunCreationStageResult, RuntimeStage } from "./agent-runtime.contracts.ts";
import { ensureTaskWorkspace } from "./agent-runtime.workspace.ts";

const STAGE_TIMEOUT_MS: Record<RuntimeStage, number> = {
  plan: STAGE_TIMEOUT_PLAN_MS,
  generate_book: STAGE_TIMEOUT_GENERATE_BOOK_MS,
  generate_video: STAGE_TIMEOUT_GENERATE_VIDEO_MS,
};

export function resolveCreationRuntimeExecutorKind(config: { provider?: string; baseUrl?: string | null }): ExecutorKind {
  if (config.provider === "custom" || config.baseUrl) return "agent";
  return "sandbox";
}

export function resolveCreationRuntimeUseResponses(config: { provider?: string; baseUrl?: string | null }): boolean {
  return !(config.provider === "custom" || config.baseUrl);
}

@Injectable()
export class AgentRuntimeService {
  constructor(
    @Inject(AgentConfigApplicationService)
    private readonly agentConfig: AgentConfigApplicationService,
    @Inject(ENCRYPTION_PORT) private readonly encryption: EncryptionPort,
    @Inject(PrismaService) private readonly prisma: PrismaService,
  ) {}

  async runCreationStage(input: RunCreationStageInput): Promise<RunCreationStageResult> {
    await ensureTaskWorkspace({
      workspacePath: input.workspacePath,
      taskId: input.taskId,
      goal: input.prompt,
      assetIds: [],
      stage: input.stage,
    });

    const providerConfig = await this.resolveProviderConfig();
    const timeoutMs = STAGE_TIMEOUT_MS[input.stage];

    const runtime = new AgentRuntime({
      executorKind: providerConfig.executorKind,
      executor: providerConfig.executorKind === "agent"
        ? new OpenAICompatibleAgentLoopExecutor()
        : undefined,
      provider: providerConfig
        ? {
          model: providerConfig.model,
          baseURL: providerConfig.baseURL,
          apiKey: providerConfig.apiKey,
          useResponses: providerConfig.useResponses,
        }
        : undefined,
      maxTurns: 50,
      builtinTools: { pollinations: true },
      middleware: [
        {
          beforeToolCall: async ({ tool }) => {
            await this.addRuntimeEvent(
              input.taskId,
              "step",
              `Tool started: ${tool.id} (${tool.source})`,
            );
          },
          afterToolCall: async ({ tool }) => {
            await this.addRuntimeEvent(
              input.taskId,
              "step",
              `Tool finished: ${tool.id}`,
            );
          },
        },
      ],
    });

    const runRequest: AgentRunRequest = {
      workspaceDir: input.workspacePath,
      prompt: input.prompt,
      sessionId: `creation_${input.taskId}_${input.stage}`,
      traceId: input.traceId,
      metadata: {
        taskId: input.taskId,
        stage: input.stage,
        creationType: input.creationType,
        ...input.metadata,
      },
      requiredOutputFiles: REQUIRED_OUTPUT_FILES_BY_STAGE[input.stage],
    };

    let result: AgentRunResult | RunCreationStageResult;
    try {
      result = await Promise.race([
        runtime.run(runRequest),
        this.timeoutFailure(timeoutMs, input.stage, runRequest.sessionId),
      ]);
    } catch (error) {
      return {
        ok: false,
        sessionId: runRequest.sessionId,
        error: this.toCreationStageError(error, input.stage),
      };
    }

    if (!result.ok) {
      const errorResult = result as { error: { category: string; message: string; code?: string } };
      return {
        ok: false,
        runId: result.runId,
        sessionId: result.sessionId,
        error: {
          category: errorResult.error.category,
          message: errorResult.error.message,
          code: errorResult.error.code,
        },
      };
    }

    return {
      ok: true,
      runId: result.runId,
      sessionId: result.sessionId,
      summary: result.summary,
    };
  }

  private async resolveProviderConfig(): Promise<{
    model: string;
    baseURL?: string;
    apiKey?: string;
    useResponses?: boolean;
    executorKind: ExecutorKind;
  }> {
    const config = await this.agentConfig.getDefaultConfig();
    if (!config) {
      return {
        model: "gpt-4o",
        useResponses: true,
        executorKind: "sandbox",
      };
    }

    const encryptedKey = await this.agentConfig.getEncryptedApiKey(config.id);
    const apiKey = encryptedKey ? this.encryption.decryptFromStorage(encryptedKey) : undefined;

    return {
      model: config.model,
      baseURL: config.baseUrl ?? undefined,
      apiKey,
      useResponses: resolveCreationRuntimeUseResponses({ provider: config.provider, baseUrl: config.baseUrl }),
      executorKind: resolveCreationRuntimeExecutorKind({ provider: config.provider, baseUrl: config.baseUrl }),
    };
  }

  private async addRuntimeEvent(
    taskId: string,
    type: string,
    message: string,
    stepId?: string,
  ): Promise<void> {
    await this.prisma.creationEvent.create({
      data: {
        id: `event_${taskId}_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`,
        taskId,
        type,
        stepId,
        message,
      },
    });
  }

  private async timeoutFailure(ms: number, stage: RuntimeStage, sessionId: string): Promise<RunCreationStageResult> {
    await delay(ms);
    return {
      ok: false,
      sessionId,
      error: {
        category: this.errorCategoryForStage(stage),
        message: `Stage timed out after ${ms}ms.`,
        code: "STAGE_TIMEOUT",
      },
    };
  }

  private toCreationStageError(error: unknown, stage: RuntimeStage): RunCreationStageResult["error"] {
    if (error && typeof error === "object") {
      const maybeError = error as { category?: unknown; message?: unknown; code?: unknown };
      return {
        category: typeof maybeError.category === "string" ? maybeError.category : this.errorCategoryForStage(stage),
        message: typeof maybeError.message === "string" ? maybeError.message : "Agent runtime stage failed.",
        code: typeof maybeError.code === "string" ? maybeError.code : "AGENT_RUNTIME_FAILED",
      };
    }

    return {
      category: this.errorCategoryForStage(stage),
      message: "Agent runtime stage failed.",
      code: "AGENT_RUNTIME_FAILED",
    };
  }

  private errorCategoryForStage(stage: RuntimeStage): string {
    return stage === "plan" ? "planning" : "generation";
  }
}
