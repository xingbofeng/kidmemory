## ADDED Requirements

### Requirement: Sidecar 必须通过 @rekog/mcp-nest 暴露 MCP 服务

系统 SHALL 使用 `@rekog/mcp-nest` 建立 sidecar MCP endpoint。

#### Scenario: MCP endpoint 可访问
- **WHEN** 启用 MCP 并启动 sidecar
- **THEN** `/mcp` 必须可访问并支持 `tools/list`

#### Scenario: 健康工具可调用
- **WHEN** 调用 `get_sidecar_health`
- **THEN** 必须返回结构化健康状态

### Requirement: Sidecar SDK 必须可调用 MCP Tools

系统 SHALL 在 sidecar 内完成一次基于 SDK 的 MCP 调用验证，证明工具可发现、可调用、可返回。

#### Scenario: SDK MCP 调用链验证
- **WHEN** 通过 sidecar 集成的 Agent SDK 调用 MCP（至少包含 `tools/list` 和一个业务工具）
- **THEN** 必须成功返回结构化结果并记录调用日志
