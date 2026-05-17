import fs from "node:fs/promises";
import path from "node:path";
import { Inject, Injectable } from "@nestjs/common";

import { AppConfigService } from "../config/app-config.service.ts";

export type GenerationJob = {
  id: string;
  status: "running" | "generated" | "failed" | "exported" | "cancelled";
  runner: string | Record<string, unknown>;
  selectedAssetIds: string[];
  childId?: string;
  workspacePath?: string;
  bookId?: string;
  errorMessage?: string;
  createdAt?: string;
  updatedAt?: string;
};

export class FileJobStoreService {
  private readonly config?: AppConfigService;
  private readonly fixedRootDir?: string;

  constructor(configOrRootDir?: AppConfigService | string) {
    if (typeof configOrRootDir === "string") {
      this.fixedRootDir = configOrRootDir;
    } else {
      this.config = configOrRootDir;
    }
  }

  async save(job: GenerationJob) {
    await fs.mkdir(this.jobsDir, { recursive: true });
    const existing = await this.get(job.id);
    const now = new Date().toISOString();
    const next = {
      ...existing,
      ...job,
      createdAt: existing?.createdAt || job.createdAt || now,
      updatedAt: now,
    };
    await fs.writeFile(this.pathFor(job.id), JSON.stringify(next, null, 2));
    return next;
  }

  async get(id: string): Promise<GenerationJob | null> {
    try {
      return JSON.parse(await fs.readFile(this.pathFor(id), "utf8"));
    } catch (error: unknown) {
      if (error && typeof error === 'object' && 'code' in error && (error as { code: string }).code === "ENOENT") return null;
      throw error;
    }
  }

  async list() {
    await fs.mkdir(this.jobsDir, { recursive: true });
    const files = await fs.readdir(this.jobsDir);
    const jobs = await Promise.all(files.filter((file) => file.endsWith(".json")).map((file) => this.get(file.replace(/\.json$/, ""))));
    return jobs.filter(Boolean) as GenerationJob[];
  }

  private get jobsDir() {
    return path.join(this.rootDir, "jobs");
  }

  private get rootDir() {
    return this.fixedRootDir || this.config?.config.paths.dataDir || ".kidmemory/data";
  }

  private pathFor(id: string) {
    return path.join(this.jobsDir, `${id}.json`);
  }
}

export { FileJobStoreService as FileJobStore };

Inject(AppConfigService)(FileJobStoreService, undefined, 0);
Injectable()(FileJobStoreService);
