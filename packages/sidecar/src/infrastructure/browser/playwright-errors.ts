import { hasErrorCode } from "../errors/error-code.ts";

export function isPlaywrightUnavailable(error: unknown) {
  if (hasErrorCode(error, "ERR_MODULE_NOT_FOUND")) return true;
  if (!(error instanceof Error)) return false;
  const message = error.message.toLowerCase();
  return (
    message.includes("chromium") &&
    (
      message.includes("executable") ||
      message.includes("install") ||
      message.includes("not found") ||
      message.includes("failed to launch")
    )
  );
}
