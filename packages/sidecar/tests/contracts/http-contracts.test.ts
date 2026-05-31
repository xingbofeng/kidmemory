import "reflect-metadata";

import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

import { NestFactory } from "@nestjs/core";
import type { INestApplication } from "@nestjs/common";
import type { TestContext } from "node:test";

import { AppModule } from "../../src/app.module.ts";
import { assertObject, assertString, requestJson } from "./backend-contract-client.ts";
import { GlobalExceptionFilter } from "../../src/infrastructure/http/global-exception.filter.ts";
import { ApiResponseInterceptor } from "../../src/infrastructure/http/api-response.interceptor.ts";
import { useTestEnv } from "../test-env.ts";

type TestServer = {
  app: INestApplication;
  baseUrl: string;
};

test("sidecar HTTP contract names use current removed-route wording", () => {
  const source = readFileSync(new URL(import.meta.url), "utf8");
  const historicalPhrase = ["legacy", "book job endpoint"].join(" ");

  assert.equal(source.includes(historicalPhrase), false);
});

async function startContractServer(t: Pick<TestContext, "after">): Promise<TestServer> {
  useTestEnv(t, { KIDMEMORY_DISABLE_CLOUD_SYNC: "true" });

  const app = await NestFactory.create(AppModule, { logger: false });
  app.useGlobalFilters(new GlobalExceptionFilter());
  app.useGlobalInterceptors(new ApiResponseInterceptor());
  await app.listen(0, "127.0.0.1");
  const address = app.getHttpServer().address();
  if (!address || typeof address !== "object") {
    throw new Error("Could not determine contract test server address.");
  }
  return {
    app,
    baseUrl: `http://127.0.0.1:${address.port}`,
  };
}

async function stopContractServer(server: TestServer) {
  await server.app.close();
}

test("sidecar contract: health endpoint returns stable service metadata", async (t) => {
  const server = await startContractServer(t);
  const { baseUrl } = server;
  t.after(async () => {
    await stopContractServer(server);
  });

  const response = await requestJson(baseUrl, "/health", { method: "GET" });

  assert.equal(response.status, 200);
  assertObject(response.body);
  assert.equal(response.body.code, 0);
  assert.ok(response.body.msg === "success" || response.body.msg === "成功");
  assertObject(response.body.data);
  assert.equal(response.body.data.ok, true);
  assert.equal(response.body.data.service, "kidmemory-sidecar");
});

test("sidecar contract: invalid public share assets token returns an auth-style error", async (t) => {
  const server = await startContractServer(t);
  const { baseUrl } = server;
  t.after(async () => {
    await stopContractServer(server);
  });

  const response = await requestJson(baseUrl, "/api/web-companion/share/invalid-token/assets", { method: "GET" });

  assert.ok([401, 403, 404].includes(response.status), `unexpected status ${response.status}`);
  assertObject(response.body);
  assert.ok("error" in response.body || "code" in response.body || "message" in response.body);
});

test("sidecar contract: invalid public share book token returns an auth-style error", async (t) => {
  const server = await startContractServer(t);
  const { baseUrl } = server;
  t.after(async () => {
    await stopContractServer(server);
  });

  const response = await requestJson(baseUrl, "/api/web-companion/share/invalid-token/book", { method: "GET" });

  assert.ok([401, 403, 404].includes(response.status), `unexpected status ${response.status}`);
  assertObject(response.body);
  assert.ok("error" in response.body || "code" in response.body || "message" in response.body);
});

test("sidecar contract: removed book job endpoint returns 404", async (t) => {
  const server = await startContractServer(t);
  const { baseUrl } = server;
  t.after(async () => {
    await stopContractServer(server);
  });

  const response = await requestJson(baseUrl, "/books/jobs", {
    method: "POST",
    body: JSON.stringify({ assetIds: [] }),
  });

  assert.equal(response.status, 404);
  assertObject(response.body);
  assert.notEqual(response.body.code, 0);
  assertString(response.body.msg);
});
