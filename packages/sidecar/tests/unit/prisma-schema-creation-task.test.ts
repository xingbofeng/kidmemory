import { describe, it } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const schemaPath = path.resolve(__dirname, "..", "..", "prisma", "schema.prisma");
const schema = readFileSync(schemaPath, "utf8");

describe("Prisma schema creation task contract", () => {
  it("uses current creation task schema wording", () => {
    const source = readFileSync(__filename, "utf8");
    const historicalPhrases = [
      ["creation task", "migration"].join(" "),
      ["legacy", "jobs"].join(" "),
    ];

    for (const phrase of historicalPhrases) {
      assert.equal(source.includes(phrase), false);
    }
  });

  it("must have CreationTask model", () => {
    assert.match(schema, /model CreationTask/, "CreationTask model should exist");
  });

  it("must have CreationEvent model", () => {
    assert.match(schema, /model CreationEvent/, "CreationEvent model should exist");
  });

  it("must have CreationArtifact model", () => {
    assert.match(schema, /model CreationArtifact/, "CreationArtifact model should exist");
  });

  it("CreationTask must have task identity fields", () => {
    const modelMatch = schema.match(/model CreationTask \{([^}]+)\}/);
    assert.ok(modelMatch, "CreationTask model block should exist");
    const body = modelMatch[1];
    assert.match(body, /\bid\b/, "CreationTask should have id");
    assert.match(body, /\bcreationType\b/, "CreationTask should have creationType");
    assert.match(body, /\bgoal\b/, "CreationTask should have goal");
    assert.match(body, /\bassetIds\b/, "CreationTask should have assetIds");
    assert.match(body, /\bstatus\b/, "CreationTask should have status");
  });

  it("CreationTask must map to creation_tasks table", () => {
    assert.match(schema, /@@map\("creation_tasks"\)/, "CreationTask should map to creation_tasks");
  });

  it("CreationEvent must have taskId and type", () => {
    const modelMatch = schema.match(/model CreationEvent \{([^}]+)\}/);
    assert.ok(modelMatch, "CreationEvent model block should exist");
    const body = modelMatch[1];
    assert.match(body, /\btaskId\b/, "CreationEvent should have taskId");
    assert.match(body, /\btype\b/, "CreationEvent should have type");
    assert.match(body, /\bmessage\b/, "CreationEvent should have message");
  });

  it("CreationArtifact must have taskId and kind", () => {
    const modelMatch = schema.match(/model CreationArtifact \{([^}]+)\}/);
    assert.ok(modelMatch, "CreationArtifact model block should exist");
    const body = modelMatch[1];
    assert.match(body, /\btaskId\b/, "CreationArtifact should have taskId (not jobId)");
    assert.match(body, /\bkind\b/, "CreationArtifact should have kind");
  });

  it("CreationTask must have relation to CreationEvent and CreationArtifact", () => {
    const modelMatch = schema.match(/model CreationTask \{([^}]+)\}/);
    assert.ok(modelMatch, "CreationTask model block should exist");
    const body = modelMatch[1];
    assert.match(body, /CreationEvent\[\]/, "CreationTask should relate to CreationEvent");
    assert.match(body, /CreationArtifact\[\]/, "CreationTask should relate to CreationArtifact");
  });

  it("ExportArtifact model remains available for exported artifacts", () => {
    assert.match(schema, /model ExportArtifact/, "ExportArtifact should exist");
  });
});
