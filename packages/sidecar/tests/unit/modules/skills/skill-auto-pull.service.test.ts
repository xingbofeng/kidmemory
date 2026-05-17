import assert from "node:assert/strict";
import test from "node:test";

import {
  decideAutoPull,
  resolveSkillPullSource,
} from "../../../../src/modules/skills/skill-auto-pull.service.ts";
import type { SkillRegistryEntry } from "../../../../src/modules/skills/skill-loader.service.ts";

test("resolveSkillPullSource prefers explicit pull config over source URL parsing", () => {
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

test("resolveSkillPullSource falls back to GitHub tree URL parsing", () => {
  const entry = {
    id: "hyperframes",
    source: "https://github.com/heygen-com/hyperframes/tree/main/skills/hyperframes",
    version: "main",
    path: "skills/hyperframes",
    entry: "SKILL.md",
  } satisfies SkillRegistryEntry;

  const source = resolveSkillPullSource(entry);
  assert.equal(source.repoUrl, "https://github.com/heygen-com/hyperframes.git");
  assert.equal(source.branch, "main");
  assert.equal(source.repoPath, "skills/hyperframes");
});

test("decideAutoPull honors explicit disable", () => {
  assert.equal(decideAutoPull("0", true), false);
  assert.equal(decideAutoPull("false", true), false);
});

test("decideAutoPull auto mode pulls only when skills are missing", () => {
  assert.equal(decideAutoPull(undefined, true), true);
  assert.equal(decideAutoPull(undefined, false), false);
  assert.equal(decideAutoPull("auto", true), true);
  assert.equal(decideAutoPull("auto", false), false);
});

test("decideAutoPull explicit enable always pulls", () => {
  assert.equal(decideAutoPull("1", false), true);
  assert.equal(decideAutoPull("true", false), true);
});

