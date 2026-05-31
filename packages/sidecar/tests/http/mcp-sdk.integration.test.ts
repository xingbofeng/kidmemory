import "reflect-metadata";

import assert from "node:assert/strict";
import test from "node:test";

import { NestFactory } from "@nestjs/core";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";

import { useMcpTestEnv } from "./mcp-test-helpers.ts";

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
  useMcpTestEnv(t);

  const { app, baseUrl } = await startApp();

  t.after(async () => {
    await app.close();
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
