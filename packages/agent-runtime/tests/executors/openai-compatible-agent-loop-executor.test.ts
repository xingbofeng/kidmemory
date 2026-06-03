import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { OpenAICompatibleAgentLoopExecutor, type AgentTool } from "../../src/index.ts";

type FakeChatClient = ConstructorParameters<typeof OpenAICompatibleAgentLoopExecutor>[0] extends { client?: infer T } ? T : never;

function createTool(input: {
  id: string;
  execute: AgentTool["execute"];
}): AgentTool {
  return {
    id: input.id,
    name: input.id,
    description: input.id,
    source: "skill-deck",
    inputSchema: { type: "object" },
    risk: input.id === "run_skill_shell" ? "high" : "low",
    execute: input.execute,
  };
}

test("OpenAICompatibleAgentLoopExecutor lets the model choose skill-deck tools", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-agent-loop-"));
  const calls: Array<{ toolId: string; input: unknown }> = [];
  const completionRequests: unknown[] = [];
  let completionIndex = 0;
  const completions = [
    { toolCalls: [{ tool: "read_skill", input: { ref: "kidmemory-picturebook" } }] },
    {
      toolCalls: [
        {
          tool: "run_skill_shell",
          input: {
            skillRef: "kidmemory-picturebook",
            command: "node .kidmemory/skills/kidmemory-picturebook/render-picturebook.mjs",
            cwd: workspaceDir,
          },
        },
      ],
    },
    { final: "Picture book rendered." },
  ];
  const executor = new OpenAICompatibleAgentLoopExecutor({
    client: {
      chat: {
        completions: {
          async create(input) {
            completionRequests.push(input);
            return {
              choices: [
                {
                  message: {
                    content: JSON.stringify(completions[completionIndex++]),
                  },
                },
              ],
            };
          },
        },
      },
    } satisfies FakeChatClient,
  });

  const tools = [
    createTool({
      id: "read_skill",
      async execute(input) {
        calls.push({ toolId: "read_skill", input });
        return { data: { body: "Use render-picturebook.mjs" } };
      },
    }),
    createTool({
      id: "run_skill_shell",
      async execute(input) {
        calls.push({ toolId: "run_skill_shell", input });
        await fs.mkdir(path.join(workspaceDir, "output"), { recursive: true });
        await fs.writeFile(path.join(workspaceDir, "output", "book.json"), "{}");
        await fs.writeFile(path.join(workspaceDir, "output", "book.html"), "<html></html>");
        return { data: { exitCode: 0, stdout: "ok", stderr: "" } };
      },
    }),
  ];

  const result = await executor.run({
    runId: "run-1",
    sessionId: "session-1",
    workspaceDir,
    prompt: "make a picture book",
    provider: { model: "deepseek-v4-pro", baseURL: "https://tokenhub.tencentmaas.com/v1", apiKey: "test-key" },
    skills: {
      roots: [],
      skills: [
        {
          id: "kidmemory-picturebook",
          name: "kidmemory-picturebook",
          description: "Render picture books.",
          tags: [],
          dependencies: [],
          whenToUse: [],
          relatedSkills: [],
          hasExamples: false,
          exampleFiles: [],
          path: path.join(workspaceDir, ".kidmemory/skills/kidmemory-picturebook/SKILL.md"),
          bodyPath: path.join(workspaceDir, ".kidmemory/skills/kidmemory-picturebook/SKILL.md"),
          valid: true,
          warnings: [],
          errors: [],
        },
      ],
      openAIAgentsLocalSkills: [],
      mcpTools: [],
    },
    tools,
    mcpServers: [],
    requiredOutputFiles: ["output/book.json", "output/book.html"],
    maxTurns: 5,
  });

  assert.equal(result.ok, true);
  assert.deepEqual(
    completionRequests.map((request) => (request as { response_format?: unknown }).response_format),
    [
      { type: "json_object" },
      { type: "json_object" },
      { type: "json_object" },
    ],
  );
  assert.deepEqual(calls.map((call) => call.toolId), ["read_skill", "run_skill_shell"]);
  assert.deepEqual(calls[0]?.input, { ref: "kidmemory-picturebook" });
  assert.match(JSON.stringify(calls[1]?.input), /render-picturebook\.mjs/);
});

