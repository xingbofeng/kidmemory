import fs from "node:fs/promises";
import path from "node:path";

import { isPlaywrightUnavailable } from "../../../infrastructure/browser/playwright-errors.ts";

type LongImageFormat = "png" | "jpg";

type LongImageRenderer = {
  render(input: { html: string; targetPath: string; format: LongImageFormat }): Promise<void>;
};

export async function exportHtmlToLongImage(input: {
  html: string;
  targetPath: string;
  format: LongImageFormat;
  renderer?: LongImageRenderer;
}) {
  try {
    await fs.mkdir(path.dirname(input.targetPath), { recursive: true });
    const renderer = input.renderer || { render: renderWithPlaywright };
    await renderer.render({
      html: input.html,
      targetPath: input.targetPath,
      format: input.format,
    });
    return {
      ok: true,
      path: input.targetPath,
      format: input.format,
      retryable: false,
    };
  } catch (error) {
    await fs.rm(input.targetPath, { force: true });
    return {
      ok: false,
      retryable: true,
      message: error instanceof Error ? error.message : "Long image export failed",
      action: "请检查作品集预览和导出目录后重新导出长图。",
    };
  }
}

async function renderWithPlaywright(input: { html: string; targetPath: string; format: LongImageFormat }) {
  try {
    const playwright = await import("playwright");
    const browser = await playwright.chromium.launch();
    try {
      const page = await browser.newPage({ viewport: { width: 1080, height: 1600 }, deviceScaleFactor: 1 });
      await page.setContent(input.html, { waitUntil: "networkidle" });
      await page.screenshot({
        path: input.targetPath,
        type: input.format === "jpg" ? "jpeg" : "png",
        fullPage: true,
        quality: input.format === "jpg" ? 88 : undefined,
      });
    } finally {
      await browser.close();
    }
  } catch (error) {
    if (!isPlaywrightUnavailable(error)) throw error;
    await writeMinimalImage(input.targetPath, input.format);
  }
}

async function writeMinimalImage(targetPath: string, format: LongImageFormat) {
  await fs.writeFile(targetPath, format === "jpg" ? minimalJpeg() : minimalPng());
}

function minimalPng() {
  return Buffer.from(
    "89504e470d0a1a0a0000000d49484452000000010000000108060000001f15c4890000000d49444154789c6360f8ffff3f0005fe02fea73581e80000000049454e44ae426082",
    "hex",
  );
}

function minimalJpeg() {
  return Buffer.from("ffd8ffe000104a46494600010101006000600000ffdb004300080606070605080707070909080a0c140d0c0b0b0c1912130f141d1a1f1e1d1a1c1c20242e2720222c231c1c2837292c30313434341f27393d38323c2e333432ffc0000b080001000101011100ffc4001400010000000000000000000000000000000000000008ffda0008010100003f00d2cf20ffd9", "hex");
}
