const SENSITIVE_KEY_PATTERN = /(api[-_]?key|password|token|secret|authorization|cookie)/i;

export function redactSensitive(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map((item) => redactSensitive(item));
  }

  if (!value || typeof value !== "object") {
    return value;
  }

  const record = value as Record<string, unknown>;
  const next: Record<string, unknown> = {};

  for (const [key, rawValue] of Object.entries(record)) {
    if (SENSITIVE_KEY_PATTERN.test(key)) {
      next[key] = "[REDACTED]";
      continue;
    }
    next[key] = redactSensitive(rawValue);
  }

  return next;
}
