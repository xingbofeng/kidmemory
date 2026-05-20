import assert from "node:assert/strict";
import { test } from "node:test";

import { AgentConfig } from "../../../../src/modules/agent-config/domain/agent-config.entity.ts";
import { AgentTestingService } from "../../../../src/modules/agent-config/adapters/agent-testing.service.ts";

test("agent config test uses chat completions for custom OpenAI-compatible providers", async () => {
  const calls: string[] = [];
  const service = new AgentTestingService(fetch, () => ({
    responses: {
      create: async () => {
        calls.push("responses");
        throw new Error("custom provider should not use Responses API");
      },
    },
    chat: {
      completions: {
        create: async () => {
          calls.push("chat.completions");
          return { usage: { total_tokens: 12 } };
        },
      },
    },
  }));

  const config = AgentConfig.create({
    name: "Xiaomi MiMo",
    provider: "custom",
    model: "mimo-v2-pro",
    baseUrl: "https://api.xiaomimimo.com/v1",
    apiKey: "sk-test",
  });

  const result = await service.testConfiguration(config, "sk-test", "ping");

  assert.equal(result.success, true);
  assert.equal(result.modelUsed, "mimo-v2-pro");
  assert.equal(result.tokensUsed, 12);
  assert.deepEqual(calls, ["chat.completions"]);
});

test("agent config test keeps Responses API for the official OpenAI provider", async () => {
  const calls: string[] = [];
  const service = new AgentTestingService(fetch, () => ({
    responses: {
      create: async () => {
        calls.push("responses");
        return { usage: { total_tokens: 7 } };
      },
    },
    chat: {
      completions: {
        create: async () => {
          calls.push("chat.completions");
          throw new Error("official OpenAI provider should use Responses API");
        },
      },
    },
  }));

  const config = AgentConfig.create({
    name: "OpenAI",
    provider: "openai",
    model: "gpt-4.1-mini",
    apiKey: "sk-test",
  });

  const result = await service.testConfiguration(config, "sk-test", "ping");

  assert.equal(result.success, true);
  assert.equal(result.modelUsed, "gpt-4.1-mini");
  assert.equal(result.tokensUsed, 7);
  assert.deepEqual(calls, ["responses"]);
});
