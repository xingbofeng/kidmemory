import assert from "node:assert/strict";
import { test } from "node:test";

import { checkClaudeReadiness, checkPgVector, checkPostgres } from "../../../../src/modules/config/providers/readiness.ts";

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

test("Claude readiness reports missing key as actionable", async () => {
  const status = await checkClaudeReadiness({ apiKey: "", model: "claude-3-5-sonnet-20241022" });

  assert.equal(status.ok, false);
  assert.match(status.action, /CLAUDE_API_KEY/);
});
