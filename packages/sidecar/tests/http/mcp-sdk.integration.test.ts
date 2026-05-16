import "reflect-metadata";

import assert from "node:assert/strict";
import test from "node:test";

import { NestFactory } from "@nestjs/core";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";

async function startApp() {
  const { AppModule } = await import("../../src/app.module.ts");
  const app = await NestFactory.create(AppModule, { logger: false });
  await app.listen(0, "127.0.0.1");
  const server = app.getHttpServer();
  const address = server.address();
  if (!address || typeof address !== "object") {
    throw new Error("Could not determine sidecar test server address.");
  }
  return { app, baseUrl: `http://127.0.0.1:${address.port}` };
}

test("sidecar MCP is callable through MCP SDK client", async (t) => {
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

  const client = new Client({ name: "kidmemory-test-client", version: "1.0.0" });
  const transport = new StreamableHTTPClientTransport(new URL(`${baseUrl}/mcp`));

  await client.connect(transport);
  const tools = await client.listTools();
  assert.ok(tools.tools.some((tool) => tool.name === "get_sidecar_health"));

  const result = await client.callTool({ name: "get_sidecar_health", arguments: {} });
  const content = Array.isArray(result.content) ? result.content : [];
  const textContent = content.find(
    (item): item is { type: "text"; text: string } =>
      item != null
      && typeof item === "object"
      && "type" in item
      && item.type === "text"
      && "text" in item
      && typeof item.text === "string",
  );
  assert.ok(textContent, "expected text content from tool call");
  assert.match(textContent.text, /kidmemory-sidecar/);

  await client.close();
});
