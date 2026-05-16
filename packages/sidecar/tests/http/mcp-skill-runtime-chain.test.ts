import "reflect-metadata";

import assert from "node:assert/strict";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { NestFactory } from "@nestjs/core";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";

const REQUIRED_TOOLS = [
  "list_children",
  "get_child_profile",
  "list_recent_assets",
  "search_assets",
  "search_assets_by_vector",
  "get_asset_metadata",
  "get_asset_preview",
  "update_asset_metadata",
  "create_book_job",
  "get_book_job",
  "list_book_jobs",
  "export_book_pdf",
  "export_book_long_image",
  "get_config_status",
  "get_indexing_status",
  "get_recent_logs",
  "generate_cover_image_preview",
  "render_hyperframes_video",
  "list_skills",
  "run_skill_task",
  "get_sidecar_health",
];

const FORBIDDEN_TOOLS = ["run_sql", "run_shell", "read_file", "write_file", "delete_file"];

test("MCP tools expose skill runtime chain and enforce boundaries", async (t) => {
  const tmpRoot = path.join(os.tmpdir(), `kidmemory-mcp-skill-${Date.now()}`);
  const old = {
    enabled: process.env.KIDMEMORY_MCP_ENABLED,
    path: process.env.KIDMEMORY_MCP_PATH,
    root: process.env.KIDMEMORY_ROOT_DIR,
    provider: process.env.KIDMEMORY_IMAGE_PROVIDER,
    hyperframesCommand: process.env.HYPERFRAMES_RENDER_COMMAND,
  };

  process.env.KIDMEMORY_MCP_ENABLED = "true";
  process.env.KIDMEMORY_MCP_PATH = "/mcp";
  process.env.KIDMEMORY_ROOT_DIR = tmpRoot;
  process.env.KIDMEMORY_IMAGE_PROVIDER = "pollinations";
  delete process.env.HYPERFRAMES_RENDER_COMMAND;

  const { AppModule } = await import(`../../src/app.module.ts?mcp=skill-chain&ts=${Date.now()}`);
  const app = await NestFactory.create(AppModule, { logger: false });
  await app.listen(0, "127.0.0.1");

  const address = app.getHttpServer().address();
  if (!address || typeof address !== "object") {
    throw new Error("failed to read listening address");
  }
  const baseUrl = `http://127.0.0.1:${address.port}`;

  t.after(async () => {
    await app.close();
    restoreEnv(old);
  });

  await fetch(`${baseUrl}/children`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ id: "child-skill-runtime-01", name: "Skill Runtime Child" }),
  });

  const client = new Client({ name: "kidmemory-skill-runtime-test-client", version: "0.1.0" });
  const transport = new StreamableHTTPClientTransport(new URL(`${baseUrl}/mcp`));
  await client.connect(transport);

  t.after(async () => {
    await client.close();
  });

  const list = await client.listTools();
  const names = list.tools.map((item) => item.name);

  for (const required of REQUIRED_TOOLS) {
    assert.ok(names.includes(required), `missing MCP tool: ${required}`);
  }
  for (const forbidden of FORBIDDEN_TOOLS) {
    assert.ok(!names.includes(forbidden), `forbidden MCP tool should not exist: ${forbidden}`);
  }

  const skillRunResult = decodeJsonResult(await client.callTool({
    name: "run_skill_task",
    arguments: {
      skillId: "picturebook-maker",
      tool: "list_children",
      arguments: {},
      traceId: "trace_skill_chain",
    },
  }));

  assert.equal(skillRunResult.ok, true);
  const skillChildren = pickArray(skillRunResult, ["toolResult.children", "toolResult.child", "children"]);
  assert.ok(Array.isArray(skillChildren));
  assert.ok(JSON.stringify(skillChildren).includes("child-skill-runtime-01"));

  const deniedResult = decodeJsonResult(await client.callTool({
    name: "run_skill_task",
    arguments: {
      skillId: "hyperframes",
      tool: "list_children",
      arguments: {},
    },
  }));
  assert.equal(deniedResult.ok, false);
  assert.match(String(deniedResult.message ?? ""), /denied/i);

  const coverResult = decodeJsonResult(await client.callTool({
    name: "generate_cover_image_preview",
    arguments: {
      prompt: "watercolor child storybook cover",
      traceId: "trace_cover_preview",
      width: 768,
      height: 1024,
    },
  }));
  assert.equal(coverResult.ok, true);
  assert.equal(coverResult.provider, "pollinations");
  assert.equal(coverResult.privacyBoundary?.textOnly, true);
  assert.equal(coverResult.privacyBoundary?.childPhotoUpload, false);

  const hyperframesResult = decodeJsonResult(await client.callTool({
    name: "render_hyperframes_video",
    arguments: {
      projectId: "demo-video-project",
      traceId: "trace_hyperframes_preview",
    },
  }));
  assert.equal(hyperframesResult.ok, false);
  assert.equal(hyperframesResult.recoverable, true);

  const bookListResult = decodeJsonResult(await client.callTool({
    name: "list_book_jobs",
    arguments: {},
  }));
  assert.ok(Array.isArray(bookListResult.jobs));

  const recentLogsResult = decodeJsonResult(await client.callTool({
    name: "get_recent_logs",
    arguments: { limit: 200 },
  }));
  assert.ok(Array.isArray(recentLogsResult.logs));
  const logsText = JSON.stringify(recentLogsResult.logs);
  assert.ok(logsText.includes("skills.runtime.execute.start"));
  assert.ok(logsText.includes("trace_skill_chain"));
});

function decodeJsonResult(result: Awaited<ReturnType<Client["callTool"]>>) {
  const first = result.content?.[0];
  if (!first || !("text" in first) || typeof first.text !== "string") {
    return {} as Record<string, unknown>;
  }

  const nested = decodeNestedJson(first.text);
  if (nested && typeof nested === "object" && !Array.isArray(nested)) {
    return nested as Record<string, any>;
  }
  return {} as Record<string, unknown>;
}

function decodeNestedJson(value: string): unknown {
  let current: unknown = value;
  for (let index = 0; index < 3; index += 1) {
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

function pickArray(source: Record<string, any>, paths: string[]) {
  for (const pathKey of paths) {
    const parts = pathKey.split(".");
    let cursor: any = source;
    for (const part of parts) {
      if (!cursor || typeof cursor !== "object") {
        cursor = undefined;
        break;
      }
      cursor = cursor[part];
    }

    if (Array.isArray(cursor)) {
      return cursor;
    }
  }

  return [];
}

function restoreEnv(old: Record<string, string | undefined>) {
  setOrDelete("KIDMEMORY_MCP_ENABLED", old.enabled);
  setOrDelete("KIDMEMORY_MCP_PATH", old.path);
  setOrDelete("KIDMEMORY_ROOT_DIR", old.root);
  setOrDelete("KIDMEMORY_IMAGE_PROVIDER", old.provider);
  setOrDelete("HYPERFRAMES_RENDER_COMMAND", old.hyperframesCommand);
}

function setOrDelete(key: string, value: string | undefined) {
  if (value === undefined) {
    delete process.env[key];
    return;
  }
  process.env[key] = value;
}
