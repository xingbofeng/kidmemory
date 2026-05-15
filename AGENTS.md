# Repository Guidelines

## 项目结构与模块组织

KidMemory 是一个本地优先的多应用仓库。当前 MVP 主要包括 `packages/desktop` 的 macOS Flutter 桌面端，以及 `packages/backend` 的 Node.js sidecar API 与任务编排服务。Flutter 代码位于 `lib/app`、`lib/core`、`lib/data`、`lib/features`、`lib/shared`，测试位于 `packages/desktop/test`。Sidecar 运行时代码位于 `packages/backend/src`，其中业务模块在 `src/modules`，基础设施代码在 `src/infrastructure`，测试位于 `packages/backend/tests`。产品说明、发布报告在 `docs/`，示例输入在 `examples/sample-dataset/`，模板资源在 `templates/`。

## 构建、测试与开发命令

- `cd packages/backend && npm install`：安装 sidecar 依赖，要求 Node 22+。
- `cd packages/backend && npm run dev`：运行 `src/main.ts` 启动 sidecar。
- `cd packages/backend && npm test`：执行 `tests/**/*.test.ts` 下的 Node 测试。
- `cd packages/backend && npm run build`：对 sidecar 做语法级构建检查。
- `cd packages/backend && npx prisma migrate deploy`：按迁移历史应用数据库迁移（基线迁移目录：`prisma/migrations/init`）。
- `cd packages/desktop && flutter pub get`：安装 Flutter 依赖。
- `cd packages/desktop && flutter analyze`：执行 Dart/Flutter 静态检查。
- `cd packages/desktop && flutter test`：运行单元测试和组件测试。
- `cd packages/desktop && flutter run -d macos`：本地启动桌面端 MVP。

## 编码风格与命名约定

遵循现有目录分层，新增功能应明确归属对应应用。Flutter 侧使用 `flutter_lints`，优先使用 `const` 构造和不可变字面量。Dart 文件使用 `snake_case.dart`，类型使用 `PascalCase`，成员使用 lowerCamelCase。Sidecar 的 TypeScript 文件名保持 kebab-case，并带职责后缀，例如 `books.service.ts`、`config.controller.ts`。尽量保持模块小而清晰，避免打破 `modules/` 与 `infrastructure/` 的边界。

## 测试指南

提交 PR 前为相关改动补齐测试。Flutter 测试放在 `packages/desktop/test`，文件名使用 `_test.dart` 后缀。Sidecar 使用 Node 内置测试运行器，测试文件放在 `packages/backend/tests/unit` 或 `packages/backend/tests/architecture`，文件名使用 `.test.ts` 后缀。涉及跨端流程时，至少同时运行桌面端和 sidecar 的对应测试命令。

## 提交与 Pull Request 规范

提交信息使用 Conventional Commits：`type(scope): summary`，例如 `feat(sidecar): add dataset readiness endpoint`。标题使用祈使语气，保持简洁。Pull Request 需要说明变更范围、影响的应用、关联 issue 或 spec、本地验证步骤；若涉及 UI，请附截图，并尽量对照 `docs/design` 中的设计稿说明差异。

## 配置与 Agent 说明

本地配置从 `.env.example` 开始，禁止把密钥或环境配置提交进仓库。接入 PostgreSQL、pgvector、Claude、对象存储或导出路径前，先阅读 `README.md` 与 `docs/README.md`。如需浏览器自动化验证，优先使用 Codex Browser 路径，不要默认切到 Playwright。

## scripts 约定

- `scripts/check-sidecar-runtime-imports.mjs`、`scripts/verify-environment.mjs`、`scripts/verify-asset-workflow.mjs`：用于本地/CI 验证，修改 sidecar 核心链路后优先运行。
- `scripts/run-all-tests.sh`、`scripts/pre-release-check.sh`、`scripts/security-check.sh`：用于发布前与安全基线检查。
- `scripts/setup-dev-env.sh`：仅用于新环境初始化，不要在 CI 中直接依赖其副作用。
- `scripts/dashboard.sh`、`scripts/health-check.sh`：用于人工巡检，不作为发布阻断条件。

### 子 Agent 模型策略（Token 优先）

为降低 token 消耗并保持执行速度，默认采用“主控 + 执行”模式：

- 主控 Agent（当前会话主模型）负责：任务拆分、风险判断、结果验收、最终收口。
- 子 Agent 负责：小范围实现、检索、测试修复、文档改动。

模型分配约定：

- 子 Agent 默认模型：`gpt-5.3-codex-spark`。
- 仅当任务涉及跨模块架构决策、疑难 bug 根因定位、或高风险最终审查时，才升级到更强模型。

执行约定：

- 每个子任务必须限制可改文件范围，避免重复读取全仓库。
- 并行只允许在不重叠文件集上执行，避免冲突与返工。
- 子任务返回内容保持精简：改动文件、关键原因、验证结果。
- 每个阶段完成后立即小步提交（Conventional Commits），再进入下一阶段，避免上下文滚大。
