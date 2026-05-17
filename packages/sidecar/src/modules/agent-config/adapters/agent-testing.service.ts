import OpenAI from "openai";

import type { AgentConfig } from "../domain/agent-config.entity.ts";
import type { AgentTestingPort } from "../ports/agent-config.ports.ts";

type OpenAIClientFactory = (input: { apiKey: string; baseURL?: string }) => OpenAI;

export class AgentTestingService implements AgentTestingPort {
  private readonly fetchImpl: typeof fetch;
  private readonly openAIClientFactory: OpenAIClientFactory;

  constructor(fetchImpl: typeof fetch = fetch, openAIClientFactory: OpenAIClientFactory = (input) => new OpenAI(input)) {
    this.fetchImpl = fetchImpl;
    this.openAIClientFactory = openAIClientFactory;
  }

  async testConfiguration(config: AgentConfig, apiKey: string, testPrompt: string) {
    const startedAt = Date.now();
    try {
      if (config.provider === "anthropic") {
        const result = await this.testAnthropic(config, apiKey, testPrompt);
        return { ...result, responseTime: Date.now() - startedAt };
      }
      const result = await this.testOpenAICompatible(config, apiKey, testPrompt);
      return { ...result, responseTime: Date.now() - startedAt };
    } catch (error) {
      return {
        success: false,
        responseTime: Date.now() - startedAt,
        errorMessage: error instanceof Error ? error.message : "Unknown agent test failure",
      };
    }
  }

  private async testOpenAICompatible(config: AgentConfig, apiKey: string, testPrompt: string) {
    const client = this.openAIClientFactory({
      apiKey,
      baseURL: config.baseUrl || undefined,
    });
    const response = await client.responses.create({
      model: config.model,
      input: testPrompt,
      max_output_tokens: Math.min(config.maxTokens, 64),
    });
    const usage = response.usage as { total_tokens?: number } | null | undefined;
    return {
      success: true,
      modelUsed: config.model,
      tokensUsed: usage?.total_tokens,
    };
  }

  private async testAnthropic(config: AgentConfig, apiKey: string, testPrompt: string) {
    const endpoint = `${(config.baseUrl || "https://api.anthropic.com").replace(/\/$/, "")}/v1/messages`;
    const response = await this.fetchImpl(endpoint, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: config.model,
        max_tokens: Math.min(config.maxTokens, 64),
        messages: [{ role: "user", content: testPrompt }],
      }),
    });
    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Anthropic test request failed with HTTP ${response.status}: ${errorText.slice(0, 200)}`);
    }
    const body = await response.json() as { usage?: { input_tokens?: number; output_tokens?: number } };
    return {
      success: true,
      modelUsed: config.model,
      tokensUsed: (body.usage?.input_tokens || 0) + (body.usage?.output_tokens || 0) || undefined,
    };
  }
}
