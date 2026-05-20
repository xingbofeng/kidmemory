import assert from "node:assert/strict";
import path from "node:path";
import { test } from "node:test";

import {
  AppConfigService,
  loadConfigFromEnv,
  redactConfig,
} from "../../../../src/infrastructure/config/app-config.service.ts";
import { ConfigService } from "../../../../src/modules/config/config.service.ts";

test("loads startup .env values without treating setup config as env fallback", () => {
  const config = loadConfigFromEnv({
    POSTGRES_HOST: "localhost",
    POSTGRES_PORT: "5432",
    POSTGRES_DATABASE: "kidmemory",
    POSTGRES_USER: "postgres",
    POSTGRES_PASSWORD: "super-secret-db",
    CLAUDE_API_KEY: "sk-ant-secret",
    CLAUDE_MODEL: "claude-3-5-sonnet-20241022",
    OPENAI_API_KEY: "sk-openai-secret",
    OPENAI_BASE_URL: "https://api.openai.com/v1",
    OPENAI_MODEL: "gpt-4o-mini",
    SUPABASE_URL: "https://kidmemory.supabase.co",
    SUPABASE_SERVICE_ROLE_KEY: "supabase-service-secret",
    SUPABASE_STORAGE_BUCKET: "kidmemory-assets",
    KIDMEMORY_WORKSPACE_DIR: "/tmp/kidmemory/workspace",
    KIDMEMORY_EXPORT_DIR: "/tmp/kidmemory/exports",
  });

  assert.equal(config.openai.baseUrl, "");
  assert.equal(config.openai.model, "");
  assert.equal(config.openai.apiKey, "");
  assert.equal(config.supabaseStorage.url, "");
  assert.equal(config.supabaseStorage.bucket, "");
  assert.equal(config.supabaseStorage.serviceRoleKey, "");

  const redacted = redactConfig(config);
  const serialized = JSON.stringify(redacted);

  assert.equal(redacted.postgres.host, "localhost");
  assert.equal(redacted.postgres.passwordConfigured, true);
  assert.equal(redacted.openai.provider, "openai");
  assert.equal(redacted.openai.baseUrl, "");
  assert.equal(redacted.openai.apiKey, "");
  assert.equal(redacted.openai.apiKeyConfigured, false);
  assert.equal("apiKeyDisplay" in redacted.openai, false);
  assert.equal("apiKeyStorageMode" in redacted.openai, false);
  assert.equal(redacted.claude.apiKeyConfigured, true);
  assert.equal(serialized.includes("super-secret-db"), false);
  assert.equal(serialized.includes("sk-ant-secret"), false);
  assert.equal(serialized.includes("sk-openai-secret"), false);
  assert.equal(serialized.includes("supabase-service-secret"), false);
});

test("resolves relative path env values against the sidecar working directory", () => {
  const config = loadConfigFromEnv({
    KIDMEMORY_WORKSPACE_DIR: ".kidmemory/workspace",
    KIDMEMORY_EXPORT_DIR: ".kidmemory/exports",
    KIDMEMORY_DATA_DIR: ".kidmemory/data",
  });

  assert.equal(
    config.paths.workspaceDir,
    path.resolve(process.cwd(), ".kidmemory/workspace"),
  );
  assert.equal(
    config.paths.exportDir,
    path.resolve(process.cwd(), ".kidmemory/exports"),
  );
  assert.equal(
    config.paths.dataDir,
    path.resolve(process.cwd(), ".kidmemory/data"),
  );
});

test("stores Supabase Storage setup config only through runtime updates", () => {
  const service = new AppConfigService(loadConfigFromEnv({}));
  const config = service.config;

  service.updateSupabaseStorageConfig({
    url: "https://kidmemory.supabase.co",
    bucket: "kidmemory-assets",
    serviceRoleKey: "supabase-service-secret",
    publicBaseUrl: "https://cdn.example.test/storage",
    signedUrlTtlSeconds: 900,
  });

  assert.equal(config.supabaseStorage.url, "https://kidmemory.supabase.co");
  assert.equal(config.supabaseStorage.bucket, "kidmemory-assets");
  assert.equal(config.supabaseStorage.serviceRoleKey, "supabase-service-secret");
  assert.equal(config.supabaseStorage.publicBaseUrl, "https://cdn.example.test/storage");
  assert.equal(config.supabaseStorage.signedUrlTtlSeconds, 900);

  const redacted = redactConfig(config);
  const serialized = JSON.stringify(redacted);

  assert.equal(redacted.supabaseStorage.provider, "supabase");
  assert.equal(redacted.supabaseStorage.url, "https://kidmemory.supabase.co");
  assert.equal(redacted.supabaseStorage.bucket, "kidmemory-assets");
  assert.equal(redacted.supabaseStorage.serviceRoleKey, "[REDACTED]");
  assert.equal(redacted.supabaseStorage.serviceRoleKeyConfigured, true);
  assert.equal(serialized.includes("supabase-service-secret"), false);
});

