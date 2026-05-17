## ADDED Requirements

### Requirement: 素材库页面必须支持智能挑选入口

系统 SHALL 在素材库增加 `帮我挑素材` 入口与确认流程。

#### Scenario: 智能挑选流程可完成
- **WHEN** 用户点击 `帮我挑素材`
- **THEN** 返回可确认/重选/手动调整的建议素材集

### Requirement: 生成页必须提供智能流程可视化

系统 SHALL 在生成页提供智能动作入口、进度面板、确认弹窗和结果卡片。

#### Scenario: 生成流程状态可见
- **WHEN** 用户发起 `生成儿童绘本`
- **THEN** 页面显示阶段进度、封面确认和结果操作

### Requirement: UI 必须隐藏底层技术术语

系统 SHALL 不向最终用户暴露实现术语。

#### Scenario: 文案审查通过
- **WHEN** 审查相关页面文案
- **THEN** 不出现 MCP/Skill/Provider 等术语
