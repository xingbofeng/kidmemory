import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { OpenAICompatibleChatExecutor } from "../../src/executors/index.ts";

type FakeChatClient = ConstructorParameters<typeof OpenAICompatibleChatExecutor>[0] extends { client?: infer T } ? T : never;

test("OpenAICompatibleChatExecutor writes required output files returned by chat completion", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-chat-executor-"));
  const executor = new OpenAICompatibleChatExecutor({
    client: {
      chat: {
        completions: {
          async create() {
            return {
              choices: [
                {
                  message: {
                    content: JSON.stringify({
                      files: [
                        {
                          path: "output/plan.json",
                          content: JSON.stringify({
                            summary: "Plan",
                            skillName: "storybook",
                            steps: [{ stepId: "plan", label: "Plan", detail: "Plan" }],
                            requirements: ["one asset"],
                          }),
                        },
                      ],
                    }),
                  },
                },
              ],
            };
          },
        },
      },
    } satisfies FakeChatClient,
  });

  const result = await executor.run({
    runId: "run-1",
    sessionId: "session-1",
    workspaceDir,
    prompt: "make a plan",
    provider: { model: "deepseek-v4-flash", baseURL: "https://api.deepseek.com", apiKey: "test-key" },
    skills: { roots: [], skills: [] },
    tools: [],
    mcpServers: [],
    requiredOutputFiles: ["output/plan.json"],
  });

  assert.equal(result.ok, true);
  const plan = JSON.parse(await fs.readFile(path.join(workspaceDir, "output", "plan.json"), "utf8"));
  assert.equal(plan.summary, "Plan");
});
