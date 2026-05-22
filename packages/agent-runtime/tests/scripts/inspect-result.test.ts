import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { collectWorkspaceInspection } from "../../scripts/lib.ts";

test("collectWorkspaceInspection returns artifacts, events, session summaries, and trace refs", async () => {
  const workspaceDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-inspect-"));
  await fs.mkdir(path.join(workspaceDir, "output"), { recursive: true });
  await fs.mkdir(path.join(workspaceDir, ".kidmemory", "sessions"), { recursive: true });
  await fs.mkdir(path.join(workspaceDir, ".kidmemory", "logs"), { recursive: true });
  await fs.writeFile(path.join(workspaceDir, "output", "book.json"), "{}");
  await fs.writeFile(
    path.join(workspaceDir, ".kidmemory", "sessions", "session_1.jsonl"),
    [
      JSON.stringify({
        type: "agent.run.started",
        runId: "run_1",
        sessionId: "session_1",
        timestamp: "2026-05-22T00:00:00.000Z",
        level: "info",
        channels: ["session", "log", "stream"],
        message: "Run started",
        data: { workspaceDir, traceId: "trace_1" },
      }),
      JSON.stringify({
        type: "agent.artifact.detected",
        runId: "run_1",
        sessionId: "session_1",
        timestamp: "2026-05-22T00:00:01.000Z",
        level: "info",
        channels: ["session", "log", "stream"],
        message: "Artifact detected: output/book.json",
        data: {
          artifact: {
            artifactId: "artifact_1",
            kind: "json",
            localPath: "output/book.json",
          },
          traceId: "trace_1",
        },
      }),
      JSON.stringify({
        type: "agent.run.finished",
        runId: "run_1",
        sessionId: "session_1",
        timestamp: "2026-05-22T00:00:02.000Z",
        level: "info",
        channels: ["session", "log", "stream"],
        message: "Run finished",
        data: {
          traceId: "trace_1",
          loopControl: {
            decision: "complete",
            reason: "executor_succeeded",
          },
        },
      }),
    ].join("\n"),
  );
  await fs.writeFile(
    path.join(workspaceDir, ".kidmemory", "sessions", "session_1.latest.json"),
    `${JSON.stringify({
      ok: true,
      runId: "run_1",
      sessionId: "session_1",
      trace: {
        provider: "openai-agents",
        traceId: "trace_1",
        groupId: "session_1",
      },
    })}\n`,
  );
  await fs.writeFile(
    path.join(workspaceDir, ".kidmemory", "logs", "events.jsonl"),
    `${JSON.stringify({
      type: "agent.run.finished",
      runId: "run_1",
      sessionId: "session_1",
      timestamp: "2026-05-22T00:00:02.000Z",
      level: "info",
      channels: ["session", "log", "stream"],
      message: "Run finished",
    })}\n`,
  );

  const inspection = await collectWorkspaceInspection(workspaceDir);

  assert.deepEqual(inspection.artifacts, ["output/book.json"]);
  assert.equal(inspection.events.count, 1);
  assert.equal(inspection.sessions[0].sessionId, "session_1");
  assert.equal(inspection.sessions[0].summary.status, "succeeded");
  assert.equal(inspection.sessions[0].summary.artifactCount, 1);
  assert.deepEqual(inspection.sessions[0].loopControl, {
    decision: "complete",
    reason: "executor_succeeded",
  });
  assert.deepEqual(inspection.traces, [{ provider: "openai-agents", traceId: "trace_1", groupId: "session_1" }]);
});
