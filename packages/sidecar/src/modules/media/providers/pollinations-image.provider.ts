import { Inject, Injectable, Optional } from "@nestjs/common";

import type { GenerateImageInput, GenerateImageResult, ImageProvider } from "./image-provider.ts";

const DEFAULT_BASE_URL = "https://image.pollinations.ai/prompt";
const DEFAULT_TIMEOUT_MS = 3500;
const DEFAULT_RETRY_COUNT = 2;

export type PollinationsImageProviderOptions = {
  fetchImpl?: typeof fetch;
  probeEnabled?: boolean;
  timeoutMs?: number;
  retryCount?: number;
};
export const POLLINATIONS_IMAGE_PROVIDER_OPTIONS = Symbol("POLLINATIONS_IMAGE_PROVIDER_OPTIONS");

@Injectable()
export class PollinationsImageProvider implements ImageProvider {
  readonly providerName = "pollinations";
  private readonly fetchImpl: typeof fetch;
  private readonly probeEnabled: boolean;
  private readonly timeoutMs: number;
  private readonly retryCount: number;

  constructor(
    @Optional()
    @Inject(POLLINATIONS_IMAGE_PROVIDER_OPTIONS)
    options: PollinationsImageProviderOptions = {},
  ) {
    this.fetchImpl = options.fetchImpl ?? fetch;
    this.probeEnabled = options.probeEnabled ?? parseBoolean(process.env.POLLINATIONS_PROBE_ENABLED, false);
    this.timeoutMs = normalizePositiveNumber(
      options.timeoutMs,
      normalizePositiveNumber(
        Number.parseInt(process.env.POLLINATIONS_TIMEOUT_MS ?? "", 10),
        DEFAULT_TIMEOUT_MS,
      ),
    );
    this.retryCount = normalizePositiveNumber(
      options.retryCount,
      normalizePositiveNumber(
        Number.parseInt(process.env.POLLINATIONS_RETRY_COUNT ?? "", 10),
        DEFAULT_RETRY_COUNT,
      ),
    );
  }

  async generate(input: GenerateImageInput): Promise<GenerateImageResult> {
    const prompt = normalizePrompt(input.prompt);
    if (!prompt) {
      return {
        ok: false,
        provider: this.providerName,
        prompt,
        error: {
          code: "PROMPT_REQUIRED",
          message: "Prompt is required for image generation.",
          recoverable: true,
        },
        privacyBoundary: {
          textOnly: true,
          childPhotoUpload: false,
        },
      };
    }

    if (hasDisallowedPhotoPayload(input as Record<string, unknown>)) {
      return {
        ok: false,
        provider: this.providerName,
        prompt,
        error: {
          code: "PHOTO_INPUT_NOT_ALLOWED",
          message: "Pollinations provider only accepts text prompts; photo payloads are blocked.",
          recoverable: true,
        },
        privacyBoundary: {
          textOnly: true,
          childPhotoUpload: false,
        },
      };
    }

    const width = normalizeDimension(input.width, 1024);
    const height = normalizeDimension(input.height, 1024);
    const seed = normalizeSeed(input.seed);

    const params = new URLSearchParams({
      width: String(width),
      height: String(height),
      nologo: "true",
      model: process.env.POLLINATIONS_IMAGE_MODEL?.trim() || "flux",
    });
    if (seed != null) {
      params.set("seed", String(seed));
    }

    const baseUrl = process.env.POLLINATIONS_IMAGE_BASE_URL?.trim() || DEFAULT_BASE_URL;
    const imageUrl = `${baseUrl}/${encodeURIComponent(prompt)}?${params.toString()}`;

    if (this.probeEnabled) {
      const probe = await this.probeProvider(imageUrl);
      if (!probe.ok) {
        return {
          ok: false,
          provider: this.providerName,
          prompt,
          error: {
            code: probe.timeout ? "PROVIDER_TIMEOUT" : "PROVIDER_UNAVAILABLE",
            message: probe.message,
            recoverable: true,
          },
          privacyBoundary: {
            textOnly: true,
            childPhotoUpload: false,
          },
        };
      }
    }

    return {
      ok: true,
      provider: this.providerName,
      prompt,
      imageUrl,
      privacyBoundary: {
        textOnly: true,
        childPhotoUpload: false,
      },
    };
  }

