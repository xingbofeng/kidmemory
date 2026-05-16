import "reflect-metadata";

import assert from "node:assert/strict";
import test from "node:test";

import { NestFactory } from "@nestjs/core";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";

async function startApp() {
  const { AppModule } = await import(`../../src/app.module.ts?mcp=skill-runtime&ts=${Date.now()}`);
  const app = await NestFactory.create(AppModule, { logger: false });
  await app.listen(0, "127.0.0.1");
  const address = app.getHttpServer().address();
  if (!address || typeof address !== "object") {
    throw new Error("failed to read listening address");
  }
  return {
    app,
    baseUrl: `http://127.0.0.1:${address.port}`,
  };
}

async function connectClient(baseUrl: string) {
  const client = new Client({ name: "kidmemory-skill-runtime-test-client", version: "0.1.0" });
  const transport = new StreamableHTTPClientTransport(new URL(`${baseUrl}/mcp`));
  await client.connect(transport);
  return client;
}

function parseToolJson(result: Awaited<ReturnType<Client["callTool"]>>) {
  const first = result.content?.[0];
  if (!first || !("text" in first) || typeof first.text !== "string") {
    return {};
  }

  const decoded = decodeNestedJson(first.text);
  if (decoded && typeof decoded === "object" && !Array.isArray(decoded)) {
    return decoded as Record<string, unknown>;
  }
  return {};
}

function decodeNestedJson(value: string): unknown {
  let current: unknown = value;

  for (let i = 0; i < 3; i += 1) {
    if (typeof current !== "string") {
      break;
    }
    try {
      current = JSON.parse(current);
    } catch {
      break;
    }
  }

  return current;
}

test("skill runtime MCP tools are discoverable", async (t) => {
  const oldEnabled = process.env.KIDMEMORY_MCP_ENABLED;
  const oldPath = process.env.KIDMEMORY_MCP_PATH;
  process.env.KIDMEMORY_MCP_ENABLED = "true";
  process.env.KIDMEMORY_MCP_PATH = "/mcp";

  const { app, baseUrl } = await startApp();
  t.after(async () => {
    await app.close();
    if (oldEnabled === undefined) {
      delete process.env.KIDMEMORY_MCP_ENABLED;
    } else {
      process.env.KIDMEMORY_MCP_ENABLED = oldEnabled;
    }
    if (oldPath === undefined) {
      delete process.env.KIDMEMORY_MCP_PATH;
    } else {
      process.env.KIDMEMORY_MCP_PATH = oldPath;
    }
  });

  const client = await connectClient(baseUrl);
  t.after(async () => {
    await client.close();
  });

  const listResult = await client.listTools();
  const names = listResult.tools.map((tool) => tool.name);

  assert.ok(names.includes("list_skills"));
  assert.ok(names.includes("run_skill_task"));
});

test("run_skill_task executes skill runtime and triggers tool call", async (t) => {
  const oldEnabled = process.env.KIDMEMORY_MCP_ENABLED;
  const oldPath = process.env.KIDMEMORY_MCP_PATH;
  process.env.KIDMEMORY_MCP_ENABLED = "true";
  process.env.KIDMEMORY_MCP_PATH = "/mcp";

  const { app, baseUrl } = await startApp();
  t.after(async () => {
    await app.close();
    if (oldEnabled === undefined) {
      delete process.env.KIDMEMORY_MCP_ENABLED;
    } else {
      process.env.KIDMEMORY_MCP_ENABLED = oldEnabled;
    }
    if (oldPath === undefined) {
      delete process.env.KIDMEMORY_MCP_PATH;
    } else {
      process.env.KIDMEMORY_MCP_PATH = oldPath;
    }
  });

  const client = await connectClient(baseUrl);
  t.after(async () => {
    await client.close();
  });

  const listSkillsPayload = parseToolJson(await client.callTool({
    name: "list_skills",
    arguments: {},
  }));

  assert.ok(Array.isArray(listSkillsPayload.skills), "skills should be listed");

  const runPayload = parseToolJson(await client.callTool({
    name: "run_skill_task",
    arguments: {
      skillId: "picturebook-maker",
      tool: "get_sidecar_health",
      arguments: {},
      traceId: "test-trace-skill-runtime",
    },
  }));

  assert.equal(runPayload.ok, true);
  assert.equal(runPayload.skillId, "picturebook-maker");
  assert.equal(runPayload.tool, "get_sidecar_health");
  assert.equal(typeof runPayload.workspaceDir, "string");

  const toolResult = runPayload.toolResult as Record<string, unknown>;
  assert.equal(toolResult.status, "ok");
});
