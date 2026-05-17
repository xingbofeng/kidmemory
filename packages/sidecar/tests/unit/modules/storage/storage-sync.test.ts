import assert from "node:assert/strict";
import { test } from "node:test";

import { MemoryDatasetDb } from "../../../../src/infrastructure/dataset-state/memory-dataset-db.ts";

test("storage sync queue is idempotent and claimable", async () => {
  const db = new MemoryDatasetDb();
  const first = await db.enqueueStorageSyncJob?.({
    targetType: "asset",
    targetId: "asset-1",
    provider: "supabase",
    objectPath: "children/child-1/assets/asset-1/image.jpg",
  });
  const second = await db.enqueueStorageSyncJob?.({
    targetType: "asset",
    targetId: "asset-1",
    provider: "supabase",
    objectPath: "children/child-1/assets/asset-1/image.jpg",
  });

  assert.equal(first?.enqueued, true);
  assert.equal(second?.enqueued, false);
  assert.equal(second?.jobId, first?.jobId);

  const claimed = await db.claimStorageSyncJobs?.({
    limit: 1,
    workerId: "storage-worker",
    now: new Date(Date.now() + 2_000),
  });

  assert.equal(claimed?.length, 1);
  assert.equal(claimed?.[0].status, "running");
  assert.equal(claimed?.[0].lockedBy, "storage-worker");
});

test("storage sync queue retries and recovers stale running jobs", async () => {
  const db = new MemoryDatasetDb();
  const created = await db.enqueueStorageSyncJob?.({
    targetType: "export_artifact",
    targetId: "artifact-1",
    provider: "supabase",
    objectPath: "children/child-1/exports/job-1/book.png",
    maxAttempts: 3,
  });
  assert.equal(created?.enqueued, true);

  const base = new Date(Date.now() + 2_000);
  const [job] = await db.claimStorageSyncJobs?.({
    limit: 1,
    workerId: "storage-worker",
    now: base,
    staleAfterSeconds: 60,
  }) ?? [];
  assert.equal(job.status, "running");

  await db.markStorageSyncJobRetry?.({
    jobId: job.id,
    attempt: 1,
    runAfter: new Date(base.getTime() + 5_000),
    errorCode: "SUPABASE_STORAGE_RETRYABLE",
    errorMessage: "rate limited",
  });

  const notYet = await db.claimStorageSyncJobs?.({
    limit: 1,
    workerId: "storage-worker",
    now: new Date(base.getTime() + 4_000),
  });
  assert.equal(notYet?.length, 0);

  const retry = await db.claimStorageSyncJobs?.({
    limit: 1,
    workerId: "storage-worker",
    now: new Date(base.getTime() + 5_000),
  });
  assert.equal(retry?.length, 1);
  assert.equal(retry?.[0].attempt, 1);

  const staleRecovered = await db.claimStorageSyncJobs?.({
    limit: 1,
    workerId: "storage-worker-b",
    now: new Date(base.getTime() + 70_000),
    staleAfterSeconds: 60,
  });
  assert.equal(staleRecovered?.length, 1);
  assert.equal(staleRecovered?.[0].status, "running");
  assert.equal(staleRecovered?.[0].attempt, 2);
});

test("storage sync writes asset and export artifact remote state", async () => {
  const db = new MemoryDatasetDb();
  await db.upsertChild({ id: "child-1", name: "澄澄" });
  await db.upsertAsset({
    id: "asset-1",
    childId: "child-1",
    type: "photo",
    title: "同步目标",
    description: "",
    tags: [],
    imagePath: "/tmp/asset.jpg",
    thumbnailPath: "/tmp/asset.jpg",
    sourceUrl: "",
    license: "local",
  });

  await db.updateAssetStorageState?.({
    assetId: "asset-1",
    storageProvider: "supabase",
    storageStatus: "synced",
    storagePath: "children/child-1/assets/asset-1/image.jpg",
    remoteUrl: "https://cdn.example.test/image.jpg",
  });
  const asset = await db.getAsset("asset-1");
  assert.equal(asset?.storageStatus, "synced");
  assert.equal(asset?.remoteUrl, "https://cdn.example.test/image.jpg");
  assert.equal(asset?.imagePath, "/tmp/asset.jpg");

  await db.upsertExportArtifact?.({
    id: "artifact-1",
    jobId: "job-1",
    kind: "long_image_png",
    localPath: "/tmp/book.png",
  });
  await db.updateExportArtifactStorageState?.({
    artifactId: "artifact-1",
    storageProvider: "supabase",
    storageStatus: "synced",
    storagePath: "children/child-1/exports/job-1/book.png",
    remoteUrl: "https://cdn.example.test/book.png",
  });
  const artifact = await db.getExportArtifact?.("artifact-1");

  assert.equal(artifact?.storageStatus, "synced");
  assert.equal(artifact?.remoteUrl, "https://cdn.example.test/book.png");
  assert.equal(artifact?.localPath, "/tmp/book.png");
});
