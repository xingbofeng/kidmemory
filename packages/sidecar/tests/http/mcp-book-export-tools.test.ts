import "reflect-metadata";

import assert from "node:assert/strict";
import test from "node:test";

import { NestFactory } from "@nestjs/core";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";

import { AppModule } from "../../src/app.module.ts";

const REQUIRED_BOOK_TOOLS = [
  "create_book_job",
  "get_book_job",
  "list_book_jobs",
  "export_book_pdf",
  "export_book_long_image",
];

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
  const client = new Client({ name: "kidmemory-book-tools-test-client", version: "0.1.0" });
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

test("book/export MCP tools are discoverable via tools/list", async (t) => {
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

  for (const toolName of REQUIRED_BOOK_TOOLS) {
    assert.ok(names.includes(toolName), `missing MCP tool: ${toolName}`);
  }
});

test("book/export MCP tools are callable with valid payloads", async (t) => {
  const { app, baseUrl } = await startApp();
  t.after(async () => {
    await app.close();
  });

  const client = await connectClient(baseUrl);
  t.after(async () => {
    await client.close();
  });

  const createPayload = parseToolJson(await client.callTool({
    name: "create_book_job",
    arguments: {
      assetIds: [],
    },
  }));
  assert.equal(typeof createPayload.status, "number");

  const listPayload = parseToolJson(await client.callTool({
    name: "list_book_jobs",
    arguments: {},
  }));
  assert.ok(Array.isArray(listPayload.jobs), "list_book_jobs should return jobs array");

  const getPayload = parseToolJson(await client.callTool({
    name: "get_book_job",
    arguments: {
      jobId: "job-not-found",
    },
  }));
  assert.equal(typeof getPayload.ok, "boolean");

  const exportPdfPayload = parseToolJson(await client.callTool({
    name: "export_book_pdf",
    arguments: {
      jobId: "job-not-found",
      body: {},
    },
  }));
  assert.equal(typeof exportPdfPayload.status, "number");

  const exportLongImagePayload = parseToolJson(await client.callTool({
    name: "export_book_long_image",
    arguments: {
      jobId: "job-not-found",
      body: {},
    },
  }));
  assert.equal(typeof exportLongImagePayload.status, "number");
});
