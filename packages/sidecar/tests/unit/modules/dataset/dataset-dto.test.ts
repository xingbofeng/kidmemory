import assert from "node:assert/strict";
import { test } from "node:test";

import { SearchAssetsDtoSchema } from "../../../../src/modules/dataset/dto/search-assets.dto.ts";
import { UpdateAssetDtoSchema } from "../../../../src/modules/dataset/dto/update-asset.dto.ts";

test("asset metadata DTOs limit tag count and tag length", () => {
  const tooManyTags = Array.from({ length: 51 }, (_, index) => `tag-${index}`);
  const tooLongTag = "x".repeat(65);

  assert.equal(UpdateAssetDtoSchema.safeParse({ tags: tooManyTags }).success, false);
  assert.equal(UpdateAssetDtoSchema.safeParse({ tags: [tooLongTag] }).success, false);
  assert.equal(
    SearchAssetsDtoSchema.safeParse({
      childId: "child-1",
      query: "rainbow",
      filters: { tags: tooManyTags },
    }).success,
    false,
  );
});
