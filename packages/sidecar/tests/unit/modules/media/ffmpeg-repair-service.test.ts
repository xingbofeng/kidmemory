import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";

import { FfmpegRepairService } from "../../../../src/modules/media/ffmpeg-repair.service.ts";

test("configured FFmpeg repair command is verified by a real ffmpeg probe", async () => {
  const previousPath = process.env.PATH;
  const previousCommand = process.env.KIDMEMORY_FFMPEG_REPAIR_COMMAND;
  const previousRepairPath = process.env.KIDMEMORY_FFMPEG_REPAIR_PATH;
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-ffmpeg-repair-"));
  const binDir = path.join(root, "bin");
  const installScript = path.join(root, "install-ffmpeg.js");
  const ffmpegPath = path.join(binDir, "ffmpeg");

  await fs.mkdir(binDir, { recursive: true });
  await fs.writeFile(
    installScript,
    [
      "const fs = require('node:fs');",
      `fs.writeFileSync(${JSON.stringify(ffmpegPath)}, '#!/bin/sh\\necho ffmpeg repaired 9.9.9\\n');`,
      `fs.chmodSync(${JSON.stringify(ffmpegPath)}, 0o755);`,
    ].join("\n"),
  );

  process.env.PATH = binDir;
  process.env.KIDMEMORY_FFMPEG_REPAIR_PATH = binDir;
  process.env.KIDMEMORY_FFMPEG_REPAIR_COMMAND = `${quote(process.execPath)} ${quote(installScript)}`;

  try {
    const result = await new FfmpegRepairService().repair();

    assert.equal(result.ok, true);
    assert.match(result.message, /KIDMEMORY_FFMPEG_REPAIR_COMMAND/);
  } finally {
    setOrDelete("PATH", previousPath);
    setOrDelete("KIDMEMORY_FFMPEG_REPAIR_COMMAND", previousCommand);
    setOrDelete("KIDMEMORY_FFMPEG_REPAIR_PATH", previousRepairPath);
  }
});

test("configured FFmpeg repair command must make ffmpeg available", async () => {
  const previousPath = process.env.PATH;
  const previousCommand = process.env.KIDMEMORY_FFMPEG_REPAIR_COMMAND;
  const previousRepairPath = process.env.KIDMEMORY_FFMPEG_REPAIR_PATH;
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-ffmpeg-repair-missing-"));
  const binDir = path.join(root, "bin");

  await fs.mkdir(binDir, { recursive: true });
  process.env.PATH = binDir;
  process.env.KIDMEMORY_FFMPEG_REPAIR_PATH = binDir;
  process.env.KIDMEMORY_FFMPEG_REPAIR_COMMAND = `${quote(process.execPath)} -e "process.exit(0)"`;

  try {
    const result = await new FfmpegRepairService().repair();

    assert.equal(result.ok, false);
    assert.equal(result.code, "FFMPEG_REPAIR_NOT_ON_PATH");
    assert.match(result.message, /still not available on PATH/);
  } finally {
    setOrDelete("PATH", previousPath);
    setOrDelete("KIDMEMORY_FFMPEG_REPAIR_COMMAND", previousCommand);
    setOrDelete("KIDMEMORY_FFMPEG_REPAIR_PATH", previousRepairPath);
  }
});

function quote(value: string) {
  return `"${value.replaceAll('"', '\\"')}"`;
}

function setOrDelete(key: string, value: string | undefined) {
  if (value === undefined) {
    delete process.env[key];
  } else {
    process.env[key] = value;
  }
}
