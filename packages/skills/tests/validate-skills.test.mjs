import assert from "node:assert/strict";
import { mkdtemp, mkdir, writeFile, rm } from "node:fs/promises";
import path from "node:path";
import os from "node:os";
import test from "node:test";

import { validateSkillsRegistry } from "../scripts/validate-skills.mjs";

test("validateSkillsRegistry accepts a valid registry entry", async () => {
  const root = await mkdtemp(path.join(os.tmpdir(), "skills-valid-"));
  try {
    await mkdir(path.join(root, "skills", "picturebook-maker"), { recursive: true });
    await writeFile(path.join(root, "skills", "picturebook-maker", "SKILL.md"), "# skill\n", "utf8");
    await writeFile(
      path.join(root, "skill-registry.json"),
      JSON.stringify(
        {
          skills: [
            {
              id: "picturebook-maker",
              source: "https://github.com/Hermess/picturebook-maker/tree/main/picturebook-maker",
              version: "main",
              path: "skills/picturebook-maker",
              entry: "SKILL.md",
            },
          ],
        },
        null,
        2,
      ),
      "utf8",
    );

    const result = await validateSkillsRegistry({ rootDir: root });
    assert.equal(result.ok, true);
    assert.equal(result.errors.length, 0);
  } finally {
    await rm(root, { recursive: true, force: true });
  }
});

test("validateSkillsRegistry rejects missing required fields and missing entry file", async () => {
  const root = await mkdtemp(path.join(os.tmpdir(), "skills-invalid-"));
  try {
    await mkdir(path.join(root, "skills", "broken"), { recursive: true });
    await writeFile(
      path.join(root, "skill-registry.json"),
      JSON.stringify(
        {
          skills: [
            {
              id: "",
              source: "",
              version: "main",
              path: "skills/broken",
              entry: "SKILL.md",
            },
          ],
        },
        null,
        2,
      ),
      "utf8",
    );

    const result = await validateSkillsRegistry({ rootDir: root });
    assert.equal(result.ok, false);
    assert.ok(result.errors.some((item) => item.includes("id")));
    assert.ok(result.errors.some((item) => item.includes("source")));
    assert.ok(result.errors.some((item) => item.includes("SKILL.md")));
  } finally {
    await rm(root, { recursive: true, force: true });
  }
});
