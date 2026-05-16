## ADDED Requirements

### Requirement: Skills 必须统一托管在 packages/skills

系统 SHALL 提供 `packages/skills` 作为 skill 内容唯一托管位置，并包含 registry、校验与打包能力。

#### Scenario: skills 基础结构存在
- **WHEN** 检查仓库目录
- **THEN** 必须存在 `packages/skills`、`skill-registry.json`、校验脚本和打包脚本

#### Scenario: registry 校验失败可阻断
- **WHEN** skill 缺失必填字段或路径无效
- **THEN** `validate-skills.mjs` 必须返回失败并输出可定位错误
