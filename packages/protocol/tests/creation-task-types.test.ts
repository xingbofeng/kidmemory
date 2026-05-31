import { describe, it } from "node:test";
import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const creationSourcePath = path.resolve(__dirname, "..", "src", "common", "creation.ts");
const indexSourcePath = path.resolve(__dirname, "..", "src", "index.ts");
const sidecarOpenApiPath = path.resolve(__dirname, "..", "openapi", "sidecar.openapi.json");
const sidecarGeneratedTypesPath = path.resolve(__dirname, "..", "generated", "sidecar", "ts", "index.d.ts");
const sidecarGeneratedDartApiPath = path.resolve(__dirname, "..", "generated", "sidecar", "dart", "lib", "src", "api", "creation_api.dart");
const sidecarGeneratedDartApiTestPath = path.resolve(__dirname, "..", "generated", "sidecar", "dart", "test", "creation_api_test.dart");

describe("Protocol creation task contracts", () => {
  const creationSource = readFileSync(creationSourcePath, "utf8");
  const indexSource = readFileSync(indexSourcePath, "utf8");

  function interfaceBody(name: string): string {
    return creationSource.match(new RegExp(`interface\\s+${name}\\s*\\{([^}]+)\\}`))?.[1] ?? "";
  }

  it("defines task-first creation types only", () => {
    for (const pattern of [
      /export\s+(type\s+)?interface\s+CreationPlan\b/,
      /export\s+(type\s+)?interface\s+CreationJob\b/,
      /\bCreationPlanStatus\b/,
      /\bCreationJobStatus\b/,
    ]) {
      assert.equal(pattern.test(creationSource), false);
    }

    for (const pattern of [
      /export\s+type\s+CreationTaskStatus\s*=/,
      /export\s+(type\s+)?interface\s+CreationTask\b/,
    ]) {
      assert.match(creationSource, pattern);
    }
  });

  it("CreationTask has taskId field", () => {
    assert.match(interfaceBody("CreationTask"), /\btaskId\b/, "CreationTask should have taskId field");
  });

  it("CreationArtifact must use taskId instead of jobId", () => {
    const artifactBody = interfaceBody("CreationArtifact");
    assert.equal(/\bjobId\b/.test(artifactBody), false, "CreationArtifact should not reference jobId");
    assert.match(artifactBody, /\btaskId\b/, "CreationArtifact should reference taskId");
  });

  it("CreationArtifact kind must include generated book outputs", () => {
    const artifactBody = interfaceBody("CreationArtifact");
    assert.match(artifactBody, /"book_json"/, "CreationArtifact should include generated book JSON artifacts");
    assert.match(artifactBody, /"book_html"/, "CreationArtifact should include generated book HTML artifacts");
  });

  it("CreationEvent must use taskId instead of jobId", () => {
    const eventBody = interfaceBody("CreationEvent");
    assert.equal(/\bjobId\b/.test(eventBody), false, "CreationEvent should not reference jobId");
    assert.match(eventBody, /\btaskId\b/, "CreationEvent should reference taskId");
  });

  it("CreationEvent type must include 'task' event type", () => {
    assert.match(
      creationSource,
      /"task"/,
      "CreationEvent type should include 'task'"
    );
  });

  it("index.ts exports task types only", () => {
    assert.equal(/\bCreationPlan\b/.test(indexSource), false, "index.ts should not export CreationPlan");
    assert.equal(/\bCreationJob\b/.test(indexSource), false, "index.ts should not export CreationJob");
    assert.match(indexSource, /CreationTask/, "index.ts should export CreationTask");
    assert.match(indexSource, /CreationTaskStatus/, "index.ts should export CreationTaskStatus");
  });

  it("generated sidecar contracts expose task routes without creation job routes", () => {
    const sidecarOpenApi = readFileSync(sidecarOpenApiPath, "utf8");
    const sidecarGeneratedTypes = readFileSync(sidecarGeneratedTypesPath, "utf8");
    const sidecarGeneratedDartApi = readFileSync(sidecarGeneratedDartApiPath, "utf8");
    const sidecarGeneratedDartApiTest = existsSync(sidecarGeneratedDartApiTestPath)
      ? readFileSync(sidecarGeneratedDartApiTestPath, "utf8")
      : "";

    for (const source of [sidecarOpenApi, sidecarGeneratedTypes, sidecarGeneratedDartApi, sidecarGeneratedDartApiTest].filter(Boolean)) {
      assert.equal(source.includes("/creation/jobs"), false, "generated contracts should not expose /creation/jobs");
      assert.equal(source.includes("{jobId}"), false, "generated contracts should not expose creation jobId path params");
      assert.match(source, /taskId/, "generated contracts should expose taskId");
    }
    for (const source of [sidecarOpenApi, sidecarGeneratedTypes, sidecarGeneratedDartApi]) {
      assert.match(source, /\/creation\/tasks/, "generated contracts should expose /creation/tasks");
    }
  });
});
