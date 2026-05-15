import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";

import { DatasetState } from "../../src/infrastructure/dataset-state/dataset-state.service.ts";
import { MemoryDatasetDb } from "../../src/infrastructure/dataset-state/memory-dataset-db.ts";
import { FileJobStoreService } from "../../src/infrastructure/jobs/file-job-store.service.ts";
import { createBooksService } from "../../src/modules/books/providers/books.domain.ts";

async function buildGeneratedJob() {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-long-image-flow-"));
  const workspace = path.join(root, "workspace", "job-1");
  const exportDir = path.join(root, "exports");
  const output = path.join(workspace, "output");
  await fs.mkdir(output, { recursive: true });
  await fs.writeFile(path.join(output, "book.json"), JSON.stringify({
    metadata: { title: "阳光的一天", childName: "澄澄" },
    pages: [
      { kind: "cover", title: "阳光的一天", text: "封面" },
      { kind: "artwork", title: "太阳下的小房子", text: "内容", assetId: "asset-sun-house" },
      { kind: "closing", title: "尾声", text: "结束" },
    ],
  }));
  await fs.writeFile(path.join(output, "book.html"), "<html><body><section class=\"page\">book</section></body></html>");

  const db = new MemoryDatasetDb();
  const datasetState = new DatasetState(db, async () => db);
  const jobStore = new FileJobStoreService(path.join(root, "data"));
  await jobStore.save({
    id: "job-1",
    status: "generated",
    runner: "mock",
    workspacePath: workspace,
    selectedAssetIds: ["asset-sun-house"],
  });
  const service = createBooksService({
    config: {
      paths: {
        workspaceDir: path.join(root, "workspace"),
        exportDir,
        dataDir: path.join(root, "data"),
      },
    } as any,
    datasetState: datasetState as any,
    jobStore,
    longImageRenderer: {
      render: async ({ targetPath }) => {
        await fs.writeFile(targetPath, Buffer.from([0x89, 0x50, 0x4e, 0x47]));
      },
    },
    pdfRenderer: {
      render: async (_html, targetPath) => {
        await fs.writeFile(targetPath, "%PDF-1.7\n% KidMemory test\n");
      },
    },
    pdfLoader: {
      load: async () => ({ numPages: 3, firstPageRendered: true }),
    },
  });
  return { service, db, exportDir };
}

test("books service exports PNG long image and records an export artifact", async () => {
  const { service, db, exportDir } = await buildGeneratedJob();

  const result = await service.exportLongImage("job-1", {
    format: "png",
    targetPath: path.join(exportDir, "custom-book"),
  });

  assert.equal(result.status, 200);
  assert.equal(result.data.exported.ok, true);
  assert.match(result.data.exported.path, /\.png$/);
  assert.equal(result.data.artifact.kind, "long_image_png");
  assert.equal(result.data.artifact.storageStatus, "local_only");
  assert.equal((await db.getExportArtifact?.(result.data.artifact.id))?.localPath, result.data.exported.path);
});

test("books service exports JPG long image with normalized suffix", async () => {
  const { service, exportDir } = await buildGeneratedJob();

  const result = await service.exportLongImage("job-1", {
    format: "jpg",
    targetPath: path.join(exportDir, "custom-book"),
  });

  assert.equal(result.status, 200);
  assert.match(result.data.exported.path, /\.jpg$/);
  assert.equal(result.data.artifact.kind, "long_image_jpg");
});

test("books service rejects long image export for missing generated job", async () => {
  const { service } = await buildGeneratedJob();

  const result = await service.exportLongImage("missing-job", { format: "png" });

  assert.equal(result.status, 404);
  assert.equal(result.data.ok, false);
  assert.match(result.data.message, /not found/i);
});

test("books service records PDF export artifacts", async () => {
  const { service, db, exportDir } = await buildGeneratedJob();

  const result = await service.exportPdf("job-1", {
    targetPath: path.join(exportDir, "custom-book"),
  });

  assert.equal(result.status, 200);
  assert.equal(result.data.exported.ok, true);
  assert.equal(result.data.artifact.kind, "pdf");
  assert.equal(result.data.artifact.storageStatus, "local_only");
  assert.equal((await db.getExportArtifact?.(result.data.artifact.id))?.localPath, result.data.exported.path);
});
