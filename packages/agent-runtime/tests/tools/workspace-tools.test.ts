import assert from "node:assert/strict";
import fsSync from "node:fs";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test, { type TestContext } from "node:test";

import { createWorkspaceAgentTools } from "../../src/index.ts";

function useEnv(t: Pick<TestContext, "after">, key: string, value: string): void {
  const previous = process.env[key];
  process.env[key] = value;
  t.after(() => {
    if (previous === undefined) {
      delete process.env[key];
      return;
    }
    process.env[key] = previous;
  });
}

test("createWorkspaceAgentTools exposes one tool per workspace behavior", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-workspace-tools-"));
  const tools = createWorkspaceAgentTools({ workspaceDir, command: { enabled: true } });

  assert.deepEqual(
    tools.map((tool) => tool.id).sort(),
    ["edit_file", "list_files", "read_file", "run_command", "search_files", "write_file"],
  );
  assert.deepEqual([...new Set(tools.map((tool) => tool.source))], ["workspace"]);
});

test("run_command rejects shell executables by default and does not inherit parent secrets", async (t) => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-workspace-command-"));
  const runCommand = createWorkspaceAgentTools({ workspaceDir, command: { enabled: true } })
    .find((tool) => tool.id === "run_command");

  assert.ok(runCommand);
  await assert.rejects(
    () => runCommand.execute({ command: "bash", args: ["-lc", "echo escaped"] }, { workspaceDir }),
    /Command is not allowed/,
  );

  useEnv(t, "KIDMEMORY_SECRET_TEST_VALUE", "secret-from-parent-env");
  const output = await runCommand.execute({
    command: "node",
    args: ["-e", "console.log(process.env.KIDMEMORY_SECRET_TEST_VALUE || 'missing')"],
  }, { workspaceDir });

  assert.equal(typeof output, "object");
  assert.equal((output as { stdout: string }).stdout.trim(), "missing");
});

test("workspace tools write and read output files", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-workspace-tools-"));
  const tools = createWorkspaceAgentTools({ workspaceDir, command: { enabled: false } });
  const writeFile = tools.find((tool) => tool.id === "write_file");
  const readFile = tools.find((tool) => tool.id === "read_file");

  assert.ok(writeFile);
  assert.ok(readFile);
  await writeFile.execute({ path: "output/book.html", content: "<h1>ok</h1>" }, { workspaceDir });

  assert.deepEqual(await readFile.execute({ path: "output/book.html" }, { workspaceDir }), {
    path: "output/book.html",
    offset: 0,
    limit: 2_000,
    totalLines: 1,
    truncated: false,
    content: "1\t<h1>ok</h1>",
  });
});

test("workspace tools reject writes outside work and output", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-workspace-tools-"));
  const writeFile = createWorkspaceAgentTools({ workspaceDir, command: { enabled: false } })
    .find((tool) => tool.id === "write_file");

  assert.ok(writeFile);
  await assert.rejects(
    () => writeFile.execute({ path: "input/notes.md", content: "bad" }, { workspaceDir }),
    /Write path is not allowed/,
  );
});

test("read_file supports line windows", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-workspace-tools-"));
  await fs.mkdir(path.join(workspaceDir, "output"), { recursive: true });
  await fs.writeFile(path.join(workspaceDir, "output/lines.txt"), "a\nb\nc", "utf8");
  const readFile = createWorkspaceAgentTools({ workspaceDir, command: { enabled: false } })
    .find((tool) => tool.id === "read_file");

  assert.ok(readFile);
  assert.deepEqual(await readFile.execute({ path: "output/lines.txt", offset: 1, limit: 1 }, { workspaceDir }), {
    path: "output/lines.txt",
    offset: 1,
    limit: 1,
    totalLines: 3,
    truncated: true,
    content: "2\tb",
  });
});

test("edit_file requires unique search text unless replaceAll is set", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-workspace-tools-"));
  await fs.mkdir(path.join(workspaceDir, "output"), { recursive: true });
  await fs.writeFile(path.join(workspaceDir, "output/story.txt"), "kid\nkid\n", "utf8");
  const editFile = createWorkspaceAgentTools({ workspaceDir, command: { enabled: false } })
    .find((tool) => tool.id === "edit_file");

  assert.ok(editFile);
  await assert.rejects(
    () => editFile.execute({ path: "output/story.txt", search: "kid", replace: "child" }, { workspaceDir }),
    /not unique/,
  );

  assert.deepEqual(
    await editFile.execute({ path: "output/story.txt", search: "kid", replace: "child", replaceAll: true }, { workspaceDir }),
    {
      ok: true,
      path: "output/story.txt",
      replacements: 2,
    },
  );
});

test("workspace path policy reads object inputs through one helper", () => {
  const source = fsSync.readFileSync("src/tools/path-policy.ts", "utf8");

  assert.equal(source.match(/typeof input !== "object"/g)?.length, 1);
});

test("workspace tool implementations reuse path-policy input readers", () => {
  const toolSources = [
    "src/tools/edit-file.tool.ts",
    "src/tools/run-command.tool.ts",
    "src/tools/search-files.tool.ts",
    "src/tools/write-file.tool.ts",
  ].map((file) => fsSync.readFileSync(file, "utf8")).join("\n");

  assert.equal(toolSources.includes('typeof input !== "object"'), false);
});
