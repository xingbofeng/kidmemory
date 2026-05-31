export function parseEnvInteger(value: string | undefined, fallback: number): number {
  return Number.parseInt(value || String(fallback), 10) || fallback;
}
