import fs from "node:fs/promises";
import path from "node:path";

import { directoryExists, hashPath, toPosixPath } from "../core/utils.js";

export type AgentArtifactKind = "json" | "html" | "mp4" | "image" | "text" | "directory";

export type AgentArtifact = {
  artifactId: string;
  kind: AgentArtifactKind;
  localPath: string;
  schemaRef?: string;
  metadata?: Record<string, unknown>;
};

export type ArtifactScanRequest = {
  workspaceDir: string;
  outputDir?: string;
  schemaRefs?: Record<string, string>;
};

export type ArtifactScanResult = {
  artifacts: AgentArtifact[];
};

type ArtifactEntry =
  | {
      kind: "file";
      path: string;
    }
  | {
      kind: "directory";
      path: string;
      fileCount: number;
    };

export class ArtifactScanner {
  async scan(request: ArtifactScanRequest): Promise<ArtifactScanResult> {
    const outputDir = request.outputDir ?? "output";
    const absoluteOutputDir = path.resolve(request.workspaceDir, outputDir);
    const entries = await listArtifactEntries(absoluteOutputDir);
    return {
      artifacts: entries.map((entry) => {
        const localPath = toPosixPath(path.relative(request.workspaceDir, entry.path));
        return {
          artifactId: `artifact_${hashPath(localPath)}`,
          kind: entry.kind === "directory" ? "directory" : inferArtifactKind(entry.path),
          localPath,
          schemaRef: request.schemaRefs?.[localPath],
          metadata: entry.kind === "directory" ? { fileCount: entry.fileCount } : undefined,
        };
      }),
    };
  }
}

async function listArtifactEntries(rootDir: string): Promise<ArtifactEntry[]> {
  if (!(await directoryExists(rootDir))) return [];
  const entries = await fs.readdir(rootDir, { withFileTypes: true });
  const artifacts = new Array<ArtifactEntry>();
  for (const entry of entries) {
    if (entry.name.startsWith(".")) continue;
    const entryPath = path.join(rootDir, entry.name);
    if (entry.isDirectory()) {
      const nested = await listArtifactEntries(entryPath);
      artifacts.push({
        kind: "directory",
        path: entryPath,
        fileCount: nested.filter((artifact) => artifact.kind === "file").length,
      });
      artifacts.push(...nested);
    } else if (entry.isFile()) {
      artifacts.push({
        kind: "file",
        path: entryPath,
      });
    }
  }
  return artifacts;
}

function inferArtifactKind(filePath: string): AgentArtifactKind {
  const ext = path.extname(filePath).toLowerCase();
  if (ext === ".json") return "json";
  if (ext === ".html" || ext === ".htm") return "html";
  if (ext === ".mp4") return "mp4";
  if ([".png", ".jpg", ".jpeg", ".webp", ".gif"].includes(ext)) return "image";
  if ([".txt", ".md"].includes(ext)) return "text";
  return "directory";
}
