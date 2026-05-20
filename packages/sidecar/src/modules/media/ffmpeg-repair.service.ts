import { access } from "node:fs/promises";
import { constants } from "node:fs";
import { spawn } from "node:child_process";

import { Injectable } from "@nestjs/common";

export type FfmpegRepairResult = {
  ok: boolean;
  message: string;
  code?: string;
};

const REPAIR_TIMEOUT_MS = 5 * 60 * 1000;
const FFMPEG_REPAIR_PATHS = [
  "/opt/homebrew/bin",
  "/usr/local/bin",
  "/usr/bin",
  "/bin",
  "/usr/sbin",
  "/sbin",
];

@Injectable()
export class FfmpegRepairService {
  async repair(): Promise<FfmpegRepairResult> {
    if (await commandSucceeds("ffmpeg", ["-version"])) {
      return { ok: true, message: "FFmpeg is already available." };
    }

    const configured = process.env.KIDMEMORY_FFMPEG_REPAIR_COMMAND?.trim();
    if (configured) {
      return runShellRepairCommand(configured, "KIDMEMORY_FFMPEG_REPAIR_COMMAND");
    }

    if (process.platform !== "darwin") {
      return {
        ok: false,
        code: "FFMPEG_REPAIR_UNSUPPORTED_PLATFORM",
        message: "Automatic FFmpeg repair is only configured for macOS in the local setup runner.",
      };
    }

    const brew = await findExecutable(["/opt/homebrew/bin/brew", "/usr/local/bin/brew"]);
    if (!brew) {
      return {
        ok: false,
        code: "FFMPEG_REPAIR_BREW_MISSING",
        message: "Homebrew was not found, so FFmpeg could not be installed automatically.",
      };
    }

    const installed = await runCommand(brew, ["install", "ffmpeg"]);
    if (!installed.ok) {
      return {
        ok: false,
        code: "FFMPEG_REPAIR_FAILED",
        message: shortOutput(installed.output) || "Homebrew could not install FFmpeg.",
      };
    }

    if (await commandSucceeds("ffmpeg", ["-version"])) {
      return { ok: true, message: "FFmpeg installed by setup runner." };
    }

    return {
      ok: false,
      code: "FFMPEG_REPAIR_NOT_ON_PATH",
      message: "FFmpeg install completed, but ffmpeg is still not available on PATH.",
    };
  }
}

async function runShellRepairCommand(command: string, label: string): Promise<FfmpegRepairResult> {
  const result = await runCommand(command, [], { shell: true });
  if (result.ok) {
    if (await commandSucceeds("ffmpeg", ["-version"])) {
      return { ok: true, message: `FFmpeg repair command succeeded: ${label}.` };
    }
    return {
      ok: false,
      code: "FFMPEG_REPAIR_NOT_ON_PATH",
      message: `FFmpeg repair command succeeded, but ffmpeg is still not available on PATH: ${label}.`,
    };
  }
  return {
    ok: false,
    code: "FFMPEG_REPAIR_FAILED",
    message: shortOutput(result.output) || `FFmpeg repair command failed: ${label}.`,
  };
}

async function commandSucceeds(command: string, args: string[]) {
  return (await runCommand(command, args)).ok;
}

async function findExecutable(candidates: string[]) {
  for (const candidate of candidates) {
    try {
      await access(candidate, constants.X_OK);
      return candidate;
    } catch {
      // Try the next known install location.
    }
  }
  return undefined;
}

async function runCommand(
  command: string,
  args: string[],
  options: { shell?: boolean } = {},
): Promise<{ ok: boolean; output: string }> {
  return await new Promise((resolve) => {
    const child = spawn(command, args, {
      shell: options.shell ?? false,
      env: { ...process.env, PATH: ffmpegRepairPath() },
      stdio: ["ignore", "pipe", "pipe"],
    });
    const chunks: string[] = [];
    const timer = setTimeout(() => {
      child.kill("SIGTERM");
      chunks.push(`Timed out after ${Math.round(REPAIR_TIMEOUT_MS / 60000)} minutes.`);
    }, REPAIR_TIMEOUT_MS);

    child.stdout.setEncoding("utf8");
    child.stderr.setEncoding("utf8");
    child.stdout.on("data", (chunk) => chunks.push(chunk));
    child.stderr.on("data", (chunk) => chunks.push(chunk));
    child.on("error", (error) => {
      clearTimeout(timer);
      resolve({ ok: false, output: error.message });
    });
    child.on("close", (code) => {
      clearTimeout(timer);
      resolve({ ok: code === 0, output: chunks.join("") });
    });
  });
}

function ffmpegRepairPath() {
  const configured = process.env.KIDMEMORY_FFMPEG_REPAIR_PATH?.trim();
  if (configured) return configured;
  return [process.env.PATH, ...FFMPEG_REPAIR_PATHS]
    .filter((entry): entry is string => Boolean(entry?.trim()))
    .join(":");
}

function shortOutput(output: string) {
  return output.replace(/\s+/g, " ").trim().slice(0, 500);
}
