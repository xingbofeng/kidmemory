export type AgentRuntimeErrorCategory = "asset_validation" | "generation" | "skill" | "hyperframes" | "environment" | "unknown";

export type AgentRuntimeError = {
  category: AgentRuntimeErrorCategory;
  code: string;
  message: string;
  recoverable?: boolean;
  cause?: unknown;
  details?: Record<string, unknown>;
};

export type AgentTraceRef = {
  provider: "openai-agents";
  traceId?: string;
  groupId?: string;
  disabled?: boolean;
  metadata?: Record<string, unknown>;
};

export function isRuntimeErrorCategory(value: unknown): value is AgentRuntimeErrorCategory {
  return (
    value === "asset_validation" ||
    value === "generation" ||
    value === "skill" ||
    value === "hyperframes" ||
    value === "environment" ||
    value === "unknown"
  );
}
