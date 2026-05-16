import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { MemoryDatasetDb } from "../../../src/infrastructure/dataset-state/memory-dataset-db.ts";
import { collectImportFiles, importLocalAssets } from "../../../src/modules/dataset/providers/asset-import.ts";

test("collectImportFiles recursively includes nested files", async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-import-scan-"));
  const nested = path.join(dir, "nested");
  await fs.mkdir(nested, { recursive: true });
  await fs.writeFile(path.join(dir, "a.jpg"), "a");
  await fs.writeFile(path.join(nested, "b.png"), "b");

  const files = await collectImportFiles([dir], true);
  assert.equal(files.length, 2);
  assert.equal(files.some((v) => v.endsWith("a.jpg")), true);
  assert.equal(files.some((v) => v.endsWith("b.png")), true);
});

test("imports images, skips unsupported files, and reports duplicates by hash", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-import-"));
  const dataDir = path.join(root, "data");
  const sourceDir = path.join(root, "source");
  await fs.mkdir(sourceDir, { recursive: true });

  const img1 = path.join(sourceDir, "one.jpg");
  const img2 = path.join(sourceDir, "dup.jpg");
  const txt = path.join(sourceDir, "readme.txt");
  await fs.writeFile(img1, "image-content-1");
  await fs.writeFile(img2, "image-content-1");
  await fs.writeFile(txt, "not-image");

  const db = new MemoryDatasetDb();
  const report = await importLocalAssets(db, {
    childId: "child-1",
    paths: [sourceDir],
    recursive: true,
    dataDir,
  });

  assert.equal(report.imported.length, 1);
  assert.equal(report.duplicates.length, 1);
  assert.equal(report.skipped.length, 1);
  assert.equal(report.skipped[0].reason, "unsupported_file_type");
  assert.equal(report.failed.length, 0);

  const managed = report.imported[0].path;
  const managedStat = await fs.stat(managed);
  assert.equal(managedStat.isFile(), true);
});

test("imports assets with a default capture date", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-import-date-"));
  const dataDir = path.join(root, "data");
  const image = path.join(root, "drawing.jpg");
  await fs.writeFile(image, "image-content");

  const db = new MemoryDatasetDb();
  const report = await importLocalAssets(db, {
    childId: "child-1",
    paths: [image],
    dataDir,
  });

  assert.equal(report.imported.length, 1);
  const imported = await db.getAsset(report.imported[0].id);
  assert.match(imported?.capturedAt ?? "", /^\d{4}-\d{2}-\d{2}$/);
});

test("imports assets with a generated thumbnail path distinct from the source image", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-import-thumbnail-"));
  const dataDir = path.join(root, "data");
  const image = path.join(root, "drawing.jpg");
  await fs.writeFile(image, "image-content");

  const db = new MemoryDatasetDb();
  const report = await importLocalAssets(db, {
    childId: "child-1",
    paths: [image],
    dataDir,
  });

  assert.equal(report.imported.length, 1);
  const imported = await db.getAsset(report.imported[0].id);
  assert.notEqual(imported?.thumbnailPath, imported?.imagePath);
  assert.match(imported?.thumbnailPath ?? "", /thumbnails/);
  assert.equal((await fs.stat(imported!.thumbnailPath)).isFile(), true);
});

test("reports unreadable import paths", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-import-missing-"));
  const missing = path.join(root, "missing.jpg");
  const db = new MemoryDatasetDb();

  const report = await importLocalAssets(db, {
    childId: "child-1",
    paths: [missing],
    dataDir: path.join(root, "data"),
  });

  assert.equal(report.imported.length, 0);
  assert.equal(report.failed.length, 1);
  assert.equal(report.failed[0].path, missing);
  assert.equal(report.failed[0].reason, "path_not_found");
});

test("rejects child ids that escape the managed assets directory", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-import-unsafe-child-"));
  const dataDir = path.join(root, "data");
  const image = path.join(root, "drawing.jpg");
  const escapedChildDir = path.join(root, "escaped-child");
  await fs.writeFile(image, "image-content");

  const db = new MemoryDatasetDb();
  const report = await importLocalAssets(db, {
    childId: escapedChildDir,
    paths: [image],
    dataDir,
  });

  assert.equal(report.imported.length, 0);
  assert.equal(report.failed.length, 1);
  assert.equal(report.failed[0].reason, "unsafe_child_id");
  await assert.rejects(fs.stat(escapedChildDir), { code: "ENOENT" });
});
