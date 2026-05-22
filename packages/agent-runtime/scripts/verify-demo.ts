import { fileURLToPath } from "node:url";

import { runCommand } from "./lib.ts";

export type DemoVerificationCommandRunner = (command: string, args: string[]) => Promise<void> | void;

export async function runDemoVerification(commandRunner: DemoVerificationCommandRunner = runCommand): Promise<void> {
  await commandRunner("npm", ["run", "check-env"]);
  await commandRunner("npm", ["run", "check-model"]);
  try {
    await commandRunner("npm", ["run", "check-provider", "--", "--workspace", "examples/provider-healthcheck"]);
  } catch (error) {
    await commandRunner("npm", ["run", "demo:inspect", "--", "--workspace", "examples/provider-healthcheck"]);
    throw error;
  }
  await commandRunner("npm", [
    "run",
    "demo:prepare",
    "--",
    "--preset",
    "storybook",
    "--workspace",
    "examples/storybook",
  ]);
  await commandRunner("npm", [
    "run",
    "demo:run",
    "--",
    "--preset",
    "storybook",
    "--workspace",
    "examples/storybook",
    "--executor",
    "agent",
  ]);
  await commandRunner("npm", ["run", "demo:inspect", "--", "--workspace", "examples/storybook"]);
  await commandRunner("npm", ["run", "demo:prepare", "--", "--preset", "video", "--workspace", "examples/video"]);
  await commandRunner("npm", ["run", "demo:run", "--", "--preset", "video", "--workspace", "examples/video", "--executor", "agent"]);
  await commandRunner("npm", ["run", "demo:inspect", "--", "--workspace", "examples/video"]);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  await runDemoVerification();
}
