import "reflect-metadata";

import assert from "node:assert/strict";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { NestFactory } from "@nestjs/core";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";
import type { NextFunction, Request, Response } from "express";
import { FileLoggerService } from "../../src/infrastructure/logging/file-logger.service.ts";
import {
  REQUEST_HEADER,
  TRACE_HEADER,
  TraceContextService,
} from "../../src/infrastructure/logging/trace-context.service.ts";
import { useTestEnv } from "../test-env.ts";
import { parseToolJson, useMcpTestEnv } from "./mcp-test-helpers.ts";

type TraceRequest = Request & {
  traceId?: string;
  requestId?: string;
};

test("trace header is logged and queryable via get_recent_logs", async (t) => {
  useMcpTestEnv(t);

  const tempRoot = path.join(os.tmpdir(), `kidmemory-trace-${Date.now()}`);
  useTestEnv(t, { KIDMEMORY_ROOT_DIR: tempRoot });

  const { AppModule } = await import(`../../src/app.module.ts?trace-logging=${Date.now()}`);
  const app = await NestFactory.create(AppModule, { logger: false });
  const fileLogger = app.get(FileLoggerService);
  const traceContext = app.get(TraceContextService);

  app.use((req: TraceRequest, res: Response, next: NextFunction) => {
    const startedAt = Date.now();
    const traceId = traceContext.normalizeTraceId(req.get(TRACE_HEADER));
    const requestId = traceContext.normalizeRequestId(req.get(REQUEST_HEADER) ?? req.requestId);

    req.traceId = traceId;
    req.requestId = requestId;
    res.setHeader(TRACE_HEADER, traceId);
    res.setHeader(REQUEST_HEADER, requestId);

    void fileLogger.append({
      timestamp: new Date().toISOString(),
      level: "info",
      event: "http.request.started",
      traceId,
      requestId,
      data: {
        method: req.method,
        path: req.path,
      },
    });

    res.on("finish", () => {
      void fileLogger.append({
        timestamp: new Date().toISOString(),
        level: res.statusCode >= 500 ? "error" : "info",
        event: "http.request.completed",
        traceId,
        requestId,
        data: {
          method: req.method,
          path: req.path,
          status: res.statusCode,
          durationMs: Date.now() - startedAt,
        },
      });
    });

    traceContext.runWithContext({ traceId, requestId }, () => next());
  });

  await app.listen(0, "127.0.0.1");

  const address = app.getHttpServer().address();
  if (!address || typeof address !== "object") {
    throw new Error("failed to read listening address");
  }

  const baseUrl = `http://127.0.0.1:${address.port}`;

  t.after(async () => {
    await app.close();
  });

  const traceId = `trace-http-header-e2e-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;

  const healthResponse = await fetch(`${baseUrl}/health`, {
    method: "GET",
    headers: {
      "x-kidmemory-trace-id": traceId,
    },
  });
  assert.equal(healthResponse.status, 200);

  const client = new Client({
    name: "kidmemory-trace-test-client",
    version: "0.1.0",
  });
  await client.connect(new StreamableHTTPClientTransport(new URL(`${baseUrl}/mcp`)));

  t.after(async () => {
    await client.close();
  });

  const logs = await waitForLogs(client, traceId);
  const hasTrace = logs.some((row) => row.traceId === traceId);
  assert.equal(hasTrace, true, "expected at least one recent log entry with propagated traceId");

  const hasHttpStart = logs.some((row) => row.event === "http.request.started");
  const hasHttpEnd = logs.some((row) => row.event === "http.request.completed");
  assert.equal(hasHttpStart, true, "expected http.request.started log entry");
  assert.equal(hasHttpEnd, true, "expected http.request.completed log entry");
});

test("trace header propagates into provider logs even without explicit tool trace argument", async (t) => {
  useMcpTestEnv(t);

  const tempRoot = path.join(os.tmpdir(), `kidmemory-trace-provider-${Date.now()}`);
  useTestEnv(t, { KIDMEMORY_ROOT_DIR: tempRoot });

  const { AppModule } = await import(`../../src/app.module.ts?trace-provider=${Date.now()}`);
  const app = await NestFactory.create(AppModule, { logger: false });
  await app.listen(0, "127.0.0.1");

  const address = app.getHttpServer().address();
  if (!address || typeof address !== "object") {
    throw new Error("failed to read listening address");
  }

  const baseUrl = `http://127.0.0.1:${address.port}`;

  t.after(async () => {
    await app.close();
  });

  const traceId = "trace-provider-header-e2e";
  const rpcResponse = await fetch(`${baseUrl}/mcp`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "accept": "application/json, text/event-stream",
      "x-kidmemory-trace-id": traceId,
    },
    body: JSON.stringify({
      jsonrpc: "2.0",
      id: 101,
      method: "tools/call",
      params: {
        name: "generate_cover_image_preview",
        arguments: {
          prompt: "watercolor storybook cover",
          width: 512,
          height: 512,
        },
      },
    }),
  });
  assert.equal(rpcResponse.status, 200);

  const client = new Client({ name: "kidmemory-trace-provider-test-client", version: "0.1.0" });
  await client.connect(new StreamableHTTPClientTransport(new URL(`${baseUrl}/mcp`)));

  t.after(async () => {
    await client.close();
  });

  const logsPayload = parseToolJson(await client.callTool({
    name: "get_recent_logs",
    arguments: { limit: 200 },
  }));

  const logs = (Array.isArray(logsPayload.logs) ? logsPayload.logs : []) as Array<Record<string, unknown>>;
  const hasProviderTrace = logs.some(
    (row) => row.event === "image.generate_cover_preview" && row.traceId === traceId,
  );
  assert.equal(hasProviderTrace, true, "expected provider log entry to inherit HTTP traceId");
});

async function waitForLogs(client: Client, traceId: string) {
  for (let attempt = 0; attempt < 20; attempt += 1) {
    const logsPayload = parseToolJson(await client.callTool({
      name: "get_recent_logs",
      arguments: { limit: 200 },
    }));
    const logs = (Array.isArray(logsPayload.logs) ? logsPayload.logs : []) as Array<Record<string, unknown>>;
    if (logs.some((row) => row.traceId === traceId)) {
      return logs;
    }
    await new Promise((resolve) => setTimeout(resolve, 50));
  }

  const lastPayload = parseToolJson(await client.callTool({
    name: "get_recent_logs",
    arguments: { limit: 200 },
  }));
  return (Array.isArray(lastPayload.logs) ? lastPayload.logs : []) as Array<Record<string, unknown>>;
}
