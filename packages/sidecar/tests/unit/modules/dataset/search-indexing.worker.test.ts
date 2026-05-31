import assert from "node:assert/strict";
import test from "node:test";

import { SearchIndexingWorkerService } from "../../../../src/modules/dataset/providers/search-indexing.worker.ts";
import type { DatasetService } from "../../../../src/modules/dataset/dataset.service.ts";
import { useTestEnv } from "../../../test-env.ts";

type IndexerResult = Awaited<ReturnType<DatasetService["runSearchIndexer"]>>;
type IntervalHandler = Parameters<typeof setInterval>[0];

const emptyIndexerResult: IndexerResult = {
  processed: 0,
  succeeded: 0,
  retried: 0,
  failed: 0,
  skipped: 0,
};

function createDatasetService(runSearchIndexer: DatasetService["runSearchIndexer"]) {
  return { runSearchIndexer } as unknown as DatasetService;
}

function createIntervalHandle(handler: IntervalHandler): ReturnType<typeof setInterval> {
  return { handler } as unknown as ReturnType<typeof setInterval>;
}

test("search indexing worker does not start when disabled by env", async (t) => {
  const originalSetInterval = globalThis.setInterval;
  const originalClearInterval = globalThis.clearInterval;
  useTestEnv(t, { KIDMEMORY_DISABLE_INDEXING_WORKER: "true" });

  let intervalRegistered = 0;
  let runCalls = 0;
  globalThis.setInterval = ((handler: IntervalHandler) => {
    intervalRegistered += 1;
    return createIntervalHandle(handler);
  }) as typeof setInterval;
  globalThis.clearInterval = (() => undefined) as typeof clearInterval;

  const datasetService = createDatasetService(
    async () => {
      runCalls += 1;
      return emptyIndexerResult;
    },
  );
  const worker = new SearchIndexingWorkerService(datasetService);

  try {
    worker.onModuleInit();
    await new Promise((resolve) => setImmediate(resolve));
    assert.equal(intervalRegistered, 0);
    assert.equal(runCalls, 0);
  } finally {
    globalThis.setInterval = originalSetInterval;
    globalThis.clearInterval = originalClearInterval;
    worker.onModuleDestroy();
  }
});

test("search indexing worker skips overlapping ticks while a run is in progress", async (t) => {
  const originalSetInterval = globalThis.setInterval;
  const originalClearInterval = globalThis.clearInterval;
  useTestEnv(t, {
    KIDMEMORY_DISABLE_INDEXING_WORKER: "",
    KIDMEMORY_INDEXING_INTERVAL_MS: "1000",
  });

  let tickHandler: (() => void) | null = null;
  globalThis.setInterval = ((handler: IntervalHandler) => {
    tickHandler = typeof handler === "function" ? () => handler() : null;
    return createIntervalHandle(handler);
  }) as typeof setInterval;
  globalThis.clearInterval = (() => undefined) as typeof clearInterval;

  let resolveRun: (() => void) | null = null;
  let runCalls = 0;
  const datasetService = createDatasetService(
    () => {
      runCalls += 1;
      return new Promise<IndexerResult>((resolve) => {
        resolveRun = () => {
          resolve(emptyIndexerResult);
        };
      });
    },
  );
  const worker = new SearchIndexingWorkerService(datasetService);

  try {
    worker.onModuleInit();
    assert.ok(tickHandler, "worker should register interval handler");
    assert.equal(runCalls, 1, "first run starts immediately on init");

    tickHandler?.();
    tickHandler?.();
    await new Promise((resolve) => setImmediate(resolve));
    assert.equal(runCalls, 1, "overlapping ticks should not trigger extra run");

    resolveRun?.();
    await new Promise((resolve) => setImmediate(resolve));
    tickHandler?.();
    await new Promise((resolve) => setImmediate(resolve));
    assert.equal(runCalls, 2, "next tick after completion should run again");
  } finally {
    globalThis.setInterval = originalSetInterval;
    globalThis.clearInterval = originalClearInterval;
    worker.onModuleDestroy();
  }
});
