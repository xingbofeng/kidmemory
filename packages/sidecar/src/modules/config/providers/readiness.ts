import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "@prisma/client";

type PrismaReadyClient = {
  $connect(): Promise<void>;
  $disconnect?(): Promise<void>;
  child?: { count(): Promise<number> };
  assetEmbedding?: { findFirst(input?: unknown): Promise<unknown> };
};

export async function checkPostgres(config: { host: string; port: number; database: string; user: string; password?: string; connectionUrl?: string }, client?: PrismaReadyClient) {
  let ownedClient: PrismaReadyClient | undefined;
  try {
    const db = client || (ownedClient = createPrismaClient(config));
    await db.$connect();
    await db.child?.count();
    return { ok: true, service: "postgres", message: "PostgreSQL connection is available" };
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

export async function checkPgVector(clientOrFactory: PrismaReadyClient | (() => Promise<PrismaReadyClient>)) {
  try {
    const client = typeof clientOrFactory === "function" ? await clientOrFactory() : clientOrFactory;
    await client.$connect();
    await client.assetEmbedding?.findFirst({ select: { assetId: true }, take: 1 });
    return { ok: true, service: "pgvector", message: "Prisma embedding schema is reachable" };
  } catch (error) {
    const message = sanitizeError(error);
    const isConnectionFailure = /connect|ECONNREFUSED|authentication|database|ENOTFOUND/i.test(message);
    return {
      ok: false,
      service: "pgvector",
      message: isConnectionFailure ? `PostgreSQL connection failed before pgvector check: ${message}` : `pgvector check failed: ${message}`,
      action: isConnectionFailure
        ? "Check local PostgreSQL configuration and connectivity, then retry pgvector readiness."
        : "Run Prisma migrations and ensure the database supports the configured embedding schema.",
    };
  }
}

export async function checkOpenAIReadiness(config: { provider: "openai"; baseUrl: string; apiKey: string; model: string }, fetcher: typeof fetch = fetch) {
  if (!config.baseUrl.trim() || !config.model.trim() || !config.apiKey.trim()) {
    return { ok: false, service: "openai", blocksGeneration: false, message: "OpenAI-compatible API is not configured.", action: "Set OPENAI_BASE_URL, OPENAI_MODEL and OPENAI_API_KEY to enable the optional OpenAI readiness check." };
  }
  if (config.provider !== "openai" || normalizeUrl(config.baseUrl) !== "https://api.openai.com/v1") {
    return { ok: false, service: "openai", blocksGeneration: false, message: "Readiness checks support official OpenAI only.", action: "Set OPENAI_BASE_URL=https://api.openai.com/v1 or leave it unset." };
  }
  try {
    const response = await fetcher(`${normalizeUrl(config.baseUrl)}/models/${encodeURIComponent(config.model)}`, {
      headers: { Authorization: `Bearer ${config.apiKey}` },
    });
    return {
      ok: response.ok,
      service: "openai",
      blocksGeneration: false,
      message: response.ok ? "OpenAI readiness check passed" : `OpenAI readiness check returned HTTP ${response.status}`,
      action: response.ok ? undefined : "Check OPENAI_API_KEY and OPENAI_MODEL, then retry.",
    };
  } catch (error) {
    return { ok: false, service: "openai", blocksGeneration: false, message: `OpenAI readiness check failed: ${sanitizeError(error)}`, action: "Check network access and OpenAI credentials, then retry." };
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

function sanitizeError(error: unknown) {
  return error instanceof Error ? error.message.replace(/sk-[A-Za-z0-9_-]+/g, "[redacted]").replace(/password=[^ ]+/gi, "password=[redacted]") : "unknown error";
}
