import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { SkillDeckProvider, createSkillDeckAgentTools, toOpenAISandboxSkillCapabilities } from "../../src/index.ts";

test("SkillDeckProvider loads skills from configured roots", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-skill-deck-"));
  const skillDir = path.join(root, "storybook-writer");
  await fs.mkdir(skillDir, { recursive: true });
  await fs.writeFile(
    path.join(skillDir, "SKILL.md"),
    `---
name: storybook-writer
description: Writes warm storybook drafts.
---

# Storybook Writer

Use this skill to write KidMemory storybook drafts.
`,
  );

  const result = await new SkillDeckProvider().load({ roots: [root] });

  assert.equal(result.skills.length, 1);
  assert.deepEqual(result.roots, [root]);
  assert.equal(result.openAIAgentsLocalSkills[0].name, "storybook-writer");
  assert.equal(result.mcpTools.some((tool) => tool.name === "read_skill"), true);
  assert.equal(result.mcpTools.every((tool) => typeof tool.description === "string"), true);
  assert.equal(result.mcpTools.every((tool) => typeof tool.inputSchema === "object"), true);

  const capabilities = toOpenAISandboxSkillCapabilities(result);

  assert.equal(capabilities.length, 1);
  assert.equal(capabilities[0].type, "skills");
});

test("createSkillDeckAgentTools executes skill-deck handlers as runtime tools", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-skill-tools-"));
  const skillDir = path.join(root, "storybook-writer");
  await fs.mkdir(skillDir, { recursive: true });
  await fs.writeFile(
    path.join(skillDir, "SKILL.md"),
    `---
name: storybook-writer
description: Writes warm storybook drafts.
---

# Storybook Writer

Always write a structured draft.
`,
  );
  const result = await new SkillDeckProvider().load({ roots: [root] });
  const tools = createSkillDeckAgentTools(result);
  const readSkill = tools.find((tool) => tool.id === "read_skill");
  const useSkill = tools.find((tool) => tool.id.startsWith("use_skill_"));

  assert.ok(readSkill);
  assert.ok(useSkill);
  assert.equal(readSkill.source, "skill-deck");
  assert.equal(useSkill.source, "skill-deck");

  const readOutput = await readSkill.execute({ ref: "storybook-writer" }, { workspaceDir: root });
  const useOutput = await useSkill.execute({}, { workspaceDir: root });
  const readViaToolNameOutput = await readSkill.execute({ ref: useSkill.id }, { workspaceDir: root });

  assert.match(JSON.stringify(readOutput), /Always write a structured draft/);
  assert.match(JSON.stringify(useOutput), /Always write a structured draft/);
  assert.match(JSON.stringify(readViaToolNameOutput), /Always write a structured draft/);
});

test("createSkillDeckAgentTools normalizes shell cwd to the workspace root", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-skill-deck-shell-"));
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-shell-workspace-"));
  const skillDir = path.join(root, "shell-skill");
  await fs.mkdir(skillDir, { recursive: true });
  await fs.writeFile(
    path.join(skillDir, "SKILL.md"),
    [
      "---",
      "name: shell-skill",
      "description: Writes a shell marker.",
      "---",
      "",
      "Run from the workspace root: `node .kidmemory/skills/shell-skill/render.mjs`.",
      "",
    ].join("\n"),
  );
  const workspaceSkillDir = path.join(workspaceDir, ".kidmemory", "skills", "shell-skill");
  await fs.mkdir(workspaceSkillDir, { recursive: true });
  await fs.writeFile(
    path.join(workspaceSkillDir, "render.mjs"),
    "process.stdout.write(process.cwd())\n",
  );
  const result = await new SkillDeckProvider().load({ roots: [root] });
  const runShell = createSkillDeckAgentTools(result).find((tool) => tool.id === "run_skill_shell");
  assert.ok(runShell);

  const output = await runShell.execute(
    {
      skillRef: "shell-skill",
      command: "node .kidmemory/skills/shell-skill/render.mjs",
      cwd: workspaceDir,
    },
    {
      workspaceDir,
      runId: "run-shell",
    },
  );

  assert.match(JSON.stringify(output), new RegExp(workspaceDir.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")));
});

test("createSkillDeckAgentTools rejects shell commands not declared by the skill", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-skill-shell-policy-"));
  const skillRoot = path.join(workspaceDir, ".kidmemory", "skills");
  const skillDir = path.join(skillRoot, "shell-skill");
  await fs.mkdir(skillDir, { recursive: true });
  await fs.writeFile(
    path.join(skillDir, "SKILL.md"),
    [
      "---",
      "name: shell-skill",
      "description: Writes a shell marker.",
      "---",
      "",
      "# Shell Skill",
      "",
      "Run from the workspace root: `node .kidmemory/skills/shell-skill/render.mjs`.",
      "",
    ].join("\n"),
  );
  await fs.writeFile(
    path.join(skillDir, "render.mjs"),
    "process.stdout.write(process.cwd())\n",
  );
  const result = await new SkillDeckProvider().load({ roots: [skillRoot] });
  const runShell = createSkillDeckAgentTools(result).find((tool) => tool.id === "run_skill_shell");
  assert.ok(runShell);

  await assert.rejects(
    runShell.execute(
      {
        skillRef: "shell-skill",
        command: "node -e \"process.stdout.write(process.cwd())\"",
        cwd: workspaceDir,
      },
      {
        workspaceDir,
        runId: "run-shell-policy",
      },
    ),
    /not declared by skill shell policy/,
  );
});

