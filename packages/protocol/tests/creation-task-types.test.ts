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

describe("Protocol creation types migration to task-first", () => {
  const creationSource = readFileSync(creationSourcePath, "utf8");
  const indexSource = readFileSync(indexSourcePath, "utf8");

  it("must remove old CreationPlan type", () => {
    assert.equal(
      /export\s+(type\s+)?interface\s+CreationPlan\b/.test(creationSource),
      false,
      "CreationPlan interface should be removed"
    );
  });

  it("must remove old CreationJob type", () => {
    assert.equal(
      /export\s+(type\s+)?interface\s+CreationJob\b/.test(creationSource),
      false,
      "CreationJob interface should be removed"
    );
  });

  it("must remove old CreationPlanStatus type", () => {
    assert.equal(
      /\bCreationPlanStatus\b/.test(creationSource),
      false,
      "CreationPlanStatus should be removed"
    );
  });

  it("must remove old CreationJobStatus type", () => {
    assert.equal(
      /\bCreationJobStatus\b/.test(creationSource),
      false,
      "CreationJobStatus should be removed"
    );
  });

  it("must add new CreationTaskStatus type", () => {
    assert.match(
      creationSource,
      /export\s+type\s+CreationTaskStatus\s*=/,
      "CreationTaskStatus should be defined"
    );
  });

  it("must add new CreationTask interface", () => {
    assert.match(
      creationSource,
      /export\s+(type\s+)?interface\s+CreationTask\b/,
      "CreationTask should be defined"
    );
  });

  it("CreationTask must have taskId field", () => {
    const taskMatch = creationSource.match(/interface\s+CreationTask\s*\{([^}]+)\}/);
    if (taskMatch) {
      assert.match(taskMatch[1], /\btaskId\b/, "CreationTask should have taskId field");
    }
  });

  it("CreationArtifact must use taskId instead of jobId", () => {
    const artifactSource = readFileSync(creationSourcePath, "utf8");
    assert.equal(
      /\bjobId\b/.test(artifactSource.match(/interface\s+CreationArtifact\s*\{([^}]+)\}/)?.[1] ?? ""),
      false,
      "CreationArtifact should not reference jobId"
    );
    assert.match(
      artifactSource.match(/interface\s+CreationArtifact\s*\{([^}]+)\}/)?.[1] ?? "",
      /\btaskId\b/,
      "CreationArtifact should reference taskId"
    );
  });

  it("CreationArtifact kind must include generated book outputs", () => {
    const artifactBody = creationSource.match(/interface\s+CreationArtifact\s*\{([^}]+)\}/)?.[1] ?? "";
    assert.match(artifactBody, /"book_json"/, "CreationArtifact should include generated book JSON artifacts");
    assert.match(artifactBody, /"book_html"/, "CreationArtifact should include generated book HTML artifacts");
  });

  it("CreationEvent must use taskId instead of jobId", () => {
    const eventBody = creationSource.match(/interface\s+CreationEvent\s*\{([^}]+)\}/)?.[1] ?? "";
    assert.equal(
      /\bjobId\b/.test(eventBody),
      false,
      "CreationEvent should not reference jobId"
    );
    assert.match(
      eventBody,
      /\btaskId\b/,
      "CreationEvent should reference taskId"
    );
  });

  it("CreationEvent type must include 'task' event type", () => {
    assert.match(
      creationSource,
      /"task"/,
      "CreationEvent type should include 'task'"
    );
  });

  it("index.ts must not export old plan/job types", () => {
    assert.equal(
      /\bCreationPlan\b/.test(indexSource),
      false,
      "index.ts should not export CreationPlan (CreationPlanRequirements is allowed)"
    );
    assert.equal(
      /\bCreationJob\b/.test(indexSource),
      false,
      "index.ts should not export CreationJob"
    );
  });

  it("index.ts must export new task types", () => {
    assert.match(
      indexSource,
      /CreationTask/,
      "index.ts should export CreationTask"
    );
    assert.match(
      indexSource,
      /CreationTaskStatus/,
      "index.ts should export CreationTaskStatus"
    );
  });

  it("generated sidecar contracts must expose task routes instead of old creation job routes", () => {
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
