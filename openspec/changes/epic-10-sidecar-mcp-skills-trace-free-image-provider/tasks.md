# Epic 10 - Task List

## 阶段清单（严格对应 12 个 specs）

- [x] 1. Skills Packaging Foundation ✓ 2026-05-17
- [x] 2. picturebook + Hyperframes Skill Integration ✓ 2026-05-17
- [x] 3. MCP Baseline Module ✓ 2026-05-17
- [x] 4. Asset MCP Tools ✓ 2026-05-17
- [x] 5. Book / Export MCP Tools ✓ 2026-05-17
- [x] 6. Diagnostic / Image / Hyperframes Tools ✓ 2026-05-17
- [x] 7. Sidecar Skills Runtime ✓ 2026-05-17
- [x] 8. File Logging ✓ 2026-05-17
- [x] 9. Trace Propagation ✓ 2026-05-17
- [x] 10. Image Provider (Pollinations) ✓ 2026-05-17
- [x] 11. UI Lightweight Enhancement ✓ 2026-05-17
- [x] 12. Verification & Gates ✓ 2026-05-17

## 1) Skills Packaging Foundation

- [x] 1.1 创建 `packages/skills/package.json` ✓ 2026-05-17
- [x] 1.2 创建 `packages/skills/skill-registry.json` ✓ 2026-05-17
- [x] 1.3 创建 `scripts/validate-skills.mjs` ✓ 2026-05-17
- [x] 1.4 创建 `scripts/package-skills.mjs` ✓ 2026-05-17
- [x] 1.5 编写 skills 维护 README ✓ 2026-05-17

## 2) picturebook + Hyperframes Skill Integration

- [x] 2.1 从 `https://github.com/Hermess/picturebook-maker/tree/main/picturebook-maker` vendor picturebook-maker 到 `packages/skills/skills/picturebook-maker` ✓ 2026-05-17
- [x] 2.2 增加 KidMemory 边界说明（禁 shell、限制外部调用）✓ 2026-05-17
- [x] 2.3 增加 Pollinations extension 脚本与说明 ✓ 2026-05-17
- [x] 2.4 新增 Hyperframes skill source 声明 ✓ 2026-05-17
- [x] 2.5 新增 Hyperframes 安装/挂载脚本 ✓ 2026-05-17
- [x] 2.6 新增 Hyperframes registry 安装/挂载与使用说明（包含 registry 组件引入）✓ 2026-05-17

## 3) MCP Baseline Module

- [x] 3.1 接入 `@rekog/mcp-nest` ✓ 2026-05-17
- [x] 3.2 新建 `SidecarMcpModule` ✓ 2026-05-17
- [x] 3.3 暴露 `/mcp` streamable HTTP ✓ 2026-05-17
- [x] 3.4 实现 `get_sidecar_health` ✓ 2026-05-17
- [x] 3.5 增加 MCP feature flag 配置 ✓ 2026-05-17
- [x] 3.6 通过 sidecar SDK 完成 MCP 可用性验证（tools/list + 关键工具调用）✓ 2026-05-17

## 4) Asset MCP Tools

- [x] 4.1 `list_children` ✓ 2026-05-17
- [x] 4.2 `get_child_profile` ✓ 2026-05-17
- [x] 4.3 `list_recent_assets` ✓ 2026-05-17
- [x] 4.4 `search_assets` ✓ 2026-05-17
- [x] 4.5 `search_assets_by_vector` ✓ 2026-05-17
- [x] 4.6 `get_asset_metadata` ✓ 2026-05-17
- [x] 4.7 `get_asset_preview` ✓ 2026-05-17
- [x] 4.8 `update_asset_metadata` ✓ 2026-05-17

## 5) Book / Export MCP Tools

- [x] 5.1 `create_book_job` ✓ 2026-05-17
- [x] 5.2 `get_book_job` ✓ 2026-05-17
- [x] 5.3 `list_book_jobs` ✓ 2026-05-17
- [x] 5.4 `export_book_pdf` ✓ 2026-05-17
- [x] 5.5 `export_book_long_image` ✓ 2026-05-17

## 6) Diagnostic / Image / Hyperframes Tools

