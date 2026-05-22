import fs from "node:fs/promises";
import path from "node:path";

import type { AgentRuntimeError } from "../core/errors.js";
import { pathExists, safeFileSegment } from "../core/utils.js";

export type AgentEventChannel = "session" | "log" | "stream";

export type AgentEvent = {
  type: string;
  runId: string;
  sessionId?: string;
  timestamp: string;
  level: "debug" | "info" | "warn" | "error";
  channels: AgentEventChannel[];
  message: string;
  data?: Record<string, unknown>;
};

export type AgentEventSummary = {
  count: number;
  warnings: number;
  errors: number;
  recent?: AgentEvent[];
  logPath?: string;
};

export type AgentSessionStatus = "active" | "paused" | "blocked" | "succeeded" | "failed" | "cancelled";

export type AgentSessionSummary = {
  sessionId: string;
  status: AgentSessionStatus;
  runIds: string[];
  latestRunId?: string;
  workspaceDir?: string;
  artifactCount: number;
  createdAt?: string;
  updatedAt?: string;
  lastError?: AgentRuntimeError;
  metadata?: Record<string, unknown>;
};

export type AgentEventQuery = {
  runId?: string;
  sessionId?: string;
  traceId?: string;
  channels?: AgentEventChannel[];
  limit?: number;
};

export interface AgentEventSink {
  append(event: AgentEvent): Promise<void>;
  list?(query?: AgentEventQuery): Promise<AgentEvent[]>;
}

export interface AgentSessionLogStore {
  append(event: AgentEvent): Promise<void>;
  read(sessionId: string): Promise<AgentEvent[]>;
}

export class MemorySessionLogStore implements AgentSessionLogStore {
  private readonly events = new Map<string, AgentEvent[]>();

  async append(event: AgentEvent): Promise<void> {
    if (!event.sessionId) return;
    const current = this.events.get(event.sessionId) ?? [];
    current.push(event);
    this.events.set(event.sessionId, current);
  }

  async read(sessionId: string): Promise<AgentEvent[]> {
    return [...(this.events.get(sessionId) ?? [])];
  }
}

export class FileSessionLogStore implements AgentSessionLogStore {
  private readonly rootDir: string;

  constructor(options: { rootDir: string }) {
    this.rootDir = options.rootDir;
  }

  async append(event: AgentEvent): Promise<void> {
    if (!event.sessionId) return;
    await fs.mkdir(this.rootDir, { recursive: true });
    await fs.appendFile(this.filePath(event.sessionId), `${JSON.stringify(event)}\n`);
  }

  async read(sessionId: string): Promise<AgentEvent[]> {
    const filePath = this.filePath(sessionId);
    if (!(await pathExists(filePath))) return [];
    return parseJsonLines(await fs.readFile(filePath, "utf8"));
  }

  private filePath(sessionId: string): string {
    return path.join(this.rootDir, `${safeFileSegment(sessionId)}.jsonl`);
  }
}

export class MemoryEventSink implements AgentEventSink {
  private readonly events = new Array<AgentEvent>();

  async append(event: AgentEvent): Promise<void> {
    this.events.push(event);
  }

  async list(query: AgentEventQuery = {}): Promise<AgentEvent[]> {
    return filterEvents(this.events, query);
  }
}

export class FileEventSink implements AgentEventSink {
  private readonly rootDir: string;

  constructor(options: { rootDir: string }) {
    this.rootDir = options.rootDir;
  }

  async append(event: AgentEvent): Promise<void> {
    await fs.mkdir(this.rootDir, { recursive: true });
    await fs.appendFile(path.join(this.rootDir, "events.jsonl"), `${JSON.stringify(event)}\n`);
  }

  async list(query: AgentEventQuery = {}): Promise<AgentEvent[]> {
    const filePath = path.join(this.rootDir, "events.jsonl");
    if (!(await pathExists(filePath))) return [];
    return filterEvents(parseJsonLines(await fs.readFile(filePath, "utf8")), query);
  }
}

export class AgentEventBus {
  private readonly sessionLogStore?: AgentSessionLogStore;
  private readonly eventSink?: AgentEventSink;
  private readonly subscribers = new Set<(event: AgentEvent) => void | Promise<void>>();

