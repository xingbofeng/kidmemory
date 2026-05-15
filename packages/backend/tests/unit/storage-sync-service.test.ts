import assert from "node:assert/strict";
import { test } from "node:test";

import { MemoryDatasetDb } from "../../src/infrastructure/dataset-state/memory-dataset-db.ts";
import { createStorageSyncService } from "../../src/modules/storage/providers/storage-sync.ts";

function buildService(options: {
  uploadFile?: (input: { localPath: string; objectPath: string }) => Promise<any>;
} = {}) {
  const db = new MemoryDatasetDb();
  const uploadCalls: { localPath: string; objectPath: string }[] = [];
  const service = createStorageSyncService({
    db,
    provider: {
      uploadFile: async (input) => {
        uploadCalls.push(input);
        if (options.uploadFile) return options.uploadFile(input);
        return {
          ok: true,
          remoteUrl: `https://cdn.example.test/${input.objectPath}`,
        };
      },
      createSignedUrl: async (objectPath) => ({
        ok: true,
        url: `https://signed.example.test/${objectPath}?token=abc`,
        expiresInSeconds: 600,
      }),
    },
  });
  return { service, db, uploadCalls };
}

test("storage sync service uploads assets and writes remote state", async () => {
  const { service, db, uploadCalls } = buildService();
  await db.upsertChild({ id: "child-1", name: "澄澄" });
  await db.upsertAsset({
    id: "asset-1",
    childId: "child-1",
    type: "photo",
    title: "照片",
    description: "",
    tags: [],
    imagePath: "/tmp/asset.jpg",
    thumbnailPath: "/tmp/asset.jpg",
    sourceUrl: "",
    license: "local",
    hash: "hash-1",
  });

  const enqueued = await service.enqueueAssetSync("asset-1");
  assert.equal(enqueued.enqueued, true);

  const run = await service.runStorageSyncWorker({
    limit: 1,
    now: new Date(Date.now() + 2_000),
  });

  assert.equal(run.succeeded, 1);
  assert.equal(uploadCalls[0].localPath, "/tmp/asset.jpg");
  assert.equal(uploadCalls[0].objectPath, "children/child-1/assets/asset-1/hash-1.jpg");
  const asset = await db.getAsset("asset-1");
  assert.equal(asset?.storageStatus, "synced");
  assert.equal(asset?.storageProvider, "supabase");
  assert.equal(asset?.remoteUrl, "https://cdn.example.test/children/child-1/assets/asset-1/hash-1.jpg");
});

test("storage sync service uploads export artifacts and writes remote state", async () => {
  const { service, db, uploadCalls } = buildService();
  await db.upsertExportArtifact?.({
    id: "artifact-1",
    jobId: "job-1",
    kind: "long_image_png",
    localPath: "/tmp/book.png",
  });

  const enqueued = await service.enqueueExportArtifactSync({
    artifactId: "artifact-1",
    childId: "child-1",
  });
  assert.equal(enqueued.enqueued, true);

  const run = await service.runStorageSyncWorker({
    limit: 1,
    now: new Date(Date.now() + 2_000),
  });

  assert.equal(run.succeeded, 1);
  assert.equal(uploadCalls[0].objectPath, "children/child-1/exports/job-1/artifact-1.png");
  const artifact = await db.getExportArtifact?.("artifact-1");
  assert.equal(artifact?.storageStatus, "synced");
  assert.equal(artifact?.remoteUrl, "https://cdn.example.test/children/child-1/exports/job-1/artifact-1.png");
});

test("storage sync service retries retryable upload failures", async () => {
  let attempts = 0;
  const { service, db } = buildService({
    uploadFile: async () => {
      attempts += 1;
      if (attempts === 1) {
        return {
          ok: false,
          code: "SUPABASE_STORAGE_RETRYABLE",
          message: "rate limited",
          retryable: true,
        };
      }
      return { ok: true, remoteUrl: "https://cdn.example.test/asset.jpg" };
    },
  });
  await db.upsertChild({ id: "child-1", name: "澄澄" });
  await db.upsertAsset({
    id: "asset-1",
    childId: "child-1",
    type: "photo",
    title: "照片",
    description: "",
    tags: [],
    imagePath: "/tmp/asset.jpg",
    thumbnailPath: "/tmp/asset.jpg",
    sourceUrl: "",
    license: "local",
  });

  await service.enqueueAssetSync("asset-1");
  const base = new Date(Date.now() + 2_000);
  const first = await service.runStorageSyncWorker({ limit: 1, now: base });
  const second = await service.runStorageSyncWorker({
    limit: 1,
    now: new Date(base.getTime() + 5_000),
  });

  assert.equal(first.retried, 1);
  assert.equal(second.succeeded, 1);
  assert.equal((await db.getAsset("asset-1"))?.storageStatus, "synced");
});

test("storage sync service returns signed sharing metadata", async () => {
  const { service, db } = buildService();
  await db.upsertExportArtifact?.({
    id: "artifact-1",
    jobId: "job-1",
    kind: "long_image_png",
    localPath: "/tmp/book.png",
    storageProvider: "supabase",
    storageStatus: "synced",
    storagePath: "children/child-1/exports/job-1/artifact-1.png",
  });

  const share = await service.getShareMetadata("artifact-1");

  assert.equal(share.ok, true);
  assert.equal(share.expiresInSeconds, 600);
  assert.match(share.text, /有效期/);
  assert.match(share.url, /token=abc/);
});
