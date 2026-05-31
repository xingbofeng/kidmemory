import "reflect-metadata";

import assert from "node:assert/strict";
import test from "node:test";

import { NestFactory } from "@nestjs/core";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";

import { useMcpTestEnv } from "./mcp-test-helpers.ts";

async function startApp() {
  const { AppModule } = await import(`../../src/app.module.ts?mcp=probe&ts=${Date.now()}`);
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

test("mcp is reachable through @modelcontextprotocol/sdk client", async (t) => {
  useMcpTestEnv(t);

  const { app, baseUrl } = await startApp();
  t.after(async () => {
    await app.close();
  });

  const client = new Client({ name: "kidmemory-mcp-test-client", version: "0.1.0" });
  const transport = new StreamableHTTPClientTransport(new URL(`${baseUrl}/mcp`));

  await client.connect(transport);

  const listResult = await client.listTools();
  assert.ok(listResult.tools.some((item) => item.name === "get_sidecar_health"));

  const healthResult = await client.callTool({
    name: "get_sidecar_health",
    arguments: {},
  });

  const firstText = healthResult.content?.[0] && "text" in healthResult.content[0]
    ? healthResult.content[0].text
    : "";
  assert.match(firstText, /ok|healthy|ready/i);

  await client.close();
});
