# Engineering Refactor Audit (2026-05-17)

## Scope

按照 `openspec/changes/kidmemory-engineering-refactor/tasks.md`，以“默认未完成”标准重新验收 step1~4，并推进 step5。

## Acceptance Checklist and Evidence

### 1) i18n / TS / ESLint / Tests / API migration

- Protocol gates: `npm run check && npm run build && npm test && npm run gen:ts && npm run gen:dart` passed.
- Web gates: `npm run lint && npm run type-check && npm test -- --run && npm run build` passed.
- Cloud API gates: `npm run lint && npm run type-check && npm run test && npm run build && npm run gen:openapi` passed.
- Desktop gates: `flutter analyze && flutter test` passed.
- Sidecar gates with DB (local PostgreSQL cluster):
  - `npm run lint`
  - `npm run type-check`
  - `npm run test` (525/525)
  - `npm run build` (unit suites all pass)
  - `npm run gen:openapi`

API migration契约复核：

- Sidecar sync client now matches cloud-api endpoints and verbs:
  - `POST /devices/register`
  - `PUT /devices/:id/heartbeat`
  - `GET /upload-items/pending-sync?...`
  - `PUT /upload-items/:id/sync-status`
  - `GET /jobs/pending?...`
  - `PUT /jobs/:id/status`
- Sidecar sync client supports `code/msg/data` envelope unwrap and non-zero code errors.
- Unit test coverage: `packages/sidecar/tests/unit/modules/sync/cloud-api-client.test.ts`.

新增复核与修复（本轮）：

- ✅ `packages/protocol/proto/kidmemory/v1/*.proto` 已补齐（`common/device/job/upload/share/artifact`），并新增 `proto:lint`（`buf lint proto`）。
- ✅ 新增测试 `packages/protocol/tests/proto-definitions.test.ts`（先红后绿）验证：
  - Proto 文件齐备；
  - `proto3` + `package kidmemory.v1`；
  - 不含 gRPC `service` 定义；
  - `npm run proto:lint` 可执行且通过。
- ✅ Cloud API 已补齐 Web 上传/分享兼容入口（`/api/web-companion/*`）：
  - `GET /api/web-companion/direct-upload/sessions/:sessionId/config`
  - `GET /api/web-companion/sessions/:sessionId`
  - `POST /api/web-companion/sessions/:sessionId/items`
  - `PUT /api/web-companion/sessions/:sessionId/items/:uploadItemId/commit`
  - `GET /api/web-companion/share/:shareToken/access`
  - `GET /api/web-companion/share/:shareToken/assets`
  - `GET /api/web-companion/share/:shareToken/book`
- ✅ 对 `OpenAPI -> generated TS` 的契约完整性做了 TDD 加固：
  - 新增 `packages/protocol/tests/openapi-path-params.test.ts` 断言：
    - web-companion 写接口必须有 `requestBody` schema；
    - 生成的 `generated/cloud-api/ts/index.d.ts` 必须保留 `requestBody` 类型。
  - 在 `packages/cloud-api/src/modules/web-companion/web-companion.controller.ts` 补 `@ApiBody`，并重生成 OpenAPI/TS 产物。
- ✅ `web` API 层继续向协议生成类型收敛：
  - `packages/web/src/api/uploadApi.ts` 的请求/响应类型改为基于 `@kidmemory/protocol/generated/cloud-api/ts` 推导。
- ✅ `web` 测试质量闸门补齐：
  - 在 `packages/web/src/test/setup.ts` 将 React `act(...)` 警告升级为测试失败；
  - 修复 `FileUpload`/`AssetBrowser` 测试交互，现 `npm test -- --run` 无 `act` 警告。
- ✅ 侧车端严格集成验收下修复真实缺陷：
  - `packages/sidecar/src/infrastructure/database/prisma.service.ts` 改为兼容 `@prisma/client` 的多导出形态；
  - 修复后 `DATABASE_URL=... npm run test:integration` 全绿（59/59）。

### 2) OpenAPI / generated clients / CI sync checks

- `packages/sidecar/scripts/generate-openapi.ts` and `packages/cloud-api/scripts/generate-openapi.ts` are implemented.
- `packages/protocol/scripts/generate-ts-client.mjs` and `generate-dart-client.mjs` are implemented.
- `packages/protocol/package.json` exports generated TS paths:
  - `./generated/cloud-api/ts`
  - `./generated/sidecar/ts`
- `protocol-ci.yml` now runs codegen and verifies generated outputs are up to date.
- `cloud-api-ci.yml` now verifies cloud-api OpenAPI artifacts are up to date.

### 3) Service split and deployment path consistency

- Deploy workflow path fixed to `packages/cloud-api` (no `packages/backend` runtime deploy path).
- Full workflow set exists:
  - `.github/workflows/ci.yml`
  - `.github/workflows/protocol-ci.yml`
  - `.github/workflows/cloud-api-ci.yml`
  - `.github/workflows/acceptance.yml`
  - `.github/workflows/deploy-tencent.yml`
  - `.github/workflows/deploy-vercel.yml`
  - `.github/workflows/desktop-release.yml`

### 4) Docs/architecture consistency fixes done in this pass

- `README.md` updated from legacy `backend` references to `sidecar/cloud-api/protocol`.
- Removed stale links to deleted docs and stale script references.
- Updated test/dev/deploy commands and secrets naming to current workflows.

## Step 5 status

- 5.1~5.12: 本地等价验收已完成（含 DB 集成与 smoke）。
- 5.13 CI 全绿：本地等价命令链全绿，但远端 GitHub Actions 仍需一次真实流水线结果作为最终证据。
- 5.14 cloud-api deployment success: **environment-gated**（需真实云端主机、密钥、网络）。
- 5.15 web deployment success: **environment-gated**（需真实 Vercel 环境与部署触发）。

## Blockers

Deployment verification cannot be fully closed in local workspace without real GitHub Secrets / target infrastructure.

## Conclusion

- Step1~4：按“默认未完成”标准重验并修复后，当前本地证据已闭环（架构、代码、类型、lint、测试、API 迁移）。
- Step5：本地可验证项已覆盖，剩余阻塞仅为真实远端部署与远端 CI 结果证明。

## Additional production-build findings fixed in this pass

- `build:prod` for sidecar/cloud-api previously inherited `noEmit: true` and could silently produce no `dist` output.
- Fixed:
  - `packages/sidecar/tsconfig.build.json`: added `noEmit: false`.
  - `packages/cloud-api/tsconfig.build.json`: added explicit build compiler options + `noEmit: false` + `rewriteRelativeImportExtensions` and `include: [src/main.ts]`.
- Re-verified:
  - `packages/sidecar/dist/main.js` exists after `npm run build:prod`.
  - `packages/cloud-api/dist/main.js` exists after `npm run build:prod`.
  - cloud-api production smoke (local):
    - `GET /health` returned `{code:0,msg:"success",data:{status:"ok"...}}`
    - `GET /docs/openapi.json` returned OpenAPI 3.0.0 document.

Note: sidecar `dist/main.js` local runtime currently still depends on protocol package runtime export strategy; desktop bundled sidecar path uses release bundling script and source entry path (`src/main.ts`) with `--experimental-strip-types`.
