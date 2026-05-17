import { execFile } from "node:child_process";
import { access, cp, mkdtemp, rm } from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { promisify } from "node:util";

import { Inject, Injectable, Logger, OnModuleInit } from "@nestjs/common";

import { SkillLoaderService, type SkillRegistryEntry } from "./skill-loader.service.ts";
import { SkillRegistryService } from "./skill-registry.service.ts";

const execFileAsync = promisify(execFile);

@Injectable()
export class SkillAutoPullService implements OnModuleInit {
  private readonly logger = new Logger(SkillAutoPullService.name);

  constructor(
    @Inject(SkillLoaderService) private readonly loader: SkillLoaderService,
    @Inject(SkillRegistryService) private readonly registry: SkillRegistryService,
  ) {}

  async onModuleInit() {
    const registryFile = await this.loader.loadRegistry();
    const missingSkillEntries = await detectMissingSkills(
      this.loader.getSkillsRootDir(),
      registryFile.skills,
    );

    if (!decideAutoPull(process.env.KIDMEMORY_SKILLS_AUTO_PULL, missingSkillEntries.length > 0)) {
      return;
    }

    const strict = parseBoolean(process.env.KIDMEMORY_SKILLS_AUTO_PULL_STRICT, false);
    const clean = parseBoolean(process.env.KIDMEMORY_SKILLS_AUTO_PULL_CLEAN, false);

    try {
      const result = await this.pullFromRegistry({ clean, registryFile });
      this.logger.log(
        `Skill auto-pull complete: pulled=${result.pulled} repositories=${result.repositories} clean=${clean} missingBefore=${missingSkillEntries.length}`,
      );
      await this.registry.refresh();
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      this.logger.error(`Skill auto-pull failed: ${message}`);
      if (strict) {
        throw error;
      }
    }
  }

  private async pullFromRegistry(options: { clean: boolean; registryFile: { skills: SkillRegistryEntry[] } }) {
    const registryFile = options.registryFile;
    const skillsRootDir = this.loader.getSkillsRootDir();
    const tempRoot = await mkdtemp(path.join(os.tmpdir(), "kidmemory-skills-pull-"));
    const clonedRepos = new Map<string, string>();

    if (options.clean) {
      await rm(path.join(skillsRootDir, "skills"), { recursive: true, force: true });
      await rm(path.join(skillsRootDir, "registries"), { recursive: true, force: true });
    }

    try {
      for (const entry of registryFile.skills) {
        const source = resolveSkillPullSource(entry);
        const cloneKey = `${source.repoUrl}#${source.branch}`;

        if (!clonedRepos.has(cloneKey)) {
          const cloneDir = path.join(tempRoot, String(clonedRepos.size));
          await gitClone(source.repoUrl, source.branch, cloneDir);
          clonedRepos.set(cloneKey, cloneDir);
        }

        const cloneDir = clonedRepos.get(cloneKey);
        if (!cloneDir) {
          throw new Error(`Missing cloned repository for key: ${cloneKey}`);
        }

        const sourceDir = path.join(cloneDir, source.repoPath);
        const destinationDir = path.resolve(skillsRootDir, entry.path);
        await rm(destinationDir, { recursive: true, force: true });
        await cp(sourceDir, destinationDir, { recursive: true });
      }

      return {
        pulled: registryFile.skills.length,
        repositories: clonedRepos.size,
      };
    } finally {
      await rm(tempRoot, { recursive: true, force: true });
    }
  }
}

async function gitClone(repoUrl: string, branch: string, targetDir: string) {
  await execFileAsync(
    "git",
    ["clone", "--depth", "1", "--branch", branch, repoUrl, targetDir],
    {
      env: process.env,
      timeout: 120000,
      maxBuffer: 16 * 1024 * 1024,
    },
  );
}

export function resolveSkillPullSource(entry: SkillRegistryEntry) {
  if (entry.pull) {
    const repoUrl = entry.pull.repo.trim();
    const branch = entry.pull.ref.trim();
    const repoPath = entry.pull.subPath.trim().replace(/^\/+|\/+$/g, "");
    if (!repoUrl || !branch || !repoPath) {
      throw new Error(
        `Invalid pull config for ${entry.id}: require pull.repo, pull.ref, pull.subPath`,
      );
    }
    return { repoUrl, branch, repoPath };
  }

  let parsed: URL;
  try {
    parsed = new URL(entry.source);
  } catch {
    throw new Error(`Invalid skill source URL for ${entry.id}: ${entry.source}`);
  }

  if (parsed.hostname !== "github.com") {
    throw new Error(`Unsupported skill source host for ${entry.id}: ${parsed.hostname}`);
  }

  const parts = parsed.pathname.split("/").filter(Boolean);
  if (parts.length < 5 || parts[2] !== "tree") {
    throw new Error(`Unsupported GitHub tree URL for ${entry.id}: ${entry.source}`);
  }

  const owner = parts[0];
  const repo = parts[1];
  const branch = parts[3];
  const repoPath = parts.slice(4).join("/");
  return {
    repoUrl: `https://github.com/${owner}/${repo}.git`,
    branch,
    repoPath,
  };
}

export function decideAutoPull(mode: string | undefined, hasMissingSkills: boolean) {
  const normalized = (mode || "").trim().toLowerCase();
  if (["0", "false", "no", "off"].includes(normalized)) {
    return false;
  }
  if (["1", "true", "yes", "on"].includes(normalized)) {
    return true;
  }
  return hasMissingSkills;
}

async function detectMissingSkills(skillsRootDir: string, entries: SkillRegistryEntry[]) {
  const missing: string[] = [];
  for (const entry of entries) {
    const entryFile = path.resolve(skillsRootDir, entry.path, entry.entry);
    try {
      await access(entryFile);
    } catch {
      missing.push(entry.id);
    }
  }
  return missing;
}
