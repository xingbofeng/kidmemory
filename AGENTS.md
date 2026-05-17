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

## 提交与 Pull Request 指南

Git 历史使用 Conventional Commits，例如 `fix(repo): stabilize ts lint and test suites`、`refactor(sidecar): remove legacy skill path`。提交主题应使用祈使语气并保持简短。Codex 生成的提交需包含：

`Co-authored-by: OpenAI Codex <codex@openai.com>`

PR 应说明变更目的、影响范围、已运行的测试命令，并在涉及 UI 时附截图或录屏。关联 issue、OpenSpec 变更或设计文档时，请在描述中明确链接。

## 安全与配置提示

不要提交真实密钥或本地凭据；以 `.env.example` 作为配置模板。涉及 Prisma、Supabase、OpenAI、MCP 或文件导出路径的改动，应确认环境变量、迁移脚本和权限边界。

## 桌面端启动与清理约定

- 调试 KidMemory 桌面端时，只保留一个启动入口：要么只用 Xcode Run，要么只用 `cd packages/desktop && flutter run -d macos`，不要在同一轮里混用两者。
- 排查“界面版本不一致”时，优先确认当前运行中的 `.app` 路径，再决定是否重启或清理。
- 清理桌面端构建产物时，优先清理当前实际使用的那一套 `DerivedData`，避免同时保留 `workspace/build/derivedData` 和 `~/Library/Developer/Xcode/DerivedData/...` 两份可执行文件。
