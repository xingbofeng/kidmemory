import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { DatasetState } from "../../src/infrastructure/dataset-state/dataset-state.service.ts";
import { MemoryDatasetDb } from "../../src/infrastructure/dataset-state/memory-dataset-db.ts";
import { createDatasetService } from "../../src/modules/dataset/providers/dataset.domain.ts";

function buildService(options: { dataDir: string; embedText?: (text: string) => Promise<number[]> }) {
  const db = new MemoryDatasetDb();
  const datasetState = new DatasetState(db, async () => db);
  const service = createDatasetService({
    datasetState: datasetState as any,
    config: { config: { paths: { dataDir: options.dataDir } } } as any,
    embedText: options.embedText,
  });
  return { service, db };
}

test("import enqueues embedding jobs and search becomes available after indexing", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-search-indexing-"));
  const image = path.join(root, "sun-drawing.jpg");
  await fs.writeFile(image, "image-content");

  const { service, db } = buildService({ dataDir: path.join(root, "data") });
  await db.upsertChild({ id: "child-1", name: "澄澄" });

  const imported = await service.importAssets({ childId: "child-1", paths: [image] });
  assert.equal(imported.imported.length, 1);

  const statusBefore = await service.getSearchIndexingStatus("child-1");
  assert.equal(statusBefore.pending > 0, true);

  const ran = await service.runSearchIndexer({ limit: 10 });
  assert.equal(ran.processed > 0, true);

  const statusAfter = await service.getSearchIndexingStatus("child-1");
  assert.equal(statusAfter.pending, 0);

  const found = await service.searchAssets({
    childId: "child-1",
    query: "sun drawing",
    page: 1,
    pageSize: 10,
  });
  assert.equal(found.items.length, 1);
  assert.equal(found.items[0].asset.id, imported.imported[0].id);
  assert.equal(found.items[0].reasons.length >= 1, true);
});

test("search enforces child isolation and hard filters", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-search-filters-"));
  const { service, db } = buildService({ dataDir: path.join(root, "data") });
  await db.upsertChild({ id: "c1", name: "A" });
  await db.upsertChild({ id: "c2", name: "B" });

  await db.upsertAsset({
    id: "asset-1",
    childId: "c1",
    type: "artwork",
    title: "sun tree",
    description: "outdoor painting",
    tags: ["sun", "outdoor"],
    imagePath: "/tmp/a1.jpg",
    thumbnailPath: "/tmp/a1.jpg",
    sourceUrl: "",
    license: "local",
    capturedAt: "2026-01-10T00:00:00.000Z",
  });
  await db.upsertAsset({
    id: "asset-2",
    childId: "c2",
    type: "photo",
    title: "sun beach",
    description: "trip",
    tags: ["sun"],
    imagePath: "/tmp/a2.jpg",
    thumbnailPath: "/tmp/a2.jpg",
    sourceUrl: "",
    license: "local",
    capturedAt: "2026-02-10T00:00:00.000Z",
  });

  await service.enqueueSearchIndexing("asset-1");
  await service.enqueueSearchIndexing("asset-2");
  await service.runSearchIndexer({ limit: 20 });

  const c1 = await service.searchAssets({
    childId: "c1",
    query: "sun",
    page: 1,
    pageSize: 10,
  });
  assert.equal(c1.items.length, 1);
  assert.equal(c1.items[0].asset.id, "asset-1");

  const filtered = await service.searchAssets({
    childId: "c1",
    query: "sun",
    filters: {
      types: ["artwork"],
      tags: ["sun"],
      capturedFrom: "2026-01-01",
      capturedTo: "2026-01-31",
    },
    page: 1,
    pageSize: 10,
  });
  assert.equal(filtered.items.length, 1);
  assert.equal(filtered.items[0].asset.id, "asset-1");

  const empty = await service.searchAssets({
    childId: "c1",
    query: "sun",
    filters: { types: ["photo"] },
    page: 1,
    pageSize: 10,
  });
  assert.equal(empty.items.length, 0);
});

test("search caps vector recall size for deep pages", async () => {
  let observedTopK = 0;
  const db = new MemoryDatasetDb();
  db.searchAssetsByVector = async (input) => {
    observedTopK = input.topK;
    return [];
  };
  const datasetState = new DatasetState(db, async () => db);
  const service = createDatasetService({
    datasetState: datasetState as any,
    embedText: async () => new Array(1536).fill(0),
  });

  await service.searchAssets({
    childId: "child-1",
    query: "sun",
    page: 50,
    pageSize: 100,
  });

  assert.equal(observedTopK, 500);
});

test("candidate pool add/remove is idempotent", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-search-pool-"));
  const { service, db } = buildService({ dataDir: path.join(root, "data") });
  await db.upsertChild({ id: "child-1", name: "澄澄" });
  await db.upsertAsset({
    id: "asset-1",
    childId: "child-1",
    type: "artwork",
    title: "sun",
    description: "",
    tags: [],
    imagePath: "/tmp/a1.jpg",
    thumbnailPath: "/tmp/a1.jpg",
    sourceUrl: "",
    license: "local",
  });

  const add1 = await service.addSearchCandidatePoolItems({ childId: "child-1", assetIds: ["asset-1"], sourceQuery: "sun" });
  const add2 = await service.addSearchCandidatePoolItems({ childId: "child-1", assetIds: ["asset-1"], sourceQuery: "sun" });
  assert.equal(add1.added, 1);
  assert.equal(add2.added, 0);

  const pool = await service.listSearchCandidatePool("child-1");
  assert.equal(pool.items.length, 1);
  assert.equal(pool.items[0].assetId, "asset-1");

  const remove1 = await service.removeSearchCandidatePoolItems({ childId: "child-1", assetIds: ["asset-1"] });
  const remove2 = await service.removeSearchCandidatePoolItems({ childId: "child-1", assetIds: ["asset-1"] });
  assert.equal(remove1.removed, 1);
  assert.equal(remove2.removed, 0);
});

