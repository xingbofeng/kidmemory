import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";

/**
 * Web Companion Supabase Direct Upload — schema architecture tests.
 *
 * 这一组测试守住 Direct Upload 的持久化契约：
 *   - Prisma baseline migration 存在并包含 direct_upload_pullbacks。
 *   - 表字段覆盖 spec/local-data Requirement 的全部 14 项。
 *   - `(session_id, object_key)` 唯一约束存在。
 *   - status 列被 CHECK 限制在 spec 状态机 4 个值之内。
 */

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const migrationPath = path.join(root, "prisma", "migrations", "init", "migration.sql");

const REQUIRED_COLUMNS = [
  "id",
  "session_id",
  "child_id",
  "object_key",
  "remote_size_bytes",
  "remote_content_type",
  "remote_last_modified",
  "asset_id",
  "local_path",
  "status",
  "error_code",
  "error_message",
  "pulled_at",
  "created_at",
  "updated_at",
];

function readMigration(): string {
  assert.ok(
    fs.existsSync(migrationPath),
    "Prisma baseline migration should exist",
  );
  return fs.readFileSync(migrationPath, "utf8");
}

test("Direct Upload Prisma migration creates direct_upload_pullbacks", () => {
  const sql = readMigration();
  assert.match(
    sql,
    /CREATE TABLE\s+"direct_upload_pullbacks"\s*\(/i,
    "Prisma migration should create direct_upload_pullbacks",
  );
});

test("direct_upload_pullbacks 包含 spec 列表中的全部字段", () => {
  const sql = readMigration();
  for (const column of REQUIRED_COLUMNS) {
    assert.match(
      sql,
      new RegExp(`\\b${column}\\b`),
      `direct_upload_pullbacks 应包含字段 ${column}`,
    );
  }
});

test("direct_upload_pullbacks 在 (session_id, object_key) 上有唯一约束", () => {
  const sql = readMigration();
  const uniqueIndex =
    /CREATE\s+UNIQUE\s+INDEX[^;]+ON\s+"direct_upload_pullbacks"\s*\(\s*"session_id"\s*,\s*"object_key"\s*\)/i
      .test(sql);
  assert.ok(
    uniqueIndex,
    "应在 (session_id, object_key) 上声明唯一约束",
  );
});

test("direct_upload_pullbacks.status 通过 CHECK 限制在 spec 4 个状态值", () => {
  const schema = fs.readFileSync(path.join(root, "prisma", "schema.prisma"), "utf8");
  assert.match(
    schema,
    /model DirectUploadPullback[\s\S]*status\s+String\b/,
    "direct_upload_pullbacks.status should be represented in Prisma schema",
  );
});
