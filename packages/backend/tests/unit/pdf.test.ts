import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";

import { exportHtmlToPdf, verifyPdfWithPdfJs } from "../../src/modules/books/providers/pdf.ts";

test("exports retryable PDF result and verifies expected page count through injected pdf.js loader", async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-pdf-"));
  const pdfPath = path.join(dir, "book.pdf");

  const exportResult = await exportHtmlToPdf("<html><body>book</body></html>", pdfPath, {
    render: async (_html, target) => {
      await fs.writeFile(target, "%PDF-1.7\n% KidMemory test PDF\n");
    },
  });

  assert.equal(exportResult.ok, true);

  const verifyResult = await verifyPdfWithPdfJs(pdfPath, 3, {
    load: async () => ({ numPages: 3, firstPageRendered: true }),
  });

  assert.deepEqual(verifyResult, { ok: true, pageCount: 3, firstPageRendered: true });
});

test("PDF export failures are retryable and actionable", async () => {
  const result = await exportHtmlToPdf("<html></html>", "/tmp/nope/book.pdf", {
    render: async () => { throw new Error("Chromium missing"); },
  });

  assert.equal(result.ok, false);
  assert.equal(result.retryable, true);
  assert.match(result.action, /retry/i);
});

test("exports a basic openable PDF without optional Playwright dependency", async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), "kidmemory-basic-pdf-"));
  const pdfPath = path.join(dir, "book.pdf");

  const result = await exportHtmlToPdf("<html><body><section class=\"page\"><h1>封面</h1></section><section class=\"page\"><h1>太阳下的小房子</h1></section><section class=\"page\"><h1>尾声</h1></section></body></html>", pdfPath);
  const bytes = await fs.readFile(pdfPath);
  const verification = await verifyPdfWithPdfJs(pdfPath, 3);

  assert.equal(result.ok, true);
  assert.equal(bytes.subarray(0, 5).toString("utf8"), "%PDF-");
  assert.equal(verification.ok, true);
  assert.equal(verification.pageCount, 3);
});
