## ADDED Requirements

### Requirement: Asset 相关能力必须通过受控 MCP tools 暴露

系统 SHALL 暴露 children/assets 检索与元数据管理能力给 Agent。

#### Scenario: 基础素材查询可用
- **WHEN** 调用 `list_children`、`get_child_profile`、`list_recent_assets`
- **THEN** 返回可用于选材的结构化数据

#### Scenario: 搜索与向量检索可用
- **WHEN** 调用 `search_assets` 与 `search_assets_by_vector`
- **THEN** 必须通过业务服务完成检索，且不暴露 SQL 接口

#### Scenario: 元数据读取与更新可用
- **WHEN** 调用 `get_asset_metadata`、`update_asset_metadata`
- **THEN** 变更按权限生效且可追踪
