import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";

import { FileJobStore } from "../../../../src/infrastructure/jobs/file-job-store.service.ts";

test("persists generation job status to local filesystem", async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-jobs-"));
  const store = new FileJobStore(dir);

  await store.save({ id: "job_001", status: "running", runner: "mock", selectedAssetIds: ["asset-sun-house"] });
  await store.save({ id: "job_001", status: "generated", runner: "mock", selectedAssetIds: ["asset-sun-house"], bookId: "book_001" });

  const loaded = await store.get("job_001");

  assert.equal(loaded?.status, "generated");
  assert.equal(loaded?.bookId, "book_001");
  assert.deepEqual(loaded?.selectedAssetIds, ["asset-sun-house"]);
});
