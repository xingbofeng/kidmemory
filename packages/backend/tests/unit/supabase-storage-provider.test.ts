import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";

import { loadConfigFromEnv } from "../../src/infrastructure/config/app-config.service.ts";
import { createSupabaseStorageProvider } from "../../src/modules/storage/providers/supabase-storage.ts";

function storageConfig() {
  return loadConfigFromEnv({
    SUPABASE_URL: "https://kidmemory.supabase.co/",
    SUPABASE_SERVICE_ROLE_KEY: "service-role-secret",
    SUPABASE_STORAGE_BUCKET: "kidmemory-assets",
    SUPABASE_STORAGE_PUBLIC_BASE_URL: "https://cdn.example.test/storage/",
    SUPABASE_STORAGE_SIGNED_URL_TTL_SECONDS: "600",
  }).supabaseStorage;
}

function s3StorageConfig() {
  return loadConfigFromEnv({
    SUPABASE_S3_ENDPOINT: "https://project-ref.storage.supabase.co/storage/v1/s3",
    SUPABASE_S3_ACCESS_KEY_ID: "s3-access-key",
    SUPABASE_S3_SECRET_ACCESS_KEY: "s3-secret-key",
    SUPABASE_S3_BUCKET: "kidmemory-assets",
    SUPABASE_S3_REGION: "ap-southeast-1",
    SUPABASE_STORAGE_SIGNED_URL_TTL_SECONDS: "300",
  }).supabaseStorage;
}

test("Supabase Storage provider builds public URLs without leaking the service key", () => {
  const provider = createSupabaseStorageProvider({
    config: storageConfig(),
    fetch: async () => new Response(null, { status: 200 }),
  });

  const url = provider.getPublicUrl("children/child-1/exports/job-1/book.png");

  assert.equal(
    url,
    "https://cdn.example.test/storage/children/child-1/exports/job-1/book.png",
  );
  assert.equal(url.includes("service-role-secret"), false);
});

test("Supabase Storage provider verifies upload, download, and cleanup", async () => {
  const calls: { url: string; init: RequestInit }[] = [];
  const provider = createSupabaseStorageProvider({
    config: storageConfig(),
    fetch: async (url, init = {}) => {
      calls.push({ url: `${url}`, init });
      return new Response(init.method === "GET" ? "ok" : null, { status: 200 });
    },
  });

  const result = await provider.testConnection({
    objectPath: "healthchecks/test-object.txt",
  });

  assert.equal(result.ok, true);
  assert.equal(result.cleanup.ok, true);
  assert.equal(calls[0].init.method, "POST");
  assert.equal(
    calls[0].url,
    "https://kidmemory.supabase.co/storage/v1/object/kidmemory-assets/healthchecks/test-object.txt",
  );
  assert.equal(calls[1].init.method, "GET");
  assert.equal(calls[2].init.method, "DELETE");
  assert.equal(JSON.stringify(calls).includes("service-role-secret"), true);
});

test("Supabase Storage provider uploads a local file and returns a remote URL", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-supabase-provider-"));
  const filePath = path.join(root, "book.png");
  await fs.writeFile(filePath, "image-bytes");
  let uploadedBody = "";
  const provider = createSupabaseStorageProvider({
    config: storageConfig(),
    fetch: async (_url, init = {}) => {
      uploadedBody = String(init.body);
      assert.equal(init.method, "POST");
      assert.equal((init.headers as Record<string, string>)["content-type"], "image/png");
      return new Response(null, { status: 200 });
    },
  });

  const result = await provider.uploadFile({
    localPath: filePath,
    objectPath: "children/child-1/exports/job-1/book.png",
    contentType: "image/png",
  });

  assert.equal(result.ok, true);
  assert.equal(uploadedBody, "image-bytes");
  assert.equal(
    result.remoteUrl,
    "https://cdn.example.test/storage/children/child-1/exports/job-1/book.png",
  );
});

test("Supabase S3 provider uploads with AWS signature headers", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-supabase-s3-provider-"));
  const filePath = path.join(root, "book.png");
  await fs.writeFile(filePath, "image-bytes");
  const calls: { url: string; init: RequestInit }[] = [];
  const provider = createSupabaseStorageProvider({
    config: s3StorageConfig(),
    fetch: async (url, init = {}) => {
      calls.push({ url: `${url}`, init });
      return new Response(null, { status: 200 });
    },
  });

  const result = await provider.uploadFile({
    localPath: filePath,
    objectPath: "children/child-1/exports/job-1/book.png",
    contentType: "image/png",
  });

  const headers = calls[0].init.headers as Record<string, string>;
  assert.equal(result.ok, true);
  assert.equal(result.remoteUrl, undefined);
  assert.equal(calls[0].init.method, "PUT");
  assert.equal(
    calls[0].url,
    "https://project-ref.storage.supabase.co/storage/v1/s3/kidmemory-assets/children/child-1/exports/job-1/book.png",
  );
  assert.match(headers.authorization, /^AWS4-HMAC-SHA256 Credential=s3-access-key\//);
  assert.equal(headers.authorization.includes("s3-secret-key"), false);
  assert.equal(headers["content-type"], "image/png");
  assert.equal(headers["x-amz-content-sha256"].length, 64);
});

