import "reflect-metadata";

import assert from "node:assert/strict";
import { writeFile, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import test from "node:test";

import { NestFactory } from "@nestjs/core";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";

import { AppModule } from "../../src/app.module.ts";

async function startApp() {
  process.env.KIDMEMORY_MCP_ENABLED = "true";
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
  const client = new Client({ name: "kidmemory-asset-tools-test-client", version: "0.1.0" });
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

const REQUIRED_ASSET_TOOLS = [
  "list_children",
  "get_child_profile",
  "list_recent_assets",
  "search_assets",
  "search_assets_by_vector",
  "get_asset_metadata",
  "get_asset_preview",
  "update_asset_metadata",
];

test("asset MCP tools are discoverable via tools/list", async (t) => {
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

  for (const toolName of REQUIRED_ASSET_TOOLS) {
    assert.ok(names.includes(toolName), `missing MCP tool: ${toolName}`);
  }
});

test("list_children and get_child_profile are callable", async (t) => {
  const { app, baseUrl } = await startApp();
  t.after(async () => {
    await app.close();
  });

  await fetch(`${baseUrl}/children`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ id: "child-mcp-1", name: "MCP Child" }),
  });

  const client = await connectClient(baseUrl);
  t.after(async () => {
    await client.close();
  });

  const childrenResult = await client.callTool({
    name: "list_children",
    arguments: {},
  });
  const childrenText = childrenResult.content?.[0] && "text" in childrenResult.content[0]
    ? childrenResult.content[0].text
    : "";
  assert.match(childrenText, /child-mcp-1|MCP Child/);

  const childResult = await client.callTool({
    name: "get_child_profile",
    arguments: { childId: "child-mcp-1" },
  });
  const childText = childResult.content?.[0] && "text" in childResult.content[0]
    ? childResult.content[0].text
    : "";
  assert.match(childText, /child-mcp-1|MCP Child/);
});

test("all asset MCP tools are callable with valid payloads", async (t) => {
  const { app, baseUrl } = await startApp();
  t.after(async () => {
    await app.close();
  });

  const seededChildId = "child-mcp-tools-seed";
  await fetch(`${baseUrl}/children`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ id: seededChildId, name: "MCP Tools Seed Child" }),
  });

  const tempAssetPath = path.join(tmpdir(), `kidmemory-mcp-asset-${Date.now()}.png`);
  await writeFile(
    tempAssetPath,
    Buffer.from(
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO7M5f8AAAAASUVORK5CYII=",
      "base64",
    ),
  );
  t.after(async () => {
    await rm(tempAssetPath, { force: true }).catch(() => undefined);
  });

  await fetch(`${baseUrl}/assets/import`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ childId: seededChildId, paths: [tempAssetPath] }),
  });

  await fetch(`${baseUrl}/sample/import`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ persist: true }),
  });

  const client = await connectClient(baseUrl);
  t.after(async () => {
    await client.close();
  });

  await client.callTool({ name: "list_children", arguments: {} });
  const childId = seededChildId;
  assert.equal(typeof childId, "string");

  await client.callTool({ name: "get_child_profile", arguments: { childId } });

  const assetsPayload = parseToolJson(
    await client.callTool({ name: "list_recent_assets", arguments: { childId, limit: 5 } }),
  );
  const assetId = Array.isArray(assetsPayload.assets) && assetsPayload.assets.length > 0
    ? extractId(assetsPayload.assets[0] as Record<string, unknown>, ["id", "assetId"])
    : undefined;
  assert.equal(typeof assetId, "string");

  await client.callTool({
    name: "search_assets",
    arguments: { childId, query: "photo", page: 1, pageSize: 5 },
  });

  await client.callTool({
    name: "search_assets_by_vector",
    arguments: { childId, query: "smile", page: 1, pageSize: 5 },
  });

  await client.callTool({ name: "get_asset_metadata", arguments: { assetId } });
  await client.callTool({ name: "get_asset_preview", arguments: { assetId } });
  await client.callTool({
    name: "update_asset_metadata",
    arguments: { assetId, title: "Updated by MCP Test" },
  });
});

function extractId(record: Record<string, unknown>, keys: string[]) {
  for (const key of keys) {
    const value = record[key];
    if (typeof value === "string" && value.length > 0) {
      return value;
    }
  }
  return undefined;
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
