#!/usr/bin/env node
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";

import { validateSkillsRegistry } from "./validate-skills.mjs";

export async function packageSkills(options = {}) {
  const rootDir = options.rootDir ? path.resolve(options.rootDir) : path.resolve(process.cwd());
  const outDir = options.outDir ? path.resolve(options.outDir) : path.join(rootDir, "dist");

  const validation = await validateSkillsRegistry({ rootDir });
  if (!validation.ok) {
    return {
      ok: false,
      errors: validation.errors,
      manifestPath: "",
    };
  }

  await mkdir(outDir, { recursive: true });
  const manifest = {
    generatedAt: new Date().toISOString(),
    skills: validation.skills,
  };
  const manifestPath = path.join(outDir, "skills-manifest.json");
  await writeFile(manifestPath, JSON.stringify(manifest, null, 2), "utf8");

  return {
    ok: true,
    errors: [],
    manifestPath,
  };
}

async function main() {
  const result = await packageSkills();
  if (!result.ok) {
    for (const error of result.errors) {
      console.error(`- ${error}`);
    }
    process.exitCode = 1;
    return;
  }
  console.log(`Packaged skills manifest: ${result.manifestPath}`);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  await main();
}
