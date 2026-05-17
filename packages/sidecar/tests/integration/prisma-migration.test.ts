import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { createRequire } from "node:module";
import path from "node:path";
import { test } from "node:test";

const backendRoot = new URL("../..", import.meta.url);
const require = createRequire(import.meta.url);
const prismaCliPath = path.join(path.dirname(require.resolve("prisma/package.json")), "build", "index.js");

function runPrisma(args: string[]) {
  return spawnSync(process.execPath, [prismaCliPath, ...args], {
    cwd: backendRoot,
    env: process.env,
    encoding: "utf8",
  });
}

test("prisma schema validates", () => {
  const result = runPrisma(["validate"]);

  assert.equal(result.status, 0, result.stderr || result.stdout);
});

test("prisma migrations apply to the configured database", { skip: process.env.DATABASE_URL ? false : "DATABASE_URL is not configured" }, () => {
  const result = runPrisma(["migrate", "deploy"]);

  assert.equal(result.status, 0, result.stderr || result.stdout);
});
