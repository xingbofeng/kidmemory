## ADDED Requirements

### Requirement: 架构验收门禁必须通过

系统 SHALL 验证 skills 位置、MCP 接入方式与日志策略符合文档要求。

#### Scenario: 架构验收通过
- **WHEN** 执行架构清单
- **THEN** skills 在 `packages/skills`、MCP 使用 `@rekog/mcp-nest`、日志不落库

### Requirement: MCP 功能验收门禁必须通过

系统 SHALL 验证 `/mcp` 与关键工具可调用。

#### Scenario: MCP 核心工具验收通过
- **WHEN** 调用 `tools/list`、`get_sidecar_health`、`search_assets`、`create_book_job`、`generate_cover_image_preview`
- **THEN** 均返回预期结构

### Requirement: 实施顺序门禁必须通过

系统 SHALL 先完成 MCP + skills runtime 验收，再进行 provider/UI 集成验收。

#### Scenario: 顺序门禁检查
- **WHEN** 进入 provider/UI 验收阶段
- **THEN** 必须已有 MCP baseline 与 skills runtime 的通过记录

### Requirement: 安全/日志/UI 验收门禁必须通过

系统 SHALL 同时满足安全边界、日志链路与 UI 轻量增强要求。

#### Scenario: 安全验收通过
- **WHEN** 审计工具与生图请求
- **THEN** 无危险工具暴露且不上传孩子照片

#### Scenario: 日志与 trace 验收通过
- **WHEN** 验证一次完整任务日志
- **THEN** JSONL 合法、trace 可串联、cleanup 生效

#### Scenario: UI 验收通过
- **WHEN** 审查页面变更
- **THEN** 不改设置页、不引入大聊天窗、关键交互项完整

### Requirement: 调试模型配置必须文档化

系统 SHALL 在设计/运行文档中标注调试模型配置，并要求 API key 仅从本地 `.env` 读取。

#### Scenario: 调试配置文档检查
- **WHEN** 检查变更文档
- **THEN** 必须包含 `OPENAI_BASE_URL=https://api.xiaomimimo.com/v1` 与 `OPENAI_MODEL=mimo-v2-pro`，并声明 API key 不入库
