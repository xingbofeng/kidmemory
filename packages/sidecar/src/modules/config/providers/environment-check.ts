export type EnvironmentCheck = {
  name: string;
  ok: boolean;
  detail: string;
  action?: string;
};

export function summarizeEnvironmentChecks(checks: EnvironmentCheck[]) {
  const passing = checks.filter((check) => check.ok);
  const blockers = checks.filter((check) => !check.ok);
  return {
    ok: blockers.length === 0,
    passing,
    blockers,
  };
}
