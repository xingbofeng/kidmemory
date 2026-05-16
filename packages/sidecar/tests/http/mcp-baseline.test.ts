import "reflect-metadata";

import assert from "node:assert/strict";
import test from "node:test";

import { NestFactory } from "@nestjs/core";

async function startApp() {
  const { AppModule } = await import(`../../src/app.module.ts?mcp=baseline&ts=${Date.now()}`);
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

test("mcp endpoint exposes tools/list and includes get_sidecar_health", async (t) => {
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

  const listResponse = await fetch(`${baseUrl}/mcp`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      accept: "application/json, text/event-stream",
    },
    body: JSON.stringify({
      jsonrpc: "2.0",
      id: 1,
      method: "tools/list",
      params: {},
    }),
  });

  assert.equal(listResponse.status, 200);
  const listPayload = (await listResponse.json()) as {
    result?: { tools?: Array<{ name?: string }> };
  };

  const toolNames = (listPayload.result?.tools ?? []).map((item) => item.name ?? "");
  assert.ok(toolNames.includes("get_sidecar_health"));
});

test("mcp tool get_sidecar_health is callable", async (t) => {
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

  const callResponse = await fetch(`${baseUrl}/mcp`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      accept: "application/json, text/event-stream",
    },
    body: JSON.stringify({
      jsonrpc: "2.0",
      id: 2,
      method: "tools/call",
      params: {
        name: "get_sidecar_health",
        arguments: {},
      },
    }),
  });

  assert.equal(callResponse.status, 200);
  const payload = (await callResponse.json()) as { result?: { content?: Array<{ text?: string }> } };
  const firstText = payload.result?.content?.[0]?.text ?? "";
  assert.match(firstText, /ok|healthy|ready/i);
});
