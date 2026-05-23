import { describe, it } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const moduleDir = path.resolve(__dirname, "..", "..", "src", "modules", "agent-runtime");

describe("Agent runtime adapter module contracts", () => {
  it("must export RuntimeStage type", async () => {
    const mod = await import(path.join(moduleDir, "agent-runtime.contracts.ts"));
    // RuntimeStage is a type; we can check key values via the constants
    assert.equal(typeof mod.REQUIRED_OUTPUT_FILES_BY_STAGE, "object");
  });

  it("REQUIRED_OUTPUT_FILES_BY_STAGE must define plan stage", async () => {
    const mod = await import(path.join(moduleDir, "agent-runtime.contracts.ts"));
    assert.ok("plan" in mod.REQUIRED_OUTPUT_FILES_BY_STAGE);
    assert.deepEqual(mod.REQUIRED_OUTPUT_FILES_BY_STAGE.plan, ["output/plan.json"]);
  });

  it("REQUIRED_OUTPUT_FILES_BY_STAGE must define generate_book stage", async () => {
    const mod = await import(path.join(moduleDir, "agent-runtime.contracts.ts"));
    assert.ok("generate_book" in mod.REQUIRED_OUTPUT_FILES_BY_STAGE);
    assert.deepEqual(
      mod.REQUIRED_OUTPUT_FILES_BY_STAGE.generate_book,
      ["output/book.json", "output/book.html"]
    );
  });

  it("REQUIRED_OUTPUT_FILES_BY_STAGE must define generate_video stage", async () => {
    const mod = await import(path.join(moduleDir, "agent-runtime.contracts.ts"));
    assert.ok("generate_video" in mod.REQUIRED_OUTPUT_FILES_BY_STAGE);
    assert.deepEqual(mod.REQUIRED_OUTPUT_FILES_BY_STAGE.generate_video, ["output/video.mp4"]);
  });

  it("stage timeout constants must be defined", async () => {
    const mod = await import(path.join(moduleDir, "agent-runtime.contracts.ts"));
    assert.equal(typeof mod.STAGE_TIMEOUT_PLAN_MS, "number");
    assert.equal(typeof mod.STAGE_TIMEOUT_GENERATE_BOOK_MS, "number");
    assert.equal(typeof mod.STAGE_TIMEOUT_GENERATE_VIDEO_MS, "number");
  });

  it("runtime event type prefixes must map correctly", async () => {
    const mod = await import(path.join(moduleDir, "agent-runtime.contracts.ts"));
    // Event type mapping from agent-runtime events to creation events
    const eventMap = mod.RUNTIME_EVENT_TO_CREATION_EVENT_TYPE;
    assert.equal(eventMap["agent.run.started"], "plan");
    assert.equal(eventMap["agent.run.finished"], "task");
  });

  it("timeout handling must return a stage failure result instead of throwing through service", () => {
    const source = readFileSync(path.join(moduleDir, "agent-runtime.service.ts"), "utf8");
    assert.equal(
      source.includes("AbortSignal.timeout"),
      false,
      "timeout signal must be wired into runtime execution or removed"
    );
    assert.equal(
      /Promise\s*<\s*never\s*>/.test(source),
      false,
      "timeout helper must return RunCreationStageResult-compatible failure data"
    );
    assert.match(
      source,
      /STAGE_TIMEOUT/,
      "timeout failure should preserve STAGE_TIMEOUT code"
    );
  });

  it("uses the agent executor for OpenAI-compatible custom providers", async () => {
    const mod = await import(path.join(moduleDir, "agent-runtime.service.ts"));
    assert.equal(mod.resolveCreationRuntimeExecutorKind({ provider: "custom", baseUrl: "https://api.deepseek.com" }), "agent");
    assert.equal(mod.resolveCreationRuntimeExecutorKind({ provider: "openai", baseUrl: undefined }), "sandbox");
  });

  it("does not force the Responses API for custom OpenAI-compatible providers", async () => {
    const mod = await import(path.join(moduleDir, "agent-runtime.service.ts"));
    assert.equal(mod.resolveCreationRuntimeUseResponses({ provider: "custom", baseUrl: "https://api.deepseek.com" }), false);
    assert.equal(mod.resolveCreationRuntimeUseResponses({ provider: "openai", baseUrl: undefined }), true);
  });
});
