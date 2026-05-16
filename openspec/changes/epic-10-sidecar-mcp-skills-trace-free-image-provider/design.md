## Context

本变更来自 `docs/Skill 系统.md` Epic 10，目标是在不重做产品交互的前提下，将 KidMemory 升级为“现有页面 + 隐藏式 Agent 能力层”。

关键约束：
- 用户界面不暴露 MCP/Skill/Provider 等术语。
- Agent 只能调用受控业务工具。
- 日志先文件化（JSONL），通过 traceId 串联。
- 默认免费生图采用 Pollinations，需明确隐私边界。
- Hyperframes 除全家桶 skill 外，必须包含 registry 引入能力。
- picturebook skill 来源固定为 `https://github.com/Hermess/picturebook-maker/tree/main/picturebook-maker`。

## Goals / Non-Goals

**Goals**
- 基于 `@rekog/mcp-nest` 暴露 sidecar MCP tools。
- 建立 `packages/skills` 统一 skill 管理。
- 实现 desktop + sidecar 日志与 trace 贯通。
- 接入 picturebook-maker / Hyperframes / Pollinations。
- 完成现有页面轻量增强与可解释进度反馈。

**Non-Goals**
- 不做完整 Skill 平台或 marketplace。
- 不做日志入库与 OTel 全链路体系。
- 不重构设置页与整体导航。

## Decisions

### 决策 1：12 个能力独立 spec 管理

将 Epic 10 拆分为 12 个 capability spec，保证每个任务有独立 requirement/scenario 与验收证据。

### 决策 2：MCP 复用 sidecar 既有领域服务

MCP 层仅做工具包装和权限收口，不复制领域逻辑，降低分叉风险。

并且必须完成 “SDK 可调用验证”：通过 sidecar 集成的 Agent SDK 调用 MCP tools，验证工具可发现、可调用、可返回结构化结果。

### 决策 3：skills 内容与 runtime 分层

skills 内容放 `packages/skills`；sidecar 持有 runtime（loader/registry/workspace/permission），职责清晰。

### 决策 4：文件日志优先

一期采用 JSONL 文件日志 + retention cleanup + redaction，满足本地排障与隐私边界。

### 决策 5：生图默认免费并可降级

默认 Pollinations；失败时支持“跳过封面继续导出”，保证主流程可完成。

### 决策 6：UI 轻量增强而非产品形态重构

只在素材库与生成页增加智能入口、进度、确认、结果卡片，保持原有 IA 与学习成本。

### 决策 7：实施顺序强约束

先实现并验收：
1. MCP baseline + tools
2. Skills packaging + runtime（含 picturebook-maker / Hyperframes registry）

之后才实现 provider、UI 与端到端联调，避免“UI 先行但能力层不可用”。

## Debug Model Configuration (Local)

调试 sidecar 的 SDK 调用时，使用 `.env` 中以下变量：

```env
OPENAI_BASE_URL=https://api.xiaomimimo.com/v1
OPENAI_API_KEY=<use-local-.env-secret>
OPENAI_MODEL=mimo-v2-pro
```

说明：
- `OPENAI_API_KEY` 仅放本地 `.env`，不写入仓库明文。
- 调试记录和 runbook 文档需标注使用上述 provider/model 组合完成验证。
