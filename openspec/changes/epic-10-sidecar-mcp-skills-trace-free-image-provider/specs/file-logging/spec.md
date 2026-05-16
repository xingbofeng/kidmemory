## ADDED Requirements

### Requirement: Desktop 与 Sidecar 必须输出 JSONL 文件日志

系统 SHALL 在两端写入统一字段的 JSONL 日志。

#### Scenario: 双端日志写入成功
- **WHEN** 用户发起智能任务
- **THEN** desktop 与 sidecar 日志目录均新增有效日志记录

### Requirement: 日志清理与脱敏必须生效

系统 SHALL 实施 retention cleanup 与 redaction。

#### Scenario: 旧日志可清理
- **WHEN** 超过保留期限
- **THEN** cleanup worker 按策略清理旧文件

#### Scenario: 敏感字段被脱敏
- **WHEN** 日志含敏感字段
- **THEN** 写入内容按 redaction 规则脱敏
