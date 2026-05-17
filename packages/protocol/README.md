# KidMemory Protocol

`packages/protocol` 是 KidMemory 的共享协议包。它集中维护 Sidecar 与 Cloud API 的共享类型、统一响应格式、错误码、本地化错误文案、OpenAPI 文档增强和生成客户端，是 Web、Desktop、Sidecar、Cloud API 之间的契约中心。

### 主要职责

- 定义共享 TypeScript 类型和 API 响应模型。
- 管理错误码分段、错误消息和本地化文案。
- 汇总并增强 Sidecar/Cloud API 的 OpenAPI 文档。
- 生成 TypeScript 和 Dart client，供 Web、Desktop 和服务端包使用。
- 通过测试确保协议、路径参数、错误码和 proto 定义保持一致。

### 目录说明

- `src/common/`：统一响应、API code、locale 等共享基础类型。
- `src/sidecar/`：Sidecar 协议入口和导出。
- `src/cloud-api/`：Cloud API 协议入口和导出。
- `errors/`：错误码定义和中英文错误消息。
- `openapi/`：生成和增强后的 OpenAPI 文档输出位置。
- `generated/`：生成的 TypeScript/Dart client 或模型。
- `proto/`：Protocol Buffers 定义。
- `scripts/`：检查、生成 client、增强 OpenAPI 文档等脚本。
- `tests/`：协议一致性、错误码、locale、OpenAPI 路径参数和 proto 测试。

### 常用命令

```bash
npm --prefix packages/protocol run build
npm --prefix packages/protocol run test
npm --prefix packages/protocol run type-check
npm --prefix packages/protocol run check
npm --prefix packages/protocol run gen:ts
npm --prefix packages/protocol run gen:dart
npm --prefix packages/protocol run docs:openapi
npm --prefix packages/protocol run proto:lint
```

### 开发提示

- 任何跨包 API 变化都应先考虑协议层是否需要更新。
- 生成物应来自脚本，不要手写大段 generated client。
- 修改错误码时，同步更新 `errors/error-codes.yaml`、本地化消息和测试。
- 更新 Sidecar 或 Cloud API OpenAPI 后，运行相应生成命令，确保 Web/Desktop 使用的 client 与服务端一致。
