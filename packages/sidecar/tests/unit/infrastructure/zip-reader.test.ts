import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import AdmZip from "adm-zip";

import { MemoryDatasetDb } from "../../../src/infrastructure/dataset-state/memory-dataset-db.ts";
import { importLocalAssets } from "../../../src/modules/dataset/providers/asset-import.ts";

test("imports supported images from zip archive", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-zip-ok-"));
  const zipPath = path.join(root, "assets.zip");
  const zip = new AdmZip();
  zip.addFile("a.jpg", Buffer.from("img-a"));
  zip.addFile("nested/b.png", Buffer.from("img-b"));
  zip.addFile("note.txt", Buffer.from("skip-me"));
  zip.writeZip(zipPath);

  const db = new MemoryDatasetDb();
  const report = await importLocalAssets(db, {
    childId: "child-zip",
    paths: [zipPath],
    recursive: true,
    dataDir: path.join(root, "data"),
  });

  assert.equal(report.imported.length, 2);
  assert.equal(report.skipped.some((v) => v.reason === "unsupported_file_type"), true);
});

test("rejects unsafe zip entry paths", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-zip-unsafe-"));
  const zipPath = path.join(root, "unsafe.zip");
  const dataDir = path.join(root, "data");
  const zip = new AdmZip();
  zip.addFile("../evil.jpg", Buffer.from("evil"));
  zip.writeZip(zipPath);

  const db = new MemoryDatasetDb();
  const report = await importLocalAssets(db, {
    childId: "child-zip",
    paths: [zipPath],
    recursive: true,
    dataDir,
  });

  for (const item of report.imported) {
    const normalized = path.resolve(item.path);
    assert.equal(normalized.startsWith(path.resolve(dataDir)), true);
    assert.equal(normalized.includes(".."), false);
  }
  if (report.imported.length > 0) {
    assert.equal(report.failed.some((v) => v.reason === "unsafe_zip_path"), false);
  }
});

test("zip entry safety uses resolved containment instead of raw substring checks", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-zip-normalized-"));
  const zipPath = path.join(root, "normalized.zip");
  const zip = new AdmZip();
  addRawZipEntry(zip, "nested/../safe.jpg", Buffer.from("safe"));
  addRawZipEntry(zip, "nested/../../evil.jpg", Buffer.from("evil"));
  addRawZipEntry(zip, "C:/absolute.jpg", Buffer.from("absolute"));
  zip.writeZip(zipPath);

  const db = new MemoryDatasetDb();
  const report = await importLocalAssets(db, {
    childId: "child-zip",
    paths: [zipPath],
    recursive: true,
    dataDir: path.join(root, "data"),
  });

  assert.equal(report.imported.length, 1);
  assert.equal((await db.getAssets())[0].originalFilename, "safe.jpg");
  assert.equal(report.failed.filter((v) => v.reason === "unsafe_zip_path").length, 2);
});

function addRawZipEntry(zip: AdmZip, entryName: string, data: Buffer) {
  const placeholder = `placeholder-${zip.getEntries().length}.jpg`;
  zip.addFile(placeholder, data);
  const entry = zip.getEntries().find((candidate) => candidate.entryName === placeholder);
  if (!entry) throw new Error(`Failed to add ${entryName}`);
  entry.entryName = entryName;
}
