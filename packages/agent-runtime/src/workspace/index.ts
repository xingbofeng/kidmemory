import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";

import { dedupe, directoryExists, pathExists } from "../core/utils.js";

export type WorkspaceManifest = {
  version: 1;
  artifact: {
    outputDir: string;
  };
  skills: {
    roots: string[];
  };
  session: {
    dir: string;
  };
  logs: {
    dir: string;
  };
};

export type EnsureAgentWorkspaceRequest = {
  workspaceDir: string;
  homeDir?: string;
  forceRuntimeInstructions?: boolean;
};

export type EnsureAgentWorkspaceResult = {
  workspaceDir: string;
  manifest: WorkspaceManifest;
};

export type InitializeManagedSkillsRequest = {
  workspaceDir: string;
  homeDir?: string;
  sourceRoots?: string[];
};

export type InitializeManagedSkillsResult = {
  copied: string[];
  skippedExisting: string[];
  missing: string[];
};

export type DiscoverSkillRootsRequest = {
  workspaceDir: string;
  homeDir?: string;
  skillRoots?: string[];
};

export async function ensureAgentWorkspace(request: EnsureAgentWorkspaceRequest): Promise<EnsureAgentWorkspaceResult> {
  const workspaceDir = request.workspaceDir;
  const controlDir = path.join(workspaceDir, ".kidmemory");
  await fs.mkdir(path.join(controlDir, "skills"), { recursive: true });
  await fs.mkdir(path.join(controlDir, "sessions"), { recursive: true });
  await fs.mkdir(path.join(controlDir, "logs"), { recursive: true });
  await fs.mkdir(path.join(workspaceDir, "input"), { recursive: true });
  await fs.mkdir(path.join(workspaceDir, "work"), { recursive: true });
  await fs.mkdir(path.join(workspaceDir, "output"), { recursive: true });
  await initializeManagedSkills({
    workspaceDir,
    homeDir: request.homeDir,
  });

  const runtimePath = path.join(controlDir, "runtime.md");
  if (request.forceRuntimeInstructions || !(await pathExists(runtimePath))) {
    await fs.writeFile(runtimePath, defaultRuntimeInstructions());
  }

  const manifest = await loadWorkspaceManifest(workspaceDir);
  await fs.writeFile(path.join(controlDir, "manifest.json"), `${JSON.stringify(manifest, null, 2)}\n`);
  return { workspaceDir, manifest };
}

export async function initializeManagedSkills(request: InitializeManagedSkillsRequest): Promise<InitializeManagedSkillsResult> {
  const workspaceSkillsDir = path.join(request.workspaceDir, ".kidmemory", "skills");
  await fs.mkdir(workspaceSkillsDir, { recursive: true });
  const sourceRoots = request.sourceRoots ?? defaultManagedSkillSourceRoots(request.homeDir);
  const discovered = new Map<string, string>();
  for (const sourceRoot of sourceRoots) {
    if (!(await directoryExists(sourceRoot))) continue;
    const entries = await fs.readdir(sourceRoot, { withFileTypes: true });
    for (const entry of entries) {
      if (!entry.isDirectory()) continue;
      const skillId = String(entry.name).trim();
      if (!isManagedKidMemorySkill(skillId) || discovered.has(skillId)) continue;
      const skillDir = path.join(sourceRoot, skillId);
      if (await pathExists(path.join(skillDir, "SKILL.md"))) discovered.set(skillId, skillDir);
    }
  }

  const copied = new Array<string>();
  const skippedExisting = new Array<string>();
  for (const [skillId, sourceDir] of discovered) {
    const destinationDir = path.join(workspaceSkillsDir, skillId);
    if (await pathExists(path.join(destinationDir, "SKILL.md"))) {
      skippedExisting.push(skillId);
      continue;
    }
    await fs.cp(sourceDir, destinationDir, { recursive: true });
    copied.push(skillId);
  }

  return {
    copied,
    skippedExisting,
    missing: managedSkillIds().filter((skillId) => !discovered.has(skillId)),
  };
}

