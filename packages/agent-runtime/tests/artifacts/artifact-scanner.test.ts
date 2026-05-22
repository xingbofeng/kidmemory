import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { ArtifactScanner } from "../../src/index.ts";

test("ArtifactScanner only scans output and ignores input, work, and .kidmemory", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-artifacts-"));
  await fs.mkdir(path.join(workspaceDir, "input"), { recursive: true });
  await fs.mkdir(path.join(workspaceDir, "work"), { recursive: true });
  await fs.mkdir(path.join(workspaceDir, ".kidmemory", "sessions"), { recursive: true });
  await fs.mkdir(path.join(workspaceDir, "output"), { recursive: true });
  await fs.writeFile(path.join(workspaceDir, "input", "source.json"), "{}");
  await fs.writeFile(path.join(workspaceDir, "work", "draft.html"), "<p>draft</p>");
  await fs.writeFile(path.join(workspaceDir, ".kidmemory", "sessions", "session.jsonl"), "{}");
  await fs.writeFile(path.join(workspaceDir, "output", ".gitkeep"), "");
  await fs.writeFile(path.join(workspaceDir, "output", "book.json"), "{}");
  await fs.writeFile(path.join(workspaceDir, "output", "book.html"), "<p>book</p>");

  const result = await new ArtifactScanner().scan({ workspaceDir });

  assert.deepEqual(result.artifacts.map((artifact) => artifact.localPath).sort(), [
    "output/book.html",
    "output/book.json",
  ]);
});

test("ArtifactScanner supports directory artifacts and schema refs", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-artifact-schema-"));
  await fs.mkdir(path.join(workspaceDir, "output", "frames"), { recursive: true });
  await fs.writeFile(path.join(workspaceDir, "output", "book.json"), "{}");
  await fs.writeFile(path.join(workspaceDir, "output", "frames", "frame-001.png"), "png");

  const result = await new ArtifactScanner().scan({
    workspaceDir,
    schemaRefs: {
      "output/book.json": "kidmemory://schemas/storybook-draft/v1",
      "output/frames": "kidmemory://schemas/frame-directory/v1",
    },
  });

  const book = result.artifacts.find((artifact) => artifact.localPath === "output/book.json");
  const frames = result.artifacts.find((artifact) => artifact.localPath === "output/frames");

  assert.equal(book?.schemaRef, "kidmemory://schemas/storybook-draft/v1");
  assert.equal(frames?.kind, "directory");
  assert.equal(frames?.schemaRef, "kidmemory://schemas/frame-directory/v1");
  assert.equal(frames?.metadata?.fileCount, 1);
});
