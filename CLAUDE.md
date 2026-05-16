# CLAUDE.md

本文件为 Claude Code（claude.ai/code）在此仓库中工作时提供指导。

## 构建与测试命令

### Sidecar（Node.js NestJS）
```bash
cd packages/sidecar && npm install              # 安装依赖（需要 Node 22+）
cd packages/sidecar && npm run dev              # 启动开发服务器（src/main.ts）
cd packages/sidecar && npm test                 # 运行所有测试：find tests -name '*.test.ts' | xargs tsx --test
cd packages/sidecar && npm run build            # 完整构建检查

# 运行单个测试文件：
cd packages/sidecar && tsx --test tests/unit/asset-import.test.ts

# 测试需要 PostgreSQL + pgvector，可以使用 Docker：
docker run -d --name postgres-dev -e POSTGRES_PASSWORD=postgres -p 5432:5432 pgvector/pgvector:pg16
cd packages/sidecar && npm test
docker stop postgres-dev && docker rm postgres-dev
```

### 桌面端 Flutter（macOS）
```bash
cd packages/desktop && flutter pub get       # 安装依赖
cd packages/desktop && flutter analyze        # 静态分析
cd packages/desktop && flutter test           # 所有测试
cd packages/desktop && flutter run -d macos   # 启动桌面端

# 运行单个测试文件：
cd packages/desktop && flutter test test/sidecar_api_test.dart
cd packages/desktop && flutter test test/asset_library_test.dart
cd packages/desktop && flutter test test/widget_test.dart

# 运行视觉/界面回归测试（需要 macOS）：
cd packages/desktop && flutter test test/design_capture_test.dart
```

### Sidecar 架构测试
```bash
cd packages/sidecar && tsx --test tests/architecture/architecture.test.ts
```

## 项目架构

### Monorepo 结构
- `packages/desktop/` — macOS Flutter 桌面端（Dart）
- `packages/sidecar/` — NestJS HTTP API + 任务编排（TypeScript，Node.js 运行时）
- `packages/cloud-api/` — 云端 API（上传/分享/设备同步）
- `packages/web/` — 手机网页端（扫码上传、轻量浏览与分享）
- `packages/protocol/` — 共享类型定义和 OpenAPI 规范
- `docs/` — 统一产品说明、发布报告、架构文档和设计资源
- `templates/` — 书稿输出模板（例如 `warm-artwork-book/template.html`）
- `examples/sample-dataset/` — 示例素材数据集
- `scripts/` — 运维与验证脚本（见 README 的 scripts 清单）

### 产品流程
Capture → Curate → Search → Compose → Generate → Review → Publish → Archive

### 桌面端 Flutter 架构
入口：`lib/main.dart` → `KidMemoryApp` → `DesktopShell`

5 步向导（`AppStep` 枚举）：
- `setup` — 环境检测（PostgreSQL, pgvector, OpenAI, Claude）
- `sample` — 导入示例数据集
- `child` — 孩子档案管理
- `assets` — 素材库（CRUD、批量删除、文件导入、拖拽导入）
- `generate` — Agent 书稿生成 + PDF 导出

关键模式：
- `lib/core/sidecar/sidecar_api.dart` — 通过 HttpClient 调用 sidecar API（GET/POST/DELETE，支持重试）
- `lib/features/*/` — 每个页面一个目录，导出一个 StatelessWidget
- `lib/shared/widgets/` — `chrome.dart`（Sidebar, NavItem）、`layout.dart`、`content.dart`、`status.dart`
- 无状态管理库 — 全部状态在 `DesktopShell` 中通过 `setState` 管理
- Sidecar API 通过构造参数注入（便于测试）
- 视觉回归测试文件在 `test/design_capture_test.dart`

### Sidecar（NestJS）架构
入口：`src/main.ts` → NestFactory.create(AppModule)

业务模块（`src/modules/`）：
- `config/` — 环境检测（PostgreSQL, pgvector, OpenAI, Claude）和就绪状态端点
- `dataset/` — 孩子 CRUD、素材导入/更新/删除、示例数据集
- `books/` — 书稿生成任务生命周期（创建 → 预览 → PDF 导出），Claude Agent SDK 集成

基础设施（`src/infrastructure/`）：
- `config/app-config.service.ts` — 基于环境变量的配置（`.env`）
- `database/` — PostgreSQL + pgvector 连接与迁移服务（Prisma，baseline 在 `prisma/migrations/init`）
- `dataset-state/` — 内存 + 持久化 DB 两层切换（`DatasetStateService`）
- `jobs/file-job-store.service.ts` — 基于文件系统的任务存储

关键模式：
- 领域逻辑在 `providers/*.domain.ts` 纯函数中，由 NestJS 服务类包装
- 不使用 DI 框架装饰器 — 通过 `registerInjectable()` 辅助函数手动注册
- 测试使用 Node 内置 `node:test` 和 `node:assert/strict`

### Agent Workspace
- OpenAI Agents SDK 在受控 workspace 中运行（input/ templates/ rules/ → 输出 book.json + book.html）
- Agent 不直接访问数据库、密钥或对象存储
- 系统校验输出后才通过 Playwright 导出 PDF

## 提交规范
遵循 Conventional Commits：`type(scope): summary`
类型：feat, fix, docs, test, refactor, chore
范围：desktop, sidecar, web, docs
示例：`feat(desktop): support bulk delete for selected assets`

## 测试模式
- Flutter：`flutter_test` + `WidgetTester`，偏好 `find.text()` 和 `tester.tap()`
- Sidecar：`node:test` + `node:assert/strict`，领域 provider 单元测试在 `tests/unit/`
- 架构测试：`tests/architecture/` 检查模块边界和导入规则

## 本地启动
1. 复制 `.env.example` 为 `.env`，配置 PostgreSQL/pgvector、Claude API key、workspace/export 路径
2. 启动 PostgreSQL：`docker run -d --name postgres-dev -e POSTGRES_PASSWORD=postgres -p 5432:5432 pgvector/pgvector:pg16`
3. 启动 sidecar：`cd packages/sidecar && npm run dev`
4. 启动 Flutter 桌面端：`cd packages/desktop && flutter run -d macos`
