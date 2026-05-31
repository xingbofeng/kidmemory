import type { TestContext } from "node:test";

export function useTestEnv(
  t: Pick<TestContext, "after">,
  values: Record<string, string | undefined>,
): void {
  const previous = new Map<string, string | undefined>();

  for (const [key, value] of Object.entries(values)) {
    previous.set(key, process.env[key]);
    setEnv(key, value);
  }

  t.after(() => {
    for (const [key, value] of previous) {
      setEnv(key, value);
    }
  });
}

function setEnv(key: string, value: string | undefined): void {
  if (value === undefined) {
    delete process.env[key];
    return;
  }
  process.env[key] = value;
}
