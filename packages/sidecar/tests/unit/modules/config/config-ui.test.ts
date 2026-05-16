import assert from "node:assert/strict";
import { test } from "node:test";

import { loadConfigFromEnv } from "../../../../src/infrastructure/config/app-config.service.ts";
import { createConfigReadinessService } from "../../../../src/modules/config/providers/config.domain.ts";

test("ui config endpoint exposes defaults for frontend option lists", () => {
  const service = createConfigReadinessService({
    config: loadConfigFromEnv({}),
    prisma: {} as any,
    migrations: {} as any,
  });

  const uiConfig = service.uiConfig();

  assert.equal(Array.isArray(uiConfig.search.typeOptions), true);
  assert.equal(uiConfig.search.typeOptions[0].value, "all");
  assert.equal(uiConfig.assetLibrary.typeOptions[0].value, "all");
  assert.equal(uiConfig.generate.templates.includes("温暖童趣"), true);
  assert.equal(
    uiConfig.generate.pageSizes.includes("A4 竖版  210 × 297 mm"),
    true,
  );
  assert.equal(
    uiConfig.generate.styles.includes("纪实风  中性偏学术表达"),
    true,
  );
  assert.equal(uiConfig.generate.defaults.template, "温暖童趣");
  assert.equal(uiConfig.setup.checks.length, 4);
  assert.equal(uiConfig.setup.checks[0].title, "PostgreSQL 配置");
  assert.equal(uiConfig.setup.checks[2].title, "OpenAI-compatible API");
});

test("ui config includes generate defaults and directory selectors", () => {
  const service = createConfigReadinessService({
    config: loadConfigFromEnv({
      KIDMEMORY_DATA_DIR: "/tmp/kidmemory/data",
      KIDMEMORY_WORKSPACE_DIR: "/tmp/kidmemory/workspace",
    }),
    prisma: {} as any,
    migrations: {} as any,
  });

  const uiConfig = service.uiConfig();

  assert.equal(uiConfig.generate.defaults.template, "温暖童趣");
  assert.equal(uiConfig.generate.defaults.pageSize, "A4 竖版  210 × 297 mm");
  assert.equal(
    uiConfig.generate.defaults.style,
    "温暖童趣  亲切温暖，适合儿童阅读",
  );
  assert.equal(
    uiConfig.generate.defaults.exportTarget,
    "PDF 文件  高质量 PDF（打印级别）",
  );
  assert.equal(uiConfig.setup.checks[3].title.includes("本地数据目录"), true);
  assert.equal(uiConfig.setup.checks[3].body.includes("/tmp/kidmemory/workspace"), true);
  assert.equal(uiConfig.setup.checks[3].action, "配置目录");
});
