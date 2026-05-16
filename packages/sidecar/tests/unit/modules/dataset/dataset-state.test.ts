import assert from "node:assert/strict";
import { test } from "node:test";

import { DatasetState } from "../../../../src/infrastructure/dataset-state/dataset-state.service.ts";

test("activates persistent dataset db for subsequent reads after persistent import", async () => {
  const memoryDb = { name: "memory" };
  const postgresDb = { name: "postgres" };
  let calls = 0;
  const state = new DatasetState(memoryDb, async () => {
    calls += 1;
    return postgresDb;
  });

  assert.equal(await state.current(), memoryDb);
  assert.equal(await state.activatePersistent(), postgresDb);
  assert.equal(await state.current(), postgresDb);
  assert.equal(await state.current(), postgresDb);
  assert.equal(calls, 1);
});
