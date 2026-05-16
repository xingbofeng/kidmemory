## Why

当前 KidMemory 项目存在协议不统一、接口格式混乱、安全防护不完善、工程规范缺失等问题。架构审查发现了 7 个需要修复的问题（2 个严重、2 个中高、3 个中等）。为了支持后续的服务拆分（sidecar + cloud-api）和多端协作（Web + Desktop），需要系统性地进行工程改造，建立统一的协议层、接口规范、安全机制和工程标准。

## What Changes

**Epic 1：协议层与统一响应协议**
- 新建 `packages/protocol` 作为唯一真相源
- 定义 `ApiCode` 错误码体系（分段规则：10000/11000/12000...）
- 定义 `ApiResponse<T>` 统一响应结构
- 定义 `PageData<T>` 分页结构
- 支持 `zh-CN` / `en-US` 双语错误文案
- 预留 OpenAPI / Proto 生成目录

**Epic 2：全量接口统一为 code/msg/data** (**BREAKING**)
- 所有 JSON API 返回统一格式：`{ code: 0, msg: "success", data: {...} }`
- 新增 `ApiResponseInterceptor` 自动包装成功响应
- 改造 `GlobalExceptionFilter` 统一错误响应
- 改造所有 Controller 返回格式
- 文件流 / HTML / PDF 接口不被包装
- 破坏式变更：直接切换到统一格式（项目早期，客户端少）

**Epic 3：内存限流与上传/分享防刷**
- 修复 `RateLimitMiddleware` 内存泄漏（定时清理替代随机清理）
- 完善 `SessionQuotaMiddleware` 配额逻辑
- 实现上传 commit 幂等性
- 实现 pullback 防重复触发
- 实现分享访问限流
- 实现 share token accessCount 原子消费
- 统一限流错误返回 code/msg/data
- **不引入 PG 或 Redis，保持内存方案**

**Epic 4：Web + Desktop 统一 API 层**
- Web 新增 `src/api/httpClient.ts` 统一请求层
- Web 新增业务 API 模块（uploadApi / shareApi / sidecarApi）
- Web 移除 hooks/pages 中直接 axios 调用
- Desktop 升级 `SidecarApi` 解析 code/msg/data
- Desktop code != 0 抛 `SidecarApiException`
- Desktop 不再失败返回空对象

**Epic 5：NestJS 标准化 + 根目录工程配置统一**
- Controller 改用标准 `@Post()` / `@Get()` 装饰器
- Service 改用标准 `@Injectable()`
- 删除 `registerInjectable` 手动注册
- `dev` 改为 `tsx watch src/main.ts`
- 根目录新增 `eslint.config.mjs` 统一 ESLint
- 根目录新增 `tsconfig.*.json` 统一 TypeScript 配置

**Epic 6：OpenAPI / 类型生成**
- 接入 `@nestjs/swagger` 生成 OpenAPI
- DTO 改为 class DTO
- 生成 OpenAPI JSON/YAML 到 `packages/protocol/openapi`
- 使用 `openapi-typescript` 生成 TypeScript 类型到 `packages/protocol/generated/ts/`
- 使用 `openapi-generator` 生成 Dart client 到 `packages/protocol/generated/dart/`
- CI 校验 OpenAPI 生成物与代码同步
- **不引入 Proto**：OpenAPI 作为唯一真相源已满足文档、codegen、类型统一三个目标

**Epic 7：i18n + mock/sample/scripts 清理**
- Web 接入 i18next
- Desktop 接入 Flutter l10n
- 后端 msg 支持 Accept-Language
- sample dataset metadata 双语化
- 生产代码清理 mock/sample/demo fallback
- 删除旧 scripts，新增 `doctor.mjs`

**Epic 8：服务拆分 + 表结构拆分**
- `packages/backend` 改名 `packages/sidecar`
- 新建 `packages/cloud-api`
- 设计 sidecar local DB schema（本地 DB、本地素材、本地 Agent）
- 设计 cloud-api cloud DB schema（上传、分享、设备同步、任务状态）
- 标注现有 schema 中 local-only / cloud-only / shared concept
- Agent 继续本地做，不拆 agent-runtime

**Epic 9：CI/CD、云部署、桌面 Release Dry-run**
- protocol / sidecar / cloud-api / web / desktop CI
- acceptance job 验收门禁
- cloud-api 腾讯云部署 + Cloudflare Tunnel
- Web Vercel 部署
- desktop tag release dry-run（macOS artifact）
- 部署后 smoke test

