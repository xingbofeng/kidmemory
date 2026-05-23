import fs from "node:fs/promises";
import path from "node:path";
import { URLSearchParams } from "node:url";

import type { AgentTool } from "./index.js";

export type PollinationsStorybookImageToolOptions = {
  apiKey?: string;
  baseURL?: string;
  model?: string;
  fetchImpl?: typeof globalThis.fetch;
  env?: Record<string, string | undefined>;
};

export function createPollinationsStorybookImageTool(options: PollinationsStorybookImageToolOptions = {}): AgentTool {
  return {
    id: "generate_storybook_image_with_pollinations",
    name: "Generate Storybook Image With Pollinations",
    description: [
      "Generate a storybook illustration image from a text-only prompt using Pollinations.",
      "Use this for cover or page illustrations, then reference the returned output path from book.json/book.html.",
      "Do not pass child photos, binary data, base64 images, or external image URLs.",
    ].join(" "),
    source: "builtin",
    inputSchema: {
      type: "object",
      properties: {
        prompt: { type: "string" },
        path: { type: "string" },
        width: { type: "number" },
        height: { type: "number" },
        seed: { type: "number" },
        model: { type: "string" },
      },
      required: ["prompt", "path"],
      additionalProperties: false,
    },
    risk: "medium",
    execute: async (input, context) => {
      assertTextOnlyPollinationsInput(input);
      const prompt = readRequiredStringField(input, "prompt");
      const relativePath = requireInputPath(input);
      const target = resolveWorkspacePath(context.workspaceDir, relativePath);
      if (!target.relativePath.startsWith("output/")) {
        throw new Error("Pollinations image output path must be under output/");
      }

      const width = normalizeDimension(readOptionalNumberField(input, "width"), 1024);
      const height = normalizeDimension(readOptionalNumberField(input, "height"), 1024);
      const seed = readOptionalNumberField(input, "seed");
      const env = options.env ?? process.env;
      const model = readOptionalStringField(input, "model")
        ?? readEnvValue(options.model)
        ?? readEnvValue(env.POLLINATIONS_IMAGE_MODEL)
        ?? "flux";
      const baseURL = readEnvValue(options.baseURL)
        ?? readEnvValue(env.IMAGE_API_URL)
        ?? readEnvValue(env.POLLINATIONS_IMAGE_BASE_URL)
        ?? "https://image.pollinations.ai/prompt";
      const apiKey = readEnvValue(options.apiKey)
        ?? readEnvValue(env.POLLINATIONS_API_KEY)
        ?? readEnvValue(env.POLLINATIONS_TOKEN);
      const imageUrl = buildPollinationsImageUrl({ baseURL, prompt, width, height, seed, model });
      const headers = apiKey ? { Authorization: `Bearer ${apiKey}` } : undefined;
      const response = await (options.fetchImpl ?? globalThis.fetch)(imageUrl, { headers });
      if (!response.ok) {
        throw new Error(`Pollinations image generation failed with HTTP ${response.status}.`);
      }

      const bytes = new Uint8Array(await response.arrayBuffer());
      if (bytes.byteLength === 0) {
        throw new Error("Pollinations image generation returned an empty image.");
      }
      await fs.mkdir(path.dirname(target.absolutePath), { recursive: true });
      await fs.writeFile(target.absolutePath, bytes);
      return {
        ok: true,
        provider: "pollinations",
        path: target.relativePath,
        width,
        height,
        model,
        privacyBoundary: {
          textOnly: true,
          childPhotoUpload: false,
        },
      };
    },
  };
}

function requireInputPath(input: unknown): string {
  const value = readInputPath(input);
  if (!value) throw new Error("Missing required path.");
  return value;
}

function readInputPath(input: unknown): string | undefined {
  if (!input || typeof input !== "object" || !("path" in input)) return undefined;
  const value = input.path;
  return typeof value === "string" && value.trim().length > 0 ? toPosixPath(value.trim()) : undefined;
}

function readRequiredStringField(input: unknown, field: string): string {
  const value = readOptionalStringField(input, field);
  if (!value) throw new Error(`Missing required ${field}.`);
  return value;
}

function readOptionalStringField(input: unknown, field: string): string | undefined {
  if (!input || typeof input !== "object" || !(field in input)) return undefined;
  const value = (input as Record<string, unknown>)[field];
  return typeof value === "string" && value.trim().length > 0 ? value.trim() : undefined;
}

function readOptionalNumberField(input: unknown, field: string): number | undefined {
  if (!input || typeof input !== "object" || !(field in input)) return undefined;
  const value = (input as Record<string, unknown>)[field];
  if (typeof value === "number" && Number.isFinite(value)) return value;
  if (typeof value === "string") {
    const parsed = Number.parseFloat(value);
    return Number.isFinite(parsed) ? parsed : undefined;
  }
  return undefined;
}

function resolveWorkspacePath(workspaceDir: string, relativePath: string): { absolutePath: string; relativePath: string } {
  const workspaceRoot = path.resolve(workspaceDir);
  const absolutePath = path.resolve(workspaceRoot, relativePath);
  const normalizedRelativePath = toPosixPath(path.relative(workspaceRoot, absolutePath));
  if (normalizedRelativePath.startsWith("..") || path.isAbsolute(normalizedRelativePath)) {
    throw new Error(`Path is outside workspace: ${relativePath}`);
  }
  return {
    absolutePath,
    relativePath: normalizedRelativePath === "" ? "." : normalizedRelativePath,
  };
}

function buildPollinationsImageUrl(input: {
  baseURL: string;
  prompt: string;
  width: number;
  height: number;
  seed?: number;
  model: string;
}): string {
  const params = new URLSearchParams({
    width: String(input.width),
    height: String(input.height),
    nologo: "true",
    model: input.model,
  });
  if (typeof input.seed === "number" && Number.isFinite(input.seed)) {
    params.set("seed", String(Math.max(0, Math.floor(input.seed))));
  }
  return `${input.baseURL.replace(/\/+$/g, "")}/${encodeURIComponent(input.prompt)}?${params.toString()}`;
}

function assertTextOnlyPollinationsInput(input: unknown): void {
  if (!input || typeof input !== "object") return;
  const disallowed = new Set(["image", "imageurl", "imagepath", "file", "photo", "binary", "b64_json", "base64"]);
  for (const key of Object.keys(input)) {
    if (disallowed.has(key.trim().toLowerCase())) {
      throw new Error("Pollinations storybook image tool only accepts text prompts; child photo payloads are blocked.");
    }
  }
}

function normalizeDimension(value: number | undefined, fallback: number): number {
  if (typeof value !== "number" || !Number.isFinite(value)) return fallback;
  return Math.min(Math.max(Math.round(value), 256), 2048);
}

function readEnvValue(value: string | undefined): string | undefined {
  const normalized = value?.trim();
  return normalized && normalized.length > 0 ? normalized : undefined;
}

function toPosixPath(value: string): string {
  return value.split(path.sep).join("/");
}
