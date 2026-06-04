import fs from "node:fs";
import { createRequire } from "node:module";
import os from "node:os";
import path from "node:path";

import type { AppConfig } from "../../../infrastructure/config/app-config.service.ts";

import {
  createSupabaseStorageProvider,
  type SupabaseStorageConfig,
  type StorageActionResult,
} from "./supabase-storage.ts";
import { trimTrailingSlash } from "../../../infrastructure/url/trailing-slash.ts";

export type ObjectStorageProviderType = "supabase" | "cos" | "s3";

export type ObjectStorageConfig = Omit<SupabaseStorageConfig, "provider"> & {
  provider: ObjectStorageProviderType;
};

export type ObjectStorageProvider = ReturnType<typeof createObjectStorageProvider>;

type CosOptions = { SecretId: string; SecretKey: string };
type CosClient = {
  getObjectUrl?: (
    params: Record<string, unknown>,
    callback?: (error: Error | null, data?: { Url?: string }) => void,
  ) => string | undefined;
  getBucket?: (params: Record<string, unknown>) => Promise<{ Contents?: Array<{ Key?: string; Size?: string | number; LastModified?: string }> }>;
  getObject?: (params: Record<string, unknown>) => Promise<{ Body?: Buffer | string | Uint8Array; headers?: Record<string, string> }>;
  putObject?: (params: Record<string, unknown>) => Promise<{ ETag?: string }>;
};

type ProviderDependencies = {
  config: ObjectStorageConfig | AppConfig["supabaseStorage"];
  fetch?: typeof fetch;
  cosFactory?: (options: CosOptions) => CosClient;
};

export function createObjectStorageProvider(dependencies: ProviderDependencies) {
  const config = dependencies.config as ObjectStorageConfig;
  if (config.provider === "cos") {
    return createCosObjectStorageProvider(config, dependencies.cosFactory);
  }
  return createSupabaseStorageProvider({
    config: dependencies.config as SupabaseStorageConfig,
    fetch: dependencies.fetch,
  });
}

function createCosObjectStorageProvider(
  config: ObjectStorageConfig,
  cosFactory = defaultCosFactory,
) {
  const client = () => cosFactory({
    SecretId: config.s3.accessKeyId,
    SecretKey: config.s3.secretAccessKey,
  });
  const region = () => config.s3.region || "ap-guangzhou";
  const publicUrlForObject = (objectPath: string) => {
    const normalized = normalizeObjectPath(objectPath);
    const base = config.publicBaseUrl.trim()
      || `https://${config.bucket}.cos.${region()}.myqcloud.com`;
    return `${trimTrailingSlash(base)}/${normalized}`;
  };

  return {
    getPublicUrl(objectPath: string) {
      return publicUrlForObject(objectPath);
    },

    async testConnection(input: { objectPath?: string } = {}) {
      const validation = validateCosConfig(config);
      if (!validation.ok) return { ...validation, cleanup: { ok: false } };
      const objectPath = input.objectPath || `healthchecks/${Date.now()}.txt`;
      const tempPath = await writeTempHealthcheck();
      try {
        const upload = await this.uploadFile({
          localPath: tempPath,
          objectPath,
          contentType: "text/plain; charset=utf-8",
        });
        return {
          ...upload,
          objectPath,
          cleanup: { ok: true },
        };
      } finally {
        await fs.promises.rm(tempPath, { force: true });
      }
    },

    async uploadFile(input: { localPath: string; objectPath: string; contentType?: string }) {
      const validation = validateCosConfig(config);
      if (!validation.ok) return validation;
      if (!fs.existsSync(input.localPath)) {
        return {
          ok: false,
          code: "LOCAL_FILE_MISSING",
          message: "Local file is missing or unreadable.",
          action: "Re-export the file or check the local data directory.",
          retryable: false,
        };
      }
      const cos = client();
      if (!cos.putObject) return missingSdkMethod("putObject");
      await cos.putObject({
        Bucket: config.bucket,
        Region: region(),
        Key: normalizeObjectKey(input.objectPath),
        Body: fs.createReadStream(input.localPath),
        ContentType: input.contentType,
      });
      return {
        ok: true,
        ...(config.publicBaseUrl.trim()
          ? { remoteUrl: publicUrlForObject(input.objectPath) }
          : {}),
      };
    },

    async createSignedUrl(objectPath: string) {
      return createCosSignedUrl({
        config,
        cos: client(),
        method: "GET",
        objectPath,
      });
    },

    async createSignedUploadUrl(objectPath: string) {
      return createCosSignedUrl({
        config,
        cos: client(),
        method: "PUT",
        objectPath,
      });
    },

    async listObjects(input: { prefix: string }) {
      const validation = validateCosConfig(config);
      if (!validation.ok) throw new Error(validation.message);
      const cos = client();
      if (!cos.getBucket) throw new Error("COS SDK getBucket method is unavailable.");
      const data = await cos.getBucket({
        Bucket: config.bucket,
        Region: region(),
        Prefix: input.prefix,
        MaxKeys: 1000,
      });
      return (data.Contents ?? [])
        .filter((item) => item.Key && !item.Key.endsWith("/"))
        .map((item) => ({
          objectKey: item.Key || "",
          size: Number(item.Size || 0),
          contentType: "application/octet-stream",
          lastModified: item.LastModified || new Date().toISOString(),
        }));
    },

    async downloadObject(objectPath: string) {
      const validation = validateCosConfig(config);
      if (!validation.ok) throw new Error(validation.message);
      const cos = client();
      if (!cos.getObject) throw new Error("COS SDK getObject method is unavailable.");
      const data = await cos.getObject({
        Bucket: config.bucket,
        Region: region(),
        Key: normalizeObjectKey(objectPath),
      });
      const body = Buffer.isBuffer(data.Body)
        ? data.Body
        : Buffer.from(data.Body ?? "");
      return {
        body,
        contentType: data.headers?.["content-type"] || "application/octet-stream",
        size: body.byteLength,
      };
    },
  };
}

