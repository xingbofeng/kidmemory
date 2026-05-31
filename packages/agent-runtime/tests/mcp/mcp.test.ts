import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

import { toOpenAIAgentsMcpTools } from "../../src/index.ts";

test("toOpenAIAgentsMcpTools exposes enabled HTTP MCP servers as hosted MCP tools", () => {
  const tools = toOpenAIAgentsMcpTools([
    {
      id: "assets",
      name: "Asset MCP",
      enabled: true,
      transport: {
        type: "http",
        url: "https://mcp.example.test",
        headers: {
          "x-runtime": "kidmemory",
        },
      },
      toolAllowlist: ["list_assets"],
    },
    {
      id: "disabled",
      name: "Disabled MCP",
      enabled: false,
      transport: {
        type: "http",
        url: "https://disabled.example.test",
      },
    },
  ]);

  assert.equal(tools.length, 1);
  assert.equal(tools[0].type, "hosted_tool");
  assert.equal(tools[0].name, "hosted_mcp");
});

test("toOpenAIAgentsMcpTools rejects stdio MCP servers instead of silently dropping them", () => {
  assert.throws(
    () => toOpenAIAgentsMcpTools([
      {
        id: "local",
        name: "Local MCP",
        transport: {
          type: "stdio",
          command: "node",
          args: ["server.js"],
        },
      },
    ]),
    /stdio MCP servers are not supported/i,
  );
});

test("toOpenAIAgentsMcpTools keeps server mapping as one explicit pass", () => {
  const source = fs.readFileSync("src/mcp/index.ts", "utf8");

  assert.equal(source.includes(".filter("), false);
  assert.equal(source.includes(".flatMap("), false);
});
