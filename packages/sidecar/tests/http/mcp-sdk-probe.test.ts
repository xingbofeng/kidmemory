import "reflect-metadata";

import assert from "node:assert/strict";
import test from "node:test";

import { NestFactory } from "@nestjs/core";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";

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
