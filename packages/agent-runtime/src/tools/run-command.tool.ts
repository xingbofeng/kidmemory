import { spawn } from "node:child_process";

import type { AgentTool } from "../index.js";
import { readRequiredString, readStringArray } from "./path-policy.js";

const DEFAULT_ALLOWED_COMMANDS = ["node", "npm", "npx", "python", "python3"];

export function createRunCommandTool(options: {
  workspaceDir: string;
  timeoutMs?: number;
  allowedCommands?: string[];
}): AgentTool {
  return {
    id: "run_command",
    name: "Run Command",
    description: "Run an allowed command inside the workspace. Pass the executable as command and arguments separately. For shell pipelines use command=\"bash\" and args=[\"-lc\", \"...\"] rather than putting spaces in command.",
    source: "workspace",
    inputSchema: {
      type: "object",
      properties: {
        command: { type: "string", description: "Executable name only, for example bash, npm, npx, node, python3." },
        args: {
          type: "array",
          items: { type: "string" },
          description: "Command arguments. For compound shell commands use [\"-lc\", \"cd work && npm run render\"].",
        },
      },
      required: ["command"],
      additionalProperties: false,
    },
    risk: "high",
    execute: async (input) => runWorkspaceCommand(options, input),
  };
}

async function runWorkspaceCommand(
  options: { workspaceDir: string; timeoutMs?: number; allowedCommands?: string[] },
  input: unknown,
) {
  const command = readRequiredString(input, "command", "Missing required command.");
  const args = readStringArray(input, "args");
  const allowedCommands = new Set(options.allowedCommands ?? DEFAULT_ALLOWED_COMMANDS);
  if (!allowedCommands.has(command)) {
    throw new Error(`Command is not allowed: ${command}`);
  }

  return new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      cwd: options.workspaceDir,
      env: minimalCommandEnv(),
      stdio: ["ignore", "pipe", "pipe"],
    });
    const timeout = setTimeout(() => {
      child.kill("SIGTERM");
      reject(new Error(`Command timed out after ${options.timeoutMs ?? 60_000}ms.`));
    }, options.timeoutMs ?? 60_000);
    const stdout = new Array<Buffer>();
    const stderr = new Array<Buffer>();

    child.stdout.on("data", (chunk: Buffer) => stdout.push(chunk));
    child.stderr.on("data", (chunk: Buffer) => stderr.push(chunk));
    child.on("error", (error) => {
      clearTimeout(timeout);
      reject(error);
    });
    child.on("close", (exitCode) => {
      clearTimeout(timeout);
      resolve({
        ok: exitCode === 0,
        command,
        args,
        exitCode,
        stdout: Buffer.concat(stdout).toString("utf8"),
        stderr: Buffer.concat(stderr).toString("utf8"),
      });
    });
  });
}

function minimalCommandEnv(): NodeJS.ProcessEnv {
  const env: NodeJS.ProcessEnv = {};
  for (const key of ["PATH", "SystemRoot", "WINDIR"]) {
    const value = process.env[key];
    if (value) env[key] = value;
  }
  return env;
}
