import { getGlobalTraceProvider, type TraceProvider } from "@openai/agents";

import { readProviderHost } from "../provider-diagnostics.js";
import type { RuntimeProviderConfig } from "../types.js";

export function shouldDisableOpenAITracing(provider?: RuntimeProviderConfig): boolean {
  const baseURL = provider?.baseURL;
  if (!baseURL) return false;
  const host = readProviderHost(baseURL);
  return host !== "api.openai.com";
}

export function configureOpenAITracingForProvider(
  provider?: RuntimeProviderConfig,
  traceProvider: Pick<TraceProvider, "setDisabled"> = getGlobalTraceProvider(),
): void {
  traceProvider.setDisabled(shouldDisableOpenAITracing(provider));
}
