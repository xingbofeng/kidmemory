import assert from "node:assert/strict";
import test from "node:test";

import { buildPollinationsPromptUrl, validatePromptOnlyPayload } from "../skills/picturebook-maker/extensions/generate_pollinations_image.mjs";

test("buildPollinationsPromptUrl encodes prompt and uses pollinations endpoint", () => {
  const url = buildPollinationsPromptUrl("a warm child memory cover");
  assert.match(url, /^https:\/\/image\.pollinations\.ai\/prompt\//);
  assert.ok(url.includes("a%20warm%20child%20memory%20cover"));
});

test("validatePromptOnlyPayload rejects photo inputs", () => {
  assert.throws(() => validatePromptOnlyPayload({ prompt: "ok", imagePath: "./kid.png" }), /prompt-only/i);
  assert.throws(() => validatePromptOnlyPayload({ prompt: "ok", imageUrl: "https://x/y.png" }), /prompt-only/i);
  assert.doesNotThrow(() => validatePromptOnlyPayload({ prompt: "ok" }));
});
