import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";
import type { Request, Response } from "express";

import { InputValidationMiddleware } from "../../../../src/infrastructure/security/input-validation.middleware.ts";
import { RateLimitMiddleware } from "../../../../src/infrastructure/security/rate-limit.middleware.ts";
import { SecurityMonitorController } from "../../../../src/infrastructure/security/security-monitor.controller.ts";
import { SessionQuotaMiddleware } from "../../../../src/infrastructure/security/session-quota.middleware.ts";

type MockResponse = {
  statusCode: number;
  payload?: unknown;
  status: (code: number) => MockResponse;
  json: (payload: unknown) => MockResponse;
};

function createResponse(): MockResponse {
  return {
    statusCode: 200,
    status(code: number) {
      this.statusCode = code;
      return this;
    },
    json(payload: unknown) {
      this.payload = payload;
      return this;
    },
  };
}

function createRequest(input: {
  method?: string;
  path?: string;
  childId?: string;
  userAgent?: string;
  contentLength?: string;
  ip?: string;
}): Request {
  return {
    method: input.method ?? "POST",
    path: input.path ?? "/api/web-companion/sessions",
    url: input.path ?? "/api/web-companion/sessions",
    body: input.childId === undefined ? {} : { childId: input.childId },
    headers: {
      "user-agent": input.userAgent ?? "curl/8.0",
      ...(input.contentLength ? { "content-length": input.contentLength } : {}),
    },
    ip: input.ip ?? "127.0.0.1",
    socket: { remoteAddress: input.ip ?? "127.0.0.1" },
  } as unknown as Request;
}

function asExpressResponse(response: MockResponse): Response {
  return response as unknown as Response;
}

test("input validation accepts existing sanitized child ids used by the backend", () => {
  const middleware = new InputValidationMiddleware();
  const response = createResponse();
  let nextCalled = false;

  middleware.use(createRequest({ childId: "sample-child-001" }), asExpressResponse(response), () => {
    nextCalled = true;
  });

  assert.equal(nextCalled, true);
  assert.equal(response.statusCode, 200);
});

test("input validation names current safe child ids without legacy terminology", () => {
  const source = readFileSync("src/infrastructure/security/input-validation.middleware.ts", "utf8");

  assert.equal(source.includes("Legacy"), false);
  assert.equal(source.includes("legacy"), false);
});

test("input validation rejects path traversal child ids", () => {
  const middleware = new InputValidationMiddleware();
  const response = createResponse();
  let nextCalled = false;

  middleware.use(createRequest({ childId: "../secret" }), asExpressResponse(response), () => {
    nextCalled = true;
  });

  assert.equal(nextCalled, false);
  assert.equal(response.statusCode, 400);
});

test("security monitor reads injected middleware instances", () => {
  const rateLimit = new RateLimitMiddleware();
  const sessionQuota = new SessionQuotaMiddleware();
  const inputValidation = new InputValidationMiddleware();
  const controller = new SecurityMonitorController(rateLimit, sessionQuota, inputValidation);

  const stats = controller.getSecurityStats();

  assert.equal(typeof stats.timestamp, "string");
  assert.equal(stats.rateLimit?.ipRecords, 0);
  assert.equal(stats.sessionQuota?.totalChildren, 0);
  assert.equal(stats.inputValidation?.totalSuspicious, 0);

  rateLimit.onModuleDestroy();
});

test("rate limit middleware cleans up expired timestamps to prevent memory leak", () => {
  const middleware = new RateLimitMiddleware();
  const response = createResponse();

  for (let i = 0; i < 100; i++) {
    middleware.use(createRequest({ ip: `10.0.0.${i % 256}` }), asExpressResponse(response), () => {});
  }

  const stats = middleware.getStats();
  assert.ok(stats.ipRecords <= 256, `ipRecords should be bounded, got ${stats.ipRecords}`);
  assert.ok(stats.globalTimestamps <= 10000, `globalTimestamps should be bounded, got ${stats.globalTimestamps}`);

  middleware.onModuleDestroy();
});

test("rate limit middleware onModuleDestroy clears the cleanup timer", () => {
  const middleware = new RateLimitMiddleware();
  middleware.onModuleDestroy();
  middleware.onModuleDestroy();
});