test("createSkillDeckAgentTools aborts a running shell command", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-skill-shell-abort-"));
  const skillRoot = path.join(workspaceDir, ".kidmemory", "skills");
  const skillDir = path.join(skillRoot, "shell-skill");
  const markerPath = path.join(workspaceDir, "output", "late-marker.txt");
  await fs.mkdir(skillDir, { recursive: true });
  await fs.mkdir(path.dirname(markerPath), { recursive: true });
  await fs.writeFile(
    path.join(skillDir, "SKILL.md"),
    [
      "---",
      "name: shell-skill",
      "description: Writes a delayed marker.",
      "---",
      "",
      "# Shell Skill",
      "",
      "Run from the workspace root: `node .kidmemory/skills/shell-skill/delayed-write.mjs`.",
      "",
    ].join("\n"),
  );
  await fs.writeFile(
    path.join(skillDir, "delayed-write.mjs"),
    [
      "import fs from 'node:fs/promises';",
      "import path from 'node:path';",
      "await new Promise((resolve) => setTimeout(resolve, 800));",
      "await fs.writeFile(path.join(process.cwd(), 'output', 'late-marker.txt'), 'late');",
      "process.stdout.write('done');",
      "",
    ].join("\n"),
  );
  const result = await new SkillDeckProvider().load({ roots: [skillRoot] });
  const runShell = createSkillDeckAgentTools(result).find((tool) => tool.id === "run_skill_shell");
  const controller = new globalThis.AbortController();
  assert.ok(runShell);

  const execution = runShell.execute(
    {
      skillRef: "shell-skill",
      command: "node .kidmemory/skills/shell-skill/delayed-write.mjs",
      cwd: workspaceDir,
    },
    {
      workspaceDir,
      runId: "run-shell-abort",
      signal: controller.signal,
    },
  );
  setTimeout(() => controller.abort(new Error("stage timed out")), 100);

  await assert.rejects(execution, /stage timed out|aborted/i);
  await new Promise((resolve) => setTimeout(resolve, 1000));
  await assert.rejects(fs.stat(markerPath), /ENOENT/);
});

test("createSkillDeckAgentTools reports validation failures as tool errors", async () => {
  const result = await new SkillDeckProvider().load({ roots: [] });
  const tools = createSkillDeckAgentTools({
    ...result,
    skills: [
      {
        id: "storybook-writer",
        name: "storybook-writer",
        description: "Writes warm storybook drafts.",
        tags: [],
        dependencies: [],
        whenToUse: [],
        relatedSkills: [],
        hasExamples: false,
        exampleFiles: [],
        path: "/tmp/storybook-writer",
        bodyPath: "/tmp/storybook-writer/SKILL.md",
        valid: true,
        warnings: [],
        errors: [],
      },
    ],
  });
  const readSkill = tools.find((tool) => tool.id === "read_skill");

  assert.ok(readSkill);
  await assert.rejects(readSkill.execute({}, { workspaceDir: os.tmpdir() }), /ref is required/);
});

test("demo workspaces provide discoverable storybook and video skills", async () => {
  const packageRoot = path.resolve(import.meta.dirname, "..", "..");
  const storybookSkillsRoot = path.join(packageRoot, "examples", "storybook", ".kidmemory", "skills");
  const videoSkillsRoot = path.join(packageRoot, "examples", "video", ".kidmemory", "skills");

  const result = await new SkillDeckProvider().load({
    roots: [storybookSkillsRoot, videoSkillsRoot],
  });

  const names = result.openAIAgentsLocalSkills.map((skill) => skill.name).sort();

  assert.equal(names.includes("kidmemory-storybook-demo-writer"), true);
  assert.equal(names.includes("kidmemory-video-demo-director"), true);
  assert.equal(names.includes("hyperframes"), true);
  assert.equal(names.includes("picturebook-maker"), true);
  assert.equal(result.mcpTools.some((tool) => tool.name.startsWith("use_skill_")), true);
});