- [x] 6.1 `get_config_status` ✓ 2026-05-17
- [x] 6.2 `get_indexing_status` ✓ 2026-05-17
- [x] 6.3 `get_recent_logs` ✓ 2026-05-17
- [x] 6.4 `generate_cover_image_preview` ✓ 2026-05-17
- [x] 6.5 `render_hyperframes_video` ✓ 2026-05-17
- [x] 6.6 工具边界审计（禁 run_sql/run_shell/unscoped read_file）✓ 2026-05-17

## 7) Sidecar Skills Runtime

- [x] 7.1 `skills.module.ts` ✓ 2026-05-17
- [x] 7.2 `skill-loader.service.ts` ✓ 2026-05-17
- [x] 7.3 `skill-registry.service.ts` ✓ 2026-05-17
- [x] 7.4 `skill-workspace.service.ts` ✓ 2026-05-17
- [x] 7.5 `skill-permission.service.ts` ✓ 2026-05-17
- [x] 7.6 SDK 调用链验证：runtime 能被 sidecar SDK 驱动并调用 skill->tool ✓ 2026-05-17

## 8) File Logging

- [x] 8.1 sidecar `file-logger.service.ts` ✓ 2026-05-17
- [x] 8.2 sidecar `trace-context.service.ts` ✓ 2026-05-17
- [x] 8.3 sidecar `log-cleanup.worker.ts` ✓ 2026-05-17
- [x] 8.4 desktop `desktop_logger.dart` ✓ 2026-05-17
- [x] 8.5 desktop `trace_context.dart` ✓ 2026-05-17
- [x] 8.6 desktop `log_cleanup_worker.dart` ✓ 2026-05-17
- [x] 8.7 redaction 规则与 JSONL 字段统一 ✓ 2026-05-17

## 9) Trace Propagation

- [x] 9.1 desktop 生成 traceId/requestId ✓ 2026-05-17
- [x] 9.2 header 透传 `X-KidMemory-Trace-Id` ✓ 2026-05-17
- [x] 9.3 sidecar 注入 trace context ✓ 2026-05-17
- [x] 9.4 MCP tool 复用 trace ✓ 2026-05-17
- [x] 9.5 provider 调用透传 trace ✓ 2026-05-17

## 10) Image Provider (Pollinations)

- [x] 10.1 实现 `PollinationsImageProvider` ✓ 2026-05-17
- [x] 10.2 预留 Cloudflare Workers AI provider 接口 ✓ 2026-05-17
- [x] 10.3 预留 OpenAI-compatible provider 接口 ✓ 2026-05-17
- [x] 10.4 超时/重试/降级（跳过封面继续导出） ✓ 2026-05-17
- [x] 10.5 隐私边界校验（不上传孩子照片） ✓ 2026-05-17

## 11) UI Lightweight Enhancement

- [x] 11.1 素材库：`帮我挑素材` ✓ 2026-05-17
- [x] 11.2 生成页：智能动作入口 ✓ 2026-05-17
- [x] 11.3 生成页：Agent 进度面板 ✓ 2026-05-17
- [x] 11.4 生成页：免费生图确认弹窗 ✓ 2026-05-17
- [x] 11.5 生成页：结果卡片 + requestId ✓ 2026-05-17
- [x] 11.6 错误交互：重试/跳过/查看日志 ✓ 2026-05-17

## 12) Verification & Gates

- [x] 12.1 架构验收（skills 位置、mcp 方案、日志不落库） ✓ 2026-05-17
- [x] 12.2 MCP 验收（/mcp、tools/list、关键工具可调用） ✓ 2026-05-17
- [x] 12.3 安全验收（禁危险工具 + 生图隐私边界） ✓ 2026-05-17
- [x] 12.4 日志验收（JSONL、trace 串联、cleanup） ✓ 2026-05-17
- [x] 12.5 UI 验收（轻量增强原则） ✓ 2026-05-17
- [x] 12.6 调试配置验收：文档标注 `OPENAI_BASE_URL`/`OPENAI_MODEL`，并要求 API key 仅来自本地 `.env` ✓ 2026-05-17

## Completion Gate

- [x] 12 个 capability spec 全部通过 ✓ 2026-05-17
- [x] 对应任务全部打勾 ✓ 2026-05-17
- [x] Ready for `/openspec-apply epic-10-sidecar-mcp-skills-trace-free-image-provider` ✓ 2026-05-17
