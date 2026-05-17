import assert from "node:assert/strict";
import path from "node:path";
import test from "node:test";

import { SkillLoaderService } from "../../../../src/modules/skills/skill-loader.service.ts";

test("skill loader defaults to sidecar-local registry and runtime skills root", () => {
  const originalRoot = process.env.KIDMEMORY_SKILLS_ROOT;
  const originalRegistry = process.env.KIDMEMORY_SKILL_REGISTRY_PATH;
  delete process.env.KIDMEMORY_SKILLS_ROOT;
  delete process.env.KIDMEMORY_SKILL_REGISTRY_PATH;

  try {
    const loader = new SkillLoaderService();
    assert.equal(
      loader.getSkillsRootDir(),
      path.resolve(process.cwd(), ".kidmemory", "skills"),
    );
    assert.equal(
      loader.getRegistryPath(),
      path.resolve(process.cwd(), "skills", "skill-registry.json"),
    );
  } finally {
    if (originalRoot == null) {
      delete process.env.KIDMEMORY_SKILLS_ROOT;
    } else {
      process.env.KIDMEMORY_SKILLS_ROOT = originalRoot;
    }
    if (originalRegistry == null) {
      delete process.env.KIDMEMORY_SKILL_REGISTRY_PATH;
    } else {
      process.env.KIDMEMORY_SKILL_REGISTRY_PATH = originalRegistry;
    }
  }
});

