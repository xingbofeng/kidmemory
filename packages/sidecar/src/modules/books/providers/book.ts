export type BookPage = {
  kind: "cover" | "artwork" | "photo" | "craft" | "closing";
  title: string;
  text: string;
  assetId?: string;
};

export type BookOutput = {
  metadata: {
    title: string;
    childName: string;
  };
  pages: BookPage[];
};

const allowedPageKinds = new Set(["cover", "artwork", "photo", "craft", "closing"]);

export function validateBookOutput(book: any, selectedAssetIds: Set<string>) {
  const errors: string[] = [];
  if (!book || typeof book !== "object") errors.push("Book output must be an object.");
  if (!book?.metadata?.title) errors.push("Book metadata.title is required.");
  if (!book?.metadata?.childName) errors.push("Book metadata.childName is required.");
  if (!Array.isArray(book?.pages) || book.pages.length < 3) errors.push("Book pages must include cover, content and closing pages.");
  const pages = Array.isArray(book?.pages) ? book.pages : [];
  if (!pages.some((page: any) => page.kind === "cover")) errors.push("Book must include a cover page.");
  if (!pages.some((page: any) => page.kind === "closing")) errors.push("Book must include a closing page.");
  if (!pages.some((page: any) => page.kind !== "cover" && page.kind !== "closing")) errors.push("Book must include at least one content page.");
  for (const [index, page] of pages.entries()) {
    if (!page.title || !page.text || !page.kind) errors.push(`Page ${index + 1} is missing kind, title or text.`);
    if (page.kind && !allowedPageKinds.has(page.kind)) errors.push(`Page ${index + 1} has unsupported page kind ${page.kind}.`);
    if (page.assetId && !selectedAssetIds.has(page.assetId)) errors.push(`Page ${index + 1} references unselected asset ${page.assetId}.`);
  }
  return errors.length ? { ok: false, errors } : { ok: true, errors: [] };
}

export function renderBookHtml(book: BookOutput, assets: Array<{ id: string; title: string; thumbnailPath?: string; imagePath?: string }>) {
  const assetById = new Map(assets.map((asset) => [asset.id, asset]));
  const pages = book.pages.map((page, index) => {
    const asset = page.assetId ? assetById.get(page.assetId) : undefined;
    const image = asset?.thumbnailPath || asset?.imagePath;
    return `<section class="page page-${escapeHtml(page.kind)}">
      <p class="page-number">${index + 1}</p>
      <h1>${escapeHtml(page.title)}</h1>
      ${image ? `<img src="${escapeHtml(image)}" alt="${escapeHtml(asset?.title || page.title)}">` : ""}
      <p>${escapeHtml(page.text)}</p>
    </section>`;
  }).join("\n");

  return `<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <title>${escapeHtml(book.metadata.title)}</title>
  <style>
    body { margin: 0; font-family: -apple-system, BlinkMacSystemFont, "PingFang SC", sans-serif; color: #352318; background: #fffaf2; }
    .page { width: 794px; min-height: 1123px; box-sizing: border-box; padding: 64px; page-break-after: always; background: #fffaf2; }
    .page-number { color: #8c7663; }
    h1 { font-size: 42px; margin: 0 0 18px; }
    p { font-size: 20px; line-height: 1.7; }
    img { display: block; width: 100%; max-height: 600px; object-fit: cover; border-radius: 18px; border: 1px solid #f2dfc9; margin: 24px 0; }
  </style>
</head>
<body>${pages}</body>
</html>`;
}

function escapeHtml(value: unknown) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}
