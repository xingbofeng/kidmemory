import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  assertOpenAIProviderEnvValid,
  loadDefaultEnvFile,
  packageRoot,
  parseArgs,
  readProviderHealthcheckTimeoutMs,
  resolveWorkspace,
  runProviderSandboxHealthcheck,
  type CliArgs,
} from "./lib.ts";

async function main(): Promise<void> {
  await loadDefaultEnvFile();
  assertOpenAIProviderEnvValid();

  const args = parseArgs();
  const workspaceDir = resolveProviderHealthcheckWorkspace(args);

  try {
    const result = await runProviderSandboxHealthcheck({
      workspaceDir,
      timeoutMs: readProviderHealthcheckTimeoutMs(),
    });
    console.log("Provider executor healthcheck passed.");
    console.log(`Run: ${result.runId}`);
    console.log(`Workspace: ${workspaceDir}`);
    console.log("Required file: output/healthcheck.txt");
  } catch (error) {
    console.error(error instanceof Error ? error.message : "Provider executor healthcheck failed.");
    console.error(`Workspace: ${workspaceDir}`);
    process.exitCode = 1;
  }
}

export function resolveProviderHealthcheckWorkspace(args: CliArgs, suffix = Date.now().toString(36)): string {
  if (typeof args.workspace === "string") return resolveWorkspace(args.workspace);
  return path.join(packageRoot(), ".tmp", `provider-healthcheck-${suffix}`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  await main();
}
