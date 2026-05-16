import assert from "node:assert/strict";
import { test } from "node:test";

import {
  AppConfigService,
  loadConfigFromEnv,
  redactConfig,
} from "../../../../src/infrastructure/config/app-config.service.ts";
import { ConfigService } from "../../../../src/modules/config/config.service.ts";

test("loads .env values and returns only redacted config status", () => {
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
    KIDMEMORY_WORKSPACE_DIR: "/tmp/kidmemory/workspace",
    KIDMEMORY_EXPORT_DIR: "/tmp/kidmemory/exports",
  });

  assert.equal(config.openai.baseUrl, "https://api.openai.com/v1");

  const redacted = redactConfig(config);
  const serialized = JSON.stringify(redacted);

  assert.equal(redacted.postgres.host, "localhost");
  assert.equal(redacted.postgres.passwordConfigured, true);
  assert.equal(redacted.openai.provider, "openai");
  assert.equal(redacted.openai.baseUrl, "https://api.openai.com/v1");
  assert.equal(redacted.openai.apiKeyConfigured, true);
  assert.equal(redacted.claude.apiKeyConfigured, true);
  assert.equal(serialized.includes("super-secret-db"), false);
  assert.equal(serialized.includes("sk-ant-secret"), false);
  assert.equal(serialized.includes("sk-openai-secret"), false);
});

test("loads Supabase Storage config and redacts service role key", () => {
  const config = loadConfigFromEnv({
    SUPABASE_URL: "https://kidmemory.supabase.co",
    SUPABASE_SERVICE_ROLE_KEY: "supabase-service-secret",
    SUPABASE_STORAGE_BUCKET: "kidmemory-assets",
    SUPABASE_STORAGE_PUBLIC_BASE_URL: "https://cdn.example.test/storage",
    SUPABASE_STORAGE_SIGNED_URL_TTL_SECONDS: "900",
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
  assert.equal(redacted.supabaseStorage.serviceRoleKeyConfigured, true);
  assert.equal(serialized.includes("supabase-service-secret"), false);
});

test("detects incomplete Supabase S3 env without leaking credentials", () => {
  const config = loadConfigFromEnv({
    SUPABASE_S3_ACCESS_KEY_ID: "legacy-access-key",
    SUPABASE_S3_SECRET_ACCESS_KEY: "legacy-secret-key",
  });

  const redacted = redactConfig(config);
  const serialized = JSON.stringify(redacted);

  assert.equal(redacted.supabaseStorage.configured, false);
  assert.equal(redacted.supabaseStorage.s3CredentialsDetected, true);
  assert.equal(redacted.supabaseStorage.s3.accessKeyIdConfigured, true);
  assert.equal(redacted.supabaseStorage.s3.secretAccessKeyConfigured, true);
  assert.match(redacted.supabaseStorage.diagnosticMessage, /SUPABASE_S3_ENDPOINT/);
  assert.match(
    redacted.supabaseStorage.diagnosticMessage,
    /SUPABASE_STORAGE_BUCKET/,
  );
  assert.equal(serialized.includes("legacy-access-key"), false);
  assert.equal(serialized.includes("legacy-secret-key"), false);
});

test("loads complete Supabase S3 config as a configured storage mode", () => {
  const config = loadConfigFromEnv({
    SUPABASE_S3_ENDPOINT: "https://project-ref.storage.supabase.co/storage/v1/s3",
    SUPABASE_S3_ACCESS_KEY_ID: "s3-access-key",
    SUPABASE_S3_SECRET_ACCESS_KEY: "s3-secret-key",
    SUPABASE_S3_BUCKET: "kidmemory-assets",
    SUPABASE_S3_REGION: "ap-southeast-1",
  });

  const redacted = redactConfig(config);
  const serialized = JSON.stringify(redacted);

  assert.equal(config.supabaseStorage.bucket, "kidmemory-assets");
  assert.equal(config.supabaseStorage.s3.region, "ap-southeast-1");
  assert.equal(redacted.supabaseStorage.configured, true);
  assert.equal(redacted.supabaseStorage.authMode, "s3");
  assert.equal(redacted.supabaseStorage.s3.configured, true);
  assert.equal(serialized.includes("s3-access-key"), false);
  assert.equal(serialized.includes("s3-secret-key"), false);
});

test("OpenAI-compatible API defaults to empty until configured by the user", () => {
  const config = loadConfigFromEnv({});

  assert.equal(config.openai.baseUrl, "");
  assert.equal(config.openai.model, "");
  assert.equal(config.openai.apiKey, "");
});

test("updates local data root and keeps workspace and exports as siblings", () => {
  const service = new AppConfigService(loadConfigFromEnv({}));

  const paths = service.updateLocalDataRoot("/tmp/kidmemory-local");

  assert.equal(paths.dataDir, "/tmp/kidmemory-local/data");
  assert.equal(paths.workspaceDir, "/tmp/kidmemory-local/workspace");
  assert.equal(paths.exportDir, "/tmp/kidmemory-local/exports");
  assert.deepEqual(service.config.paths, paths);
});

test("updates config paths from the setup page request body", () => {
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
    service.uiConfig().setup.checks[3].body.includes("/tmp/kidmemory-local/workspace"),
    true,
  );
});

test("updates Supabase Storage config from the setup page request body", () => {
  const appConfig = new AppConfigService(loadConfigFromEnv({}));
  const service = new ConfigService(appConfig, {} as any);

  const result = service.updateSupabaseStorage({
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
  const appConfig = new AppConfigService(loadConfigFromEnv({
    SUPABASE_URL: "https://kidmemory.supabase.co",
    SUPABASE_SERVICE_ROLE_KEY: "supabase-service-secret",
    SUPABASE_STORAGE_BUCKET: "kidmemory-assets",
  }));
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
  const appConfig = new AppConfigService(loadConfigFromEnv({
    SUPABASE_URL: "https://kidmemory.supabase.co",
    SUPABASE_SERVICE_ROLE_KEY: "supabase-service-secret",
    SUPABASE_STORAGE_BUCKET: "missing-bucket",
  }));
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
