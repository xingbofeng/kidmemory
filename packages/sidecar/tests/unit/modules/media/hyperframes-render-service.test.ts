import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";

import { HyperframesRenderService } from "../../../../src/modules/media/hyperframes-render.service.ts";

function createService(root: string, logs: unknown[]) {
  return new HyperframesRenderService(
    {
      config: {
        paths: {
          exportDir: path.join(root, "exports"),
        },
      },
    } as any,
    {
      async append(entry: unknown) {
        logs.push(entry);
      },
    } as any,
    {
      getTraceId() {
        return "trace_hyperframes_test";
      },
    } as any,
  );
}

test("Hyperframes renderer command writes MP4 to the requested output path", async () => {
  const previousCommand = process.env.HYPERFRAMES_RENDER_COMMAND;
  const previousTimeout = process.env.HYPERFRAMES_RENDER_TIMEOUT_MS;
  const root = await fs.mkdtemp(
    path.join(os.tmpdir(), "kidmemory-hyperframes-render-"),
  );
  const outputPath = path.join(root, "exports", "memoir.mp4");
  const logs: unknown[] = [];
  process.env.HYPERFRAMES_RENDER_COMMAND = [
    "node",
    "-e",
    JSON.stringify(
      "require('fs').writeFileSync(process.env.HYPERFRAMES_OUTPUT_PATH, Buffer.from('kidmemory mp4 command test'))",
    ),
  ].join(" ");
  process.env.HYPERFRAMES_RENDER_TIMEOUT_MS = "5000";

  try {
    const result = await createService(root, logs).render({
      projectId: "memoir command smoke",
      prompt: "生成一段回忆视频",
      targetPath: outputPath,
    });

    assert.equal(result.ok, true);
    assert.equal(result.localPath, outputPath);
    assert.equal(
      await fs.readFile(outputPath, "utf8"),
      "kidmemory mp4 command test",
    );
    assert.ok(
      logs.some((entry) =>
        JSON.stringify(entry).includes("hyperframes.render.succeeded"),
      ),
    );
  } finally {
    setOrDelete("HYPERFRAMES_RENDER_COMMAND", previousCommand);
    setOrDelete("HYPERFRAMES_RENDER_TIMEOUT_MS", previousTimeout);
  }
});

test("Hyperframes renderer command reports missing output as a recoverable failure", async () => {
  const previousCommand = process.env.HYPERFRAMES_RENDER_COMMAND;
  const previousTimeout = process.env.HYPERFRAMES_RENDER_TIMEOUT_MS;
  const root = await fs.mkdtemp(
    path.join(os.tmpdir(), "kidmemory-hyperframes-render-missing-"),
  );
  process.env.HYPERFRAMES_RENDER_COMMAND = 'node -e "process.exit(0)"';
  process.env.HYPERFRAMES_RENDER_TIMEOUT_MS = "5000";

  try {
    const result = await createService(root, []).render({
      projectId: "missing-output",
    });

    assert.equal(result.ok, false);
    assert.equal(result.code, "HYPERFRAMES_OUTPUT_MISSING");
    assert.match(result.message, /did not create the expected MP4/);
  } finally {
    setOrDelete("HYPERFRAMES_RENDER_COMMAND", previousCommand);
    setOrDelete("HYPERFRAMES_RENDER_TIMEOUT_MS", previousTimeout);
  }
});

function setOrDelete(key: string, value: string | undefined) {
  if (value === undefined) {
    delete process.env[key];
  } else {
    process.env[key] = value;
  }
}
