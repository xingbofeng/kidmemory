import assert from "node:assert/strict";
import { test } from "node:test";

import { renderBookHtml, validateBookOutput } from "../../../../src/modules/books/providers/book.ts";

test("validates cover, content, closing pages and selected asset references", () => {
  const book = {
    metadata: { title: "阳光的一天", childName: "澄澄" },
    pages: [
      { kind: "cover", title: "阳光的一天", text: "封面" },
      { kind: "artwork", title: "太阳下的小房子", text: "温暖明亮", assetId: "asset-sun-house" },
      { kind: "closing", title: "尾声", text: "继续珍藏" },
    ],
  };

  const result = validateBookOutput(book, new Set(["asset-sun-house"]));

  assert.equal(result.ok, true);
});

test("rejects invalid book output before preview or export", () => {
  const result = validateBookOutput({
    metadata: { title: "坏输出" },
    pages: [{ kind: "artwork", assetId: "not-selected", title: "bad", text: "bad" }],
  }, new Set(["asset-sun-house"]));

  assert.equal(result.ok, false);
  assert.match(result.errors.join("\n"), /cover/);
  assert.match(result.errors.join("\n"), /not-selected/);
});

test("rejects pages with unsupported kinds", () => {
  const result = validateBookOutput({
    metadata: { title: "坏输出", childName: "澄澄" },
    pages: [
      { kind: "cover", title: "封面", text: "封面" },
      { kind: "spreadsheet", assetId: "asset-sun-house", title: "bad", text: "bad" },
      { kind: "closing", title: "尾声", text: "结束" },
    ],
  }, new Set(["asset-sun-house"]));

  assert.equal(result.ok, false);
  assert.match(result.errors.join("\n"), /unsupported page kind/);
});

test("renders preview HTML from valid book and selected assets", () => {
  const html = renderBookHtml({
    metadata: { title: "阳光的一天", childName: "澄澄" },
    pages: [
      { kind: "cover", title: "阳光的一天", text: "封面" },
      { kind: "artwork", title: "太阳下的小房子", text: "温暖明亮", assetId: "asset-sun-house" },
      { kind: "closing", title: "尾声", text: "继续珍藏" },
    ],
  }, [{ id: "asset-sun-house", title: "太阳下的小房子", thumbnailPath: "assets/sun.svg" }]);

  assert.match(html, /阳光的一天/);
  assert.match(html, /太阳下的小房子/);
  assert.match(html, /温暖明亮/);
});
