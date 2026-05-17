## ADDED Requirements

### Requirement: 所有 JSON API 必须返回统一格式

系统 SHALL 确保所有 JSON API 返回 `{ code: number, msg: string, data: T }` 格式，成功时 code 为 0，失败时 code 非 0。

#### Scenario: 成功响应
- **WHEN** API 调用成功
- **THEN** 返回 `{ code: 0, msg: "success", data: {...} }`

#### Scenario: 失败响应
- **WHEN** API 调用失败
- **THEN** 返回 `{ code: 非0, msg: "错误描述", data: null 或错误详情 }`

#### Scenario: 校验失败响应
- **WHEN** 参数校验失败
- **THEN** 返回 `{ code: 10001, msg: "参数校验失败", data: { issues: [...] } }`

### Requirement: 文件流接口不被包装

系统 SHALL 确保文件流、HTML、PDF 等非 JSON 响应不被包装成 code/msg/data 格式。

#### Scenario: 图片预览不被包装
- **WHEN** 请求 GET /assets/:id/preview
- **THEN** 直接返回 image/* 内容，不包装

#### Scenario: HTML 预览不被包装
- **WHEN** 请求 GET /books/jobs/:id/preview
- **THEN** 直接返回 text/html 内容，不包装

#### Scenario: PDF 下载不被包装
- **WHEN** 请求 GET /books/jobs/:id/export
- **THEN** 直接返回 application/pdf 内容，不包装

### Requirement: 统一格式（Breaking Change）

系统 SHALL 对所有 JSON API 返回统一格式，不支持旧格式（破坏式变更）。

#### Scenario: 所有请求返回统一格式
- **WHEN** 请求 GET /children
- **THEN** 返回统一格式 `{ code: 0, msg: "success", data: { children: [...] } }`

#### Scenario: 客户端同步更新
- **GIVEN** 后端已切换到统一格式
- **WHEN** Web 和 Desktop 客户端同步更新 HTTP client
- **THEN** 所有客户端正确解析统一格式响应

### Requirement: 中间件错误必须统一格式

系统 SHALL 确保中间件（限流、校验、鉴权）抛出的错误也返回 code/msg/data 格式。

#### Scenario: 限流错误统一格式
- **WHEN** 触发限流
- **THEN** 返回 `{ code: 16001, msg: "请求过于频繁", data: { retryAfter: 60 } }`

#### Scenario: 校验错误统一格式
- **WHEN** 参数校验失败
- **THEN** 返回 `{ code: 10001, msg: "参数校验失败", data: { issues: [...] } }`

#### Scenario: 鉴权错误统一格式
- **WHEN** token 无效
- **THEN** 返回 `{ code: 11003, msg: "Token 无效", data: null }`

### Requirement: 必须有 Contract Tests 覆盖

系统 SHALL 为所有 JSON API 编写 Contract Tests，验证响应格式符合 code/msg/data 规范。

#### Scenario: 验证成功响应格式
- **WHEN** 运行 Contract Tests
- **THEN** 必须验证 typeof body.code === "number" && body.code === 0

#### Scenario: 验证失败响应格式
- **WHEN** 运行 Contract Tests
- **THEN** 必须验证 typeof body.code === "number" && body.code !== 0

#### Scenario: 验证 data 字段存在
- **WHEN** 运行 Contract Tests
- **THEN** 必须验证 "data" in body

#### Scenario: 验证 msg 字段类型
- **WHEN** 运行 Contract Tests
- **THEN** 必须验证 typeof body.msg === "string"

### Requirement: 支持回滚方案

系统 SHALL 支持通过 feature flag 关闭新格式，快速回滚到旧格式。

#### Scenario: 通过环境变量关闭新格式
- **WHEN** 设置 ENABLE_UNIFIED_RESPONSE=false
- **THEN** 所有 API 返回旧格式

#### Scenario: 通过配置文件关闭新格式
- **WHEN** 配置文件中 unifiedResponse: false
- **THEN** 所有 API 返回旧格式
