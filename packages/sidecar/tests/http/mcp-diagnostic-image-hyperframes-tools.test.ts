import "reflect-metadata";

import assert from "node:assert/strict";
import test from "node:test";

import { NestFactory } from "@nestjs/core";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";

import { parseToolJson, useMcpTestEnv } from "./mcp-test-helpers.ts";

const REQUIRED_TOOLS = [
  "get_config_status",
  "get_indexing_status",
  "get_recent_logs",
  "generate_cover_image_preview",
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

test("diagnostic/image/hyperframes MCP tools are discoverable", async (t) => {
  useMcpTestEnv(t);

  const { app, baseUrl } = await startApp();
  t.after(async () => {
    await app.close();
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
  useMcpTestEnv(t);

  const { app, baseUrl } = await startApp();
  t.after(async () => {
    await app.close();
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
});
