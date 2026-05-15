import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { DatasetState } from "../../src/infrastructure/dataset-state/dataset-state.service.ts";
import { MemoryDatasetDb } from "../../src/infrastructure/dataset-state/memory-dataset-db.ts";
import { createDatasetService } from "../../src/modules/dataset/providers/dataset.domain.ts";
import { importSampleDataset } from "../../src/modules/dataset/providers/sample-dataset.ts";

test("dataset domain lists assets with child filter", async () => {
  const db = new MemoryDatasetDb();
  const datasetState = new DatasetState(db, async () => db);
  const service = createDatasetService({ datasetState: datasetState as any });
  await db.upsertAsset({
    id: "a1",
    childId: "c1",
    type: "artwork",
    title: "a1",
    tags: [],
    description: "",
    imagePath: "x",
    thumbnailPath: "x",
    sourceUrl: "",
    license: "local",
  });
  await db.upsertAsset({
    id: "a2",
    childId: "c2",
    type: "artwork",
    title: "a2",
    tags: [],
    description: "",
    imagePath: "x",
    thumbnailPath: "x",
    sourceUrl: "",
    license: "local",
  });

  const result = await service.listAssets({ childId: "c1" });
  assert.equal(result.assets.length, 1);
  assert.equal(result.assets[0].id, "a1");
});

test("dataset domain updates and deletes assets", async () => {
  const db = new MemoryDatasetDb();
  const datasetState = new DatasetState(db, async () => db);
  const service = createDatasetService({ datasetState: datasetState as any });
  await db.upsertAsset({
    id: "a3",
    childId: "c3",
    type: "artwork",
    title: "old",
    tags: [],
    description: "",
    imagePath: "x",
    thumbnailPath: "x",
    sourceUrl: "",
    license: "local",
  });

  const updated = await service.updateAsset("a3", { title: "new" });
  assert.equal(updated.asset?.title, "new");

  const deleted = await service.deleteAsset("a3");
  assert.equal(deleted.ok, true);
  assert.equal(await db.getAsset("a3"), null);
});

test("dataset domain persists the selected child before importing real assets", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-domain-import-"));
  const image = path.join(root, "drawing.jpg");
  await fs.writeFile(image, "image-content");

  const memoryDb = new MemoryDatasetDb();
  const persistentDb = new MemoryDatasetDb();
  await memoryDb.upsertChild({ id: "child-1", name: "澄澄" });
  const datasetState = new DatasetState(memoryDb, async () => persistentDb);
  const service = createDatasetService({
    datasetState: datasetState as any,
    config: { config: { paths: { dataDir: path.join(root, "data") } } } as any,
  });

  const result = await service.importAssets({
    childId: "child-1",
    paths: [image],
  });

  assert.equal(result.imported.length, 1);
  assert.equal((await persistentDb.getChild("child-1"))?.name, "澄澄");
});

test("dataset domain can create a default child for first asset import", async () => {
  const db = new MemoryDatasetDb();
  const datasetState = new DatasetState(db, async () => db);
  const service = createDatasetService({
    datasetState: datasetState as any,
    config: { config: { paths: { dataDir: "/tmp/kidmemory-test" } } } as any,
  });

  const result = await service.createChild({ name: "孩子" });

  assert.equal(result.child.id, "child-default");
  assert.equal((await db.getChild("child-default"))?.name, "孩子");
});

test("dataset domain resets sample assets and related indexes", async () => {
  const db = new MemoryDatasetDb();
  const datasetState = new DatasetState(db, async () => db);
  const service = createDatasetService({
    datasetState: datasetState as any,
  });
  await importSampleDataset(db, new URL("../../../../examples/sample-dataset/", import.meta.url));
  assert.equal((await db.getAssets({ childId: "sample-child-001" })).length > 0, true);

  const beforeResetStatus = await service.getSearchIndexingStatus("sample-child-001");
  assert.equal(beforeResetStatus.pending >= 0, true);

  const resetResult = await service.resetSampleAssets();

  assert.equal(resetResult.ok, true);
  assert.equal(resetResult.childId, "sample-child-001");
  assert.equal(resetResult.deletedAssets >= 0, true);
  assert.equal((await db.getAssets({ childId: "sample-child-001" })).length, 0);
  assert.equal((await service.getSearchIndexingStatus("sample-child-001")).pending, 0);
});
