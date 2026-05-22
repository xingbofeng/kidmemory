import assert from "node:assert/strict";
import fs from "node:fs/promises";
import path from "node:path";
import test from "node:test";

import * as runtime from "../../src/index.ts";

test("package exports runtime JavaScript and declaration files from dist", async () => {
  const packageJsonPath = path.resolve(import.meta.dirname, "..", "..", "package.json");
  const packageJson = JSON.parse(await fs.readFile(packageJsonPath, "utf8")) as {
    main?: string;
    types?: string;
    exports?: {
      "."?: {
        default?: string;
        types?: string;
      };
    };
    scripts?: Record<string, string>;
  };

  assert.equal(packageJson.main, "./dist/index.js");
  assert.equal(packageJson.types, "./dist/index.d.ts");
  assert.equal(packageJson.exports?.["."]?.default, "./dist/index.js");
  assert.equal(packageJson.exports?.["."]?.types, "./dist/index.d.ts");
  assert.equal(packageJson.scripts?.["verify:package"], "node scripts/verify-package-export.mjs");
  assert.match(packageJson.scripts?.build ?? "", /node --run compile && node --run verify:package && node --run test/);
});

test("package does not export built-in HyperFrames tools", () => {
  assert.equal("createHyperFramesRenderTool" in runtime, false);
});

test("package does not export workspace file tools", () => {
  assert.equal("createWorkspaceFileTools" in runtime, false);
});
