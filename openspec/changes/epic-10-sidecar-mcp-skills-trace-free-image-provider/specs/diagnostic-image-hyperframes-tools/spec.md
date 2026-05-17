## ADDED Requirements

### Requirement: 诊断工具必须覆盖配置、索引与日志摘要

系统 SHALL 提供运行状态排障能力。

#### Scenario: 运行状态可诊断
- **WHEN** 调用 `get_config_status`、`get_indexing_status`、`get_recent_logs`
- **THEN** 返回用于定位问题的状态信息

### Requirement: 生图预览与视频渲染必须可调用

系统 SHALL 提供封面预览与视频渲染工具。

#### Scenario: 封面预览可用
- **WHEN** 调用 `generate_cover_image_preview`
- **THEN** 返回图像预览结果或可恢复失败信息

#### Scenario: 视频渲染可用
- **WHEN** 调用 `render_hyperframes_video`
- **THEN** 输出 MP4 或明确可定位错误

### Requirement: MCP 工具面必须满足安全边界

系统 SHALL 禁止危险通用工具暴露。

#### Scenario: 危险工具不可见
- **WHEN** 审计 MCP tools 列表
- **THEN** 不得出现 `run_sql`、`run_shell`、任意 `read_file` 工具
