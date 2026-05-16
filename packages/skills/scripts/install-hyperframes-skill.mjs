#!/usr/bin/env node
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";

export async function installHyperframesSkill(options = {}) {
  const projectDir = path.resolve(options.projectDir || process.cwd());
  const dryRun = Boolean(options.dryRun);

  const config = {
    registry: "https://raw.githubusercontent.com/heygen-com/hyperframes/main/registry",
    paths: {
      blocks: "compositions",
      components: "compositions/components",
      assets: "assets",
    },
  };

  const commands = [
    "hyperframes add data-chart",
    "hyperframes add grain-overlay",
  ];

  if (!dryRun) {
    await mkdir(path.join(projectDir, "compositions", "components"), { recursive: true });
    await mkdir(path.join(projectDir, "assets"), { recursive: true });
    await writeFile(path.join(projectDir, "hyperframes.json"), JSON.stringify(config, null, 2), "utf8");
  }

  return {
    ok: true,
    projectDir,
    dryRun,
    commands,
  };
}

async function main() {
  const result = await installHyperframesSkill({ projectDir: process.cwd(), dryRun: false });
  console.log(`Hyperframes skill install scaffold ready at ${result.projectDir}`);
  for (const command of result.commands) {
    console.log(`- ${command}`);
  }
}

if (import.meta.url === `file://${process.argv[1]}`) {
  await main();
}
