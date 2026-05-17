import "reflect-metadata";

import assert from "node:assert/strict";
import test from "node:test";

import { NestFactory } from "@nestjs/core";
import type { INestApplication } from "@nestjs/common";

import { AppModule } from "../../src/app.module.ts";
import { GlobalExceptionFilter } from "../../src/infrastructure/http/global-exception.filter.ts";
import { ApiResponseInterceptor } from "../../src/infrastructure/http/api-response.interceptor.ts";

type TestServer = {
  app: INestApplication;
  baseUrl: string;
};

async function startServer(): Promise<TestServer> {
  const app = await NestFactory.create(AppModule, { logger: false });
  app.useGlobalFilters(new GlobalExceptionFilter());
  app.useGlobalInterceptors(new ApiResponseInterceptor());
  await app.listen(0, "127.0.0.1");
  const address = app.getHttpServer().address();
  if (!address || typeof address !== "object") {
    throw new Error("Could not determine test server address");
  }
  return {
    app,
    baseUrl: `http://127.0.0.1:${address.port}`,
  };
}

test("success responses use code/msg/data envelope", async (t) => {
  const { app, baseUrl } = await startServer();
  t.after(async () => app.close());

  const response = await fetch(`${baseUrl}/health`);
  const payload = await response.json();

  assert.equal(response.status, 200);
  assert.equal(payload.code, 0);
  assert.equal(typeof payload.msg, "string");
  assert.equal(typeof payload.data, "object");
  assert.equal(payload.data.ok, true);
});

test("404 responses use code/msg/data envelope", async (t) => {
  const { app, baseUrl } = await startServer();
  t.after(async () => app.close());

  const response = await fetch(`${baseUrl}/nonexistent`);
  const payload = await response.json();

  assert.equal(response.status, 404);
  assert.notEqual(payload.code, 0);
  assert.equal(typeof payload.msg, "string");
  assert.equal(typeof payload.data, "object");
});

test("validation errors use code/msg/data envelope", async (t) => {
  const { app, baseUrl } = await startServer();
  t.after(async () => app.close());

  const response = await fetch(`${baseUrl}/sample/import`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ persist: "nope" }),
  });
  const payload = await response.json();

  assert.equal(response.status, 400);
  assert.notEqual(payload.code, 0);
  assert.equal(typeof payload.msg, "string");
  assert.equal(typeof payload.data, "object");
});
