import { URL } from "node:url";

import type { AgentRuntimeError } from "../core/errors.js";
import type { RuntimeProviderConfig } from "./types.js";

export function diagnoseOpenAISandboxError(error: unknown, provider?: RuntimeProviderConfig): AgentRuntimeError {
  return diagnoseOpenAIExecutorError(error, provider, "sandbox");
}

export function diagnoseOpenAIAgentError(error: unknown, provider?: RuntimeProviderConfig): AgentRuntimeError {
  return diagnoseOpenAIExecutorError(error, provider, "agent");
}

function diagnoseOpenAIExecutorError(
  error: unknown,
  provider: RuntimeProviderConfig | undefined,
  executorKind: "sandbox" | "agent",
): AgentRuntimeError {
  const rawMessage = error instanceof Error ? error.message : String(error);
  const httpStatus = readHttpStatus(rawMessage);
  const providerHost = readProviderHost(provider?.baseURL);
  const providerType = provider?.baseURL?.includes("openrouter") ? "openrouter" : provider?.baseURL ? "openai-compatible" : "openai-default";
  const details = {
    providerType,
    providerHost,
    httpStatus,
    modelConfigured: Boolean(provider?.model),
    baseURLConfigured: Boolean(provider?.baseURL),
    useResponses: provider?.useResponses,
    recommendedAction: undefined as string | undefined,
  };

  if (httpStatus === 429 || /rate limit|quota|free-models-per-day/i.test(rawMessage)) {
    return {
      category: "environment",
      code: "PROVIDER_RATE_LIMITED",
      message: "Provider rate limit or quota was reached. Use another model/provider or wait for quota reset.",
      recoverable: true,
      cause: error,
      details,
    };
  }

  if (httpStatus === 402 || /insufficient account balance|insufficient balance|billing/i.test(rawMessage)) {
    return {
      category: "environment",
      code: "PROVIDER_INSUFFICIENT_BALANCE",
      message: "Provider account balance is insufficient. Add credits or use another provider/model.",
      recoverable: true,
      cause: error,
      details,
    };
  }

  if (httpStatus === 404) {
    return {
      category: "environment",
      code: "PROVIDER_ENDPOINT_NOT_FOUND",
      message: "Provider endpoint returned 404. Check that the configured baseURL is OpenAI-compatible and includes the correct /v1 path.",
      recoverable: true,
      cause: error,
      details,
    };
  }

  if (httpStatus === 400 && providerHost && providerHost !== "api.openai.com" && executorKind === "agent") {
    return {
      category: "environment",
      code: "PROVIDER_AGENT_UNSUPPORTED",
      message: "Provider rejected the OpenAI Agents SDK Agent request. Use a provider/model that supports OpenAI Agents SDK tool loops, or implement a provider-specific model adapter.",
      recoverable: true,
      cause: error,
      details: {
        ...details,
        recommendedAction: "use_provider_without_reasoning_content_or_custom_model_adapter",
      },
    };
  }

  if (httpStatus === 400 && providerHost && providerHost !== "api.openai.com") {
    return {
      category: "environment",
      code: "PROVIDER_SANDBOX_UNSUPPORTED",
      message: "Provider rejected the OpenAI Agents SDK SandboxAgent request. Use a provider that supports Agents SDK sandbox/tool requests, or choose an explicit non-sandbox executor strategy.",
      recoverable: true,
      cause: error,
      details: {
        ...details,
        recommendedAction: "use_openai_sandbox_provider_or_non_sandbox_executor",
      },
    };
  }

  if (httpStatus === 400) {
    return {
      category: "environment",
      code: "PROVIDER_BAD_REQUEST",
      message: "Provider rejected the OpenAI Agents SDK request as invalid. Check provider compatibility with tools, sandbox, and the selected response mode.",
      recoverable: true,
      cause: error,
      details,
    };
  }

  if (httpStatus === 401 || httpStatus === 403 || /unauthorized|forbidden|invalid api key|authentication/i.test(rawMessage)) {
    return {
      category: "environment",
      code: "PROVIDER_AUTHENTICATION_FAILED",
      message: "Provider authentication failed. Check the configured API key and provider account access.",
      recoverable: true,
      cause: error,
      details,
    };
  }

  if (/max turns/i.test(rawMessage)) {
    return {
      category: "generation",
      code: executorKind === "agent" ? "OPENAI_AGENT_MAX_TURNS_EXCEEDED" : "OPENAI_SANDBOX_MAX_TURNS_EXCEEDED",
      message: "OpenAI Agents SDK reached the maximum turn limit before producing the required artifacts.",
      recoverable: true,
      cause: error,
      details,
    };
  }

  return {
    category: "generation",
    code: executorKind === "agent" ? "OPENAI_AGENT_RUN_FAILED" : "OPENAI_SANDBOX_RUN_FAILED",
    message: sanitizeProviderErrorMessage(rawMessage),
    recoverable: true,
    cause: error,
    details,
  };
}

export function readHttpStatus(message: string): number | undefined {
  const match = /\b(4\d\d|5\d\d)\b/.exec(message);
  return match ? Number.parseInt(match[1], 10) : undefined;
}

export function readProviderHost(baseURL: string | undefined): string | undefined {
  if (!baseURL) return undefined;
  try {
    return new URL(baseURL).host;
  } catch {
    return "invalid-url";
  }
}

export function sanitizeProviderErrorMessage(message: string): string {
  return message
    .replace(/<[^>]*>/g, " ")
    .replace(/https?:\/\/\S+/gi, "[url]")
    .replace(/\b(sk-[A-Za-z0-9_-]+|sk-or-[A-Za-z0-9_-]+)\b/g, "[redacted]")
    .replace(/\s+/g, " ")
    .trim();
}
