# KidMemory Desktop

`packages/desktop` 是 KidMemory 的 macOS 桌面端，基于 Flutter 构建。它是本地优先体验的主要入口，负责启动/连接本地 Sidecar、管理孩子档案、导入成长素材、浏览素材库、生成作品并导出 PDF 或长图。

### 主要职责

- 提供 KidMemory 桌面主界面：孩子档案、素材库、创作台、设置和示例数据集子页面。
- 启动、探测和连接本地 Sidecar 服务，显示 readiness 状态和配置入口。
- 管理本地数据目录、OpenAI/Supabase/PostgreSQL 等配置表单。
- 调用 Sidecar API 完成素材导入、样例数据导入、生成任务、导出和同步。
- 承载 macOS 打包、资源、图标、示例素材和 Flutter widget 测试。

### 目录说明

- `lib/app/`：桌面壳层、导航、Sidecar 生命周期、设置流程、数据集和导出流程编排。
- `lib/features/`：页面级功能模块，例如孩子档案、素材库、创作台、设置、示例数据集。
- `lib/core/`：Sidecar gateway、launcher、日志和 trace context 等核心服务。
- `lib/shared/`：共享模型、布局、按钮、状态卡、素材预览等 UI 组件。
- `lib/l10n/`：Flutter 本地化生成物和 ARB 文案。
- `assets/`：桌面端图标库和示例数据集图片资源。
- `macos/`：Flutter macOS Runner、Xcode 工程和打包脚本。
- `test/`：Flutter widget/unit 测试。

### 常用命令

```bash
cd packages/desktop
flutter pub get
flutter analyze
flutter test
flutter run -d macos
```

### 开发提示

- 调试桌面端时，一轮里只保留一个启动入口：Xcode Run 或 `flutter run -d macos`，不要混用。
- 排查 UI 版本不一致时，先确认当前运行的 `.app` 路径，再决定是否清理构建产物。
- 新增页面导航或 widget 行为时，优先补充 `test/` 下相邻 widget 测试。
- 与后端交互应通过 `lib/core/sidecar/` 和 Sidecar API gateway 封装，避免页面直接散落 HTTP 细节。
