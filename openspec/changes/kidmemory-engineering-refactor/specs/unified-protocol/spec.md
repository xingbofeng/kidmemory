## ADDED Requirements

### Requirement: 协议层必须提供统一的错误码体系

系统 SHALL 在 `packages/protocol` 中定义统一的 `ApiCode` 错误码体系，所有错误码必须是数字类型，且按功能分段。

#### Scenario: 错误码分段规则
- **WHEN** 定义新的错误码
- **THEN** 必须遵循分段规则：0（成功）、10000（通用错误）、11000（鉴权）、12000（参数校验）、13000（素材/书稿）、14000（分享）、15000（上传/存储）、16000（限流/安全）、50000（服务端内部错误）

#### Scenario: 错误码无重复
- **WHEN** 添加新的错误码
- **THEN** 系统必须检查该错误码是否已存在，不允许重复

#### Scenario: 成功码必须为 0
- **WHEN** API 调用成功
- **THEN** 返回的 code 必须等于 0

### Requirement: 协议层必须提供统一的响应结构

系统 SHALL 定义 `ApiResponse<T>` 类型，所有 JSON API 必须返回 `{ code: number, msg: string, data: T }` 格式。

#### Scenario: 成功响应格式
- **WHEN** API 调用成功
- **THEN** 返回 `{ code: 0, msg: "success", data: {...} }`

#### Scenario: 失败响应格式
- **WHEN** API 调用失败
- **THEN** 返回 `{ code: 非0, msg: "错误描述", data: null 或错误详情 }`

#### Scenario: 分页响应格式
- **WHEN** API 返回分页数据
- **THEN** data 字段必须包含 `{ items: [], page: number, pageSize: number, total: number }`

### Requirement: 协议层必须支持双语错误文案

系统 SHALL 为所有错误码提供 `zh-CN` 和 `en-US` 两种语言的错误文案。

#### Scenario: 中文错误文案
- **WHEN** 错误码为 16001
- **THEN** zh-CN 文案为 "请求过于频繁"

#### Scenario: 英文错误文案
- **WHEN** 错误码为 16001
- **THEN** en-US 文案为 "Rate limit exceeded"

#### Scenario: 所有错误码都有文案
- **WHEN** 定义新的错误码
- **THEN** 必须同时提供 zh-CN 和 en-US 文案

### Requirement: 协议层必须独立于业务模块

系统 SHALL 确保 `packages/protocol` 不依赖任何业务模块（sidecar / cloud-api / web / desktop）。

#### Scenario: 禁止反向依赖
- **WHEN** protocol 包尝试引用 sidecar 代码
- **THEN** 构建必须失败

#### Scenario: 只包含类型和常量
- **WHEN** 检查 protocol 包内容
- **THEN** 只能包含类型定义、错误码常量、错误文案，不能包含业务逻辑

### Requirement: 协议层必须支持 CI 检查

系统 SHALL 提供 `protocol:check` 脚本，在 CI 中检查协议完整性。

#### Scenario: 检查错误码无重复
- **WHEN** 运行 `npm run protocol:check`
- **THEN** 必须检查所有错误码无重复

#### Scenario: 检查文案完整性
- **WHEN** 运行 `npm run protocol:check`
- **THEN** 必须检查所有错误码都有 zh-CN 和 en-US 文案

#### Scenario: 检查生成物最新
- **WHEN** 运行 `npm run protocol:check`
- **THEN** 如果有生成文件（OpenAPI / Proto），必须检查是否与源码一致
