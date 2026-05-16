## ADDED Requirements

### Requirement: Proto 消息类型必须定义

系统 SHALL 在 `packages/protocol/proto/kidmemory/v1/` 中定义 Proto 消息类型，用于类型安全的数据交换。

#### Scenario: common.proto 定义通用类型
- **WHEN** 检查 proto/kidmemory/v1/common.proto
- **THEN** 必须定义 ApiResponse、PageData、Locale 等通用类型

#### Scenario: device.proto 定义设备相关消息
- **WHEN** 检查 proto/kidmemory/v1/device.proto
- **THEN** 必须定义 Device、DeviceHeartbeat、DeviceRegistration 等消息

#### Scenario: job.proto 定义任务相关消息
- **WHEN** 检查 proto/kidmemory/v1/job.proto
- **THEN** 必须定义 CloudJob、PullJobsRequest、PullJobsResponse 等消息

#### Scenario: upload.proto 定义上传相关消息
- **WHEN** 检查 proto/kidmemory/v1/upload.proto
- **THEN** 必须定义 UploadSession、UploadItem、CommitRequest 等消息

#### Scenario: share.proto 定义分享相关消息
- **WHEN** 检查 proto/kidmemory/v1/share.proto
- **THEN** 必须定义 ShareToken、ShareAccessLog、ValidateTokenRequest 等消息

#### Scenario: artifact.proto 定义产物相关消息
- **WHEN** 检查 proto/kidmemory/v1/artifact.proto
- **THEN** 必须定义 ArtifactMetadata、SyncArtifactRequest 等消息

### Requirement: Proto 必须使用 proto3 语法

系统 SHALL 使用 proto3 语法定义所有 Proto 文件。

#### Scenario: 文件头声明 proto3
- **WHEN** 检查 Proto 文件
- **THEN** 第一行必须是 `syntax = "proto3";`

#### Scenario: 使用 proto3 类型
- **WHEN** 定义字段类型
- **THEN** 必须使用 proto3 支持的类型（string、int32、int64、bool、bytes、message 等）

#### Scenario: 字段编号从 1 开始
- **WHEN** 定义消息字段
- **THEN** 字段编号必须从 1 开始，连续递增

### Requirement: Proto 必须支持 lint 检查

系统 SHALL 使用 buf 或 protoc 对 Proto 文件进行 lint 检查。

#### Scenario: 运行 proto lint
- **WHEN** 运行 `npm run protocol:lint-proto`
- **THEN** 必须检查所有 Proto 文件的语法和风格

#### Scenario: 检查命名规范
- **WHEN** 运行 proto lint
- **THEN** 必须检查消息名使用 PascalCase，字段名使用 snake_case

#### Scenario: 检查字段编号
- **WHEN** 运行 proto lint
- **THEN** 必须检查字段编号无重复、无跳跃

### Requirement: Proto 不用于 gRPC

系统 SHALL 明确 Proto 只用于类型定义，不用于 gRPC 通信。

#### Scenario: 不生成 gRPC service
- **WHEN** 检查 Proto 文件
- **THEN** 不能包含 service 定义

#### Scenario: 只生成消息类型
- **WHEN** 生成 Proto 代码
- **THEN** 只生成消息类型（TypeScript interface / Dart class），不生成 RPC 客户端

#### Scenario: REST API 使用 JSON
- **WHEN** sidecar 和 cloud-api 通信
- **THEN** 使用 REST API + JSON，不使用 gRPC
