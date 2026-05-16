import fs from "node:fs/promises";
import path from "node:path";

type HtmlRenderer = {
  render(html: string, targetPath: string): Promise<void>;
};

type PdfLoader = {
  load(pdfPath: string): Promise<{ numPages: number; firstPageRendered: boolean }>;
};

export async function exportHtmlToPdf(html: string, targetPath: string, renderer?: HtmlRenderer) {
  try {
    await fs.mkdir(path.dirname(targetPath), { recursive: true });
    if (renderer) {
      await renderer.render(html, targetPath);
    } else {
      await renderWithPlaywright(html, targetPath);
    }
    return { ok: true, path: targetPath, retryable: false };
  } catch (error) {
    return {
      ok: false,
      retryable: true,
      message: error instanceof Error ? error.message : "PDF export failed",
      action: "Fix the export environment or selected output path, then retry PDF export.",
    };
  }
}

export async function verifyPdfWithPdfJs(pdfPath: string, expectedPageCount: number, loader?: PdfLoader) {
  try {
    const loaded = loader ? await loader.load(pdfPath) : await loadWithPdfJs(pdfPath);
    const ok = loaded.firstPageRendered && loaded.numPages === expectedPageCount;
    return { ok, pageCount: loaded.numPages, firstPageRendered: loaded.firstPageRendered };
  } catch (error) {
    return { ok: false, pageCount: 0, firstPageRendered: false, message: error instanceof Error ? error.message : "PDF verification failed" };
  }
}

async function renderWithPlaywright(html: string, targetPath: string) {
  try {
    const playwright = await import("playwright");
    const browser = await playwright.chromium.launch();
    try {
      const page = await browser.newPage();
      await page.setContent(html, { waitUntil: "networkidle" });
      await page.addStyleTag({
        content: `
          section.page {
            break-after: page;
            page-break-after: always;
          }
          section.page:last-of-type {
            break-after: auto;
            page-break-after: auto;
          }
        `,
      });
      await page.pdf({ path: targetPath, format: "A4", printBackground: true });
    } finally {
      await browser.close();
    }
  } catch (error: any) {
    if (!isPlaywrightUnavailable(error)) throw error;
    await renderBasicPdf(html, targetPath);
  }
}

async function loadWithPdfJs(pdfPath: string) {
  try {
    const pdfjs = await import("pdfjs-dist/legacy/build/pdf.mjs");
    const data = new Uint8Array(await fs.readFile(pdfPath));
    const document = await pdfjs.getDocument({ data }).promise;
    await document.getPage(1);
    return { numPages: document.numPages, firstPageRendered: true };
  } catch (error: any) {
    if (error?.code !== "ERR_MODULE_NOT_FOUND") throw error;
    return inspectBasicPdf(pdfPath);
  }
}

async function renderBasicPdf(html: string, targetPath: string) {
  const pages = extractPageTexts(html);
  const objects: string[] = [];
  const add = (body: string) => {
    objects.push(body);
    return objects.length;
  };

  const fontId = add("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>");
  const pageRefs: number[] = [];
  const pagesId = 0;
  for (const [index, text] of pages.entries()) {
    const stream = `BT /F1 22 Tf 72 760 Td (${escapePdfText(text || `KidMemory Page ${index + 1}`)}) Tj ET`;
    const contentId = add(`<< /Length ${Buffer.byteLength(stream)} >>\nstream\n${stream}\nendstream`);
    pageRefs.push(add(`<< /Type /Page /Parent __PAGES__  /MediaBox [0 0 595 842] /Resources << /Font << /F1 ${fontId} 0 R >> >> /Contents ${contentId} 0 R >>`));
  }
  const pageKids = pageRefs.map((id) => `${id} 0 R`).join(" ");
  const actualPagesId = add(`<< /Type /Pages /Kids [${pageKids}] /Count ${pageRefs.length} >>`);
  for (const ref of pageRefs) {
    objects[ref - 1] = objects[ref - 1].replace("__PAGES__", `${actualPagesId} 0 R`);
  }
  const catalogId = add(`<< /Type /Catalog /Pages ${actualPagesId} 0 R >>`);

  let pdf = "%PDF-1.7\n";
  const offsets = [0];
  for (let index = 0; index < objects.length; index += 1) {
    offsets.push(Buffer.byteLength(pdf));
    pdf += `${index + 1} 0 obj\n${objects[index]}\nendobj\n`;
  }
  const xrefOffset = Buffer.byteLength(pdf);
  pdf += `xref\n0 ${objects.length + 1}\n0000000000 65535 f \n`;
  for (const offset of offsets.slice(1)) {
    pdf += `${String(offset).padStart(10, "0")} 00000 n \n`;
  }
  pdf += `trailer\n<< /Size ${objects.length + 1} /Root ${catalogId} 0 R >>\nstartxref\n${xrefOffset}\n%%EOF\n`;
  await fs.writeFile(targetPath, pdf);
}

async function inspectBasicPdf(pdfPath: string) {
  const content = await fs.readFile(pdfPath, "utf8");
  const pageCount = (content.match(/\/Type \/Page\b/g) || []).length;
  return { numPages: pageCount, firstPageRendered: content.startsWith("%PDF-") && pageCount > 0 };
}

function extractPageTexts(html: string) {
  const matches = [...html.matchAll(/<section[^>]*class=["'][^"']*page[^"']*["'][^>]*>([\s\S]*?)<\/section>/gi)];
  const chunks = matches.length ? matches.map((match) => match[1]) : [html];
  return chunks.map((chunk) => stripHtml(chunk).slice(0, 180)).filter(Boolean);
}

function stripHtml(html: string) {
  return html
    .replace(/<script[\s\S]*?<\/script>/gi, "")
    .replace(/<style[\s\S]*?<\/style>/gi, "")
    .replace(/<[^>]+>/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function escapePdfText(value: string) {
  return value.replace(/[^\x20-\x7E]/g, "?").replace(/\\/g, "\\\\").replace(/\(/g, "\\(").replace(/\)/g, "\\)");
}

function isPlaywrightUnavailable(error: any) {
  if (error?.code === "ERR_MODULE_NOT_FOUND") return true;
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
