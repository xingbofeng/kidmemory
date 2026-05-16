import fs from "node:fs/promises";
import crypto from "node:crypto";

import type { AppConfig } from "../../../infrastructure/config/app-config.service.ts";

export type SupabaseStorageConfig = AppConfig["supabaseStorage"];

export type StorageActionResult = {
  ok: boolean;
  code?: string;
  message?: string;
  action?: string;
  retryable?: boolean;
};

export type SupabaseStorageProvider = ReturnType<typeof createSupabaseStorageProvider>;
type FetchBody = BodyInit | Buffer;

type ProviderDependencies = {
  config: SupabaseStorageConfig;
  fetch?: typeof fetch;
};

export function createSupabaseStorageProvider(dependencies: ProviderDependencies) {
  const fetchImpl = dependencies.fetch || fetch;
  const config = dependencies.config;
  const publicUrlForObject = (objectPath: string) => {
    const normalizedPath = normalizeObjectPath(objectPath);
    const base = config.publicBaseUrl.trim()
      || `${trimTrailingSlash(config.url)}/storage/v1/object/public/${encodeURIComponent(config.bucket)}`;
    return `${trimTrailingSlash(base)}/${normalizedPath}`;
  };

  return {
    getPublicUrl(objectPath: string) {
      return publicUrlForObject(objectPath);
    },

    async testConnection(input: { objectPath?: string } = {}) {
      const validation = validateConfig(config);
      if (!validation.ok) return { ...validation, cleanup: { ok: false } };

      const objectPath = normalizeObjectPath(input.objectPath || `healthchecks/${Date.now()}.txt`);
      const upload = await requestStorage({
        config,
        fetchImpl,
        method: "PUT",
        objectPath,
        body: "kidmemory-storage-healthcheck",
        contentType: "text/plain; charset=utf-8",
      });
      if (!upload.ok) return { ...upload, cleanup: { ok: false } };

      const download = await requestStorage({
        config,
        fetchImpl,
        method: "GET",
        objectPath,
      });
      if (!download.ok) return { ...download, cleanup: { ok: false } };

      const cleanup = await requestStorage({
        config,
        fetchImpl,
        method: "DELETE",
        objectPath,
      });
      return {
        ok: true,
        objectPath,
        cleanup: cleanup.ok
          ? { ok: true }
          : {
              ok: false,
              code: cleanup.code,
              message: cleanup.message,
              action: cleanup.action,
            },
      };
    },

    async uploadFile(input: { localPath: string; objectPath: string; contentType?: string }) {
      const validation = validateConfig(config);
      if (!validation.ok) return validation;

      let body: Buffer;
      try {
        body = await fs.readFile(input.localPath);
      } catch {
        return {
          ok: false,
          code: "LOCAL_FILE_MISSING",
          message: "Local file is missing or unreadable.",
          action: "Re-export the file or check the local data directory.",
          retryable: false,
        };
      }

      const uploaded = await requestStorage({
        config,
        fetchImpl,
        method: "PUT",
        objectPath: input.objectPath,
        body,
        contentType: input.contentType || "application/octet-stream",
      });
      if (!uploaded.ok) return uploaded;
      return {
        ok: true,
        ...(config.publicBaseUrl.trim()
          ? { remoteUrl: publicUrlForObject(input.objectPath) }
          : {}),
      };
    },

    async createSignedUrl(objectPath: string) {
      const validation = validateConfig(config);
      if (!validation.ok) {
        return {
          ...validation,
          url: "",
          expiresInSeconds: config.signedUrlTtlSeconds,
        };
      }

      if (storageAuthMode(config) === "s3") {
        return {
          ok: true,
          url: presignedS3Url({
            config,
            method: "GET",
            objectPath,
            expiresInSeconds: config.signedUrlTtlSeconds,
          }),
          expiresInSeconds: config.signedUrlTtlSeconds,
        };
      }

      const normalizedPath = normalizeObjectPath(objectPath);
      const response = await fetchImpl(
        `${trimTrailingSlash(config.url)}/storage/v1/object/sign/${encodeURIComponent(config.bucket)}/${normalizedPath}`,
        {
          method: "POST",
          headers: authHeaders(config, "application/json"),
          body: JSON.stringify({ expiresIn: config.signedUrlTtlSeconds }),
        },
      );
      if (!response.ok) {
        return {
          ...mapStorageResponseError(response.status, await safeText(response)),
          url: "",
          expiresInSeconds: config.signedUrlTtlSeconds,
        };
      }
      const payload = await safeJson(response);
      const signedPath = String(payload.signedURL || payload.signedUrl || "");
      return {
        ok: true,
        url: signedPath.startsWith("http")
          ? signedPath
          : `${trimTrailingSlash(config.url)}${signedPath.startsWith("/") ? "" : "/"}${signedPath}`,
        expiresInSeconds: config.signedUrlTtlSeconds,
      };
    },

    async createSignedUploadUrl(objectPath: string) {
      const validation = validateConfig(config);
      if (!validation.ok) {
        return {
          ...validation,
          url: "",
          expiresInSeconds: config.signedUrlTtlSeconds,
        };
      }

      if (storageAuthMode(config) === "s3") {
        return {
          ok: true,
          url: presignedS3Url({
            config,
            method: "PUT",
            objectPath,
            expiresInSeconds: config.signedUrlTtlSeconds,
          }),
          expiresInSeconds: config.signedUrlTtlSeconds,
        };
      }

      return {
        ok: false,
        code: "SUPABASE_STORAGE_SIGNED_UPLOAD_UNAVAILABLE",
        message: "REST signed browser uploads require a valid Supabase service role key.",
        action: "Configure Supabase S3 credentials or fix SUPABASE_SERVICE_ROLE_KEY.",
        retryable: false,
        url: "",
        expiresInSeconds: config.signedUrlTtlSeconds,
      };
    },
  };
}

