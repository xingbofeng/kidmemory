import assert from "node:assert/strict";
import fs from "node:fs/promises";
import path from "node:path";
import test from "node:test";

test("package docs include the architecture plan and diagram", async () => {
  const docsPath = path.resolve(import.meta.dirname, "..", "..", "docs", "architecture.md");
  const content = await fs.readFile(docsPath, "utf8");

  assert.match(content, /^# KidMemory Agent Runtime 架构方案/m);
  assert.match(content, /```mermaid/);
  assert.match(content, /AgentRuntime/);
  assert.match(content, /OpenAI SandboxAgent/);
  assert.match(content, /OpenAIAgentExecutor/);
  assert.match(content, /executors\/sandbox/);
  assert.match(content, /executors\/agent/);
  assert.match(content, /tools\/filesystem/);
  assert.match(content, /skill-deck/);
  assert.match(content, /HyperFrames/);
  assert.match(content, /examples\/storybook/);
  assert.match(content, /examples\/video/);
});

test("storybook demo skill requires executor-neutral artifact writes", async () => {
  const skillPath = path.resolve(
    import.meta.dirname,
    "..",
    "..",
    "examples",
    "storybook",
    ".kidmemory",
    "skills",
    "storybook-demo-writer",
    "SKILL.md",
  );
  const content = await fs.readFile(skillPath, "utf8");

  assert.match(content, /file tools or sandbox filesystem\/shell/i);
  assert.match(content, /strict valid JSON/i);
  assert.match(content, /Exactly 4 items/i);
  assert.match(content, /must write/i);
  assert.match(content, /output\/book\.json/);
  assert.match(content, /output\/book\.html/);
});
