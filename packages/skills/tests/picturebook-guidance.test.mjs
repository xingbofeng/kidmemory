import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import test from "node:test";

const skillDir = path.resolve(process.cwd(), "skills", "picturebook-maker");

test("picturebook guidance documents pollinations default, prompt-only privacy, and skip-cover fallback", async () => {
  const skillDoc = await readFile(path.join(skillDir, "SKILL.md"), "utf8");
  const readme = await readFile(path.join(skillDir, "README.md"), "utf8");
  const combined = `${skillDoc}\n${readme}`;

  assert.match(combined, /Pollinations/i);
  assert.match(combined, /prompt-only|text prompt/i);
  assert.match(combined, /skip cover|跳过封面/i);
});