async function requestStorage(input: {
  config: SupabaseStorageConfig;
  fetchImpl: typeof fetch;
  method: "PUT" | "GET" | "DELETE";
  objectPath: string;
  body?: FetchBody;
  contentType?: string;
}): Promise<StorageActionResult> {
  if (storageAuthMode(input.config) === "s3") {
    return requestSupabaseS3(input);
  }
  return requestSupabaseRest(input);
}

async function requestSupabaseRest(input: {
  config: SupabaseStorageConfig;
  fetchImpl: typeof fetch;
  method: "PUT" | "GET" | "DELETE";
  objectPath: string;
  body?: FetchBody;
  contentType?: string;
}): Promise<StorageActionResult> {
  const response = await input.fetchImpl(
    `${trimTrailingSlash(input.config.url)}/storage/v1/object/${encodeURIComponent(input.config.bucket)}/${normalizeObjectPath(input.objectPath)}`,
    {
      method: input.method === "PUT" ? "POST" : input.method,
      headers: authHeaders(input.config, input.contentType),
      body: input.body as BodyInit | undefined,
    },
  );
  if (response.ok) return { ok: true };
  return mapStorageResponseError(response.status, await safeText(response));
}

async function requestSupabaseS3(input: {
  config: SupabaseStorageConfig;
  fetchImpl: typeof fetch;
  method: "PUT" | "GET" | "DELETE";
  objectPath: string;
  body?: FetchBody;
  contentType?: string;
}): Promise<StorageActionResult> {
  const url = s3ObjectUrl(input.config, input.objectPath);
  const body = input.body ?? "";
  const headers = signedS3Headers({
    config: input.config,
    method: input.method,
    url,
    body,
    contentType: input.contentType,
  });
  const response = await input.fetchImpl(url, {
    method: input.method,
    headers,
    body: input.method === "GET" || input.method === "DELETE" ? undefined : body as BodyInit,
  });
  if (response.ok) return { ok: true };
  return mapStorageResponseError(response.status, await safeText(response));
}

function validateConfig(config: SupabaseStorageConfig): StorageActionResult {
  if (storageAuthMode(config) !== "none") {
    return { ok: true };
  }
  if (config.s3.accessKeyId.trim() || config.s3.secretAccessKey.trim()) {
    return {
      ok: false,
      code: "SUPABASE_STORAGE_S3_CONFIG_MISSING",
      message: "Supabase S3 configuration is incomplete.",
      action: "Configure SUPABASE_S3_ENDPOINT, SUPABASE_STORAGE_BUCKET or SUPABASE_S3_BUCKET, SUPABASE_S3_ACCESS_KEY_ID, and SUPABASE_S3_SECRET_ACCESS_KEY.",
      retryable: false,
    };
  }
  if (!config.url.trim() || !config.bucket.trim() || !config.serviceRoleKey.trim()) {
    return {
      ok: false,
      code: "SUPABASE_STORAGE_CONFIG_MISSING",
      message: "Supabase Storage configuration is incomplete.",
      action: "Configure SUPABASE_URL, SUPABASE_STORAGE_BUCKET, and SUPABASE_SERVICE_ROLE_KEY.",
      retryable: false,
    };
  }
  return { ok: true };
}

