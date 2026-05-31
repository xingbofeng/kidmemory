import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const workspaceRoot = path.resolve(root, "..", "..");

function read(relPath: string): string {
  return fs.readFileSync(path.join(root, relPath), "utf8");
}

test("generated sidecar components are currently not a DTO schema source", () => {
  const generatedSidecarTypes = fs.readFileSync(
    path.join(workspaceRoot, "packages", "protocol", "generated", "sidecar", "ts", "index.d.ts"),
    "utf8",
  );

  assert.match(generatedSidecarTypes, /export interface components \{/);
  assert.match(generatedSidecarTypes, /schemas: Record<string, unknown>/);
});

test("web companion direct upload dto files keep explicit local API boundaries", () => {
  const dtoFiles = [
    "src/modules/web-companion/dto/create-direct-upload-session.dto.ts",
    "src/modules/web-companion/dto/get-direct-upload-status.dto.ts",
    "src/modules/web-companion/dto/list-direct-upload-objects.dto.ts",
    "src/modules/web-companion/dto/pullback-direct-upload.dto.ts",
  ];

  for (const relPath of dtoFiles) {
    const source = read(relPath);
    assert.doesNotMatch(source, /@kidmemory\/protocol\/generated\/sidecar\/ts/);
    assert.match(source, /export interface \w+(?:Request|Response)\b/);
  }
});

test("agent config dto uses local zod input validation and explicit response shapes", () => {
  const source = read("src/modules/agent-config/presentation/agent-config.dto.ts");

  assert.doesNotMatch(source, /@kidmemory\/protocol\/generated\/sidecar\/ts/);
  assert.match(source, /export const CreateAgentConfigDtoSchema = z\.object/);
  assert.match(source, /export type CreateAgentConfigDto = z\.infer/);
  assert.match(source, /export interface AgentConfigDto\b/);
  assert.match(source, /export interface TestAgentConfigResultDto\b/);
});
