import path from "node:path";
import { fileURLToPath } from "node:url";

import { RUN_PRESETS, type DemoPreset } from "./demo-presets.ts";
import {
  assertOpenAIProviderEnvValid,
  assertStorybookOutputContract,
  loadDefaultEnvFile,
  readEnvValue,
  parseArgs,
  resolveWorkspace,
  runWorkspaceDemo,
} from "./lib.ts";

type ExecutorKind = "sandbox" | "agent";

function readPreset(value: string | boolean | undefined): DemoPreset {
  return value === "video" ? "video" : "storybook";
}

function readExecutor(value: string | boolean | undefined): ExecutorKind {
  if (value === "sandbox" || value === "agent") {
    return value;
  }
  return "agent";
}

function resolveDemoWorkspace(preset: DemoPreset, workspaceArg?: string): string {
  return workspaceArg && workspaceArg.trim().length > 0 ? workspaceArg : `examples/${preset}`;
}

function readPresetPrompt(preset: DemoPreset): string {
  return RUN_PRESETS[preset].prompt;
}

export async function runDemoPreset(preset: DemoPreset, workspaceArg: string, promptArg: string): Promise<void> {
  await loadDefaultEnvFile();
  assertOpenAIProviderEnvValid();

  const workspaceDir = resolveWorkspace(workspaceArg);
  const config = RUN_PRESETS[preset];
  const result = await runWorkspaceDemo({
    workspaceDir,
    prompt: promptArg,
    requiredOutputFiles: config.requiredOutputFiles,
  });

  if (config.validateOutput === "storybook") {
    await assertStorybookOutputContract(workspaceDir);
  }

  console.log(`Run succeeded: ${result.runId}`);
  console.log(`Artifacts: ${result.artifacts.length}`);
  console.log("Required files:");
  for (const requiredOutputFile of config.requiredOutputFiles) {
    console.log(`- ${requiredOutputFile}`);
  }
  console.log(`Session: ${path.relative(process.cwd(), path.join(workspaceDir, ".kidmemory", "sessions", `${result.sessionId}.jsonl`))}`);
  console.log(`Latest result: ${path.relative(process.cwd(), path.join(workspaceDir, ".kidmemory", "sessions", `${result.sessionId}.latest.json`))}`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const args = parseArgs();
  const preset = readPreset(args.preset);
  const workspace = resolveDemoWorkspace(preset, typeof args.workspace === "string" ? args.workspace : undefined);
  const defaultPrompt = readPresetPrompt(preset);
  const promptArg = readEnvValue(typeof args.prompt === "string" ? args.prompt : undefined);
  const prompt = promptArg && promptArg.length > 0 ? promptArg : defaultPrompt;
  const executor = readExecutor(args.executor);
  const previousExecutor = process.env.AGENT_RUNTIME_EXECUTOR;

  process.env.AGENT_RUNTIME_EXECUTOR = executor;
  try {
    await runDemoPreset(preset, workspace, prompt);
  } finally {
    if (previousExecutor === undefined) {
      delete process.env.AGENT_RUNTIME_EXECUTOR;
    } else {
      process.env.AGENT_RUNTIME_EXECUTOR = previousExecutor;
    }
  }
}