test("detects incomplete Supabase S3 runtime config without leaking credentials", () => {
  const service = new AppConfigService(loadConfigFromEnv({}));
  const config = service.config;

  service.updateSupabaseStorageConfig({
    s3: {
      accessKeyId: "legacy-access-key",
      secretAccessKey: "legacy-secret-key",
    },
  });

  const redacted = redactConfig(config);
  const serialized = JSON.stringify(redacted);

  assert.equal(redacted.supabaseStorage.configured, false);
  assert.equal(redacted.supabaseStorage.s3CredentialsDetected, true);
  assert.equal(redacted.supabaseStorage.s3.accessKeyIdConfigured, true);
  assert.equal(redacted.supabaseStorage.s3.secretAccessKeyConfigured, true);
  assert.equal(redacted.supabaseStorage.s3.accessKeyId, "[REDACTED]");
  assert.equal(redacted.supabaseStorage.s3.secretAccessKey, "[REDACTED]");
  assert.match(redacted.supabaseStorage.diagnosticMessage, /endpoint/);
  assert.match(
    redacted.supabaseStorage.diagnosticMessage,
    /bucket/,
  );
  assert.equal(serialized.includes("legacy-access-key"), false);
  assert.equal(serialized.includes("legacy-secret-key"), false);
});

test("loads complete Supabase S3 runtime config as a configured storage mode", () => {
  const service = new AppConfigService(loadConfigFromEnv({}));
  const config = service.config;

  service.updateSupabaseStorageConfig({
    bucket: "kidmemory-assets",
    s3: {
      endpoint: "https://project-ref.storage.supabase.co/storage/v1/s3",
      accessKeyId: "s3-access-key",
      secretAccessKey: "s3-secret-key",
      region: "ap-southeast-1",
    },
  });

  const redacted = redactConfig(config);
  const serialized = JSON.stringify(redacted);

  assert.equal(config.supabaseStorage.bucket, "kidmemory-assets");
  assert.equal(config.supabaseStorage.s3.region, "ap-southeast-1");
  assert.equal(redacted.supabaseStorage.configured, true);
  assert.equal(redacted.supabaseStorage.authMode, "s3");
  assert.equal(redacted.supabaseStorage.s3.configured, true);
  assert.equal(redacted.supabaseStorage.s3.accessKeyId, "[REDACTED]");
  assert.equal(redacted.supabaseStorage.s3.secretAccessKey, "[REDACTED]");
  assert.equal(serialized.includes("s3-access-key"), false);
  assert.equal(serialized.includes("s3-secret-key"), false);
});

test("OpenAI 配置在未设置时默认为空", () => {
  const config = loadConfigFromEnv({});

  assert.equal(config.openai.baseUrl, "");
  assert.equal(config.openai.model, "");
  assert.equal(config.openai.apiKey, "");
});

test("loads Storage setup config from database runtime config", async () => {
  const appConfig = new AppConfigService(loadConfigFromEnv({}));
  const prisma = {
    runtimeConfig: {
      findMany: async () => [
        {
          key: "supabaseStorage",
          value: {
            url: "https://kidmemory.supabase.co",
            bucket: "kidmemory-assets",
            serviceRoleKey: "supabase-service-secret",
            publicBaseUrl: "https://cdn.example.test/storage",
            s3: {
              endpoint: "https://project-ref.storage.supabase.co/storage/v1/s3",
              region: "auto",
              accessKeyId: "s3-access-key",
              secretAccessKey: "s3-secret-key",
            },
          },
        },
      ],
      upsert: async () => ({}),
    },
  };
  const service = new ConfigService(appConfig, prisma as any);

  const status = await service.status();

  assert.equal(status.openai.baseUrl, "");
  assert.equal(status.openai.model, "");
  assert.equal(status.openai.apiKeyConfigured, false);
  assert.equal(status.supabaseStorage.configured, true);
  assert.equal(status.supabaseStorage.s3.configured, true);
});

test("persists setup config updates to database runtime config", async () => {
  const appConfig = new AppConfigService(loadConfigFromEnv({}));
  const upserts: Array<{ key: string; value: unknown }> = [];
  const prisma = {
    runtimeConfig: {
      findMany: async () => [],
      upsert: async (input: { create: { key: string; value: unknown } }) => {
        upserts.push(input.create);
        return {};
      },
    },
  };
  const service = new ConfigService(appConfig, prisma as any);

  await service.updateSupabaseStorage({
    url: "https://kidmemory.supabase.co",
    bucket: "kidmemory-assets",
    serviceRoleKey: "supabase-service-secret",
  });

  assert.deepEqual(
    upserts.map((entry) => entry.key),
    ["supabaseStorage"],
  );
});

