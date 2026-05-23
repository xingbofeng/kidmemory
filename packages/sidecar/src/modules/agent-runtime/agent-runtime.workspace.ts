import fs from "node:fs/promises";
import path from "node:path";

export type PrepareTaskWorkspaceInput = {
  workspacePath: string;
  taskId: string;
  goal: string;
  assetIds: string[];
  stage: string;
};

export async function ensureTaskWorkspace(input: PrepareTaskWorkspaceInput): Promise<void> {
  const { workspacePath } = input;
  await fs.mkdir(path.join(workspacePath, "input"), { recursive: true });
  await fs.mkdir(path.join(workspacePath, "work"), { recursive: true });
  await fs.mkdir(path.join(workspacePath, "output"), { recursive: true });
}

export async function writeTaskRequestJson(workspacePath: string, data: unknown): Promise<void> {
  await fs.writeFile(
    path.join(workspacePath, "input", "task-request.json"),
    `${JSON.stringify(data, null, 2)}\n`,
  );
}

export async function readPlanJson(workspacePath: string): Promise<Record<string, unknown> | null> {
  try {
    const content = await fs.readFile(path.join(workspacePath, "output", "plan.json"), "utf8");
    return JSON.parse(content) as Record<string, unknown>;
  } catch {
    return null;
  }
}

export async function readBookJson(workspacePath: string): Promise<Record<string, unknown> | null> {
  try {
    const content = await fs.readFile(path.join(workspacePath, "output", "book.json"), "utf8");
    return JSON.parse(content) as Record<string, unknown>;
  } catch {
    return null;
  }
}
