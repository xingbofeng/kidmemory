import assert from "node:assert/strict";
import { describe, test } from "node:test";

import { HttpRuntimeConfigService, isLanOrigin } from "../../../../src/infrastructure/http/http-runtime-config.service.ts";

test("HTTP runtime config can enable CSP and production origins from env", () => {
  const service = HttpRuntimeConfigService.fromEnv({
    KIDMEMORY_HTTP_CSP_ENABLED: "true",
    KIDMEMORY_HTTP_ALLOWED_ORIGINS: "https://kidmemory.example, https://app.example",
  });
  const config = service.getConfig();

  assert.equal(config.security.contentSecurityPolicy, true);
  assert.deepEqual(config.cors.allowedOrigins, [
    "https://kidmemory.example",
    "https://app.example",
  ]);
});

describe("isLanOrigin", () => {
  test("allows 192.168.x.x", () => {
    assert.ok(isLanOrigin("http://192.168.1.100:3001"));
  });
  test("allows 10.x.x.x", () => {
    assert.ok(isLanOrigin("http://10.0.0.1:3001"));
  });
  test("allows 172.16-31.x.x", () => {
    assert.ok(isLanOrigin("http://172.16.0.1:3001"));
    assert.ok(isLanOrigin("http://172.31.255.255:3001"));
  });
  test("rejects 172.32.x.x", () => {
    assert.ok(!isLanOrigin("http://172.32.0.1:3001"));
  });
  test("allows localhost", () => {
    assert.ok(isLanOrigin("http://localhost:3001"));
  });
  test("rejects public IP", () => {
    assert.ok(!isLanOrigin("https://example.com"));
  });
  test("rejects invalid origin", () => {
    assert.ok(!isLanOrigin("not-a-url"));
  });
});
