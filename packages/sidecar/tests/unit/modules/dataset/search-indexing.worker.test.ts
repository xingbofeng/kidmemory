import assert from "node:assert/strict";
import test from "node:test";

import { SearchIndexingWorkerService } from "../../../../src/modules/dataset/providers/search-indexing.worker.ts";

test("search indexing worker does not start when disabled by env", async () => {
  const originalDisable = process.env.KIDMEMORY_DISABLE_INDEXING_WORKER;
  const originalSetInterval = globalThis.setInterval;
  const originalClearInterval = globalThis.clearInterval;
  process.env.KIDMEMORY_DISABLE_INDEXING_WORKER = "true";

  let intervalRegistered = 0;
  let runCalls = 0;
  globalThis.setInterval = ((handler: any) => {
    intervalRegistered += 1;
    return { handler } as any;
  }) as typeof setInterval;
  globalThis.clearInterval = (() => undefined) as typeof clearInterval;

  const datasetService = {
    runSearchIndexer: async () => {
      runCalls += 1;
      return { processed: 0, succeeded: 0, retried: 0, failed: 0, skipped: 0 };
    },
  } as any;
  const worker = new SearchIndexingWorkerService(datasetService);

  try {
    worker.onModuleInit();
    await new Promise((resolve) => setImmediate(resolve));
    assert.equal(intervalRegistered, 0);
    assert.equal(runCalls, 0);
  } finally {
    process.env.KIDMEMORY_DISABLE_INDEXING_WORKER = originalDisable;
    globalThis.setInterval = originalSetInterval;
    globalThis.clearInterval = originalClearInterval;
    worker.onModuleDestroy();
  }
});

test("search indexing worker skips overlapping ticks while a run is in progress", async () => {
  const originalDisable = process.env.KIDMEMORY_DISABLE_INDEXING_WORKER;
  const originalInterval = process.env.KIDMEMORY_INDEXING_INTERVAL_MS;
  const originalSetInterval = globalThis.setInterval;
  const originalClearInterval = globalThis.clearInterval;
  process.env.KIDMEMORY_DISABLE_INDEXING_WORKER = "";
  process.env.KIDMEMORY_INDEXING_INTERVAL_MS = "1000";

  let tickHandler: (() => void) | null = null;
  globalThis.setInterval = ((handler: any) => {
    tickHandler = handler as () => void;
    return { handler } as any;
  }) as typeof setInterval;
  globalThis.clearInterval = (() => undefined) as typeof clearInterval;

  let resolveRun: (() => void) | null = null;
  let runCalls = 0;
  const datasetService = {
    runSearchIndexer: () => {
      runCalls += 1;
      return new Promise((resolve) => {
        resolveRun = () => {
          resolve({ processed: 0, succeeded: 0, retried: 0, failed: 0, skipped: 0 });
        };
      });
    },
  } as any;
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
    process.env.KIDMEMORY_DISABLE_INDEXING_WORKER = originalDisable;
    process.env.KIDMEMORY_INDEXING_INTERVAL_MS = originalInterval;
    globalThis.setInterval = originalSetInterval;
    globalThis.clearInterval = originalClearInterval;
    worker.onModuleDestroy();
  }
});
