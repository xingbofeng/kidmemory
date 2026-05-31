import assert from "node:assert/strict";
import { test } from "node:test";

import { AppConfigService, loadConfigFromEnv } from "../../../../src/infrastructure/config/app-config.service.ts";
import type { PrismaMigrationService } from "../../../../src/infrastructure/database/prisma-migration.service.ts";
import type { PrismaService } from "../../../../src/infrastructure/database/prisma.service.ts";
import { ConfigService } from "../../../../src/modules/config/config.service.ts";

// ConfigService used to invoke createConfigReadinessService on every health,
// status, uiConfig, postgresReadiness, etc. call. Every recreation throws
// away cached redactConfig output and the setup checklist computed from the
// AppConfig snapshot. Memoizing the readiness delegate per ConfigService
// instance keeps the work O(1) per HTTP request and makes the dependency
// graph easier to test.

function createConfigService(config: AppConfigService) {
  const prisma = {
    runtimeConfig: {
      async findMany() {
        return [];
      },
    },
  } as unknown as PrismaService;
  const migrations = {
    async deployWithRepair() {
      return { ok: true };
    },
  } as unknown as PrismaMigrationService;

  return new ConfigService(config, prisma, migrations, fetch);
}

test("ConfigService composes the readiness delegate exactly once per instance", async () => {
  const config = new AppConfigService(loadConfigFromEnv({}));

  const service = createConfigService(config);

  service.health();
  const delegate = (service as unknown as { readinessDelegate: unknown }).readinessDelegate;

  // 多次调用相同的方法，验证内部 delegate 只创建一次
  await service.status();
  await service.uiConfig();
  service.postgresReadiness();
  service.claudeReadiness();
  service.pgVectorReadiness();
  service.initializeSchema();

  assert.equal((service as unknown as { readinessDelegate: unknown }).readinessDelegate, delegate);
});

test("ConfigService composes a fresh readiness delegate for each new instance", () => {
  const config = new AppConfigService(loadConfigFromEnv({}));

  // 创建两个不同的 ConfigService 实例
  const service1 = createConfigService(config);
  const service2 = createConfigService(config);

  service1.health();
  service2.health();

  assert.notEqual(
    (service1 as unknown as { readinessDelegate: unknown }).readinessDelegate,
    (service2 as unknown as { readinessDelegate: unknown }).readinessDelegate,
  );
});
