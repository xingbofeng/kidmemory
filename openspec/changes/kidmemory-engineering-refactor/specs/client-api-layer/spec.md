## ADDED Requirements

### Requirement: Web 必须提供统一的 HTTP 客户端

系统 SHALL 在 Web 端提供 `httpClient.ts`，统一处理请求、响应解包、错误处理。

#### Scenario: 自动解包 code/msg/data
- **WHEN** API 返回 `{ code: 0, msg: "success", data: {...} }`
- **THEN** httpClient 自动返回 data 部分

#### Scenario: code 非 0 抛出 ApiError
- **WHEN** API 返回 `{ code: 16001, msg: "请求过于频繁", data: {...} }`
- **THEN** httpClient 抛出 ApiError，包含 code、msg、data

#### Scenario: 网络错误统一处理
- **WHEN** 网络请求失败（超时、断网等）
- **THEN** httpClient 抛出 NetworkError

#### Scenario: 支持重试机制
- **WHEN** 请求失败且可重试（5xx 错误）
- **THEN** httpClient 自动重试最多 3 次

### Requirement: Web 必须提供业务 API 模块

系统 SHALL 提供 `uploadApi.ts`、`shareApi.ts`、`sidecarApi.ts` 等业务 API 模块，封装具体接口调用。

#### Scenario: uploadApi 封装上传接口
- **WHEN** 调用 `uploadApi.createSession({ childId })`
- **THEN** 返回 `{ sessionId, token, expiresAt }`

#### Scenario: shareApi 封装分享接口
- **WHEN** 调用 `shareApi.getAssets(token)`
- **THEN** 返回 `{ assets: [...] }`

#### Scenario: sidecarApi 封装本地接口
- **WHEN** 调用 `sidecarApi.getChildren()`
- **THEN** 返回 `{ children: [...] }`

### Requirement: Web 页面不能直接使用 axios

系统 SHALL 禁止在 hooks 和 pages 中直接 import axios，必须通过 API 模块调用。

#### Scenario: 禁止直接 import axios
- **WHEN** 在 hooks 或 pages 中 import axios
- **THEN** ESLint 报错

#### Scenario: 必须使用 API 模块
- **WHEN** 需要调用 API
- **THEN** 必须通过 uploadApi / shareApi / sidecarApi

### Requirement: Desktop 必须升级 SidecarApi 解析 code/msg/data

系统 SHALL 升级 Desktop 的 `SidecarApi`，统一解析后端返回的 code/msg/data 格式。

#### Scenario: 自动解包 data
- **WHEN** API 返回 `{ code: 0, msg: "success", data: {...} }`
- **THEN** SidecarApi 自动返回 data 部分

#### Scenario: code 非 0 抛出 SidecarApiException
- **WHEN** API 返回 `{ code: 16001, msg: "请求过于频繁", data: {...} }`
- **THEN** SidecarApi 抛出 SidecarApiException(code: 16001, msg: "请求过于频繁", data: {...})

#### Scenario: HTTP 错误统一处理
- **WHEN** HTTP 状态码为 500
- **THEN** SidecarApi 抛出 SidecarApiException(code: 50000, msg: "服务器内部错误")

### Requirement: Desktop 不能失败返回空对象

系统 SHALL 确保 Desktop 的 SidecarApi 在请求失败时抛出异常，而不是返回空对象 `{}`。

#### Scenario: 请求失败必须抛异常
- **WHEN** API 请求失败
- **THEN** 必须抛出 SidecarApiException，不能返回 `{}`

#### Scenario: 解析失败必须抛异常
- **WHEN** 响应体解析失败
- **THEN** 必须抛出 SidecarApiException，不能返回 `{}`

### Requirement: DesktopSidecarGateway 只保留 DTO 映射

系统 SHALL 确保 `DesktopSidecarGateway` 只负责 DTO 映射，不处理错误和重试。

#### Scenario: Gateway 只做 DTO 映射
- **WHEN** SidecarApi 返回数据
- **THEN** Gateway 将数据映射为 Flutter 模型

#### Scenario: 错误处理由 SidecarApi 负责
- **WHEN** API 请求失败
- **THEN** SidecarApi 抛出异常，Gateway 不捕获

### Requirement: 错误信息必须可本地化

系统 SHALL 支持根据错误码显示本地化的错误提示。

#### Scenario: Web 根据 code 显示中文错误
- **WHEN** ApiError.code = 16001，locale = zh-CN
- **THEN** 显示 "请求过于频繁"

#### Scenario: Desktop 根据 code 显示英文错误
- **WHEN** SidecarApiException.code = 16001，locale = en-US
- **THEN** 显示 "Rate limit exceeded"

### Requirement: 必须有集成测试覆盖

系统 SHALL 编写集成测试，验证 Web 和 Desktop 的 API 层正常工作。

#### Scenario: Web 上传流程测试
- **WHEN** 调用 uploadApi.createSession → createItems → commit
- **THEN** 整个流程成功，无异常

#### Scenario: Desktop 素材库测试
- **WHEN** 调用 sidecarApi.getChildren → getAssets
- **THEN** 返回正确的数据结构

#### Scenario: 错误处理测试
- **WHEN** API 返回错误
- **THEN** Web 抛出 ApiError，Desktop 抛出 SidecarApiException