test("OpenAICompatibleAgentLoopExecutor asks the model to repair non-JSON loop responses", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-agent-loop-repair-"));
  const completionRequests: Array<{ messages?: Array<{ role: string; content: string }> }> = [];
  const responses = [
    "我可以做这个绘本。",
    JSON.stringify({ final: "Done after repairing the loop response." }),
  ];
  const executor = new OpenAICompatibleAgentLoopExecutor({
    client: {
      chat: {
        completions: {
          async create(input) {
            completionRequests.push(
              JSON.parse(JSON.stringify(input)) as {
                messages?: Array<{ role: string; content: string }>;
              },
            );
            return {
              choices: [
                {
                  message: {
                    content: responses.shift(),
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
    runId: "run-repair",
    sessionId: "session-repair",
    workspaceDir,
    prompt: "make a picture book",
    provider: { model: "deepseek-v4-pro", baseURL: "https://tokenhub.tencentmaas.com/v1", apiKey: "test-key" },
    skills: {
      roots: [],
      skills: [],
      openAIAgentsLocalSkills: [],
      mcpTools: [],
    },
    tools: [],
    mcpServers: [],
    requiredOutputFiles: [],
    maxTurns: 3,
  });

  assert.equal(result.ok, true);
  assert.match(
    completionRequests[1]?.messages?.at(-1)?.content ?? "",
    /invalid_agent_loop_response/,
  );
});

test("OpenAICompatibleAgentLoopExecutor rejects final answers until required outputs exist", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-agent-loop-required-"));
  const completionRequests: Array<{ messages?: Array<{ role: string; content: string }> }> = [];
  const responses = [
    JSON.stringify({ final: "Done too early." }),
    JSON.stringify({
      toolCalls: [
        {
          tool: "run_skill_shell",
          input: {
            skillRef: "kidmemory-picturebook",
            command: "node .kidmemory/skills/kidmemory-picturebook/render-picturebook.mjs",
          },
        },
      ],
    }),
    JSON.stringify({ final: "Done after writing outputs." }),
  ];
  const executor = new OpenAICompatibleAgentLoopExecutor({
    client: {
      chat: {
        completions: {
          async create(input) {
            completionRequests.push(
              JSON.parse(JSON.stringify(input)) as {
                messages?: Array<{ role: string; content: string }>;
              },
            );
            return {
              choices: [
                {
                  message: {
                    content: responses.shift(),
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
    runId: "run-required",
    sessionId: "session-required",
    workspaceDir,
    prompt: "make a picture book",
    provider: { model: "deepseek-v4-pro", baseURL: "https://tokenhub.tencentmaas.com/v1", apiKey: "test-key" },
    skills: {
      roots: [],
      skills: [],
      openAIAgentsLocalSkills: [],
      mcpTools: [],
    },
    tools: [
      createTool({
        id: "run_skill_shell",
        async execute() {
          await fs.mkdir(path.join(workspaceDir, "output"), { recursive: true });
          await fs.writeFile(path.join(workspaceDir, "output", "book.json"), "{}");
          await fs.writeFile(path.join(workspaceDir, "output", "book.html"), "<html></html>");
          return { data: { exitCode: 0 } };
        },
      }),
    ],
    mcpServers: [],
    requiredOutputFiles: ["output/book.json", "output/book.html"],
    maxTurns: 5,
  });

  assert.equal(result.ok, true);
  assert.match(
    completionRequests[1]?.messages?.at(-1)?.content ?? "",
    /required_output_files_missing/,
  );
});
