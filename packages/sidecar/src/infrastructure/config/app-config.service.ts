import fs from "node:fs";
import path from "node:path";
import { Injectable } from "@nestjs/common";

import { parseEnvBoolean } from "./env-parsing.ts";

export type AppConfig = {
  postgres: {
    host: string;
    port: number;
    database: string;
    user: string;
    password: string;
    connectionUrl?: string;
  };
  openai: {
    provider: "openai";
    baseUrl: string;
    apiKey: string;
    model: string;
  };
  claude: {
    apiKey: string;
    model: string;
    baseUrl: string;
  };
  localAgent?: {
    endpoint: string;
    apiKey?: string;
  };
  supabaseStorage: {
    provider: "supabase" | "cos" | "s3";
    url: string;
    bucket: string;
    serviceRoleKey: string;
    anonKey: string;
    publicBaseUrl: string;
    signedUrlTtlSeconds: number;
    s3: {
      endpoint: string;
      region: string;
      accessKeyId: string;
      secretAccessKey: string;
    };
  };
  /**
   * Web Companion Supabase Direct Upload 配置。
   *
   * 安全边界：
   * - `serviceRoleKey` 与本地路径只保留在 sidecar，不允许出现在 sidecar 暴露给前端的响应中。
   * - `anonKey` 可以经 `POST /web-companion/direct-upload/sessions` 下发给 Web Companion 前端使用。
   * - bucket policy 必须限制 anon 仅可写入 `web-companion-uploads/{sessionId}/...` 前缀。
   */
  webCompanionDirectUpload: {
    enabled: boolean;
    bucket: string;
    publicUrl: string;
    /** 体验约束（不是安全约束）：单次推荐张数。 */
    recommendedClientLimit: number;
    /** 体验约束（不是安全约束）：建议会话有效期（秒），仅作为前端提示。 */
    expiresAtHintSeconds: number;
  };
  paths: {
    workspaceDir: string;
    exportDir: string;
    dataDir: string;
  };
  sidecar: {
    port: number;
    host: string;
    webCompanionBaseUrl: string;
  };
  mcp: {
    enabled: boolean;
    path: string;
  };
};

export type AppPathConfig = AppConfig["paths"];

export type SupabaseStorageUpdateConfig = Partial<AppConfig["supabaseStorage"]> & {
  s3?: Partial<AppConfig["supabaseStorage"]["s3"]>;
};

export type WebCompanionDirectUploadUpdateConfig = Partial<
  AppConfig["webCompanionDirectUpload"]
>;

