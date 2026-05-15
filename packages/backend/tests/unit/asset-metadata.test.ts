import assert from "node:assert/strict";
import test from "node:test";

import { MemoryDatasetDb } from "../../src/infrastructure/dataset-state/memory-dataset-db.ts";

test("filters assets by childId and type", async () => {
  const db = new MemoryDatasetDb();
  await db.upsertAsset({
    id: "a1",
    childId: "c1",
    type: "artwork",
    title: "t1",
    tags: [],
    description: "",
    imagePath: "/tmp/a1.jpg",
    thumbnailPath: "/tmp/a1.jpg",
    sourceUrl: "",
    license: "local",
  });
  await db.upsertAsset({
    id: "a2",
    childId: "c2",
    type: "photo",
    title: "t2",
    tags: [],
    description: "",
    imagePath: "/tmp/a2.jpg",
    thumbnailPath: "/tmp/a2.jpg",
    sourceUrl: "",
    license: "local",
  });

  const c1Assets = await db.getAssets({ childId: "c1" });
  assert.equal(c1Assets.length, 1);
  assert.equal(c1Assets[0].id, "a1");

  const photoAssets = await db.getAssets({ type: "photo" });
  assert.equal(photoAssets.length, 1);
  assert.equal(photoAssets[0].id, "a2");
});

test("finds duplicate by child and hash", async () => {
  const db = new MemoryDatasetDb();
  await db.upsertAsset({
    id: "dup1",
    childId: "child-1",
    type: "artwork",
    title: "dup",
    tags: [],
    description: "",
    imagePath: "/tmp/dup1.jpg",
    thumbnailPath: "/tmp/dup1.jpg",
    sourceUrl: "",
    license: "local",
    hash: "abc",
  });

  const found = await db.findAssetByChildAndHash?.("child-1", "abc");
  const missing = await db.findAssetByChildAndHash?.("child-2", "abc");
  assert.equal(found?.id, "dup1");
  assert.equal(missing, null);
});

test("updates metadata and deletes asset", async () => {
  const db = new MemoryDatasetDb();
  await db.upsertAsset({
    id: "m1",
    childId: "c1",
    type: "artwork",
    title: "old",
    tags: [],
    description: "old",
    imagePath: "/tmp/m1.jpg",
    thumbnailPath: "/tmp/m1.jpg",
    sourceUrl: "",
    license: "local",
  });

  const updated = await db.updateAssetMetadata?.("m1", {
    title: "new",
    description: "desc",
    tags: ["x"],
    capturedAt: "2026-05-12T00:00:00.000Z",
    type: "photo",
  });
  assert.equal(updated?.title, "new");
  assert.equal(updated?.type, "photo");
  assert.equal(updated?.tags[0], "x");
  assert.equal(Boolean(updated?.updatedAt), true);

  const deleted = await db.deleteAsset?.("m1");
  const afterDelete = await db.getAsset("m1");
  assert.equal(deleted, true);
  assert.equal(afterDelete, null);
});
