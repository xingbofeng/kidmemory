import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "@prisma/client";

type PrismaReadyClient = {
  $connect(): Promise<void>;
  $disconnect?(): Promise<void>;
  $queryRawUnsafe?<T = unknown>(query: string): Promise<T>;
  assetEmbedding?: { findFirst(input?: unknown): Promise<unknown> };
};

export async function checkPostgres(config: { host: string; port: number; database: string; user: string; password?: string; connectionUrl?: string }, client?: PrismaReadyClient) {
  let ownedClient: PrismaReadyClient | undefined;
  try {
    const effectiveConfig = resolvePostgresConfig(config);
    const db = client || (ownedClient = createPrismaClient(effectiveConfig));
    await db.$connect();
    return { ok: true, service: "postgres", message: "PostgreSQL 连接可用" };
  } catch (error) {
    return {
      ok: false,
      service: "postgres",
      message: `PostgreSQL connection failed: ${sanitizeError(error)}`,
      action: "Check POSTGRES_HOST, POSTGRES_PORT, POSTGRES_DATABASE, POSTGRES_USER and POSTGRES_PASSWORD in .env, then retry.",
    };
  } finally {
    await ownedClient?.$disconnect?.();
  }
}

export async function checkPgVector(
  clientOrFactory:
    | PrismaReadyClient
    | (() => Promise<PrismaReadyClient>)
    | { host: string; port: number; database: string; user: string; password?: string; connectionUrl?: string },
) {
  let ownedClient: PrismaReadyClient | undefined;
  try {
    const client =
      typeof clientOrFactory === "function"
        ? await clientOrFactory()
        : "host" in clientOrFactory
          ? (ownedClient = createPrismaClient(resolvePostgresConfig(clientOrFactory)))
          : clientOrFactory;
    await client.$connect();
    if (client.$queryRawUnsafe) {
      const rows = await client.$queryRawUnsafe<Array<{ extname: string }>>(
        "SELECT extname FROM pg_extension WHERE extname = 'vector' LIMIT 1;",
      );
      if (!Array.isArray(rows) || rows.length == 0) {
        return {
          ok: false,
          service: "pgvector",
          message: "pgvector 扩展未启用（未找到 vector 扩展）。",
          action: "Run CREATE EXTENSION vector; and retry pgvector readiness.",
        };
      }
    } else {
      await client.assetEmbedding?.findFirst({ select: { assetId: true }, take: 1 });
    }
    return { ok: true, service: "pgvector", message: "Prisma 向量 schema 可用" };
  } catch (error) {
    const message = sanitizeError(error);
    const isConnectionFailure = /connect|ECONNREFUSED|authentication|database|ENOTFOUND/i.test(message);
    return {
      ok: false,
      service: "pgvector",
      message: isConnectionFailure ? `pgvector 检测前 PostgreSQL 连接失败：${message}` : `pgvector 检测失败：${message}`,
      action: isConnectionFailure
        ? "Check local PostgreSQL configuration and connectivity, then retry pgvector readiness."
        : "Run Prisma migrations and ensure the database supports the configured embedding schema.",
    };
  } finally {
    await ownedClient?.$disconnect?.();
  }
}

