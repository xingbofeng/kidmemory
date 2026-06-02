import crypto from "node:crypto";
import { spawn } from "node:child_process";
import fs from "node:fs/promises";
import path from "node:path";
import os from "node:os";
import AdmZip from "adm-zip";

import type { SampleAsset, SampleDb } from "../../../infrastructure/dataset-state/memory-dataset-db.ts";
import { hasErrorCode } from "../../../infrastructure/errors/error-code.ts";

const SUPPORTED_EXTENSIONS = new Set([".jpg", ".jpeg", ".png", ".webp"]);

export type ImportAssetsInput = {
  childId: string;
  paths: string[];
  recursive?: boolean;
  dataDir: string;
};

export type ImportReport = {
  imported: Array<{ id: string; path: string }>;
  duplicates: Array<{ path: string; existingAssetId: string }>;
  failed: Array<{ path: string; reason: string }>;
  skipped: Array<{ path: string; reason: string }>;
};

export async function sha256File(filePath: string) {
  const data = await fs.readFile(filePath);
  return crypto.createHash("sha256").update(data).digest("hex");
}

export async function collectImportFiles(pathsInput: string[], recursive = true, report?: ImportReport) {
  const files: string[] = [];
  for (const inputPath of pathsInput) {
    const stat = await fs.stat(inputPath).catch((error: unknown) => {
      report?.failed.push({ path: inputPath, reason: hasErrorCode(error, "ENOENT") ? "path_not_found" : errorMessage(error, "path_unreadable") });
      return null;
    });
    if (!stat) {
      continue;
    }
    if (stat.isFile()) {
      files.push(inputPath);
      continue;
    }
    if (!stat.isDirectory()) {
      report?.skipped.push({ path: inputPath, reason: "unsupported_path_type" });
      continue;
    }
    const entries = await fs.readdir(inputPath, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(inputPath, entry.name);
      if (entry.isFile()) {
        files.push(fullPath);
      } else if (entry.isDirectory() && recursive) {
        files.push(...(await collectImportFiles([fullPath], true, report)));
      }
    }
  }
  return files;
}

export async function importLocalAssets(db: SampleDb, input: ImportAssetsInput): Promise<ImportReport> {
  const report: ImportReport = { imported: [], duplicates: [], failed: [], skipped: [] };
  const expandedPaths = await expandZipPaths(input.paths, report);
  const files = await collectImportFiles(expandedPaths, input.recursive !== false, report);
  for (const filePath of files) {
    const ext = path.extname(filePath).toLowerCase();
    if (!SUPPORTED_EXTENSIONS.has(ext)) {
      report.skipped.push({ path: filePath, reason: "unsupported_file_type" });
      continue;
    }
    try {
      const managedDir = resolveManagedChildDir(input.dataDir, "assets", input.childId);
      const thumbnailDir = resolveManagedChildDir(input.dataDir, "thumbnails", input.childId);
      if (!managedDir || !thumbnailDir) {
        report.failed.push({ path: filePath, reason: "unsafe_child_id" });
        continue;
      }
      const hash = await sha256File(filePath);
      const duplicated = await db.findAssetByChildAndHash?.(input.childId, hash);
      if (duplicated) {
        report.duplicates.push({ path: filePath, existingAssetId: duplicated.id });
        continue;
      }
      const id = `asset_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
      await fs.mkdir(managedDir, { recursive: true });
      await fs.mkdir(thumbnailDir, { recursive: true });
      const managedPath = path.join(managedDir, `${id}${ext}`);
      const thumbnailPath = path.join(thumbnailDir, `${id}${ext}`);
      await fs.copyFile(filePath, managedPath);
      await createThumbnail(filePath, thumbnailPath);

      const title = path.basename(filePath, ext);
      const asset: SampleAsset = {
        id,
        childId: input.childId,
        type: "photo",
        title,
        description: "",
        tags: [],
        imagePath: managedPath,
        thumbnailPath,
        sourceUrl: "",
        license: "local",
        capturedAt: new Date().toISOString().slice(0, 10),
        hash,
        originalFilename: path.basename(filePath),
        originalPath: filePath,
        storageProvider: "local",
        storageStatus: "local_only",
        storagePath: managedPath,
        embeddingStatus: "pending",
        embeddingVersion: 0,
        searchable: false,
      };
      await db.upsertAsset(asset);
      report.imported.push({ id, path: managedPath });
    } catch (error) {
      report.failed.push({ path: filePath, reason: errorMessage(error, "import_failed") });
    }
  }
  return report;
}

async function expandZipPaths(pathsInput: string[], report: ImportReport) {
  const expanded: string[] = [];
  for (const inputPath of pathsInput) {
    if (path.extname(inputPath).toLowerCase() !== ".zip") {
      expanded.push(inputPath);
      continue;
    }
    try {
      const zip = new AdmZip(inputPath);
      const tempRoot = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-zip-"));
      const zipOut = path.join(tempRoot, "unzipped");
      await fs.mkdir(zipOut, { recursive: true });
      for (const entry of zip.getEntries()) {
        if (entry.isDirectory) continue;
        const target = resolveZipEntryTarget(zipOut, entry.entryName);
        if (!target) {
          report.failed.push({ path: `${inputPath}:${entry.entryName}`, reason: "unsafe_zip_path" });
          continue;
        }
        await fs.mkdir(path.dirname(target), { recursive: true });
        await fs.writeFile(target, entry.getData());
      }
      expanded.push(zipOut);
    } catch (error) {
      report.failed.push({ path: inputPath, reason: errorMessage(error, "invalid_zip") });
    }
  }
  return expanded;
}

function errorMessage(error: unknown, fallback: string) {
  return error instanceof Error && error.message ? error.message : fallback;
}

function resolveZipEntryTarget(root: string, entryName: string) {
  const normalized = entryName.replace(/\\/g, "/");
  if (normalized.startsWith("/") || /^[a-zA-Z]:\//.test(normalized)) return null;
  const target = path.resolve(root, normalized);
  const relative = path.relative(root, target);
  if (!relative || relative.startsWith("..") || path.isAbsolute(relative)) return null;
  return target;
}

function resolveManagedChildDir(dataDir: string, bucket: "assets" | "thumbnails", childId: string) {
  const component = childId.trim();
  if (!component || path.isAbsolute(component) || component.includes("/") || component.includes("\\") || component === "." || component === "..") {
    return null;
  }
  const root = path.resolve(dataDir, bucket);
  const target = path.resolve(root, component);
  const relative = path.relative(root, target);
  if (!relative || relative.startsWith("..") || path.isAbsolute(relative)) return null;
  return target;
}

async function createThumbnail(source: string, target: string) {
  if (process.platform === "darwin" && await runSipsThumbnail(source, target)) return;
  await fs.copyFile(source, target);
}

function runSipsThumbnail(source: string, target: string) {
  return new Promise<boolean>((resolve) => {
    const child = spawn("sips", ["-Z", "512", source, "--out", target], { stdio: "ignore" });
    child.on("error", () => resolve(false));
    child.on("exit", (code) => resolve(code === 0));
  });
}
