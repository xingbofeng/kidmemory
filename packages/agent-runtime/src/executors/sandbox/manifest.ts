import { localDir } from "@openai/agents/sandbox";
import path from "node:path";

export function createOpenAISandboxManifest(workspaceDir: string) {
  const absoluteWorkspaceDir = path.resolve(workspaceDir);
  return {
    root: absoluteWorkspaceDir,
    entries: {
      ".": localDir({ src: absoluteWorkspaceDir }),
    },
  };
}