test("updates local data root and keeps workspace and exports as siblings", () => {
  const service = new AppConfigService(loadConfigFromEnv({}));

  const paths = service.updateLocalDataRoot("/tmp/kidmemory-local");

  assert.equal(paths.dataDir, "/tmp/kidmemory-local/data");
  assert.equal(paths.workspaceDir, "/tmp/kidmemory-local/workspace");
  assert.equal(paths.exportDir, "/tmp/kidmemory-local/exports");
  assert.deepEqual(service.config.paths, paths);
});

test("updates config paths from the setup page request body", async () => {
  const appConfig = new AppConfigService(loadConfigFromEnv({}));
  const service = new ConfigService(appConfig, {} as any);

  const result = service.updatePaths({
    dataDir: "/tmp/kidmemory-local/data",
    workspaceDir: "/tmp/kidmemory-local/workspace",
    exportDir: "/tmp/kidmemory-local/exports",
  });

  assert.equal(result.ok, true);
  assert.equal(appConfig.config.paths.dataDir, "/tmp/kidmemory-local/data");
  assert.equal(
    (await service.uiConfig()).setup.checks[3].body.includes("/tmp/kidmemory-local/workspace"),
    true,
  );
});

test("updates Supabase Storage config from the setup page request body", async () => {
  const appConfig = new AppConfigService(loadConfigFromEnv({}));
  const service = new ConfigService(appConfig, {} as any);

  const result = await service.updateSupabaseStorage({
    url: "https://kidmemory.supabase.co",
    bucket: "kidmemory-assets",
    serviceRoleKey: "supabase-service-secret",
    publicBaseUrl: "https://cdn.example.test/storage",
    signedUrlTtlSeconds: "1200",
    s3Endpoint: "https://project-ref.storage.supabase.co/storage/v1/s3",
    s3Region: "auto",
    s3AccessKeyId: "s3-access-key",
    s3SecretAccessKey: "s3-secret-key",
  });

  assert.equal(result.ok, true);
  assert.equal(appConfig.config.supabaseStorage.url, "https://kidmemory.supabase.co");
  assert.equal(appConfig.config.supabaseStorage.bucket, "kidmemory-assets");
  assert.equal(appConfig.config.supabaseStorage.serviceRoleKey, "supabase-service-secret");
  assert.equal(appConfig.config.supabaseStorage.signedUrlTtlSeconds, 1200);
  assert.equal(
    appConfig.config.supabaseStorage.s3.endpoint,
    "https://project-ref.storage.supabase.co/storage/v1/s3",
  );
  assert.equal(appConfig.config.supabaseStorage.s3.region, "auto");
  assert.equal(appConfig.config.supabaseStorage.s3.accessKeyId, "s3-access-key");
  assert.equal(
    appConfig.config.supabaseStorage.s3.secretAccessKey,
    "s3-secret-key",
  );
  assert.equal(JSON.stringify(result).includes("supabase-service-secret"), false);
});

test("tests Supabase Storage connection through config service", async () => {
  const appConfig = new AppConfigService(loadConfigFromEnv({}));
  appConfig.updateSupabaseStorageConfig({
    url: "https://kidmemory.supabase.co",
    serviceRoleKey: "supabase-service-secret",
    bucket: "kidmemory-assets",
  });
  const calls: string[] = [];
  const service = new ConfigService(appConfig, {} as any, {} as any, async (url, init: RequestInit = {}) => {
    calls.push(`${init.method || "GET"} ${url}`);
    return new Response(init.method === "GET" ? "ok" : null, { status: 200 });
  });

  const result = await service.testSupabaseStorage();

  assert.equal(result.ok, true);
  assert.equal(result.cleanup.ok, true);
  assert.equal(calls.some((call) => call.startsWith("POST ")), true);
  assert.equal(calls.some((call) => call.startsWith("GET ")), true);
  assert.equal(JSON.stringify(result).includes("supabase-service-secret"), false);
});

test("Supabase Storage connection test returns actionable bucket errors", async () => {
  const appConfig = new AppConfigService(loadConfigFromEnv({}));
  appConfig.updateSupabaseStorageConfig({
    url: "https://kidmemory.supabase.co",
    serviceRoleKey: "supabase-service-secret",
    bucket: "missing-bucket",
  });
  const service = new ConfigService(appConfig, {} as any, {} as any, async () => {
    return new Response("not found", { status: 404 });
  });

  const result = await service.testSupabaseStorage();

  assert.equal(result.ok, false);
  assert.ok('code' in result);
  assert.equal(result.code, "SUPABASE_STORAGE_BUCKET_NOT_FOUND");
  assert.ok('action' in result && result.action);
  assert.match(result.action, /bucket/i);
  assert.equal(JSON.stringify(result).includes("supabase-service-secret"), false);
});
