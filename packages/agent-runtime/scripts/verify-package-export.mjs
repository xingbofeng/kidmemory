import assert from "node:assert/strict";
import fs from "node:fs/promises";
import path from "node:path";

const packageRoot = path.resolve(import.meta.dirname, "..");
const distEntry = path.join(packageRoot, "dist", "index.js");
const distTypes = path.join(packageRoot, "dist", "index.d.ts");

await assertFile(distEntry);
await assertFile(distTypes);

const runtime = await import(distEntry);

assert.equal(typeof runtime.AgentRuntime, "function");
assert.equal(typeof runtime.OpenAISandboxExecutor, "function");
assert.equal(typeof runtime.SkillDeckProvider, "function");
assert.equal(typeof runtime.ensureAgentWorkspace, "function");
assert.equal("createHyperFramesRenderTool" in runtime, false);

async function assertFile(filePath) {
  const stat = await fs.stat(filePath);
  assert.equal(stat.isFile(), true, `Expected file: ${filePath}`);
  assert.equal(stat.size > 0, true, `Expected non-empty file: ${filePath}`);
}
