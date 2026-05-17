import "reflect-metadata";

import assert from "node:assert/strict";
import test from "node:test";

import { NestFactory } from "@nestjs/core";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";

const REQUIRED_TOOLS = [
  "get_config_status",
  "get_indexing_status",
  "get_recent_logs",
  "generate_cover_image_preview",
  "render_hyperframes_video",
];

const FORBIDDEN_TOOLS = ["run_sql", "run_shell", "read_file"];

async function startApp() {
  const { AppModule } = await import(`../../src/app.module.ts?mcp=diag-tools&ts=${Date.now()}`);
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
  const client = new Client({ name: "kidmemory-diag-tools-test-client", version: "0.1.0" });
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

test("diagnostic/image/hyperframes MCP tools are discoverable", async (t) => {
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

  for (const toolName of REQUIRED_TOOLS) {
    assert.ok(names.includes(toolName), `missing MCP tool: ${toolName}`);
  }

  for (const forbiddenTool of FORBIDDEN_TOOLS) {
    assert.ok(!names.includes(forbiddenTool), `forbidden MCP tool is exposed: ${forbiddenTool}`);
  }
});

test("diagnostic/image/hyperframes MCP tools are callable", async (t) => {
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

  const configPayload = parseToolJson(await client.callTool({
    name: "get_config_status",
    arguments: {},
  }));
  assert.equal(typeof configPayload.postgres, "object");
  assert.equal(typeof configPayload.openai, "object");

  const indexingPayload = parseToolJson(await client.callTool({
    name: "get_indexing_status",
    arguments: {},
  }));
  assert.equal(typeof indexingPayload.pending, "number");
  assert.equal(typeof indexingPayload.searchable, "number");

  const logsPayload = parseToolJson(await client.callTool({
    name: "get_recent_logs",
    arguments: {
      limit: 5,
    },
  }));
  assert.ok(Array.isArray(logsPayload.logs), "get_recent_logs should return logs array");

  const coverPayload = parseToolJson(await client.callTool({
    name: "generate_cover_image_preview",
    arguments: {
      prompt: "a warm illustrated memory book cover",
      width: 512,
      height: 512,
      seed: 42,
    },
  }));
  assert.equal(typeof coverPayload.ok, "boolean");

  const degradedCoverPayload = parseToolJson(await client.callTool({
    name: "generate_cover_image_preview",
    arguments: {
      provider: "pollinations",
      prompt: "degraded cover preview path",
    },
  }));
  assert.equal(degradedCoverPayload.ok, false);
  assert.equal(degradedCoverPayload.canSkipCoverAndContinue, true);
  assert.equal(degradedCoverPayload.privacyBoundary?.textOnly, true);
  assert.equal(degradedCoverPayload.privacyBoundary?.childPhotoUpload, false);

  const renderPayload = parseToolJson(await client.callTool({
    name: "render_hyperframes_video",
    arguments: {
      projectId: "demo-project",
      prompt: "gentle family memories montage",
    },
  }));
  assert.equal(typeof renderPayload.ok, "boolean");
});
