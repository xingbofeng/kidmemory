import assert from "node:assert/strict";
import { test } from "node:test";

import { AppConfigService, loadConfigFromEnv } from "../../../../src/infrastructure/config/app-config.service.ts";
import { DatasetState } from "../../../../src/infrastructure/dataset-state/dataset-state.service.ts";
import { MemoryDatasetDb, type SampleDb } from "../../../../src/infrastructure/dataset-state/memory-dataset-db.ts";
import { DatasetService } from "../../../../src/modules/dataset/dataset.service.ts";

// The dataset service composes a Supabase storage provider and a storage-sync
// service every time a storage route fires. Each composition reads the latest
// Supabase config and resets the SigV4 / HTTP keep-alive context, so the
// expected behaviour is to memoize both factories per DatasetService instance.

class StubDatasetState extends DatasetState<SampleDb> {
  constructor() {
    const memoryDb = new MemoryDatasetDb();
    super(memoryDb, async () => memoryDb);
  }
}

function buildSpyFactories() {
  const calls = { storage: 0, sync: 0 };
  const storageProviderFactory = () => {
    calls.storage += 1;
    return {
      uploadFile: async () => ({ ok: true as const }),
      createSignedUrl: async () => ({
        ok: true as const,
        url: "https://signed.example.test",
        expiresInSeconds: 60,
      }),
    };
  };
  const storageSyncFactory = () => {
    calls.sync += 1;
    return {
      enqueueAssetSync: async () => ({ enqueued: false, reason: "asset_not_found" as const }),
      enqueueExportArtifactSync: async () => ({ enqueued: false, reason: "artifact_not_found" as const }),
      runStorageSyncWorker: async () => ({ processed: 0, succeeded: 0, retried: 0, failed: 0, skipped: 0 }),
      getShareMetadata: async () => ({ ok: false as const, code: "EXPORT_ARTIFACT_NOT_FOUND", message: "Artifact not found", action: "Check artifact ID" }),
    };
  };
  return { calls, storageProviderFactory, storageSyncFactory };
}

test("DatasetService composes the storage provider and sync service exactly once per instance", async () => {
  const datasetState = new StubDatasetState();
  const config = new AppConfigService(loadConfigFromEnv({}));
  const { calls, storageProviderFactory, storageSyncFactory } = buildSpyFactories();

  const service = new DatasetService(datasetState, config, {
    createStorageProvider: storageProviderFactory,
    createStorageSync: storageSyncFactory,
  });

  await service.runStorageSyncWorker();
  await service.runStorageSyncWorker();
  await service.enqueueAssetStorageSync("missing-asset");
  await service.getExportArtifactShareMetadata("missing-artifact");

  assert.equal(calls.storage, 1, `storage provider factory should run once, got ${calls.storage}`);
  assert.equal(calls.sync, 1, `storage sync factory should run once, got ${calls.sync}`);
});

test("DatasetService composes a fresh storage provider for each new instance", async () => {
  const config = new AppConfigService(loadConfigFromEnv({}));
  const { calls, storageProviderFactory, storageSyncFactory } = buildSpyFactories();

  const first = new DatasetService(new StubDatasetState(), config, {
    createStorageProvider: storageProviderFactory,
    createStorageSync: storageSyncFactory,
  });
  await first.runStorageSyncWorker();

  const second = new DatasetService(new StubDatasetState(), config, {
    createStorageProvider: storageProviderFactory,
    createStorageSync: storageSyncFactory,
  });
  await second.runStorageSyncWorker();

  assert.equal(calls.storage, 2, `each new DatasetService instance should rebuild the storage provider, got ${calls.storage}`);
  assert.equal(calls.sync, 2, `each new DatasetService instance should rebuild the sync service, got ${calls.sync}`);
});
