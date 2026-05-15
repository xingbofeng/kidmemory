import fs from "node:fs/promises";
import path from "node:path";

type WorkspaceInput = {
  workspaceRoot: string;
  jobId: string;
  child: Record<string, unknown>;
  assets: Array<Record<string, unknown>>;
  secrets?: Record<string, string>;
};

export async function buildAgentWorkspace(input: WorkspaceInput) {
  const workspacePath = path.join(input.workspaceRoot, input.jobId);
  const dirs = ["input", "input/images", "templates", "rules", "output"];
  for (const dir of dirs) await fs.mkdir(path.join(workspacePath, dir), { recursive: true });

  const sanitizedAssets = await copyAssetImages(input.assets, workspacePath);
  await fs.writeFile(path.join(workspacePath, "input", "child.json"), JSON.stringify(input.child, null, 2));
  await fs.writeFile(path.join(workspacePath, "input", "assets.json"), JSON.stringify({ assets: sanitizedAssets }, null, 2));
  await fs.writeFile(path.join(workspacePath, "templates", "warm-artwork-book.html"), templateHtml());
  await fs.writeFile(path.join(workspacePath, "templates", "style.css"), templateCss());
  await fs.writeFile(path.join(workspacePath, "rules", "output-schema.json"), JSON.stringify(outputSchema(), null, 2));
  await fs.writeFile(path.join(workspacePath, "rules", "safety.md"), safetyRules());
  await fs.writeFile(path.join(workspacePath, "rules", "writing-style.md"), writingStyleRules());
  await fs.writeFile(path.join(workspacePath, "input", "images", ".gitkeep"), "");
  await fs.writeFile(path.join(workspacePath, "output", ".gitkeep"), "");

  return { path: workspacePath, outputPath: path.join(workspacePath, "output"), inputAssets: sanitizedAssets };
}

async function copyAssetImages(assets: Array<Record<string, unknown>>, workspacePath: string) {
  const sanitized = [];
  for (const asset of assets) {
    const next = { ...asset };
    const sourcePath = typeof asset.imagePath === "string" ? asset.imagePath : undefined;
    if (sourcePath && path.isAbsolute(sourcePath) && await exists(sourcePath)) {
      const extension = path.extname(sourcePath) || ".asset";
      const targetRelativePath = `input/images/${sanitizeFilename(String(asset.id || "asset"))}${extension}`;
      await fs.copyFile(sourcePath, path.join(workspacePath, targetRelativePath));
      next.imagePath = targetRelativePath;
      if (typeof next.thumbnailPath === "string" && next.thumbnailPath === sourcePath) {
        next.thumbnailPath = targetRelativePath;
      }
    }
    sanitized.push(next);
  }
  return sanitized;
}

async function exists(filePath: string) {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}

function sanitizeFilename(value: string) {
  return value.replace(/[^a-zA-Z0-9_-]/g, "-");
}

function templateHtml() {
  return `<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <title>{{title}}</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>{{pages}}</body>
</html>`;
}

function templateCss() {
  return [
    'body { margin: 0; font-family: "PingFang SC", "Noto Sans CJK SC", sans-serif; color: #352318; background: #fffaf2; }',
    ".page { width: 794px; min-height: 1123px; box-sizing: border-box; padding: 64px; page-break-after: always; background: linear-gradient(180deg, #fffaf2, #fff); }",
    "h1 { font-size: 42px; margin: 0 0 18px; }",
    "h2 { font-size: 30px; margin: 0 0 16px; }",
    "p { font-size: 20px; line-height: 1.7; }",
    "img { max-width: 100%; border-radius: 18px; border: 1px solid #f2dfc9; }",
  ].join("\n");
}

function outputSchema() {
  return {
    type: "object",
    required: ["metadata", "pages"],
    properties: {
      metadata: { type: "object", required: ["title", "childName"] },
      pages: {
        type: "array",
        minItems: 3,
        items: {
          type: "object",
          required: ["kind", "title", "text"],
          properties: {
            kind: { enum: ["cover", "artwork", "photo", "craft", "closing"] },
            title: { type: "string" },
            text: { type: "string" },
            assetId: { type: "string" },
          },
        },
      },
    },
  };
}

function safetyRules() {
  return [
    "# Safety",
    "- Use only files under input, templates and rules.",
    "- Write only to output.",
    "- Never request or expose API keys, database credentials, .env values or local secrets.",
    "- Treat all sample child data as synthetic demonstration content.",
  ].join("\n");
}

function writingStyleRules() {
  return [
    "# Writing Style",
    "- Warm, restrained, family-friendly Chinese prose.",
    "- Keep each page concise and suitable for children and parents reading together.",
    "- Do not invent private facts beyond the provided sample metadata.",
  ].join("\n");
}
