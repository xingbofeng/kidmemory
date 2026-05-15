import assert from "node:assert/strict";
import { test } from "node:test";

import { AppConfigService, loadConfigFromEnv } from "../../src/infrastructure/config/app-config.service.ts";
import { ConfigService } from "../../src/modules/config/config.service.ts";

// ConfigService used to invoke createConfigReadinessService on every health,
// status, uiConfig, postgresReadiness, etc. call. Every recreation throws
// away cached redactConfig output and the setup checklist computed from the
// AppConfig snapshot. Memoizing the readiness delegate per ConfigService
// instance keeps the work O(1) per HTTP request and makes the dependency
// graph easier to test.

test("ConfigService composes the readiness delegate exactly once per instance", () => {
  const config = new AppConfigService(loadConfigFromEnv({}));
  let calls = 0;
  const factory = () => {
    calls += 1;
    return {
      health: () => ({ ok: true, service: "spy" }),
      status: () => ({}),
      uiConfig: () => ({ setup: { checks: [] } }),
      postgresReadiness: async () => ({ ok: true, service: "postgres" }),
      openAIReadiness: async () => ({ ok: true, service: "openai" }),
      claudeReadiness: async () => ({ ok: true, service: "claude" }),
      pgVectorReadiness: async () => ({ ok: true, service: "pgvector" }),
      initializeSchema: async () => ({ ok: true, service: "schema" }),
    };
  };

  const service = new ConfigService(config, {} as any, fetch, { createReadiness: factory });

  service.health();
  service.status();
  service.uiConfig();
  service.postgresReadiness();
  service.openAIReadiness();
  service.claudeReadiness();
  service.pgVectorReadiness();
  service.initializeSchema();

  assert.equal(calls, 1, `readiness factory should run once per ConfigService instance, got ${calls}`);
});

test("ConfigService composes a fresh readiness delegate for each new instance", () => {
  const config = new AppConfigService(loadConfigFromEnv({}));
  let calls = 0;
  const factory = () => {
    calls += 1;
    return {
      health: () => ({ ok: true, service: "spy" }),
      status: () => ({}),
      uiConfig: () => ({ setup: { checks: [] } }),
      postgresReadiness: async () => ({ ok: true, service: "postgres" }),
      openAIReadiness: async () => ({ ok: true, service: "openai" }),
      claudeReadiness: async () => ({ ok: true, service: "claude" }),
      pgVectorReadiness: async () => ({ ok: true, service: "pgvector" }),
      initializeSchema: async () => ({ ok: true, service: "schema" }),
    };
  };

  new ConfigService(config, {} as any, fetch, { createReadiness: factory }).health();
  new ConfigService(config, {} as any, fetch, { createReadiness: factory }).health();

  assert.equal(calls, 2, `each ConfigService instance should rebuild the readiness delegate, got ${calls}`);
});
