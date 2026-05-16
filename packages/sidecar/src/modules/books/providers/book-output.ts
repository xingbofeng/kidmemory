import fs from "node:fs/promises";
import path from "node:path";

import { validateBookOutput } from "./book.ts";

export async function loadValidatedBookOutput(workspacePath: string, selectedAssetIds: Set<string>) {
  const outputPath = path.join(workspacePath, "output");
  const [bookRaw, html] = await Promise.all([
    fs.readFile(path.join(outputPath, "book.json"), "utf8"),
    fs.readFile(path.join(outputPath, "book.html"), "utf8"),
  ]);
  const book = JSON.parse(bookRaw);
  const validation = validateBookOutput(book, selectedAssetIds);
  if (!validation.ok) {
    return { ok: false, errors: validation.errors, book, html };
  }
  return { ok: true, book, html, errors: [] };
}
