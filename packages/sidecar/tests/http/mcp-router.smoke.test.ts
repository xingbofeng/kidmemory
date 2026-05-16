import "reflect-metadata";

import assert from "node:assert/strict";
import test from "node:test";

import { NestFactory } from "@nestjs/core";

async function startApp(cacheBust) {
  const suffix = cacheBust ? `?cache=${encodeURIComponent(cacheBust)}` : "";
  const { AppModule } = await import(`../../src/app.module.ts${suffix}`);
  const app = await NestFactory.create(AppModule, { logger: false });
  await app.listen(0, "127.0.0.1");
  const server = app.getHttpServer();
  const address = server.address();
  if (!address || typeof address !== "object") {
    throw new Error("Could not determine sidecar test server address.");
  }
  return { app, baseUrl: `http://127.0.0.1:${address.port}` };
}

test("MCP endpoint exists when KIDMEMORY_MCP_ENABLED=true", async (t) => {
  const oldEnabled = process.env.KIDMEMORY_MCP_ENABLED;
  const oldPath = process.env.KIDMEMORY_MCP_PATH;
  process.env.KIDMEMORY_MCP_ENABLED = "true";
  process.env.KIDMEMORY_MCP_PATH = "/mcp";

  const { app, baseUrl } = await startApp(`enabled-${Date.now()}`);
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

  const response = await fetch(`${baseUrl}/mcp`, { method: "GET" });
  assert.notEqual(response.status, 404, "MCP endpoint should be registered when enabled");
});

test("MCP endpoint is not registered when KIDMEMORY_MCP_ENABLED=false", async (t) => {
  const oldEnabled = process.env.KIDMEMORY_MCP_ENABLED;
  const oldPath = process.env.KIDMEMORY_MCP_PATH;
  process.env.KIDMEMORY_MCP_ENABLED = "false";
  process.env.KIDMEMORY_MCP_PATH = "/mcp";

  const { app, baseUrl } = await startApp(`disabled-${Date.now()}`);
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

  const response = await fetch(`${baseUrl}/mcp`, { method: "GET" });
  assert.equal(response.status, 404, "MCP endpoint should not be registered when disabled");
});