  constructor(options: { sessionLogStore?: AgentSessionLogStore; eventSink?: AgentEventSink } = {}) {
    this.sessionLogStore = options.sessionLogStore;
    this.eventSink = options.eventSink;
  }

  subscribe(subscriber: (event: AgentEvent) => void | Promise<void>): () => void {
    this.subscribers.add(subscriber);
    return () => {
      this.subscribers.delete(subscriber);
    };
  }

  async publish(event: AgentEvent): Promise<void> {
    if (event.channels.includes("session")) await this.sessionLogStore?.append(event);
    if (event.channels.includes("log")) await this.eventSink?.append(event);
    if (event.channels.includes("stream")) {
      await Promise.all([...this.subscribers].map((subscriber) => subscriber(event)));
    }
  }
}

export function createEvent(input: {
  type: string;
  runId: string;
  sessionId: string;
  traceId?: string;
  level: AgentEvent["level"];
  channels: AgentEventChannel[];
  message: string;
  data?: Record<string, unknown>;
}): AgentEvent {
  return {
    type: input.type,
    runId: input.runId,
    sessionId: input.sessionId,
    timestamp: new Date().toISOString(),
    level: input.level,
    channels: input.channels,
    message: input.message,
    data: redactForLog(input.traceId ? { ...input.data, traceId: input.traceId } : input.data) as Record<string, unknown> | undefined,
  };
}

export function redactForLog(value: unknown): unknown {
  if (Array.isArray(value)) return value.map((item) => redactForLog(item));
  if (typeof value === "string") return redactSecretText(value);
  if (!value || typeof value !== "object") return value;

  const result: Record<string, unknown> = {};
  for (const [key, nestedValue] of Object.entries(value)) {
    result[key] = isSensitiveLogKey(key) ? "[redacted]" : redactForLog(nestedValue);
  }
  return result;
}

export function summarizeEvents(events: AgentEvent[]): AgentEventSummary {
  const uniqueEvents = dedupeEvents(events);
  return {
    count: uniqueEvents.length,
    warnings: uniqueEvents.filter((event) => event.level === "warn").length,
    errors: uniqueEvents.filter((event) => event.level === "error").length,
    recent: uniqueEvents.slice(-5),
  };
}

export function findLastEvent(events: AgentEvent[], type: string): AgentEvent | undefined {
  for (let index = events.length - 1; index >= 0; index -= 1) {
    if (events[index]?.type === type) return events[index];
  }
  return undefined;
}

function filterEvents(events: AgentEvent[], query: AgentEventQuery): AgentEvent[] {
  const filtered = events.filter((event) => {
    if (query.runId && event.runId !== query.runId) return false;
    if (query.sessionId && event.sessionId !== query.sessionId) return false;
    if (query.traceId && event.data?.traceId !== query.traceId) return false;
    if (query.channels && !query.channels.some((channel) => event.channels.includes(channel))) return false;
    return true;
  });
  return typeof query.limit === "number" ? filtered.slice(-query.limit) : filtered;
}

function parseJsonLines(content: string): AgentEvent[] {
  return content
    .split("\n")
    .filter((line) => line.trim().length > 0)
    .map((line) => JSON.parse(line) as AgentEvent);
}

function dedupeEvents(events: AgentEvent[]): AgentEvent[] {
  const seen = new Set<string>();
  const result = new Array<AgentEvent>();
  for (const event of events) {
    const key = JSON.stringify(event);
    if (!seen.has(key)) {
      seen.add(key);
      result.push(event);
    }
  }
  return result;
}

function isSensitiveLogKey(key: string): boolean {
  const normalized = key.trim().toLowerCase();
  return normalized.includes("key")
    || normalized.includes("token")
    || normalized.includes("secret")
    || normalized.includes("authorization")
    || normalized.includes("password");
}

function redactSecretText(value: string): string {
  return value
    .replace(/\bBearer\s+[A-Za-z0-9._~+/=-]+\b/gi, "Bearer [redacted]")
    .replace(/\b(sk-[A-Za-z0-9_-]+|sk-or-[A-Za-z0-9_-]+|gsk_[A-Za-z0-9_-]+)\b/g, "[redacted]");
}
