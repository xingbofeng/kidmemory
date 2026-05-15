import assert from "node:assert/strict";
import path from "node:path";
import { test } from "node:test";

import { resolveExportLongImagePath, resolveExportPdfPath } from "../../src/modules/books/providers/books.domain.ts";

test("resolveExportPdfPath uses requested target path inside export dir and normalizes .pdf suffix", () => {
  const explicit = resolveExportPdfPath({
    jobId: "job_1",
    exportDir: ".kidmemory/exports",
    targetPath: ".kidmemory/exports/custom-book",
    cwd: "/workspace/packages/backend",
  });
  assert.equal(explicit, path.join("/workspace/packages/backend", ".kidmemory/exports", "custom-book.pdf"));
});

test("resolveExportPdfPath falls back to sidecar export dir when target path is not provided", () => {
  const fallback = resolveExportPdfPath({
    jobId: "job_2",
    exportDir: ".kidmemory/exports",
    cwd: "/workspace/packages/backend",
  });
  assert.equal(fallback, path.join("/workspace/packages/backend", ".kidmemory/exports", "job_2.pdf"));
});

test("resolveExportPdfPath rejects target paths outside the configured export dir", () => {
  assert.throws(
    () => resolveExportPdfPath({
      jobId: "job_3",
      exportDir: ".kidmemory/exports",
      targetPath: "/tmp/custom-book",
      cwd: "/workspace/packages/backend",
    }),
    /inside the configured export directory/,
  );
});

test("resolveExportLongImagePath normalizes jpeg and rejects path traversal", () => {
  const explicit = resolveExportLongImagePath({
    jobId: "job_4",
    exportDir: ".kidmemory/exports",
    format: "jpg",
    targetPath: ".kidmemory/exports/share-card.jpeg",
    cwd: "/workspace/packages/backend",
  });
  assert.equal(explicit, path.join("/workspace/packages/backend", ".kidmemory/exports", "share-card.jpg"));

  assert.throws(
    () => resolveExportLongImagePath({
      jobId: "job_5",
      exportDir: ".kidmemory/exports",
      format: "png",
      targetPath: ".kidmemory/exports/../escape",
      cwd: "/workspace/packages/backend",
    }),
    /inside the configured export directory/,
  );
});
