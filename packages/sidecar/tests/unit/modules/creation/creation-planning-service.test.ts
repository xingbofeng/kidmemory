import assert from "node:assert/strict";
import http from "node:http";
import { test } from "node:test";

import { CreationPlanningService } from "../../../../src/modules/creation/creation-planning.service.ts";

test("creation planning uses chat completions for custom OpenAI-compatible endpoints", async () => {
  const requests: Array<{ method?: string; url?: string }> = [];
  const server = http.createServer((request, response) => {
    requests.push({ method: request.method, url: request.url });
    request.resume();

    if (request.method === "POST" && request.url === "/v1/chat/completions") {
      response.writeHead(200, { "content-type": "application/json" });
      response.end(
        JSON.stringify({
          id: "chatcmpl_test",
          object: "chat.completion",
          created: 1,
          model: "mimo-v2-pro",
          choices: [
            {
              index: 0,
              finish_reason: "stop",
              message: {
                role: "assistant",
                content: JSON.stringify({
                  summary: "Plan from a chat-completions-compatible endpoint.",
                  skillName: "KidMemory storybook",
                  steps: [
                    {
                      stepId: "compose",
                      label: "整理素材",
                      detail: "选择可用照片",
                    },
                  ],
                  requirements: ["Selected assets"],
                }),
              },
            },
          ],
          usage: { prompt_tokens: 1, completion_tokens: 1, total_tokens: 2 },
        }),
      );
      return;
    }

    response.writeHead(404, { "content-type": "text/html" });
    response.end("<html><body>404 Not Found</body></html>");
  });

  await new Promise<void>((resolve) => server.listen(0, "127.0.0.1", resolve));
  try {
    const address = server.address();
    assert.ok(address && typeof address === "object");
    const service = new CreationPlanningService({
      async getDefaultConfig() {
        return {
          id: "agent_custom",
          provider: "custom",
          baseUrl: `http://127.0.0.1:${address.port}/v1`,
          model: "mimo-v2-pro",
          temperature: 0,
          maxTokens: 500,
        };
      },
      async getDecryptedApiKey() {
        return "sk-test";
      },
    } as any);

    const result = await service.createPlan({
      goal: "为春游照片做一本绘本",
      creationType: "storybook",
      assetIds: ["asset-1"],
    });

    assert.equal(result.ok, true);
    assert.equal(
      result.summary,
      "Plan from a chat-completions-compatible endpoint.",
    );
    assert.equal(result.skillName, "KidMemory storybook");
    assert.deepEqual(
      requests.map((request) => request.url),
      ["/v1/chat/completions"],
    );
  } finally {
    await new Promise<void>((resolve, reject) => {
      server.close((error) => (error ? reject(error) : resolve()));
    });
  }
});
