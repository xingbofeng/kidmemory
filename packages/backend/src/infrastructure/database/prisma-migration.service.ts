import { spawn } from "node:child_process";
import path from "node:path";
import { Inject, Injectable } from "@nestjs/common";

import { AppConfigService, type AppConfig } from "../config/app-config.service.ts";

export type PrismaMigrationResult = {
  ok: boolean;
  service: "prisma-migrate";
  command: string;
  message: string;
  stdout?: string;
  stderr?: string;
};

type ProcessRunner = (
  command: string,
  args: string[],
  options: {
    cwd: string;
    env: NodeJS.ProcessEnv;
  },
) => Promise<{ code: number | null; stdout: string; stderr: string }>;

export class PrismaMigrationService {
  private readonly config: AppConfigService;
  private readonly runner: ProcessRunner;
  private readonly cwd: string;

  constructor(config: AppConfigService, runner: ProcessRunner = spawnProcess, cwd = path.resolve(import.meta.dirname, "../../..")) {
    this.config = config;
    this.runner = runner;
    this.cwd = cwd;
  }

  async deploy(): Promise<PrismaMigrationResult> {
    return this.runPrismaCommand(["prisma", "migrate", "deploy"], "Prisma migrations applied successfully.");
  }

  async deployWithRepair(): Promise<PrismaMigrationResult> {
    const deployResult = await this.deploy();
    if (deployResult.ok) return deployResult;

    const repairResult = await this.runPrismaCommand(
      ["prisma", "db", "push", "--accept-data-loss"],
      "Prisma schema repaired with db push.",
    );
    if (repairResult.ok) return repairResult;

    return {
      ...repairResult,
      message: `${deployResult.message} Fallback db push also failed.`,
      stdout: [deployResult.stdout, repairResult.stdout].filter(Boolean).join("\n"),
      stderr: [deployResult.stderr, repairResult.stderr].filter(Boolean).join("\n"),
    };
  }

  private async runPrismaCommand(args: string[], successMessage: string): Promise<PrismaMigrationResult> {
    const command = "npx";
    const env = {
      ...process.env,
      DATABASE_URL: postgresConnectionUrl(this.config.config),
    };
    const result = await this.runner(command, args, { cwd: this.cwd, env });
    const commandLabel = `${command} ${args.join(" ")}`;
    if (result.code === 0) {
      return {
        ok: true,
        service: "prisma-migrate",
        command: commandLabel,
        message: successMessage,
        stdout: sanitizeMigrationOutput(result.stdout),
        stderr: sanitizeMigrationOutput(result.stderr),
      };
    }
    return {
      ok: false,
      service: "prisma-migrate",
      command: commandLabel,
      message: `Prisma migration failed with exit code ${result.code ?? "unknown"}.`,
      stdout: sanitizeMigrationOutput(result.stdout),
      stderr: sanitizeMigrationOutput(result.stderr),
    };
  }
}

Inject(AppConfigService)(PrismaMigrationService, undefined, 0);
Injectable()(PrismaMigrationService);

function postgresConnectionUrl(config: AppConfig) {
  if (config.postgres.connectionUrl) return config.postgres.connectionUrl;
  const credentials = config.postgres.password
    ? `${encodeURIComponent(config.postgres.user)}:${encodeURIComponent(config.postgres.password)}`
    : encodeURIComponent(config.postgres.user);
  return `postgresql://${credentials}@${config.postgres.host}:${config.postgres.port}/${config.postgres.database}`;
}

function spawnProcess(command: string, args: string[], options: { cwd: string; env: NodeJS.ProcessEnv }) {
  return new Promise<{ code: number | null; stdout: string; stderr: string }>((resolve, reject) => {
    const child = spawn(command, args, {
      cwd: options.cwd,
      env: options.env,
      shell: false,
      stdio: ["ignore", "pipe", "pipe"],
    });
    let stdout = "";
    let stderr = "";
    child.stdout.setEncoding("utf8");
    child.stderr.setEncoding("utf8");
    child.stdout.on("data", (chunk) => {
      stdout += chunk;
    });
    child.stderr.on("data", (chunk) => {
      stderr += chunk;
    });
    child.on("error", reject);
    child.on("close", (code) => resolve({ code, stdout, stderr }));
  });
}

function sanitizeMigrationOutput(value: string) {
  return value
    .replace(/postgres(?:ql)?:\/\/[^\s]+/gi, "postgresql://[redacted]")
    .replace(/password=[^\s]+/gi, "password=[redacted]")
    .replace(/sk-[A-Za-z0-9_-]+/g, "[redacted]");
}
