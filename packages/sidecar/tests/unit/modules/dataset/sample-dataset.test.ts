import assert from "node:assert/strict";
import path from "node:path";
import { test } from "node:test";

import { MemoryDatasetDb, buildSelectedAssetPayload, importSampleDataset, listAssets } from "../../../../src/modules/dataset/providers/sample-dataset.ts";

test("imports sample dataset idempotently and supports type filtering", async () => {
  const db = createMemoryDb();

  await importSampleDataset(db);
  await importSampleDataset(db);

  assert.equal(db.children.size, 1);
  assert.equal(db.assets.size, 17);

  const artwork = await listAssets(db, { type: "artwork" });
  assert.equal(artwork.every((asset) => asset.type === "artwork"), true);
  assert.equal(artwork.length >= 4, true);
});

test("builds selected asset payload with license/source metadata", async () => {
  const db = createMemoryDb();
  await importSampleDataset(db);

  const payload = await buildSelectedAssetPayload(db, ["asset-sun-house", "asset-dino-world"]);

  assert.equal(payload.assets.length, 2);
  assert.equal(payload.assets.every((asset) => asset.license && asset.sourceUrl && asset.thumbnailPath), true);
});

test("imports raster assets as photo assets for sample dataset", async () => {
  const db = createMemoryDb();
  await importSampleDataset(db);

  const photos = await listAssets(db, { type: "photo" });
  assert.equal(photos.length, 9);
  assert.equal(photos.every((asset) => asset.id.startsWith("asset-raster-")), true);
});

test("sample import resolves local asset image paths for workspace copying", async () => {
  const db = createMemoryDb();
  await importSampleDataset(db);

  const [asset] = await db.getAssetsByIds(["asset-sun-house"]);

  assert.equal(path.isAbsolute(asset.imagePath), true);
  assert.equal(path.isAbsolute(asset.thumbnailPath), true);
  assert.match(asset.imagePath, /\.png$/);
  assert.equal(asset.imagePath.includes(`${path.sep}raster${path.sep}`), true);
});

test("memory dataset db can fetch an imported child by id", async () => {
  const db = new MemoryDatasetDb();

  await importSampleDataset(db);

  const child = await db.getChild("sample-child-001");
  assert.equal(child?.name, "小朋友");
});

function createMemoryDb() {
  return {
    children: new Map(),
    assets: new Map(),
    async upsertChild(child: any) {
      this.children.set(child.id, child);
    },
    async upsertAsset(asset: any) {
      this.assets.set(asset.id, asset);
    },
    async getChildren() {
      return [...this.children.values()];
    },
    async getChild(id: string) {
      return this.children.get(id);
    },
    async getAssets(filter: any = {}) {
      return [...this.assets.values()].filter((asset: any) => !filter.type || asset.type === filter.type);
    },
    async getAssetsByIds(ids: string[]) {
      return ids.map((id) => this.assets.get(id)).filter(Boolean);
    },
  };
}