export function readDotEnv(
  filePath = path.resolve(process.cwd(), "../../.env"),
): Record<string, string> {
  if (!fs.existsSync(filePath)) return {};
  const content = fs.readFileSync(filePath, "utf8");
  const env: Record<string, string> = {};
  for (const line of content.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const index = trimmed.indexOf("=");
    if (index === -1) continue;
    const key = trimmed.slice(0, index).trim();
    const raw = trimmed.slice(index + 1).trim();
    env[key] = raw.replace(/^['"]|['"]$/g, "");
  }
  return env;
}

export function loadConfigFromEnv(
  env: Record<string, string | undefined> = { ...readDotEnv(), ...process.env },
): AppConfig {
  const pathRoot = defaultKidMemoryPathRoot(env);
  const objectStorageProvider = parseObjectStorageProvider(
    env.KIDMEMORY_OBJECT_STORAGE_PROVIDER,
  );
  return {
    postgres: {
      host: env.POSTGRES_HOST || "localhost",
      port: Number(env.POSTGRES_PORT || 5432),
      database: env.POSTGRES_DATABASE || "kidmemory",
      user: env.POSTGRES_USER || "postgres",
      password: env.POSTGRES_PASSWORD || "",
      connectionUrl: env.POSTGRES_URL || env.DATABASE_URL,
    },
    openai: {
      provider: "openai",
      baseUrl: "",
      apiKey: "",
      model: "",
    },
    claude: {
      apiKey: env.CLAUDE_API_KEY || "",
      model: env.CLAUDE_MODEL || "claude-3-5-sonnet-20241022",
      baseUrl: env.CLAUDE_BASE_URL || "https://api.anthropic.com",
    },
    localAgent: env.LOCAL_AGENT_ENDPOINT ? {
      endpoint: env.LOCAL_AGENT_ENDPOINT,
      apiKey: env.LOCAL_AGENT_API_KEY,
    } : undefined,
    supabaseStorage: {
      provider: objectStorageProvider,
      url: "",
      bucket: objectStorageProvider === "cos"
        ? env.COS_BUCKET || ""
        : objectStorageProvider === "s3"
          ? env.SUPABASE_S3_BUCKET || env.SUPABASE_STORAGE_BUCKET || ""
        : "",
      serviceRoleKey: "",
      anonKey: "",
      publicBaseUrl: objectStorageProvider === "cos"
        ? env.COS_PUBLIC_BASE_URL || ""
        : objectStorageProvider === "s3"
          ? env.SUPABASE_STORAGE_PUBLIC_BASE_URL || ""
        : "",
      signedUrlTtlSeconds: numberOrCurrent(
        objectStorageProvider === "cos"
          ? env.COS_SIGNED_URL_TTL_SECONDS
          : objectStorageProvider === "s3"
            ? env.SUPABASE_STORAGE_SIGNED_URL_TTL_SECONDS
          : undefined,
        3600,
      ),
      s3: {
        endpoint: objectStorageProvider === "cos"
          ? env.COS_ENDPOINT || ""
          : objectStorageProvider === "s3"
            ? env.SUPABASE_S3_ENDPOINT || ""
          : "",
        region: objectStorageProvider === "cos"
          ? env.COS_REGION || "ap-guangzhou"
          : objectStorageProvider === "s3"
            ? env.SUPABASE_S3_REGION || "auto"
          : "auto",
        accessKeyId: objectStorageProvider === "cos"
          ? env.COS_SECRET_ID || ""
          : objectStorageProvider === "s3"
            ? env.SUPABASE_S3_ACCESS_KEY_ID || ""
          : "",
        secretAccessKey: objectStorageProvider === "cos"
          ? env.COS_SECRET_KEY || ""
          : objectStorageProvider === "s3"
            ? env.SUPABASE_S3_SECRET_ACCESS_KEY || ""
          : "",
      },
    },
    webCompanionDirectUpload: {
      enabled: parseEnvBoolean(env.WEB_COMPANION_DIRECT_UPLOAD_ENABLED, false),
      bucket: objectStorageProvider === "cos"
        ? env.COS_DIRECT_UPLOAD_BUCKET || env.COS_BUCKET || ""
        : objectStorageProvider === "s3"
          ? env.SUPABASE_DIRECT_UPLOAD_BUCKET || env.SUPABASE_S3_BUCKET || env.SUPABASE_STORAGE_BUCKET || ""
        : env.SUPABASE_DIRECT_UPLOAD_BUCKET || "",
      publicUrl: env.WEB_COMPANION_DIRECT_PUBLIC_URL || "",
      recommendedClientLimit: numberOrCurrent(
        env.WEB_COMPANION_DIRECT_RECOMMENDED_CLIENT_LIMIT,
        200,
      ),
      expiresAtHintSeconds: numberOrCurrent(
        env.WEB_COMPANION_DIRECT_EXPIRES_AT_HINT_SECONDS,
        3 * 60 * 60,
      ),
    },
    paths: {
      workspaceDir: resolveConfiguredPath(
        env.KIDMEMORY_WORKSPACE_DIR,
        path.join(pathRoot, "workspace"),
      ),
      exportDir: resolveConfiguredPath(
        env.KIDMEMORY_EXPORT_DIR,
        path.join(pathRoot, "exports"),
      ),
      dataDir: resolveConfiguredPath(
        env.KIDMEMORY_DATA_DIR,
        path.join(pathRoot, "data"),
      ),
    },
    sidecar: {
      port: Number(env.KIDMEMORY_SIDECAR_PORT || 4317),
      host: env.KIDMEMORY_SIDECAR_HOST || "127.0.0.1",
      webCompanionBaseUrl: env.WEB_COMPANION_BASE_URL || "http://localhost:3001",
    },
    mcp: {
      enabled: parseEnvBoolean(env.KIDMEMORY_MCP_ENABLED, false),
      path: env.KIDMEMORY_MCP_PATH?.trim() || "/mcp",
    },
  };
}

function parseObjectStorageProvider(value: string | undefined): AppConfig["supabaseStorage"]["provider"] {
  if (value === "cos" || value === "s3") return value;
  return "supabase";
}

export function pathsForLocalDataRoot(rootPath: string): AppPathConfig {
  const root = path.resolve(rootPath.trim());
  return {
    workspaceDir: path.join(root, "workspace"),
    exportDir: path.join(root, "exports"),
    dataDir: path.join(root, "data"),
  };
}

function defaultKidMemoryPathRoot(env: Record<string, string | undefined>) {
  if (env.KIDMEMORY_ROOT_DIR) return env.KIDMEMORY_ROOT_DIR;
  if (env.KIDMEMORY_DATA_DIR) return path.dirname(env.KIDMEMORY_DATA_DIR);
  const home = env.HOME || env.USERPROFILE || process.env.HOME || process.cwd();
  if (process.platform === "darwin") {
    return path.join(home, "Library", "Application Support", "KidMemory");
  }
  if (process.platform === "win32") {
    return path.join(env.APPDATA || home, "KidMemory");
  }
  return path.join(home, ".local", "share", "KidMemory");
}

export function redactConfig(config: AppConfig) {
  const supabaseRestConfigured = Boolean(
    config.supabaseStorage.provider === "supabase"
      && config.supabaseStorage.url
      && config.supabaseStorage.bucket
      && config.supabaseStorage.serviceRoleKey,
  );
  const storageS3CredentialsDetected = Boolean(
    config.supabaseStorage.s3.accessKeyId
      || config.supabaseStorage.s3.secretAccessKey,
  );
  const storageS3Configured = isS3CompatibleStorageConfigured(config);
  const supabaseStorageConfigured = supabaseRestConfigured || storageS3Configured;
  return {
    postgres: {
      host: config.postgres.host,
      port: config.postgres.port,
      database: config.postgres.database,
      user: config.postgres.user,
      passwordConfigured: Boolean(
        config.postgres.password || config.postgres.connectionUrl,
      ),
      connectionUrlConfigured: Boolean(config.postgres.connectionUrl),
    },
    openai: {
      provider: config.openai.provider,
      baseUrl: config.openai.baseUrl,
      model: config.openai.model,
      apiKey: config.openai.apiKey,
      apiKeyConfigured: Boolean(config.openai.apiKey),
      blocksGeneration: false,
    },
    claude: {
      baseUrl: config.claude.baseUrl,
      model: config.claude.model,
      apiKeyConfigured: Boolean(config.claude.apiKey),
    },
    supabaseStorage: {
      provider: config.supabaseStorage.provider,
      url: config.supabaseStorage.url,
      bucket: config.supabaseStorage.bucket,
      serviceRoleKey: config.supabaseStorage.serviceRoleKey ? "[REDACTED]" : "",
      serviceRoleKeyConfigured: Boolean(config.supabaseStorage.serviceRoleKey),
      anonKey: config.supabaseStorage.anonKey ? "[REDACTED]" : "",
      anonKeyConfigured: Boolean(config.supabaseStorage.anonKey),
      publicBaseUrl: config.supabaseStorage.publicBaseUrl,
      signedUrlTtlSeconds: config.supabaseStorage.signedUrlTtlSeconds,
      configured: supabaseStorageConfigured,
      authMode: supabaseRestConfigured
        ? "rest"
        : (storageS3Configured ? "s3" : "none"),
      s3: {
        endpoint: config.supabaseStorage.s3.endpoint,
        region: config.supabaseStorage.s3.region,
        accessKeyId: config.supabaseStorage.s3.accessKeyId ? "[REDACTED]" : "",
        accessKeyIdConfigured: Boolean(config.supabaseStorage.s3.accessKeyId),
        secretAccessKey: config.supabaseStorage.s3.secretAccessKey ? "[REDACTED]" : "",
        secretAccessKeyConfigured: Boolean(config.supabaseStorage.s3.secretAccessKey),
        configured: storageS3Configured,
      },
      s3CredentialsDetected: storageS3CredentialsDetected,
      diagnosticMessage:
        !supabaseStorageConfigured && storageS3CredentialsDetected
          ? "检测到对象存储 S3 兼容凭据。S3 模式还需要配置 endpoint、bucket、access key 和 secret key；region 默认 auto。"
          : "",
    },
    webCompanionDirectUpload: redactWebCompanionDirectUpload(config),
    paths: config.paths,
    sidecar: config.sidecar,
    mcp: config.mcp,
  };
}

/**
 * 描述 Web Companion Direct Upload 当前是否具备「签发会话」前置条件。
 *
 * 注意：返回结构 **不** 包含任何敏感值（service role key、anon key、本地路径等），
 * 可以直接序列化给桌面端展示用。
 */
export function redactWebCompanionDirectUpload(config: AppConfig) {
  const missing = collectWebCompanionDirectUploadMissing(config);
  return {
    enabled: config.webCompanionDirectUpload.enabled,
    provider: config.supabaseStorage.provider,
    bucket: config.webCompanionDirectUpload.bucket,
    publicUrl: config.webCompanionDirectUpload.publicUrl,
    recommendedClientLimit: config.webCompanionDirectUpload.recommendedClientLimit,
    expiresAtHintSeconds: config.webCompanionDirectUpload.expiresAtHintSeconds,
    supabaseUrlConfigured: Boolean(config.supabaseStorage.url),
    anonKeyConfigured: Boolean(config.supabaseStorage.anonKey),
    serviceRoleKeyConfigured: Boolean(config.supabaseStorage.serviceRoleKey),
    publicUrlConfigured: Boolean(config.webCompanionDirectUpload.publicUrl),
    bucketConfigured: Boolean(config.webCompanionDirectUpload.bucket),
    canSignSession: missing.length === 0,
    missingConfigKeys: missing,
  };
}

/**
 * 列出当前 sidecar 配置中阻止「签发 Direct Upload 会话」的缺失项，按 spec 中 actionable error 要求返回。
 *
 * 必需项：`SUPABASE_URL`、`SUPABASE_ANON_KEY`、`SUPABASE_DIRECT_UPLOAD_BUCKET`、`WEB_COMPANION_DIRECT_PUBLIC_URL`。
 *
 * service role key 是可选项（用于 sidecar 自身的 list+download；未配置则回退到 anon key）。
 */
export function collectWebCompanionDirectUploadMissing(config: AppConfig): string[] {
  const missing: string[] = [];
  if (!isS3CompatibleStorageConfigured(config)) {
    if (!config.supabaseStorage.url) missing.push("SUPABASE_URL");
    if (!config.supabaseStorage.anonKey) missing.push("SUPABASE_ANON_KEY");
  }
  if (!config.webCompanionDirectUpload.bucket) {
    missing.push("SUPABASE_DIRECT_UPLOAD_BUCKET");
  }
  if (!config.webCompanionDirectUpload.publicUrl) {
    missing.push("WEB_COMPANION_DIRECT_PUBLIC_URL");
  }
  return missing;
}

function isS3CompatibleStorageConfigured(config: AppConfig) {
  const s3 = config.supabaseStorage.s3;
  if (config.supabaseStorage.provider === "cos") {
    return Boolean(
      s3
        && config.supabaseStorage.bucket
        && s3.region
        && s3.accessKeyId
        && s3.secretAccessKey,
    );
  }
  return Boolean(
    s3
      && s3.endpoint
      && config.supabaseStorage.bucket
      && s3.accessKeyId
      && s3.secretAccessKey,
  );
}

/**
 * Direct Upload 会话签发前置失败时抛出的可行动错误。
 *
 * 调用方（controller / service 层）应捕获该错误并以 4xx 响应返回，包含 `code`、`message` 和 `missingConfigKeys`。
 * 错误消息只引用配置 key 名称，不引用具体值，避免向前端泄露任何敏感信息。
 */
export class WebCompanionDirectUploadConfigError extends Error {
  readonly code = "web_companion_direct_upload_config_missing" as const;
  readonly missingConfigKeys: string[];

  constructor(missingConfigKeys: string[]) {
    const list = missingConfigKeys.join(", ");
    super(
      `Web Companion Direct Upload 配置不完整，无法签发会话：缺少 ${list}。`
        + "service role key 可选；anon key 与 bucket 必须显式配置。",
    );
    this.name = "WebCompanionDirectUploadConfigError";
    this.missingConfigKeys = missingConfigKeys;
  }
}

/**
 * 在签发 Direct Upload 会话前调用，确保 sidecar 已具备最小必需配置；否则抛出 actionable 错误。
 */
export function assertWebCompanionDirectUploadReady(config: AppConfig): void {
  const missing = collectWebCompanionDirectUploadMissing(config);
  if (missing.length > 0) {
    throw new WebCompanionDirectUploadConfigError(missing);
  }
}

export class AppConfigService {
  readonly config: AppConfig;

  constructor(config = loadConfigFromEnv()) {
    this.config = config;
  }

  updatePostgresConfig(nextConfig: Partial<AppConfig["postgres"]>) {
    const host = textOrCurrent(nextConfig.host, this.config.postgres.host);
    const database = textOrCurrent(nextConfig.database, this.config.postgres.database);
    const user = textOrCurrent(nextConfig.user, this.config.postgres.user);
    const password = nextConfig.password === undefined
      ? this.config.postgres.password
      : `${nextConfig.password}`;
    const port = numberOrCurrent(nextConfig.port, this.config.postgres.port);

    this.config.postgres = {
      ...this.config.postgres,
      host,
      port,
      database,
      user,
      password,
    };
    this.config.postgres.connectionUrl = stringOrCurrent(
      nextConfig.connectionUrl as string | undefined,
      this.config.postgres.connectionUrl,
    );
    return this.config.postgres;
  }

  updateOpenAIConfig(nextConfig: Partial<AppConfig["openai"]>) {
    this.config.openai = {
      ...this.config.openai,
      baseUrl: textOrCurrent(
        nextConfig.baseUrl,
        this.config.openai.baseUrl,
      ),
      apiKey: nextConfig.apiKey === undefined
        ? this.config.openai.apiKey
        : `${nextConfig.apiKey}`,
      model: textOrCurrent(nextConfig.model, this.config.openai.model),
    };
    return this.config.openai;
  }

  updateSupabaseStorageConfig(nextConfig: SupabaseStorageUpdateConfig) {
    this.config.supabaseStorage = {
      ...this.config.supabaseStorage,
      provider: nextConfig.provider ?? this.config.supabaseStorage.provider,
      url: textOrCurrent(nextConfig.url, this.config.supabaseStorage.url),
      bucket: textOrCurrent(
        nextConfig.bucket,
        this.config.supabaseStorage.bucket,
      ),
      serviceRoleKey: nextConfig.serviceRoleKey === undefined
        ? this.config.supabaseStorage.serviceRoleKey
        : `${nextConfig.serviceRoleKey}`,
      anonKey: nextConfig.anonKey === undefined
        ? this.config.supabaseStorage.anonKey
        : `${nextConfig.anonKey}`,
      publicBaseUrl: textOrCurrent(
        nextConfig.publicBaseUrl,
        this.config.supabaseStorage.publicBaseUrl,
      ),
      signedUrlTtlSeconds: numberOrCurrent(
        nextConfig.signedUrlTtlSeconds,
        this.config.supabaseStorage.signedUrlTtlSeconds,
      ),
      s3: {
        ...this.config.supabaseStorage.s3,
        endpoint: textOrCurrent(
          nextConfig.s3?.endpoint,
          this.config.supabaseStorage.s3.endpoint,
        ),
        region: textOrCurrent(
          nextConfig.s3?.region,
          this.config.supabaseStorage.s3.region,
        ),
        accessKeyId: textOrCurrent(
          nextConfig.s3?.accessKeyId,
          this.config.supabaseStorage.s3.accessKeyId,
        ),
        secretAccessKey:
          nextConfig.s3?.secretAccessKey === undefined
            ? this.config.supabaseStorage.s3.secretAccessKey
            : `${nextConfig.s3.secretAccessKey}`,
      },
    };
    return this.config.supabaseStorage;
  }

  updateWebCompanionDirectUploadConfig(
    nextConfig: WebCompanionDirectUploadUpdateConfig,
  ) {
    this.config.webCompanionDirectUpload = {
      ...this.config.webCompanionDirectUpload,
      enabled:
        nextConfig.enabled === undefined
          ? this.config.webCompanionDirectUpload.enabled
          : Boolean(nextConfig.enabled),
      bucket: textOrCurrent(
        nextConfig.bucket,
        this.config.webCompanionDirectUpload.bucket,
      ),
      publicUrl: textOrCurrent(
        nextConfig.publicUrl,
        this.config.webCompanionDirectUpload.publicUrl,
      ),
      recommendedClientLimit: numberOrCurrent(
        nextConfig.recommendedClientLimit,
        this.config.webCompanionDirectUpload.recommendedClientLimit,
      ),
      expiresAtHintSeconds: numberOrCurrent(
        nextConfig.expiresAtHintSeconds,
        this.config.webCompanionDirectUpload.expiresAtHintSeconds,
      ),
    };
    return this.config.webCompanionDirectUpload;
  }

  updateLocalDataRoot(rootPath: string) {
    Object.assign(this.config.paths, pathsForLocalDataRoot(rootPath));
    return this.config.paths;
  }

  updatePaths(paths: Partial<AppPathConfig> & { rootDir?: string }) {
    if (paths.rootDir?.trim()) {
      return this.updateLocalDataRoot(paths.rootDir);
    }
    Object.assign(this.config.paths, {
      dataDir: pathOrCurrent(paths.dataDir, this.config.paths.dataDir),
      workspaceDir: pathOrCurrent(
        paths.workspaceDir,
        this.config.paths.workspaceDir,
      ),
      exportDir: pathOrCurrent(paths.exportDir, this.config.paths.exportDir),
    });
    return this.config.paths;
  }
}

function stringOrCurrent(value: string | undefined, current: string) {
  return value?.trim() ? value.trim() : current;
}

function pathOrCurrent(value: string | undefined, current: string) {
  return value?.trim() ? path.resolve(value.trim()) : current;
}

function resolveConfiguredPath(value: string | undefined, fallback: string) {
  const trimmed = value?.trim();
  if (!trimmed) return fallback;
  return path.isAbsolute(trimmed)
    ? path.normalize(trimmed)
    : path.resolve(process.cwd(), trimmed);
}

function textOrCurrent(value: string | undefined, current: string) {
  return value === undefined ? current : value.trim();
}

function numberOrCurrent(value: number | string | undefined, current: number) {
  if (typeof value === "number" && Number.isFinite(value) && value > 0) {
    return Math.trunc(value);
  }
  if (typeof value === "string") {
    const parsed = Number.parseInt(value.trim(), 10);
    if (Number.isFinite(parsed) && parsed > 0) return parsed;
  }
  return current;
}

Injectable()(AppConfigService);
