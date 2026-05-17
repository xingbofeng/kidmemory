## ADDED Requirements

### Requirement: Web 必须接入 i18next

系统 SHALL 在 Web 端接入 i18next，支持中英文切换。

#### Scenario: 配置 i18next
- **WHEN** 检查 Web 代码
- **THEN** 必须在 src/i18n/index.ts 中配置 i18next

#### Scenario: 支持 zh-CN 和 en-US
- **WHEN** 检查语言文件
- **THEN** 必须存在 src/i18n/zh-CN.json 和 src/i18n/en-US.json

#### Scenario: 使用 useTranslation hook
- **WHEN** 在组件中使用翻译
- **THEN** 必须使用 `const { t } = useTranslation()` hook

#### Scenario: 支持语言切换
- **WHEN** 用户切换语言
- **THEN** 所有文案必须立即更新

### Requirement: Desktop 必须接入 Flutter l10n

系统 SHALL 在 Desktop 端接入 Flutter l10n，支持中英文切换。

#### Scenario: 配置 l10n
- **WHEN** 检查 pubspec.yaml
- **THEN** 必须配置 flutter_localizations 和 intl

#### Scenario: 支持 zh 和 en
- **WHEN** 检查 arb 文件
- **THEN** 必须存在 lib/l10n/app_zh.arb 和 lib/l10n/app_en.arb

#### Scenario: 使用生成的 AppLocalizations
- **WHEN** 在 Widget 中使用翻译
- **THEN** 必须使用 `AppLocalizations.of(context)!.key`

#### Scenario: 支持语言切换
- **WHEN** 用户切换语言
- **THEN** 所有文案必须立即更新

### Requirement: 后端必须支持 Accept-Language

系统 SHALL 在后端根据 Accept-Language 请求头返回对应语言的错误文案。

#### Scenario: 解析 Accept-Language
- **WHEN** 请求包含 Accept-Language: zh-CN
- **THEN** 返回中文错误文案

#### Scenario: 默认语言为 zh-CN
- **WHEN** 请求不包含 Accept-Language
- **THEN** 返回中文错误文案

#### Scenario: 不支持的语言回退到 en-US
- **WHEN** 请求 Accept-Language: ja
- **THEN** 返回英文错误文案

### Requirement: sample dataset metadata 必须双语化

系统 SHALL 将 sample dataset 的 metadata（标题、描述、标签）改为双语格式。

#### Scenario: 标题双语
- **WHEN** 检查 sample dataset metadata
- **THEN** title 必须包含 zh-CN 和 en-US 两个字段

#### Scenario: 描述双语
- **WHEN** 检查 sample dataset metadata
- **THEN** description 必须包含 zh-CN 和 en-US 两个字段

#### Scenario: 标签双语
- **WHEN** 检查 sample dataset metadata
- **THEN** tags 必须包含 zh-CN 和 en-US 两个数组

#### Scenario: 导入时选择语言
- **WHEN** 导入 sample dataset
- **THEN** 根据当前语言选择对应的标题、描述、标签

### Requirement: 生产代码必须清理 mock/sample fallback

系统 SHALL 确保生产代码不包含 mock/sample/demo 数据的 fallback 逻辑。

#### Scenario: 禁止硬编码"澄澄"
- **WHEN** 检查生产代码
- **THEN** 不能出现硬编码的"澄澄"作为默认值

#### Scenario: 禁止 fallback 到 sample-child-001
- **WHEN** 检查生产代码
- **THEN** 不能出现 `childId || 'sample-child-001'` 这样的 fallback

#### Scenario: 测试数据迁移到 tests/fixtures
- **WHEN** 检查测试代码
- **THEN** 测试数据必须在 tests/fixtures 目录

#### Scenario: 前端 mock 只放 src/mocks
- **WHEN** 检查 Web 代码
- **THEN** mock 数据必须在 src/mocks 目录，且只在开发环境使用

### Requirement: 必须删除旧 scripts

系统 SHALL 删除 scripts 目录中的旧脚本，只保留新版脚本。

#### Scenario: 删除旧脚本
- **WHEN** 检查 scripts 目录
- **THEN** 不能存在写死 backend、3001 端口、旧 mock runner 的脚本

#### Scenario: 新增 doctor.mjs
- **WHEN** 检查 scripts 目录
- **THEN** 必须存在 doctor.mjs 脚本，用于环境检测

#### Scenario: 新增 generate-openapi.ts
- **WHEN** 检查 scripts 目录
- **THEN** 必须存在 generate-openapi.ts 脚本，用于生成 OpenAPI

### Requirement: 必须有 architecture test 禁止 mock 回流

系统 SHALL 在 architecture tests 中检查生产代码不包含 mock/sample fallback。

#### Scenario: 检查生产代码无 mock import
- **WHEN** 运行 architecture tests
- **THEN** 生产代码不能 import mock 数据

#### Scenario: 检查生产代码无 sample fallback
- **WHEN** 运行 architecture tests
- **THEN** 生产代码不能包含 sample-child-001 等硬编码

#### Scenario: 检查测试代码可以使用 fixtures
- **WHEN** 运行 architecture tests
- **THEN** 测试代码可以 import tests/fixtures

### Requirement: 必须支持语言切换

系统 SHALL 支持用户在 Web 和 Desktop 端切换语言。

#### Scenario: Web 语言切换
- **WHEN** 用户在 Web 端点击语言切换按钮
- **THEN** 所有文案立即更新，localStorage 保存选择

#### Scenario: Desktop 语言切换
- **WHEN** 用户在 Desktop 端切换语言
- **THEN** 所有文案立即更新，设置持久化

#### Scenario: 语言选择持久化
- **WHEN** 用户刷新页面或重启应用
- **THEN** 语言选择保持不变

### Requirement: 必须有 CI 检查文案完整性

系统 SHALL 在 CI 中检查所有 key 都有对应的翻译。

#### Scenario: 检查 Web 文案完整性
- **WHEN** 运行 CI
- **THEN** 必须检查 zh-CN.json 和 en-US.json 的 key 一致

#### Scenario: 检查 Desktop 文案完整性
- **WHEN** 运行 CI
- **THEN** 必须检查 app_zh.arb 和 app_en.arb 的 key 一致

#### Scenario: 检查后端错误码文案完整性
- **WHEN** 运行 CI
- **THEN** 必须检查所有错误码都有 zh-CN 和 en-US 文案
