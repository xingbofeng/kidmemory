import assert from "node:assert/strict";
import { test } from "node:test";

import { checkClaudeReadiness, checkOpenAIReadiness, checkPgVector, checkPostgres } from "../../src/modules/config/providers/readiness.ts";

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
    message: "Prisma embedding schema is reachable",
  });
});

test("pgvector check fails when embedding schema is not reachable", async () => {
  const status = await checkPgVector({
    $connect: async () => undefined,
    assetEmbedding: { findFirst: async () => { throw new Error("relation asset_embeddings does not exist"); } },
  });

  assert.equal(status.ok, false);
  assert.equal(status.service, "pgvector");
  assert.match(status.message, /pgvector check failed/);
  assert.match(status.action, /Prisma migrations/);
});

test("pgvector check can report PostgreSQL connection failures as actionable readiness errors", async () => {
  const status = await checkPgVector(async () => {
    throw new Error("connect ECONNREFUSED 127.0.0.1:5432");
  });

  assert.equal(status.ok, false);
  assert.equal(status.service, "pgvector");
  assert.match(status.message, /PostgreSQL connection failed/);
  assert.match(status.action, /PostgreSQL/);
});

test("OpenAI readiness is official OpenAI only and optional for generation", async () => {
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

  const unsupported = await checkOpenAIReadiness({
    provider: "openai",
    baseUrl: "https://example.com/v1",
    apiKey: "sk-test",
    model: "gpt-4o-mini",
  });
  assert.equal(unsupported.ok, false);
  assert.match(unsupported.message, /official OpenAI/);
});

test("Claude readiness reports missing key as actionable", async () => {
  const status = await checkClaudeReadiness({ apiKey: "", model: "claude-3-5-sonnet-20241022" });

  assert.equal(status.ok, false);
  assert.match(status.action, /CLAUDE_API_KEY/);
});
