import { existsSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const agentRuntimeDir = resolve(scriptDir, "../../agent-runtime");

const requiredInstallPaths = [
  "node_modules/typescript/bin/tsc",
  "node_modules/@types/node/package.json",
].map((path) => resolve(agentRuntimeDir, path));

const npmCommand = process.platform === "win32" ? "npm.cmd" : "npm";

function run(command, args) {
  const result = spawnSync(command, args, {
    cwd: agentRuntimeDir,
    stdio: "inherit",
  });

  if (result.error) {
    throw result.error;
  }

  if (result.status !== 0) {
    process.exit(result.status ?? 1);
  }
}

if (requiredInstallPaths.some((path) => !existsSync(path))) {
  run(npmCommand, ["ci"]);
}

run(npmCommand, ["run", "compile"]);
