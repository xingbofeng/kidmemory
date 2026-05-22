import path from "node:path";
import { fileURLToPath } from "node:url";

import { PREPARE_PRESETS, type DemoPreset } from "./demo-presets.ts";
import { parseArgs, prepareDemoWorkspace, resolveWorkspace } from "./lib.ts";

function readPreset(value: string | boolean | undefined): DemoPreset {
  return value === "video" ? "video" : "storybook";
}

export async function runPrepareDemoWorkspace(preset: DemoPreset, workspaceArg?: string): Promise<void> {
  const workspaceDir = resolveWorkspace(workspaceArg ?? `examples/${preset}`);
  const config = PREPARE_PRESETS[preset];
  await prepareDemoWorkspace({
    workspaceDir,
    forceRuntimeInstructions: true,
    notes: config.notes,
    assets: config.assets,
  });

  console.log(`Prepared ${preset} demo workspace: ${path.relative(process.cwd(), workspaceDir)}`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const args = parseArgs();
  const preset = readPreset(args.preset);
  const workspace = typeof args.workspace === "string" && args.workspace.trim().length > 0 ? args.workspace : `examples/${preset}`;
  await runPrepareDemoWorkspace(preset, workspace);
}
