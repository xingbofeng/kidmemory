import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";
import { test } from "node:test";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const protocolRoot = path.resolve(__dirname, "..");
const protoRoot = path.join(protocolRoot, "proto", "kidmemory", "v1");

const requiredProtoFiles = [
  "common.proto",
  "device.proto",
  "job.proto",
  "upload.proto",
  "share.proto",
  "artifact.proto",
];

test("proto definitions exist for all required domains", () => {
  for (const file of requiredProtoFiles) {
    const fullPath = path.join(protoRoot, file);
    assert.equal(existsSync(fullPath), true, `${file} should exist`);
  }
});

test("proto definitions use proto3 and kidmemory.v1 package", () => {
  for (const file of requiredProtoFiles) {
    const fullPath = path.join(protoRoot, file);
    const source = readFileSync(fullPath, "utf8");
    assert.match(source, /^\s*syntax\s*=\s*"proto3";/m, `${file} should declare proto3`);
    assert.match(source, /^\s*package\s+kidmemory\.v1\s*;/m, `${file} should declare package kidmemory.v1`);
  }
});

test("proto definitions are message-only and do not define grpc services", () => {
  for (const file of requiredProtoFiles) {
    const fullPath = path.join(protoRoot, file);
    const source = readFileSync(fullPath, "utf8");
    assert.equal(/\bservice\s+\w+/.test(source), false, `${file} must not define service blocks`);
  }
});

test("proto lint command is available and passes", () => {
  const result = spawnSync("npm", ["run", "proto:lint"], {
    cwd: protocolRoot,
    encoding: "utf8",
  });

  assert.equal(result.status, 0, `proto:lint should pass.\nstdout:\n${result.stdout}\nstderr:\n${result.stderr}`);
});
