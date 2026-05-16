## ADDED Requirements

### Requirement: TraceId 必须贯穿 desktop 到 provider 全链路

系统 SHALL 从请求发起到 provider 调用保持 trace 一致。

#### Scenario: Header 透传 traceId
- **WHEN** desktop 发起 sidecar 请求
- **THEN** 请求头必须包含 `X-KidMemory-Trace-Id`

#### Scenario: 日志可按 trace 串联
- **WHEN** 按 traceId 检索
- **THEN** 可关联 desktop、sidecar、MCP、provider 同链路事件