test("Supabase S3 provider verifies upload, download, and cleanup", async () => {
  const calls: { url: string; init: RequestInit }[] = [];
  const provider = createSupabaseStorageProvider({
    config: s3StorageConfig(),
    fetch: async (url, init = {}) => {
      calls.push({ url: `${url}`, init });
      return new Response(init.method === "GET" ? "ok" : null, { status: 200 });
    },
  });

  const result = await provider.testConnection({
    objectPath: "healthchecks/test-object.txt",
  });

  assert.equal(result.ok, true);
  assert.equal(result.cleanup.ok, true);
  assert.deepEqual(calls.map((call) => call.init.method), ["PUT", "GET", "DELETE"]);
  assert.equal(JSON.stringify(calls).includes("s3-secret-key"), false);
});

test("Supabase Storage provider omits remote URL for private bucket strategy", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-supabase-provider-"));
  const filePath = path.join(root, "book.png");
  await fs.writeFile(filePath, "image-bytes");
  const privateConfig = loadConfigFromEnv({
    SUPABASE_URL: "https://kidmemory.supabase.co/",
    SUPABASE_SERVICE_ROLE_KEY: "service-role-secret",
    SUPABASE_STORAGE_BUCKET: "kidmemory-assets",
  }).supabaseStorage;
  const provider = createSupabaseStorageProvider({
    config: privateConfig,
    fetch: async () => new Response(null, { status: 200 }),
  });

  const result = await provider.uploadFile({
    localPath: filePath,
    objectPath: "children/child-1/exports/job-1/book.png",
    contentType: "image/png",
  });

  assert.equal(result.ok, true);
  assert.equal(result.remoteUrl, undefined);
});

test("Supabase Storage provider returns actionable local file errors", async () => {
  const provider = createSupabaseStorageProvider({
    config: storageConfig(),
    fetch: async () => new Response(null, { status: 200 }),
  });

  const result = await provider.uploadFile({
    localPath: "/tmp/does-not-exist-kidmemory.png",
    objectPath: "missing.png",
  });

  assert.equal(result.ok, false);
  assert.equal(result.code, "LOCAL_FILE_MISSING");
  assert.equal(result.retryable, false);
});

test("Supabase Storage provider maps auth failures to actionable errors", async () => {
  const provider = createSupabaseStorageProvider({
    config: storageConfig(),
    fetch: async () => new Response("invalid api key", { status: 401 }),
  });

  const result = await provider.testConnection({
    objectPath: "healthchecks/test-object.txt",
  });

  assert.equal(result.ok, false);
  assert.equal(result.code, "SUPABASE_STORAGE_CREDENTIALS_INVALID");
  assert.equal(result.retryable, false);
  assert.match(result.action, /service role key/i);
});

test("Supabase Storage provider creates signed URLs with an expiry", async () => {
  const provider = createSupabaseStorageProvider({
    config: storageConfig(),
    fetch: async (_url, init = {}) => {
      assert.equal(init.method, "POST");
      assert.equal(String(init.body).includes('"expiresIn":600'), true);
      return Response.json({ signedURL: "/storage/v1/object/sign/kidmemory-assets/file.png?token=abc" });
    },
  });

  const result = await provider.createSignedUrl("file.png");

  assert.equal(result.ok, true);
  assert.equal(result.expiresInSeconds, 600);
  assert.equal(
    result.url,
    "https://kidmemory.supabase.co/storage/v1/object/sign/kidmemory-assets/file.png?token=abc",
  );
});

test("Supabase S3 provider creates a presigned sharing URL", async () => {
  const provider = createSupabaseStorageProvider({
    config: s3StorageConfig(),
    fetch: async () => new Response(null, { status: 200 }),
  });

  const result = await provider.createSignedUrl("file.png");

  assert.equal(result.ok, true);
  assert.equal(result.expiresInSeconds, 300);
  assert.match(result.url, /^https:\/\/project-ref\.storage\.supabase\.co\/storage\/v1\/s3\/kidmemory-assets\/file\.png\?/);
  assert.match(result.url, /X-Amz-Algorithm=AWS4-HMAC-SHA256/);
  assert.match(result.url, /X-Amz-Credential=s3-access-key%2F/);
  assert.equal(result.url.includes("s3-secret-key"), false);
});
