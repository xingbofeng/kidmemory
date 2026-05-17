## Why

KidMemory 当前已经具备本地素材管理、书稿生成和导出能力，但“智能生成”链路还缺少可工程化落地的能力层：

- sidecar 能力尚未以受控 MCP tools 形式暴露，Agent 难以稳定复用。
- Skill 资产未统一托管，维护与升级成本高。
- desktop → sidecar → provider 的日志不可串联，排障效率低。
- 缺少默认免费生图通道与明确隐私边界提示。
- 现有页面缺少可解释的任务进度与结果反馈闭环。

该变更目标是按你在 `docs/Skill 系统.md` 的 Epic 10 要求，落地“隐藏式 Agent 能力层”，并严格按组件拆分验收。

## What Changes

本变更拆分为 12 个组件能力（对应文档 Task 1-12），每个能力独立 spec、独立验收：

1. `skills-packaging-foundation`
2. `picturebook-hyperframes-skill-integration`
3. `mcp-baseline-module`
4. `asset-mcp-tools`
5. `book-export-mcp-tools`
6. `diagnostic-image-hyperframes-tools`
7. `sidecar-skills-runtime`
8. `file-logging`
9. `trace-propagation`
10. `image-provider-pollinations`
11. `ui-lightweight-enhancement`
12. `verification-and-gates`

实施约束：
- 保持现有页面 IA，不改设置页，不引入大聊天窗。
- MCP 必须使用 `@rekog/mcp-nest`，不自研协议层。
- 必须先完成 MCP + skill runtime，再推进 provider/UI 集成。
- 日志一期采用文件 JSONL，不落库。
- Pollinations 仅发送文本 prompt，不上传孩子照片。
- 安全边界必须禁止 run_sql / run_shell / 任意 read_file。

## Capabilities

### New Capabilities
- `skills-packaging-foundation`: `packages/skills` 目录、registry、校验/打包脚本。
- `picturebook-hyperframes-skill-integration`: picturebook-maker 引入 + Hyperframes 全家桶与 registry 挂载。
- `mcp-baseline-module`: sidecar `/mcp` endpoint 与基础健康工具。
- `asset-mcp-tools`: children/assets 检索与 metadata 工具集合。
- `book-export-mcp-tools`: 书稿任务生命周期与 PDF/长图导出工具。
- `diagnostic-image-hyperframes-tools`: 配置/索引/日志诊断 + 封面预览 + 视频渲染。
- `sidecar-skills-runtime`: skill loader/registry/workspace/permission 运行时。
- `file-logging`: desktop+sidecar JSONL logger、脱敏、清理。
- `trace-propagation`: traceId/requestId 端到端透传与关联。
- `image-provider-pollinations`: Pollinations 默认 provider + 失败降级。
- `ui-lightweight-enhancement`: 素材库与生成页智能入口/进度/确认/结果 UI。
- `verification-and-gates`: 架构/MCP/安全/日志/UI 的总验收门禁。

### Modified Capabilities
- 当前无已有 openspec 基线 capability 被本变更直接修改（以新增能力为主）。

## Impact

**受影响范围：**
- `packages/sidecar`：MCP 模块、tools、skills runtime、provider、logging。
- `packages/desktop`：trace context、logger、生成页与素材库轻量 UI 增强。
- `packages/skills`：新建 skill 资产仓与安装/校验脚本。
- `docs/`：skills 维护、MCP 扩展、日志诊断文档。

**第三方来源（固定）：**
- picturebook-maker: `https://github.com/Hermess/picturebook-maker/tree/main/picturebook-maker`
- Hyperframes: `https://github.com/heygen-com/hyperframes`（含 registry 相关能力）
- Pollinations: `https://pollinations.ai/`（默认 provider）

**兼容性与风险：**
- 对用户功能是增强，不改变既有核心流程入口。
- 工程风险集中在 MCP 接入适配、免费 provider 稳定性、Hyperframes 依赖环境。
- 通过 12 组件独立验收 + 总门禁规避“总测通过但分项缺漏”。

**验收原则（强约束）：**
- 必须完成 12 个 `specs/<capability>/spec.md` 的逐项场景验收。
- 不接受仅凭总链路 smoke test 作为完成标准。
