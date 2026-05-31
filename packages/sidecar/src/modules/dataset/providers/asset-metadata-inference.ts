import fs from "node:fs/promises";
import path from "node:path";
import { Logger } from "@nestjs/common";

import type { AppConfigService } from "../../../infrastructure/config/app-config.service.ts";

type ChatCompletionResponse = {
  choices?: Array<{
    message?: {
      content?: unknown;
    };
  }>;
};

const logger = new Logger("AssetMetadataInference");

export type InferAssetMetadata = (input: {
  assetId: string;
  imagePath: string;
  childId: string;
}) => Promise<{
  title?: string;
  description?: string;
  tags?: string[];
} | null>;

export function createOpenAIAssetMetadataInferer(
  configService: AppConfigService,
  fetcher: typeof fetch = fetch,
): InferAssetMetadata | undefined {
  const config = configService.config.openai;
  if (!config.baseUrl || !config.apiKey || !config.model) return undefined;

  return async ({ assetId, imagePath }) => {
    let dataUrl = "";
    try {
      const image = await fs.readFile(imagePath);
      const ext = path.extname(imagePath).toLowerCase();
      const mime = ext === ".png"
        ? "image/png"
        : ext === ".webp"
          ? "image/webp"
          : "image/jpeg";
      dataUrl = `data:${mime};base64,${image.toString("base64")}`;
    } catch (error) {
      logger.warn(
        `[asset-metadata] skip asset=${assetId}: failed to read image (${error instanceof Error ? error.message : String(error)})`,
      );
      return null;
    }

    logger.log(`[asset-metadata] start asset=${assetId}`);
    try {
      const response = await fetcher(`${config.baseUrl.replace(/\/$/, "")}/chat/completions`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${config.apiKey}`,
        },
        body: JSON.stringify({
          model: config.model,
          response_format: { type: "json_object" },
          messages: [
            {
              role: "system",
              content: "你是素材标签助手。请返回 JSON：{title:string,description:string,tags:string[]}.",
            },
            {
              role: "user",
              content: [
                { type: "text", text: "请识别图片内容并生成中文标题、描述和标签。" },
                { type: "image_url", image_url: { url: dataUrl } },
              ],
            },
          ],
        }),
      });
      if (!response.ok) {
        logger.warn(`[asset-metadata] fail asset=${assetId}: http status ${response.status}`);
        return null;
      }
      const payload = await response.json() as ChatCompletionResponse;
      const raw = payload?.choices?.[0]?.message?.content;
      if (typeof raw !== "string" || !raw.trim()) {
        logger.warn(`[asset-metadata] fail asset=${assetId}: empty model content`);
        return null;
      }
      const parsed = parseMetadataContent(raw);
      if (!parsed) {
        logger.warn(`[asset-metadata] fail asset=${assetId}: model content is not valid metadata json`);
        return null;
      }
      const normalized = {
        title: typeof parsed.title === "string" ? parsed.title.trim() : undefined,
        description: typeof parsed.description === "string" ? parsed.description.trim() : undefined,
        tags: Array.isArray(parsed.tags)
          ? parsed.tags.map((tag) => String(tag).trim()).filter(Boolean).slice(0, 8)
          : undefined,
      };
      logger.log(
        `[asset-metadata] success asset=${assetId}: title=${Boolean(normalized.title)} tags=${normalized.tags?.length || 0} description=${Boolean(normalized.description)}`,
      );
      return normalized;
    } catch (error) {
      logger.warn(
        `[asset-metadata] fail asset=${assetId}: ${error instanceof Error ? error.message : String(error)}`,
      );
      return null;
    }
  };
}

function parseMetadataContent(raw: string): { title?: unknown; description?: unknown; tags?: unknown } | null {
  const trimmed = raw.trim();
  const direct = safeParseJsonObject(trimmed);
  if (direct) return direct;

  const fenced = trimmed.match(/```(?:json)?\s*([\s\S]*?)\s*```/i);
  if (fenced?.[1]) {
    const parsedFenced = safeParseJsonObject(fenced[1].trim());
    if (parsedFenced) return parsedFenced;
  }

  const firstBrace = trimmed.indexOf("{");
  const lastBrace = trimmed.lastIndexOf("}");
  if (firstBrace >= 0 && lastBrace > firstBrace) {
    return safeParseJsonObject(trimmed.slice(firstBrace, lastBrace + 1));
  }

  return null;
}

function safeParseJsonObject(value: string): { title?: unknown; description?: unknown; tags?: unknown } | null {
  try {
    const parsed = JSON.parse(value);
    if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) return null;
    return parsed as { title?: unknown; description?: unknown; tags?: unknown };
  } catch {
    return null;
  }
}
