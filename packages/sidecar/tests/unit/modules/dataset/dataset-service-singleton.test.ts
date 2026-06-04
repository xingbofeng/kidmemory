import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";

import { AppConfigService, loadConfigFromEnv } from "../../../../src/infrastructure/config/app-config.service.ts";
import { DatasetState, type DatasetStateService } from "../../../../src/infrastructure/dataset-state/dataset-state.service.ts";
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

function createDatasetState(db: SampleDb = new MemoryDatasetDb()): DatasetStateService {
  return new DatasetState(db, async () => db) as unknown as DatasetStateService;
}

function createOpenAIResponse(content: string): Response {
  return new Response(
    JSON.stringify({
      choices: [
        {
          message: { content },
        },
      ],
    }),
    {
      headers: { "content-type": "application/json" },
      status: 200,
    },
  );
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

test("DatasetService rejects persistent activation failures in production instead of serving in-memory data", async () => {
  const previousNodeEnv = process.env.NODE_ENV;
  process.env.NODE_ENV = "production";
  const memoryDb = new MemoryDatasetDb();
  await memoryDb.upsertChild({ id: "child-memory", name: "Memory Only" });
  const datasetState = new DatasetState(
    memoryDb,
    async () => {
      throw new Error("persistent database unavailable");
    },
  ) as unknown as DatasetStateService;
  const service = new DatasetService(datasetState, new AppConfigService(loadConfigFromEnv({})));

  try {
    await assert.rejects(
      service.listChildren(),
      /persistent database unavailable/,
    );
  } finally {
    if (previousNodeEnv === undefined) {
      delete process.env.NODE_ENV;
    } else {
      process.env.NODE_ENV = previousNodeEnv;
    }
  }
});

test("DatasetService uses configured OpenAI-compatible endpoint to infer imported asset metadata", async () => {
  const db = new MemoryDatasetDb();
  const config = new AppConfigService(loadConfigFromEnv({}));
  config.updateOpenAIConfig({
    baseUrl: "https://openai-compatible.example.test/v1",
    apiKey: "sk-test",
    model: "gpt-4.1-mini",
  });
  const service = new DatasetService(createDatasetState(db), config);
  await db.upsertChild({ id: "child-1", name: "测试孩子" });

  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-dataset-service-infer-"));
  const imagePath = path.join(root, "upload.png");
  await fs.writeFile(imagePath, "fake-image-content");

  const originalFetch = globalThis.fetch;
  let called = 0;
  globalThis.fetch = (async () => {
    called += 1;
    return createOpenAIResponse(JSON.stringify({
      title: "草地上的猫",
      tags: ["猫", "宠物"],
      description: "一只猫在草地上休息",
    }));
  }) as typeof fetch;

  try {
    const result = await service.importAssets({ childId: "child-1", paths: [imagePath] });
    assert.equal(result.imported.length, 1);
    assert.equal(called, 1);

    const asset = await db.getAsset(result.imported[0].id);
    assert.equal(asset?.title, "草地上的猫");
    assert.deepEqual(asset?.tags, ["猫", "宠物"]);
    assert.equal(asset?.description, "一只猫在草地上休息");
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("DatasetService picks up OpenAI config updates after service construction", async () => {
  const db = new MemoryDatasetDb();
  const config = new AppConfigService(loadConfigFromEnv({}));
  const service = new DatasetService(createDatasetState(db), config);
  await db.upsertChild({ id: "child-1", name: "测试孩子" });
  await service.listChildren();

  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-dataset-service-infer-late-config-"));
  const imagePath = path.join(root, "upload.png");
  await fs.writeFile(imagePath, "fake-image-content");

  config.updateOpenAIConfig({
    baseUrl: "https://openai-compatible.example.test/v1",
    apiKey: "sk-test",
    model: "gpt-4.1-mini",
  });

  const originalFetch = globalThis.fetch;
  let called = 0;
  globalThis.fetch = (async () => {
    called += 1;
    return createOpenAIResponse(JSON.stringify({
      title: "晚配置也生效",
      tags: ["动态配置"],
      description: "服务启动后配置也应被读取",
    }));
  }) as typeof fetch;

  try {
    const result = await service.importAssets({ childId: "child-1", paths: [imagePath] });
    assert.equal(result.imported.length, 1);
    assert.equal(called, 1);
  } finally {
    globalThis.fetch = originalFetch;
  }
});
