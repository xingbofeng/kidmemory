#!/usr/bin/env node
import { spawnSync } from "node:child_process";
import { createServer } from "node:net";
import { summarizeEnvironmentChecks } from "../packages/backend/src/modules/config/providers/environment-check.ts";

const checks = [];

checks.push(commandCheck("node", ["--version"], "Install Node.js 22 or newer."));
checks.push(commandCheck("npm", ["--version"], "Install npm with Node.js 22 or newer."));
checks.push(commandCheck("flutter", ["--version"], "Install Flutter SDK and enable macOS desktop support."));
checks.push(commandCheck("dart", ["--version"], "Install Flutter SDK; Dart is bundled with Flutter."));
checks.push(commandCheck("psql", ["--version"], "Install PostgreSQL client tools."));

checks.push(await portCheck(4317));

const summary = summarizeEnvironmentChecks(checks);
console.log(JSON.stringify(summary, null, 2));
process.exitCode = summary.ok ? 0 : 1;

function commandCheck(command, args, action) {
  const result = spawnSync(command, args, { encoding: "utf8" });
  return {
    name: command,
    ok: result.status === 0,
    detail: result.status === 0 ? (result.stdout || result.stderr).trim() : (result.stderr || result.error?.message || "command failed").trim(),
    action,
  };
}

function portCheck(port) {
  return new Promise((resolve) => {
    const server = createServer();
    server.once("error", (error) => {
      resolve({
        name: `local port ${port}`,
        ok: false,
        detail: error.message,
        action: "Allow the sidecar to listen on 127.0.0.1 or choose a free KIDMEMORY_SIDECAR_PORT.",
      });
    });
    server.listen(port, "127.0.0.1", () => {
      server.close(() => resolve({
        name: `local port ${port}`,
        ok: true,
        detail: "127.0.0.1 bind check passed",
      }));
    });
  });
}