async function createCosSignedUrl(input: {
  config: ObjectStorageConfig;
  cos: CosClient;
  method: "GET" | "PUT";
  objectPath: string;
}) {
  const validation = validateCosConfig(input.config);
  if (!validation.ok) {
    return {
      ...validation,
      url: "",
      expiresInSeconds: input.config.signedUrlTtlSeconds,
    };
  }
  if (!input.cos.getObjectUrl) {
    return {
      ...missingSdkMethod("getObjectUrl"),
      url: "",
      expiresInSeconds: input.config.signedUrlTtlSeconds,
    };
  }
  const params = {
    Bucket: input.config.bucket,
    Region: input.config.s3.region || "ap-guangzhou",
    Key: normalizeObjectKey(input.objectPath),
    Sign: true,
    Method: input.method,
    Expires: input.config.signedUrlTtlSeconds,
  };
  const url = await new Promise<string>((resolve, reject) => {
    const immediate = input.cos.getObjectUrl?.(params, (error, data) => {
      if (error) reject(error);
      else resolve(data?.Url || "");
    });
    if (immediate) resolve(immediate);
  });
  return {
    ok: true,
    url,
    expiresInSeconds: input.config.signedUrlTtlSeconds,
  };
}

function validateCosConfig(config: ObjectStorageConfig): StorageActionResult {
  if (
    config.bucket.trim()
    && config.s3.region.trim()
    && config.s3.accessKeyId.trim()
    && config.s3.secretAccessKey.trim()
  ) {
    return { ok: true };
  }
  return {
    ok: false,
    code: "COS_STORAGE_CONFIG_MISSING",
    message: "Tencent COS configuration is incomplete.",
    action: "Configure COS bucket, region, secret id, and secret key.",
    retryable: false,
  };
}

function missingSdkMethod(method: string): StorageActionResult {
  return {
    ok: false,
    code: "COS_SDK_METHOD_UNAVAILABLE",
    message: `Tencent COS SDK method is unavailable: ${method}.`,
    action: "Check cos-nodejs-sdk-v5 installation.",
    retryable: false,
  };
}

function defaultCosFactory(options: CosOptions): CosClient {
  const require = createRequire(import.meta.url);
  const COS = require("cos-nodejs-sdk-v5") as new (input: CosOptions) => CosClient;
  return new COS(options);
}

async function writeTempHealthcheck() {
  const filePath = path.join(os.tmpdir(), `kidmemory-cos-healthcheck-${Date.now()}.txt`);
  await fs.promises.writeFile(filePath, "kidmemory-storage-healthcheck");
  return filePath;
}

function normalizeObjectKey(value: string) {
  return value.trim().replace(/^\/+/, "").replace(/\/+/g, "/");
}

function normalizeObjectPath(value: string) {
  return normalizeObjectKey(value)
    .split("/")
    .map((part) => encodeURIComponent(part))
    .join("/");
}
