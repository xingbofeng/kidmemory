## ADDED Requirements

### Requirement: Book 任务生命周期必须可由 Agent 调用

系统 SHALL 提供书稿任务创建、查询、列表能力。

#### Scenario: 书稿任务可创建与追踪
- **WHEN** 调用 `create_book_job`、`get_book_job`、`list_book_jobs`
- **THEN** 返回可追踪的任务状态

### Requirement: 导出能力必须支持 PDF 与长图

系统 SHALL 暴露 PDF 与长图导出工具。

#### Scenario: 导出产物可获取
- **WHEN** 调用 `export_book_pdf` 和 `export_book_long_image`
- **THEN** 返回导出结果或可恢复错误