## Capabilities

### New Capabilities
- `unified-protocol`: 统一协议层，包含 ApiCode、ApiResponse、错误码体系、双语文案
- `unified-api-response`: 所有 JSON API 统一返回 code/msg/data 格式
- `memory-rate-limiting`: 基于内存的限流机制，支持 IP 限流、全局限流、Session 配额限流
- `upload-idempotency`: 上传 commit 和 pullback 的幂等性保证
- `share-access-control`: 分享访问限流和 accessCount 原子消费
- `client-api-layer`: Web 和 Desktop 统一 API 层，统一错误处理
- `nestjs-standard`: 标准 NestJS 装饰器和 DI，删除手动注册
- `root-engineering-config`: 根目录统一 ESLint 和 TypeScript 配置
- `openapi-generation`: 从 NestJS 生成 OpenAPI，支持 TS/Dart client 生成
- `sidecar-cloud-sync`: sidecar 设备注册、心跳、轮询拉取上传素材、领取云端任务，全链路离线降级
- `i18n-support`: Web/Desktop/Backend 全链路国际化支持（zh-CN / en-US）
- `service-split`: sidecar（本地）和 cloud-api（云端）服务拆分
- `local-cloud-db-split`: 本地 DB 和云端 DB 表结构拆分
- `ci-cd-pipeline`: 完整 CI/CD 流程，包含 acceptance gate 和云部署

### Modified Capabilities
<!-- 无现有能力需要修改 -->

## Impact

**受影响的包：**
- `packages/protocol` - 新建
- `packages/backend` - 改名为 `packages/sidecar`，大量重构
- `packages/cloud-api` - 新建
- `packages/web` - API 层重构，i18n 接入
- `packages/desktop` - SidecarApi 重构，i18n 接入

**受影响的模块：**
- 所有 Controller（装饰器标准化、响应格式统一）
- 所有 Service（DI 标准化）
- 所有 DTO（改为 class DTO）
- 所有中间件（限流、错误处理）
- 所有前端 API 调用（统一 API 层）
- Prisma schema（表结构拆分）
- CI/CD 流程（新增 acceptance gate）

**破坏性变更：**
- **BREAKING**: 所有 JSON API 响应格式从 `{ data }` 改为 `{ code, msg, data }`
- **BREAKING**: Web 和 Desktop 需要同步适配新响应格式
- **BREAKING**: 错误响应格式统一，旧的错误处理逻辑需要更新

**不影响：**
- 文件流接口（图片预览、PDF 下载）不改格式
- HTML preview 不改格式
- 业务功能逻辑不变
- 数据库数据不需要迁移（除了新增表）

**依赖关系：**
```
Epic 1 (协议层)
  ↓
Epic 2 (接口统一) ← 依赖 Epic 1
  ↓
Epic 3 (内存限流) ← 依赖 Epic 1, 2
Epic 4 (API 层) ← 依赖 Epic 1, 2
  ↓
Epic 5 (NestJS 标准化) ← 可并行
  ↓
Epic 6 (OpenAPI) ← 依赖 Epic 1, 2, 5
Epic 7 (i18n) ← 可并行
  ↓
Epic 8 (服务拆分) ← 依赖前面所有
  ↓
Epic 9 (CI/CD) ← 依赖前面所有
```

**执行顺序（调整后）：**
```
Week 0: 安全修复（架构审查 P0 问题）
Week 1-2: Epic 1 + Epic 5 + Epic 7（并行）
Week 3-4: Epic 2 + Epic 3 + Epic 4
Week 5-6: Epic 6 + Epic 7（完善）
Week 7-8: Epic 8 + Epic 9
```

**风险：**
- Epic 2 破坏性变更可能导致客户端大面积失败（缓解：同仓库同步更新，Contract tests 全覆盖）
- Epic 3 内存限流服务重启后状态丢失（可接受：本地部署场景）
- Epic 8 服务拆分复杂度高（缓解：分阶段迁移）
- 总工作量 8 周，团队带宽需要评估（缓解：分阶段交付）

**回滚方案：**
- Epic 2 可通过 feature flag 关闭新格式
- Epic 3 保留旧中间件作为 fallback
- Epic 5 按模块迁移，单模块可回滚
- Epic 8 可延后执行，不影响前面 Epic
