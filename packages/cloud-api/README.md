# KidMemory Cloud API

`packages/cloud-api` 是 KidMemory 的云端 NestJS API 服务。它负责跨设备同步、设备注册、云端上传项、任务状态和 Web Companion 云端迁移能力，是本地 Sidecar 之外的在线协作与同步边界。

### 主要职责

- 管理设备注册、设备状态和云端同步身份。
- 提供上传项、任务状态、Web Companion 云端接口和健康检查。
- 使用 Prisma/PostgreSQL 维护云端数据模型和迁移。
- 输出云端 OpenAPI 文档，并与 `packages/protocol` 共享 API 契约。
- 提供 rate limit、安全中间件、统一响应和异常处理。

### 目录说明

- `src/modules/`：云端业务模块，包括 config、devices、health、jobs、upload-items、web-companion。
- `src/infrastructure/`：数据库、统一响应、异常过滤、安全和 rate limit 基础设施。
- `prisma/`：云端数据库 schema 和迁移。
- `scripts/generate-openapi.ts`：生成 Cloud API OpenAPI 文档。
- `tests/unit/`：模块级单元测试。
- `tests/architecture/`：架构约束和协议契约测试。
- `tests/integration/`：云端集成测试占位与扩展位置。

### 常用命令

```bash
npm --prefix packages/cloud-api run dev
npm --prefix packages/cloud-api run build
npm --prefix packages/cloud-api run build:prod
npm --prefix packages/cloud-api run test
npm --prefix packages/cloud-api run test:unit
npm --prefix packages/cloud-api run lint
npm --prefix packages/cloud-api run type-check
npm --prefix packages/cloud-api run gen:openapi
```

### 开发提示

- 新增或修改 API 时，同步更新 OpenAPI/Protocol 生成链路。
- 涉及数据库时，更新 Prisma schema、迁移和相邻测试。
- 云端接口必须保持租户/设备边界清晰，避免泄露跨设备数据。
- 配置应通过环境变量和 `.env.example` 维护，不提交真实密钥。
