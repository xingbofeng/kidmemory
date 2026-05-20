import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { SkillLoaderService } from "../../../../src/modules/skills/skill-loader.service.ts";

test("skill loader merges configured registry with scanned local skills", async () => {
  const tempDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-skill-loader-"));
  const skillsRoot = path.join(tempDir, ".kidmemory");
  const registryPath = path.join(skillsRoot, "skill-registry.json");
  const scannedSkillDir = path.join(skillsRoot, "skills", "dynamic-local");

  await fs.mkdir(path.dirname(registryPath), { recursive: true });
  await fs.writeFile(
    registryPath,
    JSON.stringify({
      skills: [
        {
          id: "hyperframes",
          source: "https://example.com/hyperframes",
          version: "main",
          path: "skills/hyperframes",
          entry: "SKILL.md",
        },
      ],
    }),
    "utf8",
  );

  await fs.mkdir(scannedSkillDir, { recursive: true });
  await fs.writeFile(path.join(scannedSkillDir, "SKILL.md"), "# Dynamic skill\n", "utf8");

  const loader = new SkillLoaderService();
  (loader as { getSkillsRootDir: () => string }).getSkillsRootDir = () => skillsRoot;

  const registry = await loader.loadRegistry();
  assert.equal(registry.skills.length, 2);
  assert.ok(registry.skills.find((item) => item.id === "hyperframes"));
  const dynamic = registry.skills.find((item) => item.id === "dynamic-local");
  assert.ok(dynamic);
  assert.equal(dynamic?.source, "local://skills/dynamic-local");
  assert.equal(dynamic?.path, "skills/dynamic-local");
  assert.equal(dynamic?.entry, "SKILL.md");
  assert.equal(dynamic?.version, "local");
});

test("configured registry entry wins when local folder has same skill id", async () => {
  const tempDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-skill-loader-"));
  const skillsRoot = path.join(tempDir, ".kidmemory");
  const registryPath = path.join(skillsRoot, "skill-registry.json");
  const scannedSkillDir = path.join(skillsRoot, "skills", "hyperframes");

  await fs.mkdir(path.dirname(registryPath), { recursive: true });
  await fs.writeFile(
    registryPath,
    JSON.stringify({
      skills: [
        {
          id: "hyperframes",
          source: "https://example.com/hyperframes-upstream",
          version: "main",
          path: "skills/hyperframes-custom",
          entry: "SKILL.md",
        },
      ],
    }),
    "utf8",
  );

  await fs.mkdir(scannedSkillDir, { recursive: true });
  await fs.writeFile(path.join(scannedSkillDir, "SKILL.md"), "# Local skill\n", "utf8");

  const loader = new SkillLoaderService();
  (loader as { getSkillsRootDir: () => string }).getSkillsRootDir = () => skillsRoot;

  const registry = await loader.loadRegistry();
  assert.equal(registry.skills.length, 1);
  assert.equal(registry.skills[0]?.id, "hyperframes");
  assert.equal(registry.skills[0]?.source, "https://example.com/hyperframes-upstream");
  assert.equal(registry.skills[0]?.path, "skills/hyperframes-custom");
});
