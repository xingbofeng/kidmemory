import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";

import { buildAgentWorkspace } from "../../../../src/modules/books/providers/workspace.ts";

test("builds isolated workspace without copying env or credentials", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-workspace-"));
  const workspace = await buildAgentWorkspace({
    workspaceRoot: root,
    jobId: "job_001",
    child: { id: "sample-child-001", name: "澄澄" },
    assets: [{ id: "asset-sun-house", title: "太阳下的小房子", type: "artwork", imagePath: "assets/sun.svg" }],
    secrets: {
      POSTGRES_PASSWORD: "db-secret",
      OPENAI_API_KEY: "sk-openai-secret",
      CLAUDE_API_KEY: "sk-ant-secret",
    },
  });

  const files = await collectFiles(workspace.path);
  assert.deepEqual(files.sort(), [
    "input/assets.json",
    "input/child.json",
    "input/images/.gitkeep",
    "output/.gitkeep",
    "rules/output-schema.json",
    "rules/safety.md",
    "rules/writing-style.md",
    "templates/style.css",
    "templates/warm-artwork-book.html",
  ]);

  const serialized = await Promise.all(files.map((file) => fs.readFile(path.join(workspace.path, file), "utf8")));
  const joined = serialized.join("\n");
  assert.equal(joined.includes("db-secret"), false);
  assert.equal(joined.includes("sk-openai-secret"), false);
  assert.equal(joined.includes("sk-ant-secret"), false);
});

test("copies available asset images into isolated workspace input/images and rewrites paths", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-workspace-images-"));
  const sourceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-source-images-"));
  const imagePath = path.join(sourceDir, "sun-house.svg");
  await fs.writeFile(imagePath, "<svg></svg>");

  const workspace = await buildAgentWorkspace({
    workspaceRoot: root,
    jobId: "job_images",
    child: { id: "sample-child-001", name: "澄澄" },
    assets: [{ id: "asset-sun-house", title: "太阳下的小房子", type: "artwork", imagePath }],
  });

  const copiedImage = path.join(workspace.path, "input/images/asset-sun-house.svg");
  const assetsJson = JSON.parse(await fs.readFile(path.join(workspace.path, "input/assets.json"), "utf8"));

  assert.equal(await fs.readFile(copiedImage, "utf8"), "<svg></svg>");
  assert.equal(assetsJson.assets[0].imagePath, "input/images/asset-sun-house.svg");
});

async function collectFiles(dir: string, base = dir): Promise<string[]> {
  const entries = await fs.readdir(dir, { withFileTypes: true });
  const files: string[] = [];
  for (const entry of entries) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) files.push(...await collectFiles(full, base));
    else files.push(path.relative(base, full));
  }
  return files;
}
