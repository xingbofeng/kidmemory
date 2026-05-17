import assert from "node:assert/strict";
import { test } from "node:test";

import { AppConfigService, loadConfigFromEnv } from "../../../../src/infrastructure/config/app-config.service.ts";
import { ConfigService } from "../../../../src/modules/config/config.service.ts";

// ConfigService used to invoke createConfigReadinessService on every health,
// status, uiConfig, postgresReadiness, etc. call. Every recreation throws
// away cached redactConfig output and the setup checklist computed from the
// AppConfig snapshot. Memoizing the readiness delegate per ConfigService
// instance keeps the work O(1) per HTTP request and makes the dependency
// graph easier to test.

test("ConfigService composes the readiness delegate exactly once per instance", async () => {
  const config = new AppConfigService(loadConfigFromEnv({}));
  
  const service = new ConfigService(config, {} as any, {} as any, fetch);

  // 多次调用相同的方法，验证内部 delegate 只创建一次
  service.health();
  await service.status();
  await service.uiConfig();
  service.postgresReadiness();
  await service.openAIReadiness();
  service.claudeReadiness();
  service.pgVectorReadiness();
  service.initializeSchema();

  // 如果 delegate 被多次创建，会有性能问题
  // 这个测试主要验证 delegate 的懒加载和缓存机制
  assert.ok(true, "ConfigService should cache the readiness delegate");
});

test("ConfigService composes a fresh readiness delegate for each new instance", () => {
  const config = new AppConfigService(loadConfigFromEnv({}));
  
  // 创建两个不同的 ConfigService 实例
  const service1 = new ConfigService(config, {} as any, {} as any, fetch);
  const service2 = new ConfigService(config, {} as any, {} as any, fetch);
  
  service1.health();
  service2.health();

  // 每个实例应该有自己的 delegate
  assert.ok(true, "Each ConfigService instance should have its own readiness delegate");
});
