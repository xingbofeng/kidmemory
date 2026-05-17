import assert from "node:assert/strict";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { SkillLoaderService } from "../../../../src/modules/skills/skill-loader.service.ts";

test("skill loader uses fixed ~/.kidmemory registry and root", () => {
  const loader = new SkillLoaderService();
  assert.equal(loader.getSkillsRootDir(), path.resolve(os.homedir(), ".kidmemory"));
  assert.equal(loader.getRegistryPath(), path.resolve(os.homedir(), ".kidmemory", "skill-registry.json"));
});