export async function checkOpenAIReadiness(config: { provider: "openai"; baseUrl: string; apiKey: string; model: string }, fetcher: typeof fetch = fetch) {
  if (!config.baseUrl.trim() || !config.model.trim() || !config.apiKey.trim()) {
    return { ok: false, service: "openai", blocksGeneration: false, message: "大模型接口未配置。", action: "请先在设置页配置 Base URL、Model 和 API Key，开启可选的模型可用性检测。" };
  }
  try {
    const probeUrls = buildOpenAIProbeUrls(config.baseUrl, config.model);
    let lastFailure: { status: number; body: string; url: string } | null = null;
    for (const url of probeUrls) {
      const response = await fetcher(url, {
        headers: { Authorization: `Bearer ${config.apiKey}` },
      });
      if (response.ok) {
        return {
          ok: true,
          service: "openai",
          blocksGeneration: false,
          message: "OpenAI readiness check passed",
        };
      }
      const body = await safeReadBody(response);
      lastFailure = { status: response.status, body, url };
    }
    const bodyHint = lastFailure?.body ? ` (${lastFailure.body})` : "";
    return {
      ok: false,
      service: "openai",
      blocksGeneration: false,
      message: `OpenAI readiness check returned HTTP ${lastFailure?.status ?? 0}${bodyHint}`,
      action: "Check the configured Base URL, API key and model, then retry.",
    };
  } catch (error) {
    return { ok: false, service: "openai", blocksGeneration: false, message: `OpenAI readiness check failed: ${sanitizeError(error)}`, action: "Check network access and the configured OpenAI-compatible credentials, then retry." };
  }
}

export async function checkClaudeReadiness(config: { apiKey: string; model: string; baseUrl?: string }, fetcher: typeof fetch = fetch) {
  if (!config.apiKey) {
    return { ok: false, service: "claude", message: "Claude API key is not configured.", action: "Set CLAUDE_API_KEY in .env before running the real Agent runner." };
  }
  try {
    const response = await fetcher(`${config.baseUrl || "https://api.anthropic.com"}/v1/models`, {
      headers: { "x-api-key": config.apiKey, "anthropic-version": "2023-06-01" },
    });
    return {
      ok: response.ok,
      service: "claude",
      message: response.ok ? "Claude readiness check passed" : `Claude readiness check returned HTTP ${response.status}`,
      action: response.ok ? undefined : "Check CLAUDE_API_KEY and CLAUDE_MODEL, then retry.",
    };
  } catch (error) {
    return { ok: false, service: "claude", message: `Claude readiness check failed: ${sanitizeError(error)}`, action: "Check network access and Claude credentials, then retry." };
  }
}

function createPrismaClient(config: { host: string; port: number; database: string; user: string; password?: string; connectionUrl?: string }) {
  return new PrismaClient({
    adapter: new PrismaPg({
      connectionString: postgresConnectionUrl(config),
    }),
  });
}

function resolvePostgresConfig(config: {
  host: string;
  port: number;
  database: string;
  user: string;
  password?: string;
  connectionUrl?: string;
}) {
  return {
    host: config.host,
    port: config.port,
    database: config.database,
    user: config.user,
    password: config.password,
    connectionUrl: config.connectionUrl,
  };
}

function postgresConnectionUrl(config: { host: string; port: number; database: string; user: string; password?: string; connectionUrl?: string }) {
  if (config.connectionUrl) return config.connectionUrl;
  const credentials = config.password
    ? `${encodeURIComponent(config.user)}:${encodeURIComponent(config.password)}`
    : encodeURIComponent(config.user);
  return `postgresql://${credentials}@${config.host}:${config.port}/${config.database}`;
}

function normalizeUrl(url: string) {
  return url.replace(/\/+$/, "");
}

function buildOpenAIProbeUrls(baseUrl: string, model: string) {
  const normalized = normalizeUrl(baseUrl);
  const candidateBases = new Set<string>([
    normalized,
    normalized.replace(/\/(chat\/completions|responses)$/i, ""),
  ]);
  const urls: string[] = [];
  for (const base of candidateBases) {
    if (!base) continue;
    urls.push(`${base}/models/${encodeURIComponent(model)}`);
    urls.push(`${base}/models`);
  }
  return Array.from(new Set(urls));
}

async function safeReadBody(response: Response) {
  try {
    const body = await response.text();
    if (!body) return "";
    return sanitizeError(body).slice(0, 180);
  } catch {
    return "";
  }
}

function sanitizeError(error: unknown) {
  return error instanceof Error ? error.message.replace(/sk-[A-Za-z0-9_-]+/g, "[redacted]").replace(/password=[^ ]+/gi, "password=[redacted]") : "unknown error";
}
