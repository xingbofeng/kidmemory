import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";

import { createObjectStorageProvider } from "../../../../src/modules/storage/providers/object-storage.ts";
import type { ObjectStorageConfig } from "../../../../src/modules/storage/providers/object-storage.ts";

function cosConfig(): ObjectStorageConfig {
  return {
    provider: "cos",
    bucket: "counter-1252496948",
    publicBaseUrl: "",
    signedUrlTtlSeconds: 300,
    s3: {
      endpoint: "https://cos.ap-guangzhou.myqcloud.com",
      region: "ap-guangzhou",
      accessKeyId: "cos-secret-id",
      secretAccessKey: "cos-secret-key",
    },
  };
}

test("COS object storage provider creates provider-neutral signed upload URLs without leaking secrets", async () => {
  const calls: Array<{ method: string; params: Record<string, unknown> }> = [];
  const provider = createObjectStorageProvider({
    config: cosConfig(),
    cosFactory: (options) => ({
      getObjectUrl(params: Record<string, unknown>) {
        calls.push({ method: "getObjectUrl", params });
        assert.deepEqual(options, {
          SecretId: "cos-secret-id",
          SecretKey: "cos-secret-key",
        });
        return "https://counter-1252496948.cos.ap-guangzhou.myqcloud.com/web-companion/session-1/photo.jpg?sign=q-sign-algorithm%3Dsha1";
      },
    }),
  });

  const signed = await provider.createSignedUploadUrl("web-companion/session-1/photo.jpg");

  assert.equal(signed.ok, true);
  assert.equal(signed.expiresInSeconds, 300);
  assert.match(signed.url, /^https:\/\/counter-1252496948\.cos\.ap-guangzhou\.myqcloud\.com\/web-companion/);
  assert.match(signed.url, /q-sign-algorithm/);
  assert.equal(signed.url.includes("cos-secret-key"), false);
  assert.deepEqual(calls[0], {
    method: "getObjectUrl",
    params: {
      Bucket: "counter-1252496948",
      Region: "ap-guangzhou",
      Key: "web-companion/session-1/photo.jpg",
      Sign: true,
      Method: "PUT",
      Expires: 300,
    },
  });
});

test("COS object storage provider lists, downloads, and uploads through cos-nodejs-sdk-v5 methods", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-cos-provider-"));
  const filePath = path.join(root, "book.png");
  await fs.writeFile(filePath, "image-bytes");
  const calls: Array<{ method: string; params: Record<string, unknown> }> = [];
  const provider = createObjectStorageProvider({
    config: cosConfig(),
    cosFactory: () => ({
      async getBucket(params: Record<string, unknown>) {
        calls.push({ method: "getBucket", params });
        return {
          Contents: [{
            Key: "session-1/photo.jpg",
            LastModified: "2026-06-01T00:00:00.000Z",
            Size: "12",
          }],
        };
      },
      async getObject(params: Record<string, unknown>) {
        calls.push({ method: "getObject", params });
        return {
          Body: Buffer.from("image-bytes"),
          headers: { "content-type": "image/jpeg" },
        };
      },
      async putObject(params: Record<string, unknown>) {
        calls.push({ method: "putObject", params: { ...params, Body: "[stream]" } });
        return { ETag: '"etag"' };
      },
    }),
  });

  const objects = await provider.listObjects({ prefix: "session-1/" });
  const downloaded = await provider.downloadObject("session-1/photo.jpg");
  const uploaded = await provider.uploadFile({
    localPath: filePath,
    objectPath: "exports/book.png",
    contentType: "image/png",
  });

  assert.deepEqual(objects, [{
    objectKey: "session-1/photo.jpg",
    size: 12,
    contentType: "application/octet-stream",
    lastModified: "2026-06-01T00:00:00.000Z",
  }]);
  assert.equal(downloaded.body.toString("utf8"), "image-bytes");
  assert.equal(downloaded.contentType, "image/jpeg");
  assert.equal(uploaded.ok, true);
  assert.equal(JSON.stringify(calls).includes("cos-secret-key"), false);
  assert.deepEqual(calls.map((call) => call.method), ["getBucket", "getObject", "putObject"]);
  assert.deepEqual(calls[0].params, {
    Bucket: "counter-1252496948",
    Region: "ap-guangzhou",
    Prefix: "session-1/",
    MaxKeys: 1000,
  });
});
