import assert from "node:assert/strict";
import { test } from "node:test";

import { summarizeEnvironmentChecks } from "../../../../src/modules/config/providers/environment-check.ts";

test("environment summary separates passing checks from actionable blockers", () => {
  const summary = summarizeEnvironmentChecks([
    { name: "node", ok: true, detail: "[milestone]" },
    { name: "flutter", ok: false, detail: "command not found", action: "Install Flutter SDK and enable macOS desktop support." },
    { name: "npm install", ok: false, detail: "ENOTFOUND registry.npmjs.org", action: "Restore npm registry network access." },
  ]);

  assert.equal(summary.ok, false);
  assert.deepEqual(summary.passing.map((item) => item.name), ["node"]);
  assert.deepEqual(summary.blockers.map((item) => item.name), ["flutter", "npm install"]);
  assert.match(summary.blockers[0].action, /Flutter SDK/);
});
