import type { Client } from "@modelcontextprotocol/sdk/client/index.js";
import type { TestContext } from "node:test";

import { useTestEnv } from "../test-env.ts";

type McpTestEnvOptions = {
  enabled?: boolean;
  path?: string;
};

export function useMcpTestEnv(t: Pick<TestContext, "after">, options: McpTestEnvOptions = {}): void {
  useTestEnv(t, {
    KIDMEMORY_MCP_ENABLED: options.enabled === false ? "false" : "true",
    KIDMEMORY_MCP_PATH: options.path ?? "/mcp",
  });
}

export function parseToolJson(result: Awaited<ReturnType<Client["callTool"]>>): Record<string, unknown> {
  const first = result.content?.[0];
  if (!first || !("text" in first) || typeof first.text !== "string") {
    return {};
  }

  const decoded = decodeNestedJson(first.text);
  if (decoded && typeof decoded === "object" && !Array.isArray(decoded)) {
    return decoded as Record<string, unknown>;
  }
  return {};
}

function decodeNestedJson(value: string): unknown {
  let current: unknown = value;

  for (let i = 0; i < 3; i += 1) {
    if (typeof current !== "string") {
      break;
    }
    try {
      current = JSON.parse(current);
    } catch {
      break;
    }
  }

  return current;
}