function storageAuthMode(config: SupabaseStorageConfig) {
  if (
    config.s3.endpoint.trim()
    && config.bucket.trim()
    && config.s3.accessKeyId.trim()
    && config.s3.secretAccessKey.trim()
  ) {
    return "s3";
  }
  if (config.url.trim() && config.bucket.trim() && config.serviceRoleKey.trim()) {
    return "rest";
  }
  return "none";
}

function mapStorageResponseError(status: number, body: string): StorageActionResult {
  if (status === 401 || status === 403) {
    return {
      ok: false,
      code: "SUPABASE_STORAGE_CREDENTIALS_INVALID",
      message: "Supabase Storage rejected the configured credentials.",
      action: "Check the Supabase service role key and Storage policy for this bucket.",
      retryable: false,
    };
  }
  if (status === 404) {
    return {
      ok: false,
      code: "SUPABASE_STORAGE_BUCKET_NOT_FOUND",
      message: "Supabase Storage bucket or object was not found.",
      action: "Check SUPABASE_STORAGE_BUCKET and the target object path.",
      retryable: false,
    };
  }
  if (status === 429 || status >= 500) {
    return {
      ok: false,
      code: "SUPABASE_STORAGE_RETRYABLE",
      message: body || "Supabase Storage is temporarily unavailable.",
      action: "Retry the operation later.",
      retryable: true,
    };
  }
  return {
    ok: false,
    code: "SUPABASE_STORAGE_REQUEST_FAILED",
    message: body || `Supabase Storage request failed with HTTP ${status}.`,
    action: "Check Supabase Storage configuration and retry.",
    retryable: false,
  };
}

function authHeaders(config: SupabaseStorageConfig, contentType?: string) {
  const headers: Record<string, string> = {
    apikey: config.serviceRoleKey,
    authorization: `Bearer ${config.serviceRoleKey}`,
  };
  if (contentType) headers["content-type"] = contentType;
  return headers;
}

function s3ObjectUrl(config: SupabaseStorageConfig, objectPath: string) {
  return `${trimTrailingSlash(config.s3.endpoint)}/${encodeURIComponent(config.bucket)}/${normalizeObjectPath(objectPath)}`;
}

function signedS3Headers(input: {
  config: SupabaseStorageConfig;
  method: "PUT" | "GET" | "DELETE";
  url: string;
  body: FetchBody;
  contentType?: string;
}) {
  const now = new Date();
  const amzDate = iso8601Basic(now);
  const dateStamp = amzDate.slice(0, 8);
  const payloadHash = sha256Hex(input.body);
  const url = new URL(input.url);
  const headers: Record<string, string> = {
    host: url.host,
    "x-amz-content-sha256": payloadHash,
    "x-amz-date": amzDate,
  };
  if (input.contentType) headers["content-type"] = input.contentType;
  const signed = signS3Request({
    config: input.config,
    method: input.method,
    url,
    headers,
    payloadHash,
    dateStamp,
    amzDate,
  });
  return {
    ...headers,
    authorization: signed.authorization,
  };
}

