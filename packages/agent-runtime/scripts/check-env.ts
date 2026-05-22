import path from "node:path";
import { URL, fileURLToPath } from "node:url";

import { SkillDeckProvider, discoverSkillRoots } from "../src/index.ts";
import {
  assertOpenAIProviderEnvValid,
  loadDefaultEnvFile,
  parseArgs,
  pathExists,
  readEnvValue,
  readOptionalBooleanEnvValue,
  resolveWorkspace,
} from "./lib.ts";

export type EnvironmentWorkspaceCheck = {
  workspaceDir: string;
  requiredSkills?: string[];
};

export type EnvironmentCheckRequest = {
  workspaces: EnvironmentWorkspaceCheck[];
  env?: Record<string, string | undefined>;
};

export type EnvironmentCheckResult = {
  ok: boolean;
  errors: string[];
  messages: string[];
};

export async function collectEnvironmentCheck(request: EnvironmentCheckRequest): Promise<EnvironmentCheckResult> {
  const errors = new Array<string>();
  const messages = new Array<string>();
  const env = request.env ?? process.env;
  const apiKey = readEnvValue(env.OPENAI_API_KEY);
  const baseURL = readEnvValue(env.OPENAI_BASE_URL);
  const model = readEnvValue(env.OPENAI_MODEL);

  try {
    assertOpenAIProviderEnvValid(env);
  } catch (error) {
    errors.push(error instanceof Error ? error.message : "OpenAI provider environment is invalid.");
  }
  if (!model) {
    errors.push("OPENAI_MODEL is required to run the Agent Runtime demo.");
  }
  messages.push(`OPENAI_API_KEY: ${apiKey ? "configured" : "missing"}`);
  messages.push(`OPENAI_BASE_URL: ${baseURL ? "configured" : "not configured"}`);
  messages.push(`OPENAI_MODEL: ${model ? "configured" : "not configured"}`);
  messages.push(`OPENAI_PROVIDER_HOST: ${readOpenAIProviderHost(env)}`);
  messages.push(`OPENAI_USE_RESPONSES: ${readOpenAIUseResponses(env)}`);

  for (const workspace of request.workspaces) {
    for (const relativePath of [".kidmemory/runtime.md", ".kidmemory/manifest.json", "input", "work", "output"]) {
      const target = path.join(workspace.workspaceDir, relativePath);
      if (!(await pathExists(target))) {
        errors.push(`Workspace missing ${relativePath}: ${workspace.workspaceDir}`);
      }
    }
    const skillRoots = await discoverSkillRoots({ workspaceDir: workspace.workspaceDir });
    messages.push(`Skill roots for ${path.relative(process.cwd(), workspace.workspaceDir)}: ${skillRoots.join(", ") || "(none)"}`);
    const skills = await new SkillDeckProvider().load({ roots: skillRoots });
    const skillNames = new Set(skills.openAIAgentsLocalSkills.map((skill) => skill.name));
    for (const requiredSkill of workspace.requiredSkills ?? []) {
      if (!skillNames.has(requiredSkill)) {
        errors.push(`Workspace missing required skill ${requiredSkill}: ${workspace.workspaceDir}`);
      }
    }
  }

  return {
    ok: errors.length === 0,
    errors,
    messages,
  };
}

function readOpenAIProviderHost(env: Record<string, string | undefined>): string {
  const baseURL = readEnvValue(env.OPENAI_BASE_URL);
  if (!baseURL) return "not configured";
  try {
    return new URL(baseURL).host;
  } catch {
    return "invalid";
  }
}

function readOpenAIUseResponses(env: Record<string, string | undefined>): string {
  const useResponses = readOptionalBooleanEnvValue(env.OPENAI_USE_RESPONSES);
  return typeof useResponses === "boolean" ? String(useResponses) : "not configured";
}

async function main(): Promise<void> {
  await loadDefaultEnvFile();
  const args = parseArgs();
  const result = await collectEnvironmentCheck({
    workspaces: [
      {
        workspaceDir: resolveWorkspace(typeof args.storybook === "string" ? args.storybook : "examples/storybook"),
        requiredSkills: ["kidmemory-storybook-demo-writer"],
      },
      {
        workspaceDir: resolveWorkspace(typeof args.video === "string" ? args.video : "examples/video"),
        requiredSkills: ["kidmemory-video-demo-director"],
      },
    ],
  });

  for (const error of result.errors) console.error(error);
  for (const message of result.messages) console.log(message);

  if (result.ok) {
    console.log("Agent runtime environment looks ready.");
  } else {
    process.exitCode = 1;
  }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  await main();
}
