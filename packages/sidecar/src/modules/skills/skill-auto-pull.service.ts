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
  private backgroundPullPromise?: Promise<void>;

  constructor(
    @Inject(SkillLoaderService) private readonly loader: SkillLoaderService,
    @Inject(SkillRegistryService) private readonly registry: SkillRegistryService,
  ) {}

  onModuleInit() {
    this.backgroundPullPromise ??= this.runAutoPullInBackground();
    this.backgroundPullPromise.catch((error) => {
      const message = error instanceof Error ? error.message : String(error);
      this.logger.error(`Skill auto-pull background task failed: ${message}`);
    });
  }

  private async runAutoPullInBackground() {
    try {
      const registryFile = await this.loader.loadRegistry();
      const startupManagedEntries = registryFile.skills.filter(isStartupManagedSkill);
      const missingSkillEntries = await detectMissingSkills(
        this.loader.getSkillsRootDir(),
        startupManagedEntries,
      );

      if (missingSkillEntries.length === 0) {
        return;
      }

      const result = await this.pullFromRegistry({ skills: startupManagedEntries });
      if (result.pulled > 0) {
        this.logger.log(
          `Skill auto-pull complete: pulled=${result.pulled} repositories=${result.repositories} missingBefore=${missingSkillEntries.length}`,
        );
        await this.registry.refresh();
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      this.logger.error(`Skill auto-pull failed: ${message}`);
    } finally {
      this.backgroundPullPromise = undefined;
    }
  }

  private async pullFromRegistry(options: { skills: SkillRegistryEntry[] }) {
    const registryEntries = options.skills;
    const skillsRootDir = this.loader.getSkillsRootDir();
    const tempRoot = await mkdtemp(path.join(os.tmpdir(), "kidmemory-skills-pull-"));
    const clonedRepos = new Map<string, string>();

    try {
      for (const entry of registryEntries) {
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
        pulled: registryEntries.length,
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
  if (!entry.pull) {
    throw new Error(`Invalid pull config for ${entry.id}: missing pull settings`);
  }
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

export function isStartupManagedSkill(entry: SkillRegistryEntry) {
  if (entry.id === "picturebook-maker") {
    return true;
  }
  if (entry.id === "hyperframes" || entry.id.startsWith("hyperframes-")) {
    return true;
  }
  if (entry.source.includes("github.com/heygen-com/hyperframes")) {
    return true;
  }
  return false;
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