function presignedS3Url(input: {
  config: SupabaseStorageConfig;
  method: "GET" | "PUT";
  objectPath: string;
  expiresInSeconds: number;
}) {
  const now = new Date();
  const amzDate = iso8601Basic(now);
  const dateStamp = amzDate.slice(0, 8);
  const url = new URL(s3ObjectUrl(input.config, input.objectPath));
  const credentialScope = s3CredentialScope(input.config, dateStamp);
  url.searchParams.set("X-Amz-Algorithm", "AWS4-HMAC-SHA256");
  url.searchParams.set(
    "X-Amz-Credential",
    `${input.config.s3.accessKeyId}/${credentialScope}`,
  );
  url.searchParams.set("X-Amz-Date", amzDate);
  url.searchParams.set("X-Amz-Expires", `${Math.max(1, input.expiresInSeconds)}`);
  url.searchParams.set("X-Amz-SignedHeaders", "host");
  const canonicalRequest = [
    input.method,
    url.pathname,
    canonicalQueryString(url.searchParams),
    `host:${url.host}\n`,
    "host",
    "UNSIGNED-PAYLOAD",
  ].join("\n");
  const stringToSign = [
    "AWS4-HMAC-SHA256",
    amzDate,
    credentialScope,
    sha256Hex(canonicalRequest),
  ].join("\n");
  const signature = hmacHex(
    s3SigningKey(input.config, dateStamp),
    stringToSign,
  );
  url.searchParams.set("X-Amz-Signature", signature);
  return url.toString();
}

function signS3Request(input: {
  config: SupabaseStorageConfig;
  method: "PUT" | "GET" | "DELETE";
  url: URL;
  headers: Record<string, string>;
  payloadHash: string;
  dateStamp: string;
  amzDate: string;
}) {
  const signedHeaders = Object.keys(input.headers).sort().join(";");
  const canonicalHeaders = Object.keys(input.headers)
    .sort()
    .map((key) => `${key}:${input.headers[key].trim()}`)
    .join("\n");
  const credentialScope = s3CredentialScope(input.config, input.dateStamp);
  const canonicalRequest = [
    input.method,
    input.url.pathname,
    canonicalQueryString(input.url.searchParams),
    `${canonicalHeaders}\n`,
    signedHeaders,
    input.payloadHash,
  ].join("\n");
  const stringToSign = [
    "AWS4-HMAC-SHA256",
    input.amzDate,
    credentialScope,
    sha256Hex(canonicalRequest),
  ].join("\n");
  const signature = hmacHex(
    s3SigningKey(input.config, input.dateStamp),
    stringToSign,
  );
  return {
    authorization:
      `AWS4-HMAC-SHA256 Credential=${input.config.s3.accessKeyId}/${credentialScope}, SignedHeaders=${signedHeaders}, Signature=${signature}`,
  };
}

function s3CredentialScope(config: SupabaseStorageConfig, dateStamp: string) {
  return `${dateStamp}/${config.s3.region || "auto"}/s3/aws4_request`;
}

function s3SigningKey(config: SupabaseStorageConfig, dateStamp: string) {
  const dateKey = hmacBuffer(`AWS4${config.s3.secretAccessKey}`, dateStamp);
  const regionKey = hmacBuffer(dateKey, config.s3.region || "auto");
  const serviceKey = hmacBuffer(regionKey, "s3");
  return hmacBuffer(serviceKey, "aws4_request");
}

function canonicalQueryString(params: URLSearchParams) {
  return [...params.entries()]
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(value)}`)
    .join("&");
}

function sha256Hex(value: FetchBody | string) {
  return crypto.createHash("sha256").update(bodyToBuffer(value)).digest("hex");
}

function hmacBuffer(key: crypto.BinaryLike, value: string) {
  return crypto.createHmac("sha256", key).update(value).digest();
}

function hmacHex(key: crypto.BinaryLike, value: string) {
  return crypto.createHmac("sha256", key).update(value).digest("hex");
}

function bodyToBuffer(value: FetchBody | string) {
  if (typeof value === "string") return Buffer.from(value);
  if (Buffer.isBuffer(value)) return value;
  if (value instanceof Uint8Array) return Buffer.from(value);
  return Buffer.from(String(value));
}

function iso8601Basic(date: Date) {
  return date.toISOString().replace(/[:-]|\.\d{3}/g, "");
}

function normalizeObjectPath(value: string) {
  return value
    .trim()
    .replace(/^\/+/, "")
    .replace(/\/+/g, "/")
    .split("/")
    .map((part) => encodeURIComponent(part))
    .join("/");
}

function trimTrailingSlash(value: string) {
  return value.trim().replace(/\/+$/, "");
}

async function safeText(response: Response) {
  try {
    return await response.text();
  } catch {
    return "";
  }
}

async function safeJson(response: Response) {
  try {
    return await response.json() as Record<string, unknown>;
  } catch {
    return {};
  }
}
