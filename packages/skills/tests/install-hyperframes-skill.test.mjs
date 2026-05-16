import assert from "node:assert/strict";
import { mkdtemp, readFile, rm } from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { installHyperframesSkill } from "../scripts/install-hyperframes-skill.mjs";

test("installHyperframesSkill writes hyperframes.json and registry paths", async () => {
  const root = await mkdtemp(path.join(os.tmpdir(), "hyperframes-install-"));
  try {
    const result = await installHyperframesSkill({ projectDir: root, dryRun: false });
    assert.equal(result.ok, true);

    const configRaw = await readFile(path.join(root, "hyperframes.json"), "utf8");
    const config = JSON.parse(configRaw);
    assert.equal(config.registry, "https://raw.githubusercontent.com/heygen-com/hyperframes/main/registry");
    assert.equal(config.paths.blocks, "compositions");
    assert.equal(config.paths.components, "compositions/components");
    assert.ok(result.commands.some((item) => item.includes("hyperframes add")));
  } finally {
    await rm(root, { recursive: true, force: true });
  }
});

test("installHyperframesSkill dry run returns commands without writing files", async () => {
  const root = await mkdtemp(path.join(os.tmpdir(), "hyperframes-dryrun-"));
  try {
    const result = await installHyperframesSkill({ projectDir: root, dryRun: true });
    assert.equal(result.ok, true);
    assert.ok(result.commands.length > 0);
  } finally {
    await rm(root, { recursive: true, force: true });
  }
});
