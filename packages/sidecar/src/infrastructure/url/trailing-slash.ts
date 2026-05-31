export function trimTrailingSlash(value: string): string {
  return value.replace(/\/+$/, "");
}
