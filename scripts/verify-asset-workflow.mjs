import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import AdmZip from "../packages/backend/node_modules/adm-zip/adm-zip.js";

import { DatasetState } from "../packages/backend/src/infrastructure/dataset-state/dataset-state.service.ts";
import { MemoryDatasetDb } from "../packages/backend/src/infrastructure/dataset-state/memory-dataset-db.ts";
import { FileJobStoreService } from "../packages/backend/src/infrastructure/jobs/file-job-store.service.ts";
import { createBooksService } from "../packages/backend/src/modules/books/providers/books.domain.ts";
import { importLocalAssets } from "../packages/backend/src/modules/dataset/providers/asset-import.ts";

async function main() {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-asset-workflow-verify-"));
  const inputDir = path.join(root, "input");
  const dataDir = path.join(root, "data");
  const workspaceDir = path.join(root, "workspace");
  const exportDir = path.join(root, "export");
  await fs.mkdir(inputDir, { recursive: true });
  await fs.mkdir(dataDir, { recursive: true });
  await fs.mkdir(workspaceDir, { recursive: true });
  await fs.mkdir(exportDir, { recursive: true });

  const jpg = path.join(inputDir, "a.jpg");
  const png = path.join(inputDir, "b.png");
  const webp = path.join(inputDir, "c.webp");
  const dup = path.join(inputDir, "dup.jpg");
  const txt = path.join(inputDir, "skip.txt");
  await fs.writeFile(jpg, "asset-jpg");
  await fs.writeFile(png, "asset-png");
  await fs.writeFile(webp, "asset-webp");
  await fs.writeFile(dup, "asset-jpg");
  await fs.writeFile(txt, "unsupported");

  const zipPath = path.join(inputDir, "bundle.zip");
  const zip = new AdmZip();
  zip.addFile("zip/photo.jpg", Buffer.from("asset-zip-jpg"));
  zip.addFile("zip/skip.md", Buffer.from("skip"));
  zip.writeZip(zipPath);

  const db = new MemoryDatasetDb();
  await db.upsertChild({ id: "child-verify", name: "验证孩子" });

  const report = await importLocalAssets(db, {
    childId: "child-verify",
    paths: [inputDir, zipPath],
    recursive: true,
    dataDir,
  });

  const assets = await db.getAssets({ childId: "child-verify" });
  if (assets.length === 0) throw new Error("No assets imported.");
  await db.updateAssetMetadata?.(assets[0].id, {
    title: "更新后的标题",
    description: "更新后的描述",
    tags: ["验证"],
  });

  const datasetState = new DatasetState(db, async () => db);
  const books = createBooksService({
    config: {
      postgres: { host: "localhost", port: 5432, database: "kidmemory", user: "postgres", password: "" },
      openai: { provider: "openai", baseUrl: "https://api.openai.com/v1", apiKey: "", model: "gpt-4o-mini" },
      claude: { apiKey: "", model: "claude-3-5-sonnet-20241022", baseUrl: "https://api.anthropic.com" },
      paths: { workspaceDir, exportDir, dataDir },
      sidecar: { host: "127.0.0.1", port: 4317 },
    },
    datasetState,
    jobStore: new FileJobStoreService(dataDir),
  });

  const createJob = await books.createJob({
    childId: "child-verify",
    assetIds: assets.slice(0, 2).map((asset) => asset.id),
    runner: "mock",
  });
  if (createJob.status !== 200) throw new Error(`createJob failed: ${JSON.stringify(createJob)}`);
  const jobId = createJob.data.id;
  const exportResult = await books.exportPdf(jobId, { targetPath: path.join(exportDir, `${jobId}.pdf`) });
  if (exportResult.status !== 200) throw new Error(`exportPdf failed: ${JSON.stringify(exportResult)}`);

  const output = {
    ok: true,
    imported: report.imported.length,
    duplicates: report.duplicates.length,
    skipped: report.skipped.length,
    failed: report.failed.length,
    jobId,
    pdfOk: exportResult.data?.exported?.ok === true,
    pdfVerified: exportResult.data?.verified?.ok === true,
  };
  console.log(JSON.stringify(output, null, 2));
}

main().catch((error) => {
  console.error(JSON.stringify({ ok: false, error: String(error?.message || error) }, null, 2));
  process.exitCode = 1;
});