export async function loadWorkspaceManifest(workspaceDir: string): Promise<WorkspaceManifest> {
  const manifestPath = path.join(workspaceDir, ".kidmemory", "manifest.json");
  if (!(await pathExists(manifestPath))) return defaultManifest();
  const parsed = JSON.parse(await fs.readFile(manifestPath, "utf8")) as Partial<WorkspaceManifest>;
  const defaults = defaultManifest();
  return {
    version: 1,
    artifact: {
      outputDir: parsed.artifact?.outputDir ?? defaults.artifact.outputDir,
    },
    skills: {
      roots: parsed.skills?.roots ?? defaults.skills.roots,
    },
    session: {
      dir: parsed.session?.dir ?? defaults.session.dir,
    },
    logs: {
      dir: parsed.logs?.dir ?? defaults.logs.dir,
    },
  };
}

export async function discoverSkillRoots(request: DiscoverSkillRootsRequest): Promise<string[]> {
  if (request.skillRoots && request.skillRoots.length > 0) return request.skillRoots.map((root) => path.resolve(root));

  const manifest = await loadWorkspaceManifest(request.workspaceDir);
  const workspaceCandidates = [
    ...manifest.skills.roots.map((root) => path.resolve(request.workspaceDir, root)),
    path.join(request.workspaceDir, ".kidmemory", "skills"),
  ];
  const workspaceRoots = await existingSkillRoots(workspaceCandidates);
  const globalRoots = await existingSkillRoots([
	    path.join(request.homeDir ?? os.homedir(), ".kidmemory", "skills"),
	    path.join(request.homeDir ?? os.homedir(), ".codex", "skills"),
	  ]);
  return dedupe([...workspaceRoots, ...globalRoots]);
}

async function existingSkillRoots(candidates: string[]): Promise<string[]> {
  const existing = new Array<string>();
  for (const candidate of dedupe(candidates)) {
    if (await directoryExists(candidate) && await containsSkill(candidate)) existing.push(candidate);
  }
  return existing;
}

async function containsSkill(root: string): Promise<boolean> {
  const entries = await fs.readdir(root, { withFileTypes: true }).catch(() => []);
  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    if (await pathExists(path.join(root, entry.name, "SKILL.md"))) return true;
  }
  return false;
}

function defaultManifest(): WorkspaceManifest {
  return {
    version: 1,
    artifact: {
      outputDir: "output",
    },
    skills: {
      roots: [".kidmemory/skills"],
    },
    session: {
      dir: ".kidmemory/sessions",
    },
    logs: {
      dir: ".kidmemory/logs",
    },
  };
}

export function isManagedKidMemorySkill(skillId: string): boolean {
  const normalized = skillId.trim();
  return normalized === "picturebook-maker"
    || normalized === "hyperframes"
    || normalized.startsWith("hyperframes-")
    || normalized === "gsap"
    || normalized === "website-to-hyperframes";
}

function managedSkillIds(): string[] {
  return ["picturebook-maker", "hyperframes"];
}

function defaultManagedSkillSourceRoots(homeDir = os.homedir()): string[] {
  return [
    path.join(homeDir, ".kidmemory", "skills"),
    path.join(homeDir, ".codex", "skills"),
  ];
}

function defaultRuntimeInstructions(): string {
  return `# KidMemory Agent Runtime

You are working inside a controlled KidMemory agent workspace.

- Read this file first.
- Treat input/ as read-only user context.
- Use work/ for intermediate drafts and scratch files.
- Write final artifacts only to output/.
- Treat .kidmemory/ as read-only runtime control data.
- Do not edit .kidmemory/sessions or .kidmemory/logs directly.

## File Creation

- Depending on the active executor, filesystem access may be provided by sandbox filesystem/shell capabilities or by explicit workspace tools such as list_files, read_file, write_file, edit_file, search_files, and run_command.
- Use the available mechanism in the current run; do not assume unavailable tools exist.
- When the task requires artifacts, you must create or update files under output/ through the available filesystem mechanism.
- Before finishing, verify that every required file exists under output/ and is non-empty.
`;
}
