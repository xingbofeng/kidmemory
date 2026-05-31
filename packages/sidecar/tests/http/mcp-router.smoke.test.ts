import "reflect-metadata";

import assert from "node:assert/strict";
import test from "node:test";

import { NestFactory } from "@nestjs/core";

import { useMcpTestEnv } from "./mcp-test-helpers.ts";

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
  useMcpTestEnv(t);

  const { app, baseUrl } = await startApp(`enabled-${Date.now()}`);
  t.after(async () => {
    await app.close();
  });

  const response = await fetch(`${baseUrl}/mcp`, { method: "GET" });
  assert.notEqual(response.status, 404, "MCP endpoint should be registered when enabled");
});

test("MCP endpoint is not registered when KIDMEMORY_MCP_ENABLED=false", async (t) => {
  useMcpTestEnv(t, { enabled: false });

  const { app, baseUrl } = await startApp(`disabled-${Date.now()}`);
  t.after(async () => {
    await app.close();
  });

  const response = await fetch(`${baseUrl}/mcp`, { method: "GET" });
  assert.equal(response.status, 404, "MCP endpoint should not be registered when disabled");
});