test("embedding queue is idempotent for the same asset and metadata version", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-search-idempotent-"));
  const { db } = buildService({ dataDir: path.join(root, "data") });
  await db.upsertChild({ id: "child-1", name: "澄澄" });
  await db.upsertAsset({
    id: "asset-1",
    childId: "child-1",
    type: "artwork",
    title: "queue target",
    description: "",
    tags: [],
    imagePath: "/tmp/a1.jpg",
    thumbnailPath: "/tmp/a1.jpg",
    sourceUrl: "",
    license: "local",
  });

  const prepared = await db.prepareAssetForIndexing?.("asset-1");
  assert.equal(Boolean(prepared), true);
  const first = await db.enqueueEmbeddingJob?.({
    assetId: prepared!.assetId,
    metadataVersion: prepared!.metadataVersion,
    maxAttempts: 5,
  });
  const second = await db.enqueueEmbeddingJob?.({
    assetId: prepared!.assetId,
    metadataVersion: prepared!.metadataVersion,
    maxAttempts: 5,
  });

  assert.equal(first?.enqueued, true);
  assert.equal(second?.enqueued, false);
});

test("indexer retries retryable errors with capped backoff in dev mode", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-search-retry-"));
  let attempts = 0;
  const { service, db } = buildService({
    dataDir: path.join(root, "data"),
    embedText: async () => {
      attempts += 1;
      if (attempts <= 2) {
        const error = new Error("timeout");
        (error as any).code = "ETIMEDOUT";
        throw error;
      }
      return new Array(1536).fill(0).map((_, index) => (index === 0 ? 1 : 0));
    },
  });
  await db.upsertChild({ id: "child-1", name: "澄澄" });
  await db.upsertAsset({
    id: "asset-1",
    childId: "child-1",
    type: "artwork",
    title: "retry target",
    description: "",
    tags: [],
    imagePath: "/tmp/a1.jpg",
    thumbnailPath: "/tmp/a1.jpg",
    sourceUrl: "",
    license: "local",
  });

  await service.enqueueSearchIndexing("asset-1");

  const base = new Date(Date.now() + 2_000);
  const run1 = await service.runSearchIndexer({ limit: 1, now: base });
  assert.equal(run1.retried, 1);

  const run2 = await service.runSearchIndexer({ limit: 1, now: new Date(base.getTime() + 5_000) });
  assert.equal(run2.retried, 1);

  const run3 = await service.runSearchIndexer({ limit: 1, now: new Date(base.getTime() + 20_000) });
  assert.equal(run3.succeeded, 1);
});

test("indexer reclaims stale running jobs within 60 seconds in dev mode", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-search-stale-"));
  const { service, db } = buildService({ dataDir: path.join(root, "data") });
  await db.upsertChild({ id: "child-1", name: "澄澄" });
  await db.upsertAsset({
    id: "asset-1",
    childId: "child-1",
    type: "artwork",
    title: "stale target",
    description: "",
    tags: [],
    imagePath: "/tmp/a1.jpg",
    thumbnailPath: "/tmp/a1.jpg",
    sourceUrl: "",
    license: "local",
  });

  await service.enqueueSearchIndexing("asset-1");
  const base = new Date(Date.now() + 2_000);
  const firstClaim = await db.claimEmbeddingJobs?.({
    limit: 1,
    workerId: "test-worker",
    now: base,
    staleAfterSeconds: 60,
  });
  assert.equal(firstClaim?.length, 1);

  const run = await service.runSearchIndexer({
    limit: 1,
    now: new Date(base.getTime() + 62_000),
  });
  assert.equal(run.processed > 0, true);
  assert.equal(run.failed, 0);
});

test("sidecar restart can recover unfinished indexing jobs", async () => {
  const db = new MemoryDatasetDb();
  await db.upsertChild({ id: "child-1", name: "澄澄" });
  await db.upsertAsset({
    id: "asset-1",
    childId: "child-1",
    type: "artwork",
    title: "restart target",
    description: "",
    tags: ["restart"],
    imagePath: "/tmp/a1.jpg",
    thumbnailPath: "/tmp/a1.jpg",
    sourceUrl: "",
    license: "local",
  });

  const stateA = new DatasetState(db, async () => db);
  const stateB = new DatasetState(db, async () => db);
  const serviceA = createDatasetService({
    datasetState: stateA as any,
    config: { config: { paths: { dataDir: "/tmp/kidmemory-test" } } } as any,
  });
  const serviceB = createDatasetService({
    datasetState: stateB as any,
    config: { config: { paths: { dataDir: "/tmp/kidmemory-test" } } } as any,
  });

  await serviceA.enqueueSearchIndexing("asset-1");
  const base = new Date(Date.now() + 2_000);
  const claimed = await db.claimEmbeddingJobs?.({
    limit: 1,
    workerId: "sidecar-a",
    now: base,
    staleAfterSeconds: 60,
  });
  assert.equal(claimed?.length, 1);

  const resumed = await serviceB.runSearchIndexer({
    limit: 1,
    now: new Date(base.getTime() + 65_000),
  });
  assert.equal(resumed.processed > 0, true);
  assert.equal(resumed.failed, 0);

  const result = await serviceB.searchAssets({
    childId: "child-1",
    query: "restart",
    page: 1,
    pageSize: 10,
  });
  assert.equal(result.items.length > 0, true);
});
