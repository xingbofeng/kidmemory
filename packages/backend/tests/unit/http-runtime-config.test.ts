import assert from "node:assert/strict";
import { test } from "node:test";

import { HttpRuntimeConfigService } from "../../src/infrastructure/http/http-runtime-config.service.ts";

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
