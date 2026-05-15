import assert from "node:assert/strict";
import { test } from "node:test";

import { InputValidationMiddleware } from "../../src/infrastructure/security/input-validation.middleware.ts";
import { RateLimitMiddleware } from "../../src/infrastructure/security/rate-limit.middleware.ts";
import { SecurityMonitorController } from "../../src/infrastructure/security/security-monitor.controller.ts";
import { SessionQuotaMiddleware } from "../../src/infrastructure/security/session-quota.middleware.ts";

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

function createRequest(input: { method?: string; path?: string; childId?: string; userAgent?: string; contentLength?: string }) {
  return {
    method: input.method ?? "POST",
    path: input.path ?? "/api/web-companion/sessions",
    body: input.childId === undefined ? {} : { childId: input.childId },
    headers: {
      "user-agent": input.userAgent ?? "curl/8.0",
      ...(input.contentLength ? { "content-length": input.contentLength } : {}),
    },
    ip: "127.0.0.1",
    socket: { remoteAddress: "127.0.0.1" },
  };
}

test("input validation accepts existing sanitized child ids used by the backend", () => {
  const middleware = new InputValidationMiddleware();
  const response = createResponse();
  let nextCalled = false;

  middleware.use(createRequest({ childId: "sample-child-001" }) as any, response as any, () => {
    nextCalled = true;
  });

  assert.equal(nextCalled, true);
  assert.equal(response.statusCode, 200);
});

test("input validation rejects path traversal child ids", () => {
  const middleware = new InputValidationMiddleware();
  const response = createResponse();
  let nextCalled = false;

  middleware.use(createRequest({ childId: "../secret" }) as any, response as any, () => {
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
});
