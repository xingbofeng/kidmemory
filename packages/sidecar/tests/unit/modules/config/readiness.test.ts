import assert from "node:assert/strict";
import { test } from "node:test";

import { checkClaudeReadiness, checkOpenAIReadiness, checkPgVector, checkPostgres } from "../../../../src/modules/config/providers/readiness.ts";

test("returns actionable PostgreSQL errors without leaking credentials", async () => {
  const status = await checkPostgres(
    { host: "localhost", port: 5432, database: "kidmemory", user: "postgres", password: "secret" },
    { $connect: async () => { throw new Error("password authentication failed for user postgres password=secret"); } },
  );

  assert.equal(status.ok, false);
  assert.match(status.message, /PostgreSQL/);
  assert.match(status.action, /check/i);
  assert.equal(JSON.stringify(status).includes("secret"), false);
});

test("checks pgvector extension version", async () => {
  const status = await checkPgVector({
    $connect: async () => undefined,
    assetEmbedding: { findFirst: async () => null },
  });

  assert.deepEqual(status, {
    ok: true,
    service: "pgvector",
    message: "Prisma 向量 schema 可用",
  });
});

test("pgvector check fails when embedding schema is not reachable", async () => {
  const status = await checkPgVector({
    $connect: async () => undefined,
    assetEmbedding: { findFirst: async () => { throw new Error("relation asset_embeddings does not exist"); } },
  });

  assert.equal(status.ok, false);
  assert.equal(status.service, "pgvector");
  assert.match(status.message, /pgvector 检测失败/);
  assert.match(status.action, /Prisma migrations/);
});

test("pgvector check can report PostgreSQL connection failures as actionable readiness errors", async () => {
  const status = await checkPgVector(async () => {
    throw new Error("connect ECONNREFUSED 127.0.0.1:5432");
  });

  assert.equal(status.ok, false);
  assert.equal(status.service, "pgvector");
  assert.match(status.message, /PostgreSQL.*连接失败|连接失败.*PostgreSQL|pgvector 检测前 PostgreSQL 连接失败/);
  assert.match(status.action, /PostgreSQL/);
});

test("OpenAI readiness checks 通过模型接口做可达性检测", async () => {
  const calls: string[] = [];
  const status = await checkOpenAIReadiness(
    { provider: "openai", baseUrl: "https://api.openai.com/v1", apiKey: "sk-test", model: "gpt-4o-mini" },
    async (url) => {
      calls.push(String(url));
      return { ok: true, status: 200 } as Response;
    },
  );

  assert.equal(status.ok, true);
  assert.equal(status.blocksGeneration, false);
  assert.equal(calls[0], "https://api.openai.com/v1/models/gpt-4o-mini");

  const compatible = await checkOpenAIReadiness({
    provider: "openai",
    baseUrl: "https://example.com/v1",
    apiKey: "sk-test",
    model: "gpt-4o-mini",
  }, async (url) => {
    calls.push(String(url));
    return { ok: false, status: 503 } as Response;
  });
  assert.equal(compatible.ok, false);
  assert.match(compatible.message, /OpenAI readiness check returned HTTP 503/);
  assert.equal(calls.length, 3);
  assert.equal(calls[1], "https://example.com/v1/models/gpt-4o-mini");
  assert.equal(calls[2], "https://example.com/v1/models");
});

test("OpenAI readiness normalizes baseUrl when users paste chat completion endpoint", async () => {
  const calls: string[] = [];
  const status = await checkOpenAIReadiness(
    { provider: "openai", baseUrl: "https://api.openai.com/v1/chat/completions", apiKey: "sk-test", model: "gpt-4o-mini" },
    async (url) => {
      calls.push(String(url));
      if (String(url) === "https://api.openai.com/v1/models/gpt-4o-mini") {
        return { ok: true, status: 200 } as Response;
      }
      return { ok: false, status: 400 } as Response;
    },
  );

  assert.equal(status.ok, true);
  assert.equal(calls[0], "https://api.openai.com/v1/chat/completions/models/gpt-4o-mini");
  assert.equal(calls[1], "https://api.openai.com/v1/chat/completions/models");
  assert.equal(calls[2], "https://api.openai.com/v1/models/gpt-4o-mini");
});

test("Claude readiness reports missing key as actionable", async () => {
  const status = await checkClaudeReadiness({ apiKey: "", model: "claude-3-5-sonnet-20241022" });

  assert.equal(status.ok, false);
  assert.match(status.action, /CLAUDE_API_KEY/);
});
