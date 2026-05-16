## ADDED Requirements

### Requirement: Pollinations 必须作为默认免费生图 provider

系统 SHALL 实现 Pollinations provider，并支持后续 provider 扩展点。

#### Scenario: 文本 prompt 生图可用
- **WHEN** provider 配置为 pollinations 并发起封面生成
- **THEN** 返回图像结果或可恢复错误

### Requirement: 免费生图必须遵守隐私边界

系统 SHALL 保证外部调用不上传孩子照片。

#### Scenario: 请求体仅含文本
- **WHEN** 发起 Pollinations 请求
- **THEN** 请求内容仅包含文本 prompt，不含孩子照片二进制或 URL

### Requirement: 失败必须可降级继续主流程

系统 SHALL 支持生图失败后跳过封面继续导出。

#### Scenario: provider 超时后继续导出
- **WHEN** Pollinations 请求超时或失败
- **THEN** 用户可选择跳过封面并继续导出流程

### Requirement: Skill 文案必须引导默认使用 Pollinations provider

系统 SHALL 在 picturebook 相关 skill 指引中明确默认 provider 为 Pollinations，并说明隐私边界与降级策略。

#### Scenario: Skill 指引可见且一致
- **WHEN** 检查 skill 文档与执行提示
- **THEN** 必须明确“默认 Pollinations、仅文本 prompt、失败可跳过封面继续导出”