  private async probeProvider(imageUrl: string) {
    let timeoutDetected = false;
    let lastMessage = "Pollinations service is temporarily unavailable.";

    for (let attempt = 0; attempt <= this.retryCount; attempt += 1) {
      const probeResult = await this.runProbeAttempt(imageUrl);
      if (probeResult.ok) {
        return { ok: true, timeout: false, message: "" };
      }

      timeoutDetected = timeoutDetected || probeResult.timeout;
      lastMessage = probeResult.message;
    }

    return { ok: false, timeout: timeoutDetected, message: lastMessage };
  }

  private async runProbeAttempt(imageUrl: string) {
    const controller = new AbortController();
    const timeoutHandle = setTimeout(() => controller.abort(), this.timeoutMs);

    try {
      const response = await this.fetchImpl(imageUrl, {
        method: "HEAD",
        signal: controller.signal,
      });
      if (response.ok) {
        return { ok: true, timeout: false, message: "" };
      }
      return {
        ok: false,
        timeout: false,
        message: `Pollinations service returned HTTP ${response.status}.`,
      };
    } catch (error) {
      const timeout = isTimeoutLikeError(error);
      return {
        ok: false,
        timeout,
        message: timeout
          ? `Pollinations request timed out after ${this.timeoutMs}ms.`
          : `Pollinations request failed: ${sanitizeErrorMessage(error)}`,
      };
    } finally {
      clearTimeout(timeoutHandle);
    }
  }
}

function normalizePrompt(value: string) {
  return value.trim().replace(/\s+/g, " ");
}

function normalizeDimension(value: number | undefined, fallback: number) {
  if (typeof value !== "number" || !Number.isFinite(value)) {
    return fallback;
  }
  return Math.min(Math.max(Math.round(value), 256), 2048);
}

function normalizeSeed(value: number | undefined) {
  if (typeof value !== "number" || !Number.isFinite(value)) {
    return undefined;
  }
  return Math.max(0, Math.floor(value));
}

function normalizePositiveNumber(value: number | undefined, fallback: number) {
  if (typeof value !== "number" || !Number.isFinite(value)) {
    return fallback;
  }
  const normalized = Math.floor(value);
  return normalized >= 0 ? normalized : fallback;
}

function parseBoolean(value: string | undefined, fallback: boolean) {
  if (typeof value !== "string") {
    return fallback;
  }
  const normalized = value.trim().toLowerCase();
  if (["1", "true", "yes", "on"].includes(normalized)) {
    return true;
  }
  if (["0", "false", "no", "off"].includes(normalized)) {
    return false;
  }
  return fallback;
}

function hasDisallowedPhotoPayload(input: Record<string, unknown>) {
  const disallowed = ["image", "imageurl", "imagepath", "file", "photo", "binary", "b64_json"];
  return Object.keys(input).some((key) => disallowed.includes(key.trim().toLowerCase()));
}

function isTimeoutLikeError(error: unknown) {
  if (!error || typeof error !== "object") {
    return false;
  }
  const name = "name" in error ? String((error as { name?: unknown }).name ?? "") : "";
  const message = "message" in error ? String((error as { message?: unknown }).message ?? "") : "";
  return name.toLowerCase().includes("abort")
    || name.toLowerCase().includes("timeout")
    || message.toLowerCase().includes("abort")
    || message.toLowerCase().includes("timeout");
}

function sanitizeErrorMessage(error: unknown) {
  if (error instanceof Error) {
    return error.message.replace(/\s+/g, " ").trim();
  }
  return String(error).replace(/\s+/g, " ").trim();
}
