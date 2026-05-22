import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {
  AgentEventBus,
  FileEventSink,
  FileSessionLogStore,
  MemoryEventSink,
  MemorySessionLogStore,
  createEvent,
  redactForLog,
} from "../../src/index.ts";

test("AgentEventBus routes one event to session log, event sink, and stream subscribers", async () => {
  const sessionLogStore = new MemorySessionLogStore();
  const eventSink = new MemoryEventSink();
  const eventBus = new AgentEventBus({ sessionLogStore, eventSink });
  const streamed = new Array<string>();
  eventBus.subscribe((event) => {
    streamed.push(event.type);
  });

  await eventBus.publish({
    type: "agent.run.started",
    runId: "run_1",
    sessionId: "session_1",
    timestamp: "2026-05-22T00:00:00.000Z",
    level: "info",
    channels: ["session", "log", "stream"],
    message: "Run started",
  });

  assert.equal((await sessionLogStore.read("session_1")).length, 1);
  assert.equal((await eventSink.list({ runId: "run_1" })).length, 1);
  assert.deepEqual(streamed, ["agent.run.started"]);
});

test("FileSessionLogStore stores one jsonl file per session", async () => {
  const rootDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-session-log-"));
  const store = new FileSessionLogStore({ rootDir });

  await store.append({
    type: "user.prompt",
    runId: "run_1",
    sessionId: "session_1",
    timestamp: "2026-05-22T00:00:00.000Z",
    level: "info",
    channels: ["session"],
    message: "Prompt received",
    data: { prompt: "生成绘本" },
  });

  const content = await fs.readFile(path.join(rootDir, "session_1.jsonl"), "utf8");
  assert.match(content, /"type":"user.prompt"/);
  assert.equal((await store.read("session_1"))[0].data?.prompt, "生成绘本");
});

test("FileEventSink appends events and supports run and channel queries", async () => {
  const rootDir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-events-"));
  const sink = new FileEventSink({ rootDir });
  await sink.append({
    type: "agent.run.started",
    runId: "run_1",
    sessionId: "session_1",
    timestamp: "2026-05-22T00:00:00.000Z",
    level: "info",
    channels: ["log"],
    message: "Run started",
  });
  await sink.append({
    type: "agent.run.started",
    runId: "run_2",
    sessionId: "session_2",
    timestamp: "2026-05-22T00:00:01.000Z",
    level: "info",
    channels: ["stream"],
    message: "Run started",
  });

  assert.equal((await sink.list({ runId: "run_1" })).length, 1);
  assert.equal((await sink.list({ channels: ["log"] })).length, 1);
  assert.equal((await fs.readFile(path.join(rootDir, "events.jsonl"), "utf8")).split("\n").filter(Boolean).length, 2);
});

test("redactForLog preserves structure while removing secrets", () => {
  assert.deepEqual(
    redactForLog({
      prompt: "storybook",
      apiKey: "secret",
      nested: {
        authorization: "Bearer secret",
        values: [{ token: "secret" }, { width: 1024 }],
      },
    }),
    {
      prompt: "storybook",
      apiKey: "[redacted]",
      nested: {
        authorization: "[redacted]",
        values: [{ token: "[redacted]" }, { width: 1024 }],
      },
    },
  );
});

test("redactForLog removes secret-looking strings inside error messages", () => {
  assert.deepEqual(
    redactForLog({
      error: "Provider failed with token sk-test-secret and Authorization: Bearer abc123",
    }),
    {
      error: "Provider failed with token [redacted] and Authorization: Bearer [redacted]",
    },
  );
});

test("createEvent redacts sensitive data before persistence", () => {
  const event = createEvent({
    type: "agent.tool.started",
    runId: "run_redact",
    sessionId: "session_redact",
    level: "info",
    channels: ["log"],
    message: "Tool started",
    data: { apiKey: "secret", output: "ok" },
  });

  assert.deepEqual(event.data, { apiKey: "[redacted]", output: "ok" });
});
