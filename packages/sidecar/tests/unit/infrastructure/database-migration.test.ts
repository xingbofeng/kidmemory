import assert from "node:assert/strict";
import { describe, test } from "node:test";

import { AppConfigService, loadConfigFromEnv } from "../../../src/infrastructure/config/app-config.service.ts";
import { PrismaMigrationService } from "../../../src/infrastructure/database/prisma-migration.service.ts";

describe("PrismaMigrationService", () => {
  test("runs prisma migrate deploy with a derived DATABASE_URL", async () => {
    const config = new AppConfigService(loadConfigFromEnv({
      POSTGRES_HOST: "db.local",
      POSTGRES_PORT: "15432",
      POSTGRES_DATABASE: "kidmemory_test",
      POSTGRES_USER: "kid",
      POSTGRES_PASSWORD: "secret password",
    }));
    const calls: Array<{ command: string; args: string[]; env: NodeJS.ProcessEnv; cwd: string }> = [];
    const service = new PrismaMigrationService(
      config,
      async (command, args, options) => {
        calls.push({ command, args, env: options.env, cwd: options.cwd });
        return { code: 0, stdout: "ok", stderr: "" };
      },
      "/tmp/backend",
    );

    const result = await service.deploy();

    assert.equal(result.ok, true);
    assert.equal(result.service, "prisma-migrate");
    assert.equal(result.command, "npx prisma migrate deploy");
    assert.equal(calls.length, 1);
    assert.equal(calls[0].command, "npx");
    assert.deepEqual(calls[0].args, ["prisma", "migrate", "deploy"]);
    assert.equal(calls[0].cwd, "/tmp/backend");
    assert.equal(
      calls[0].env.DATABASE_URL,
      "postgresql://kid:secret%20password@db.local:15432/kidmemory_test",
    );
  });

  test("uses explicit connectionUrl when present", async () => {
    const config = new AppConfigService(loadConfigFromEnv({
      DATABASE_URL: "postgresql://user:pass@host:5432/app",
    }));
    let databaseUrl = "";
    const service = new PrismaMigrationService(
      config,
      async (_command, _args, options) => {
        databaseUrl = options.env.DATABASE_URL || "";
        return { code: 0, stdout: "", stderr: "" };
      },
    );

    await service.deploy();

    assert.equal(databaseUrl, "postgresql://user:pass@host:5432/app");
  });

  test("redacts database urls and API keys from migration output", async () => {
    const config = new AppConfigService(loadConfigFromEnv({
      DATABASE_URL: "postgresql://user:pass@host:5432/app",
    }));
    const service = new PrismaMigrationService(
      config,
      async () => ({
        code: 1,
        stdout: "connecting postgresql://user:pass@host:5432/app",
        stderr: "failed password=secret sk-testsecret",
      }),
    );

    const result = await service.deploy();

    assert.equal(result.ok, false);
    assert.match(result.message, /exit code 1/);
    assert.equal(result.stdout, "connecting postgresql://[redacted]");
    assert.equal(result.stderr, "failed password=[redacted] [redacted]");
  });
});
