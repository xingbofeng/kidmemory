import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";

import { Injectable } from "@nestjs/common";

export type SkillRegistryEntry = {
  id: string;
  source: string;
  version: string;
  path: string;
  entry: string;
  pull?: {
    repo: string;
    ref: string;
    subPath: string;
  };
};

export type SkillRegistryFile = {
  skills: SkillRegistryEntry[];
};

export type LoadedSkill = {
  entry: SkillRegistryEntry;
  skillDir: string;
  entryFile: string;
  content: string;
};

@Injectable()
export class SkillLoaderService {
  getSkillsRootDir() {
    return path.resolve(os.homedir(), ".kidmemory");
  }

  getRegistryPath() {
    return path.resolve(this.getSkillsRootDir(), "skill-registry.json");
  }

  async loadRegistry(): Promise<SkillRegistryFile> {
    await this.ensureDefaultRegistryExists();
    const registryPath = this.getRegistryPath();
    const raw = await fs.readFile(registryPath, "utf8");
    const parsed = JSON.parse(raw) as Partial<SkillRegistryFile>;

    if (!Array.isArray(parsed.skills)) {
      throw new Error(`Invalid skill registry format at ${registryPath}: missing skills array`);
    }

    return {
      skills: parsed.skills.map((item) => this.validateRegistryEntry(item, registryPath)),
    };
  }

  async loadSkill(entry: SkillRegistryEntry): Promise<LoadedSkill> {
    const rootDir = this.getSkillsRootDir();
    const skillDir = path.resolve(rootDir, entry.path);
    const entryFile = path.resolve(skillDir, entry.entry);
    const content = await fs.readFile(entryFile, "utf8");

    return {
      entry,
      skillDir,
      entryFile,
      content,
    };
  }

  private async ensureDefaultRegistryExists() {
    const registryPath = this.getRegistryPath();
    try {
      await fs.access(registryPath);
      return;
    } catch {
      // bootstrap below
    }

    const bundledRegistryPath = path.resolve(process.cwd(), "skills", "skill-registry.json");
    await fs.mkdir(path.dirname(registryPath), { recursive: true });
    await fs.copyFile(bundledRegistryPath, registryPath);
  }

  private validateRegistryEntry(raw: unknown, registryPath: string): SkillRegistryEntry {
    if (!raw || typeof raw !== "object") {
      throw new Error(`Invalid skill entry in ${registryPath}`);
    }

    const entry = raw as Partial<SkillRegistryEntry>;

    if (!entry.id || !entry.source || !entry.version || !entry.path || !entry.entry) {
      throw new Error(`Skill entry missing required fields in ${registryPath}`);
    }

    return {
      id: entry.id,
      source: entry.source,
      version: entry.version,
      path: entry.path,
      entry: entry.entry,
      pull: entry.pull && typeof entry.pull === "object"
        ? {
          repo: String((entry.pull as Record<string, unknown>).repo || "").trim(),
          ref: String((entry.pull as Record<string, unknown>).ref || "").trim(),
          subPath: String((entry.pull as Record<string, unknown>).subPath || "").trim(),
        }
        : undefined,
    };
  }
}
