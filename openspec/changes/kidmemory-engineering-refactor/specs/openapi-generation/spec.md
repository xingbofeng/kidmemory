## ADDED Requirements

### Requirement: 必须接入 @nestjs/swagger

系统 SHALL 在 NestJS 应用中接入 `@nestjs/swagger`，自动生成 OpenAPI 文档。

#### Scenario: 配置 SwaggerModule
- **WHEN** 在 main.ts 中配置 Swagger
- **THEN** 必须使用 SwaggerModule.setup('/docs', app, document)

#### Scenario: /docs 可访问
- **WHEN** 启动应用后访问 /docs
- **THEN** 必须显示 Swagger UI

#### Scenario: /docs/openapi.json 可访问
- **WHEN** 访问 /docs/openapi.json
- **THEN** 必须返回 OpenAPI JSON 文档

### Requirement: DTO 必须改为 class DTO

系统 SHALL 将所有 interface DTO 改为 class DTO，支持装饰器和自动类型推断。

#### Scenario: 使用 class 定义 DTO
- **WHEN** 定义 DTO
- **THEN** 必须使用 class 而非 interface

#### Scenario: 使用装饰器标注字段
- **WHEN** 定义 DTO 字段
- **THEN** 可以使用 @ApiProperty() 装饰器

#### Scenario: 支持验证装饰器
- **WHEN** 定义 DTO 字段
- **THEN** 可以使用 class-validator 装饰器（@IsString、@IsNumber 等）

### Requirement: 必须开启 Swagger CLI Plugin

系统 SHALL 开启 Swagger CLI Plugin，自动推断 DTO 类型，减少手动标注。

#### Scenario: 配置 CLI Plugin
- **WHEN** 检查 nest-cli.json
- **THEN** 必须配置 @nestjs/swagger/plugin

#### Scenario: 自动推断字段类型
- **WHEN** DTO 字段有类型标注
- **THEN** Swagger 自动推断类型，无需 @ApiProperty()

#### Scenario: 自动推断必填字段
- **WHEN** DTO 字段没有 ? 标记
- **THEN** Swagger 自动标记为 required

### Requirement: 必须生成 OpenAPI 文件到 protocol

系统 SHALL 将生成的 OpenAPI JSON/YAML 输出到 `packages/protocol/openapi` 目录。

#### Scenario: 生成 OpenAPI JSON
- **WHEN** 运行生成脚本
- **THEN** 输出到 packages/protocol/openapi/kidmemory.v1.json

#### Scenario: 生成 OpenAPI YAML
- **WHEN** 运行生成脚本
- **THEN** 输出到 packages/protocol/openapi/sidecar.openapi.json

#### Scenario: 版本化管理（可选）
- **WHEN** API 需要版本化管理
- **THEN** 可生成版本化文件（如 sidecar.v2.openapi.json）
- **NOTE** 当前项目采用破坏式变更，暂不需要版本化

### Requirement: 必须支持生成 TypeScript client

系统 SHALL 支持从 OpenAPI 生成 TypeScript client，供 Web 端使用。

#### Scenario: 生成 TS client
- **WHEN** 运行 `npm run protocol:generate-ts-client`
- **THEN** 输出到 packages/protocol/generated/ts/

#### Scenario: client 包含所有接口
- **WHEN** 检查生成的 TS client
- **THEN** 必须包含所有 Controller 的接口方法

#### Scenario: client 类型安全
- **WHEN** 使用生成的 TS client
- **THEN** 必须有完整的 TypeScript 类型提示

### Requirement: 必须支持生成 Dart client

系统 SHALL 支持从 OpenAPI 生成 Dart client，供 Desktop 端使用。

#### Scenario: 生成 Dart client
- **WHEN** 运行 `npm run protocol:generate-dart-client`
- **THEN** 输出到 packages/protocol/generated/dart/

#### Scenario: client 包含所有接口
- **WHEN** 检查生成的 Dart client
- **THEN** 必须包含所有 Controller 的接口方法

#### Scenario: client 类型安全
- **WHEN** 使用生成的 Dart client
- **THEN** 必须有完整的 Dart 类型提示

### Requirement: 必须定义 Proto 消息类型

系统 SHALL 在 `packages/protocol/proto` 中定义 Proto 消息类型，用于 sidecar 和 cloud-api 之间的通信。

#### Scenario: 定义 device.proto
- **WHEN** 检查 proto 目录
- **THEN** 必须存在 kidmemory/v1/device.proto

#### Scenario: 定义 job.proto
- **WHEN** 检查 proto 目录
- **THEN** 必须存在 kidmemory/v1/job.proto

#### Scenario: 定义 upload.proto
- **WHEN** 检查 proto 目录
- **THEN** 必须存在 kidmemory/v1/upload.proto

#### Scenario: 定义 share.proto
- **WHEN** 检查 proto 目录
- **THEN** 必须存在 kidmemory/v1/share.proto

#### Scenario: 定义 artifact.proto
- **WHEN** 检查 proto 目录
- **THEN** 必须存在 kidmemory/v1/artifact.proto

### Requirement: 必须生成 Proto TS/Dart 类型

系统 SHALL 从 Proto 定义生成 TypeScript 和 Dart 类型。

#### Scenario: 生成 Proto TS 类型
- **WHEN** 运行 `npm run protocol:generate-proto-ts`
- **THEN** 输出到 packages/protocol/generated/ts/proto/

#### Scenario: 生成 Proto Dart 类型
- **WHEN** 运行 `npm run protocol:generate-proto-dart`
- **THEN** 输出到 packages/protocol/generated/dart/proto/

### Requirement: 必须有 CI 检查生成物

系统 SHALL 在 CI 中检查生成的 OpenAPI 和 Proto 文件是否与源码一致。

#### Scenario: 检查 OpenAPI 最新
- **WHEN** 运行 CI
- **THEN** 必须检查 openapi/*.yaml 是否与当前代码一致

#### Scenario: 检查 Proto 最新
- **WHEN** 运行 CI
- **THEN** 必须检查 generated/ 是否与 proto/ 一致

#### Scenario: 生成物不一致时失败
- **WHEN** 生成物与源码不一致
- **THEN** CI 必须失败，提示需要重新生成

### Requirement: 生成的 client 可选使用

系统 SHALL 允许生成的 client 先不接入生产路径，等稳定后再替换手写 API。

#### Scenario: 保留手写 API 层
- **WHEN** 生成 client 后
- **THEN** 手写的 uploadApi / shareApi 仍然可用

#### Scenario: 逐步替换手写 API
- **WHEN** 生成的 client 稳定后
- **THEN** 可以逐个模块替换为生成的 client

#### Scenario: 支持混合使用
- **WHEN** 部分模块使用生成 client，部分使用手写 API
- **THEN** 两者可以共存
