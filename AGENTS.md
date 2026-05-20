# Repository Guidelines

## 项目结构与模块组织

本仓库是 KidMemory 多包项目。主要代码位于 `packages/`：

- `packages/web`：Vite + React Web Companion，源码在 `src/`，静态资源在 `public/`。
- `packages/desktop`：Flutter macOS 桌面端，源码在 `lib/`，测试在 `test/`，资源在 `assets/`。
- `packages/sidecar`：本地 Sidecar/NestJS 服务，源码在 `src/`，测试在 `tests/`，Prisma 配置在 `prisma/`。
- `packages/cloud-api`：云端 NestJS API，结构同 Sidecar。
- `packages/protocol`：共享协议、OpenAPI、生成客户端与类型，源码在 `src/`，测试在 `tests/`，生成物在 `generated/`。

产品、架构和设计资料放在 `docs/`；变更提案和规格放在 `openspec/changes/`；自动化脚本放在 `scripts/`。

## 构建、测试与开发命令

各包独立安装依赖并执行脚本，示例：

- `npm --prefix packages/web run dev`：启动 Web 本地开发服务。
- `npm --prefix packages/web run build`：TypeScript 检查并构建 Web。
- `npm --prefix packages/web run test`：运行 Vitest。
- `npm --prefix packages/sidecar run dev`：启动 Sidecar 监听开发模式。
- `npm --prefix packages/sidecar run build`：运行 lint 和单元测试。
- `npm --prefix packages/cloud-api run build`：运行云端 API lint 和单元测试。
- `npm --prefix packages/protocol run build`：构建共享协议包。
- `cd packages/desktop && flutter test`：运行 Flutter 测试。
- `./scripts/run-all-tests.sh`：执行仓库级测试脚本。

## 编码风格与命名规范

TypeScript 包使用 ESM、TypeScript 和 ESLint；提交前运行对应包的 `lint`、`type-check` 或 `build`。React 组件使用 PascalCase，Hooks 使用 `useXxx`，测试文件使用 `*.test.ts` 或 `*.test.tsx`。Flutter 遵循 `flutter_lints`，Dart 文件使用 `snake_case.dart`，类名使用 PascalCase。保持改动聚焦，不提交 `node_modules/`、`dist/`、Flutter `build/` 等生成目录。

## 测试指南

Web 使用 Vitest 和 Testing Library；Node 服务使用 `tsx --test`；Flutter 使用 `flutter_test`。新增业务逻辑、协议变更、API 行为或 UI 交互时，应补充相邻测试。Sidecar 与 Cloud API 的集成测试分别位于 `tests/integration/`，契约测试位于 Sidecar 的 `tests/contracts/`。

## Codex 协作约定

- Session 启动时优先读取 `CONTEXT.md`、`handoff.md`、`implementation-notes.md`（如果存在），再读取任务相关代码。
- 需求不明确时先对齐范围、非目标和验收标准；已由 GitHub Issue 标记为 `status:ready` 的任务按 Issue 执行。
- 新功能、修复或重构完成后，在 `implementation-notes.md` 追加决策记录；长 session 或中断前维护 `handoff.md`。
- 完成前使用 `verification-before-completion` 思路检查实现、测试、文档和剩余风险。
- 本地前端或 UI 验证优先使用 Codex Browser；只有 Browser 不可用、不可靠或用户明确要求时再用 Playwright。
- 查询框架、SDK、CLI 或云服务当前用法时，优先通过 `context7` 获取官方文档；OpenAI/Codex 相关问题优先使用 `openai-docs`。

## 后端架构约定

- `packages/sidecar` 与 `packages/cloud-api` 使用 NestJS feature-module 分层；涉及架构重组前，先确认目标目录结构、模块边界、测试迁移位置和验收标准。
- 每个业务域优先维护自己的 `module`、`controller`、`service`、`dto` 和 `providers`；避免把业务逻辑长期散落在 `src` 根目录。
- Sidecar 测试集中放在 `packages/sidecar/tests/`，按 `unit/`、`integration/`、`contracts/` 组织；不要新增分散在业务源码旁的临时测试。
- 后端重构完成时，说明实际目录树变化、迁移或删除的旧文件、重复文件清理情况，以及运行过的 package-level 测试命令。

## 提交与 Pull Request 指南

Git 历史使用 Conventional Commits，例如 `fix(repo): stabilize ts lint and test suites`、`refactor(sidecar): remove legacy skill path`。提交主题应使用祈使语气并保持简短。Codex 生成的提交需包含：

`Co-authored-by: OpenAI Codex <codex@openai.com>`

PR 应说明变更目的、影响范围、已运行的测试命令，并在涉及 UI 时附截图或录屏。关联 issue、OpenSpec 变更或设计文档时，请在描述中明确链接。

## 安全与配置提示

不要提交真实密钥或本地凭据；以 `.env.example` 作为配置模板。涉及 Prisma、Supabase、OpenAI、MCP 或文件导出路径的改动，应确认环境变量、迁移脚本和权限边界。

## 验证与真实运行说明

- 涉及 OpenAI、Claude、PDF、Flutter、PostgreSQL、浏览器或本地 Sidecar 的改动，最终汇报必须区分：真实外部服务调用、mock、静态测试、手工检查、因环境阻塞未验证。
- 如果使用 mock 或静态合同测试替代真实运行，说明替代范围和剩余风险。
- 桌面端验证需说明当前运行的 `.app` 路径、启动入口，以及是否真实连接到 Sidecar。

## 桌面端启动与清理约定

- 调试 KidMemory 桌面端时，只保留一个启动入口：要么只用 Xcode Run，要么只用 `cd packages/desktop && flutter run -d macos`，不要在同一轮里混用两者。
- 排查“界面版本不一致”时，优先确认当前运行中的 `.app` 路径，再决定是否重启或清理。
- 清理桌面端构建产物时，优先清理当前实际使用的那一套 `DerivedData`，避免同时保留 `workspace/build/derivedData` 和 `~/Library/Developer/Xcode/DerivedData/...` 两份可执行文件。

## Agent 工作流文档

- Hermes + Harness + Codex 的统一流程、Slack 配置、Issue 模板和状态机记录在 `docs/agent-workflow/workflow.md`。
- 四个 Hermes 角色的 `SOUL` 快照记录在 `docs/agent-workflow/souls/`。
- `AGENTS.md` 只保留执行约定；长流程说明优先维护在 `docs/agent-workflow/`。
