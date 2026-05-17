import "reflect-metadata";

import assert from "node:assert/strict";
import test from "node:test";

import { NestFactory } from "@nestjs/core";

async function startAppWithFlag(enabled: boolean) {
  process.env.KIDMEMORY_MCP_ENABLED = enabled ? "true" : "false";

  const { AppModule } = await import(`../../src/app.module.ts?flag=${enabled ? "on" : "off"}&ts=${Date.now()}`);
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

test("mcp endpoint is disabled when KIDMEMORY_MCP_ENABLED=false", async (t) => {
  const { app, baseUrl } = await startAppWithFlag(false);
  t.after(async () => {
    await app.close();
  });

  const response = await fetch(`${baseUrl}/mcp`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      accept: "application/json, text/event-stream",
    },
    body: JSON.stringify({ jsonrpc: "2.0", id: 1, method: "tools/list", params: {} }),
  });

  assert.equal(response.status, 404);
});

test("mcp endpoint is enabled when KIDMEMORY_MCP_ENABLED=true", async (t) => {
  const { app, baseUrl } = await startAppWithFlag(true);
  t.after(async () => {
    await app.close();
  });

  const response = await fetch(`${baseUrl}/mcp`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      accept: "application/json, text/event-stream",
    },
    body: JSON.stringify({ jsonrpc: "2.0", id: 1, method: "tools/list", params: {} }),
  });

  assert.equal(response.status, 200);
});
