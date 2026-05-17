import assert from "node:assert/strict";
import test from "node:test";

import {
  isStartupManagedSkill,
  resolveSkillPullSource,
} from "../../../../src/modules/skills/skill-auto-pull.service.ts";
import type { SkillRegistryEntry } from "../../../../src/modules/skills/skill-loader.service.ts";

test("resolveSkillPullSource requires explicit pull config", () => {
  const entry = {
    id: "demo",
    source: "https://github.com/example/ignored/tree/main/skills/demo",
    version: "main",
    path: "skills/demo",
    entry: "SKILL.md",
    pull: {
      repo: "https://github.com/acme/skills.git",
      ref: "refs/tags/v1.2.3",
      subPath: "catalog/demo",
    },
  } satisfies SkillRegistryEntry;

  const source = resolveSkillPullSource(entry);
  assert.equal(source.repoUrl, "https://github.com/acme/skills.git");
  assert.equal(source.branch, "refs/tags/v1.2.3");
  assert.equal(source.repoPath, "catalog/demo");
});

test("resolveSkillPullSource rejects entries without pull config", () => {
  const entry = {
    id: "hyperframes",
    source: "https://github.com/heygen-com/hyperframes/tree/main/skills/hyperframes",
    version: "main",
    path: "skills/hyperframes",
    entry: "SKILL.md",
  } satisfies SkillRegistryEntry;

  assert.throws(() => resolveSkillPullSource(entry), /missing pull settings/);
});

test("isStartupManagedSkill includes picturebook and hyperframes family", () => {
  const picturebook = {
    id: "picturebook-maker",
    source: "https://github.com/Hermess/picturebook-maker/tree/main/picturebook-maker",
    version: "main",
    path: "skills/picturebook-maker",
    entry: "SKILL.md",
  } satisfies SkillRegistryEntry;
  const hyperframesExtension = {
    id: "gsap",
    source: "https://github.com/heygen-com/hyperframes/tree/main/skills/gsap",
    version: "main",
    path: "skills/gsap",
    entry: "SKILL.md",
  } satisfies SkillRegistryEntry;
  const unrelated = {
    id: "foo-skill",
    source: "https://github.com/acme/skills/tree/main/foo-skill",
    version: "main",
    path: "skills/foo-skill",
    entry: "SKILL.md",
  } satisfies SkillRegistryEntry;

  assert.equal(isStartupManagedSkill(picturebook), true);
  assert.equal(isStartupManagedSkill(hyperframesExtension), true);
  assert.equal(isStartupManagedSkill(unrelated), false);
});
