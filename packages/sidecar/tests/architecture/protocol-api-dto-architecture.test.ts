import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");

function read(relPath: string): string {
  return fs.readFileSync(path.join(root, relPath), "utf8");
}

test("web-companion dto files use generated protocol types instead of local request/response interfaces", () => {
  const dtoFiles = [
    "src/modules/web-companion/dto/create-direct-upload-session.dto.ts",
    "src/modules/web-companion/dto/get-direct-upload-status.dto.ts",
    "src/modules/web-companion/dto/list-direct-upload-objects.dto.ts",
    "src/modules/web-companion/dto/pullback-direct-upload.dto.ts",
  ];

  for (const relPath of dtoFiles) {
    const source = read(relPath);
    assert.match(source, /@kidmemory\/protocol\/generated\/sidecar\/ts/);
    assert.doesNotMatch(source, /export\s+interface\s+\w+(Request|Response)\b/);
  }
});

test("agent-config presentation dto uses generated protocol types for API responses", () => {
  const source = read("src/modules/agent-config/presentation/agent-config.dto.ts");
  assert.match(source, /@kidmemory\/protocol\/generated\/sidecar\/ts/);
  assert.doesNotMatch(source, /export\s+interface\s+\w+(Request|Response)\b/);
});

test("modules should not define local API Request/Response interfaces or Response DTO structs", () => {
  const modulesRoot = path.join(root, "src/modules");
  const stack: string[] = [modulesRoot];
  const files: string[] = [];
  while (stack.length > 0) {
    const current = stack.pop()!;
    const entries = fs.readdirSync(current, { withFileTypes: true });
    for (const entry of entries) {
      const full = path.join(current, entry.name);
      if (entry.isDirectory()) {
        stack.push(full);
        continue;
      }
      if (entry.isFile() && full.endsWith(".ts")) {
        files.push(full);
      }
    }
  }

  const localApiRequestResponsePattern = /\b(?:export\s+)?interface\s+\w+(Request|Response)\b/;
  const localApiResponseDtoPattern = /\b(?:export\s+)?interface\s+\w+ResponseDto\b/;
  for (const filePath of files) {
    const source = fs.readFileSync(filePath, "utf8");
    assert.doesNotMatch(
      source,
      localApiRequestResponsePattern,
      `${path.relative(root, filePath)} should not define local Request/Response interfaces`,
    );
    assert.doesNotMatch(
      source,
      localApiResponseDtoPattern,
      `${path.relative(root, filePath)} should not define local ResponseDto interfaces`,
    );
  }
});
