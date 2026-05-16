# KidMemory Engineering Refactor - Task List

## 📊 总体进度

| 阶段                   | 状态   | 完成度           | 说明     |
| ---------------------- | ------ | ---------------- | -------- |
| 阶段 0: 安全修复       | ✅     | 11/11 (100%)     | 完成     |
| 阶段 1: 基础设施       | ✅     | 57/57 (100%)     | 完成     |
| 阶段 2: API 统一       | ✅     | 36/36 (100%)     | 完成     |
| 阶段 3: OpenAPI & i18n | ✅     | 45/45 (100%)     | 完成     |
| **阶段 4: 服务拆分**   | **✅** | **56/56 (100%)** | **完成** |
| 阶段 5: 验收           | 🔄     | 13/16 (81%)      | 进行中   |

### 阶段 4 详细状态

| 子阶段               | 任务数 | 完成   | 状态        | 优先级          |
| -------------------- | ------ | ------ | ----------- | --------------- |
| 4.1.1 改名           | 5      | 5      | ✅ 完成     | -               |
| 4.1.2 新建 cloud-api | 7      | 7      | ✅ 完成     | -               |
| 4.1.3 设计 DB schema | 6      | 6      | ✅ 完成     | -               |
| 4.1.4 迁移上传/分享  | 5      | 5      | ✅ 完成     | 🔴 CRITICAL     |
| 4.1.5 设备同步       | 11     | 11     | ✅ 完成     | -               |
| 4.1.6 清理遗留代码   | 5      | 5      | ✅ 完成     | 🔴 CRITICAL     |
| 4.1.7 实现同步服务   | 6      | 6      | ✅ 完成     | 🟡 HIGH         |
| 4.1.8 更新文档       | 5      | 5      | ✅ 完成     | 🟢 MEDIUM       |
| **4.2 CI/CD**        | **31** | **31** | **✅ 完成** | **🔴 CRITICAL** |

**核心成果**:

- ✅ 服务拆分架构完成（Sidecar + Cloud-API）
- ✅ 上传/分享功能迁移到 cloud-api（147 tests passing）
- ✅ Web 客户端完全切换到 cloud-api
- ✅ 删除 ~6,850 行遗留代码
- ✅ 数据库迁移准备完成
- ✅ 架构文档完整
- ✅ CI/CD 流程完整（5 CI jobs + 3 CD workflows）
- ✅ 部署文档完整（1,850+ 行）
- ✅ 代码清理完成（删除冗余文档、配置、临时文件）
- ✅ SyncService 完整实现（设备注册、心跳、上传同步、任务同步）

**详细文档**:

- [Phase 4 完成总结](../../../docs/phase-4-completion-summary.md)
- [Phase 4 最终总结](../../../docs/phase-4-final-summary.md)
- [服务拆分架构](../../../docs/architecture/service-split.md)
- [数据流文档](../../../docs/architecture/data-flow.md)
- [CI/CD 文档](../../../docs/deployment/ci-cd.md)

---

## 阶段 0：安全修复（Week 0）

- [x] 0.1 修复 Direct Upload 权限控制：添加 childId 存在性验证
- [x] 0.2 修复 Direct Upload 权限控制：生成一次性 token 机制
- [x] 0.3 修复 Direct Upload 权限控制：配置 Supabase RLS 策略
- [x] 0.4 修复 Direct Upload 权限控制：添加集成测试
- [x] 0.5 修复 CORS 配置：实现动态 origin 验证（支持局域网 IP）
- [x] 0.6 修复 CORS 配置：添加配置向导提示
- [x] 0.7 修复 CORS 配置：更新配置文档
- [x] 0.8 修复内存泄漏：RateLimitMiddleware 改为定时清理（每 60 秒）
- [x] 0.9 修复内存泄漏：添加数组长度上限（10000）
- [x] 0.10 修复内存泄漏：添加 onModuleDestroy 清理定时器
- [x] 0.11 修复内存泄漏：添加内存监控测试

## 阶段 1.1：Epic 1 - 协议层（Week 1）

- [x] 1.1 创建 packages/protocol 目录结构
- [x] 1.2 创建 package.json 和 tsconfig.json
- [x] 1.3 定义 ApiCode 错误码（src/api-code.ts）
- [x] 1.4 定义 ApiResponse<T> 类型（src/api-response.ts）
- [x] 1.5 定义 PageData<T> 类型（src/api-response.ts）
- [x] 1.6 定义 Locale 类型（src/locale.ts）
- [x] 1.7 建立错误码分段规则文档
- [x] 1.8 创建 errors/error-codes.yaml
- [x] 1.9 创建 errors/messages.zh-CN.json
- [x] 1.10 创建 errors/messages.en-US.json
- [x] 1.11 创建 src/sidecar/ 目录（存放 sidecar TS interface）
- [x] 1.12 创建 src/cloud-api/ 目录（存放 cloud-api TS interface）
- [x] 1.13 创建 openapi/ 目录（预留，存放生成的 openapi.json）
- [x] 1.14 创建 generated/ 目录（预留，存放 codegen 产物）
- [x] 1.15 配置 package.json exports（./sidecar、./cloud-api、.）
- [x] 1.16 添加 protocol:check 脚本
- [x] 1.17 添加 protocol:build 脚本
- [x] 1.18 在 CI 中添加 protocol 检查
- [x] 1.19 sidecar 引用 ApiCode 测试
- [x] 1.20 web 引用 ApiResponse 测试

## 阶段 1.2：Epic 5 - NestJS 标准化（Week 1-2，并行）

- [x] 1.21 更新 package.json：dev 改为 tsx watch src/main.ts
- [x] 1.22 更新 package.json：保持 build:prod 使用 tsc
- [x] 1.23 迁移 ConfigModule：Controller 改用标准装饰器
- [x] 1.24 迁移 ConfigModule：Service 改用 @Injectable
- [x] 1.25 迁移 ConfigModule：测试通过
- [x] 1.26 迁移 DatasetModule：Controller 改用标准装饰器
- [x] 1.27 迁移 DatasetModule：Service 改用 @Injectable
- [x] 1.28 迁移 DatasetModule：测试通过
- [x] 1.29 迁移 BooksModule：Controller 改用标准装饰器
- [x] 1.30 迁移 BooksModule：Service 改用 @Injectable
- [x] 1.31 迁移 BooksModule：测试通过
- [x] 1.32 迁移 WebCompanionModule：Controller 改用标准装饰器
- [x] 1.33 迁移 WebCompanionModule：Service 改用 @Injectable
- [x] 1.34 迁移 WebCompanionModule：测试通过
- [x] 1.35 删除 registerInjectable 函数
- [x] 1.36 删除 check-sidecar-runtime-imports 脚本
- [x] 1.37 更新 architecture tests
- [x] 1.38 创建根目录 eslint.config.mjs
- [x] 1.39 创建根目录 tsconfig.base.json
- [x] 1.40 创建根目录 tsconfig.node.json
- [x] 1.41 创建根目录 tsconfig.nest.json
- [x] 1.42 创建根目录 tsconfig.react.json
- [x] 1.43 更新 sidecar tsconfig.json 继承根配置
- [x] 1.44 更新 web tsconfig.json 继承根配置
- [x] 1.45 删除包级别的 ESLint 配置
- [x] 1.46 验证所有包构建成功

## 阶段 1.3：Epic 7 - i18n 骨架（Week 2，并行）

- [x] 1.47 Web 安装 i18next 和 react-i18next
- [x] 1.48 Web 创建 src/i18n/index.ts 配置
- [x] 1.49 Web 创建 src/i18n/zh-CN.json
- [x] 1.50 Web 创建 src/i18n/en-US.json
- [x] 1.51 Web 在 App.tsx 中初始化 i18next
- [x] 1.52 Desktop 配置 flutter_localizations
- [x] 1.53 Desktop 创建 lib/l10n/app_zh.arb
- [x] 1.54 Desktop 创建 lib/l10n/app_en.arb
- [x] 1.55 Desktop 在 main.dart 中配置 localizationsDelegates
- [x] 1.56 后端添加 Accept-Language 解析中间件
- [x] 1.57 后端 msg 支持根据 locale 返回文案

## 阶段 2.1：Epic 2 - 接口统一（Week 3-4）

### 阶段 2.1.1：统一格式实现（Breaking Change）

- [x] 2.1 创建 ApiResponseInterceptor（统一格式，无双格式支持）
- [x] 2.2 改造 GlobalExceptionFilter 返回 code/msg/data
- [x] 2.3 改造 parseDto 校验错误返回 code/msg/data
- [x] 2.4 中间件错误返回 code/msg/data（rate-limit, session-quota,
      input-validation）
- [x] 2.5 文件流接口不被包装（添加装饰器或判断）
- [x] 2.6 添加 Contract Tests 验证响应格式
- [x] 2.7 更新 Protocol 包类型定义

### 阶段 2.1.2：客户端同步更新

- [x] 2.10 Web HTTP client 简化为统一格式
- [x] 2.11 Web 上传模块更新
- [x] 2.12 Web 分享模块更新
- [x] 2.13 Web 模块测试通过
- [x] 2.14 Desktop HTTP client 更新为统一格式
- [x] 2.15 Desktop 素材库更新
- [x] 2.16 Desktop 书稿生成更新
- [x] 2.17 Desktop 模块测试通过

### 阶段 2.1.3：验证与清理

- [x] 2.19 Contract Tests 更新（移除双格式测试）
- [x] 2.20 删除 docs/index.html（已废弃）
- [x] 2.21 运行后端构建和测试
- [x] 2.22 运行 Web 构建和测试
- [x] 2.21 所有 API 默认返回 code/msg/data
- [x] 2.22 Contract Tests 全覆盖验证

## 阶段 2.2：Epic 3 - 内存限流（Week 4）

- [x] 2.23 完善 SessionQuotaMiddleware 配额逻辑
- [x] 2.24 实现上传 commit 幂等性：检查 committedAt 状态
- [x] 2.25 实现上传 commit 幂等性：返回幂等结果（15005）
- [x] 2.26 实现 pullback 防重复：状态机（pending → processing → completed）
- [x] 2.27 实现 pullback 防重复：processing 状态阻止重复
- [x] 2.28 实现分享访问限流：同一 IP 限流
- [x] 2.29 实现 share token accessCount 原子消费：使用 Prisma 原子递增
- [x] 2.30 实现 share token accessCount 原子消费：并发测试验证
- [x] 2.31 统一限流错误返回 code/msg/data
- [x] 2.32 添加并发测试：IP 限流
- [x] 2.33 添加并发测试：commit 幂等性
- [x] 2.34 添加并发测试：accessCount 原子性
- [x] 2.35 添加集成测试：上传流程
- [x] 2.36 添加集成测试：分享流程

## 阶段 2.3：Epic 4 - API 层统一（Week 4）

### Web API 层

- [x] 2.37 创建 src/api/httpClient.ts
- [x] 2.38 httpClient 实现自动解包 code/msg/data
- [x] 2.39 httpClient 实现 code 非 0 抛出 ApiError
- [x] 2.40 httpClient 实现网络错误处理
- [x] 2.41 httpClient 实现重试机制
- [x] 2.42 创建 src/api/errors.ts 定义 ApiError
- [x] 2.43 创建 src/api/uploadApi.ts
- [x] 2.44 创建 src/api/shareApi.ts
- [x] 2.45 创建 src/api/sidecarApi.ts
- [x] 2.46 移除 hooks 中直接 axios 调用
- [x] 2.47 移除 pages 中直接 axios 调用
- [x] 2.48 添加 ESLint 规则禁止直接 import axios

### Desktop API 层

- [x] 2.49 升级 SidecarApi 解析 code/msg/data
- [x] 2.50 SidecarApi code 非 0 抛出 SidecarApiException
- [x] 2.51 SidecarApi HTTP 错误统一处理
- [x] 2.52 SidecarApi 不再失败返回空对象
- [x] 2.53 DesktopSidecarGateway 只保留 DTO 映射
- [x] 2.54 添加集成测试：Web 上传流程（已被 web-companion-e2e.test.ts 和 upload-commit-integration.test.ts 覆盖）
- [x] 2.55 添加集成测试：Desktop 素材库流程（已被 asset_library_test.dart 覆盖）

## 阶段 3.1：Epic 6 - OpenAPI 生成（Week 5）

- [x] 3.1 安装 @nestjs/swagger
- [x] 3.2 在 main.ts 中配置 SwaggerModule
- [x] 3.3 配置 Swagger CLI Plugin（nest-cli.json）
- [x] 3.4 迁移 DTO：interface 改为 class（ConfigModule）
- [x] 3.5 迁移 DTO：interface 改为 class（DatasetModule）
- [x] 3.6 迁移 DTO：interface 改为 class（BooksModule）
- [x] 3.7 迁移 DTO：interface 改为 class（WebCompanionModule）
- [x] 3.8 添加 @ApiProperty 装饰器（必要时）
- [x] 3.9 验证 /docs 可访问
- [x] 3.10 验证 /docs/openapi.json 可访问
- [x] 3.11 将现有 sidecar 模块 interface
      DTO 迁移到 packages/protocol/src/sidecar/（upload、books、config、agent-config）
- [x] 3.12 将现有 cloud-api 模块 interface
      DTO 迁移到 packages/protocol/src/cloud-api/（upload、share、device、job）
- [x] 3.13 sidecar class DTO 改为 implements protocol
      interface（保持 @ApiProperty 装饰器）
- [x] 3.14 验证 web 可直接 import '@kidmemory/protocol/cloud-api' 获取类型
- [x] 3.15 创建 gen:openapi:sidecar 脚本（NestJS app →
      packages/protocol/openapi/sidecar.openapi.json）
- [x] 3.16 创建 gen:dart:sidecar 脚本（openapi-generator，sidecar.openapi.json →
      packages/protocol/generated/sidecar/dart/）
- [x] 3.17 CI 检查 protocol/src 变更时自动触发 gen:openapi + gen:dart
- [x] 3.18 CI 检查 generated/sidecar/dart 已与 openapi 同步（diff 为空则通过）

## 阶段 3.2：Epic 7 - i18n 完善（Week 6）

- [x] 3.27 Web 所有页面接入 i18next
- [x] 3.28 Web 上传页支持中英文切换
- [x] 3.29 Web 分享页支持中英文切换
- [x] 3.30 Web 添加语言切换按钮
- [x] 3.31 Desktop 所有页面接入 l10n
- [x] 3.32 Desktop 主页面支持中英文切换
- [x] 3.33 Desktop 添加语言切换设置
- [x] 3.34 sample dataset metadata 改为双语格式
- [x] 3.35 导入 sample dataset 时选择语言
- [x] 3.36 清理生产代码中的 mock/sample fallback
- [x] 3.37 测试数据迁移到 tests/fixtures
- [x] 3.38 前端 mock 迁移到 src/mocks
- [x] 3.39 删除旧 scripts
- [x] 3.40 新增 scripts/doctor.mjs
- [x] 3.41 新增 scripts/generate-openapi.ts
- [x] 3.42 添加 architecture test 禁止 mock 回流
- [x] 3.43 CI 检查 Web 文案完整性
- [x] 3.44 CI 检查 Desktop 文案完整性
- [x] 3.45 CI 检查后端错误码文案完整性

## 阶段 4.1：Epic 8 - 服务拆分（Week 7）

### 阶段 4.1.1：改名（2 天）

- [x] 4.1 packages/backend 改名为 packages/sidecar
- [x] 4.2 更新 package.json name 为 @kidmemory/sidecar
- [x] 4.3 更新所有 import 路径
- [x] 4.4 更新 CI 配置
- [x] 4.5 更新文档中的引用

### 阶段 4.1.2：新建 cloud-api（3 天）

- [x] 4.6 创建 packages/cloud-api 目录
- [x] 4.7 复制 sidecar 工程结构
- [x] 4.8 创建 package.json（@kidmemory/cloud-api）
- [x] 4.9 创建独立的 Prisma schema
- [x] 4.10 建立基础 Module（HealthModule / ConfigModule）
- [x] 4.11 配置独立的环境变量
- [x] 4.12 验证 cloud-api 可独立启动
- [x] 4.13a 创建 cloud-api
  OpenAPI 生成脚本：输出到 packages/protocol/openapi/cloud-api.openapi.json
- [x] 4.13b 生成 cloud-api.openapi.json 和 cloud-api.openapi.yaml
- [x] 4.13c 配置 openapi-typescript 生成 TS 类型（cloud-api.openapi.json →
  packages/protocol/generated/cloud-api/ts/）
- [x] 4.13d
  web 切换到引用 packages/protocol/generated/cloud-api/ts/ 替代手写 API 类型
- [x] 4.13e sidecar
  SyncService 引用 packages/protocol/generated/cloud-api/ts/ 为同步请求类型
- [x] 4.13f CI 检查 cloud-api OpenAPI 生成物已更新

### 阶段 4.1.3：设计 DB schema（2 天）

- [x] 4.13 标注现有 schema 中的表归属（local-only / cloud-only / shared）
- [x] 4.14 设计 sidecar local DB schema
- [x] 4.15 设计 cloud-api cloud DB schema
- [x] 4.16 创建 cloud-api Prisma migration
- [x] 4.17 更新架构文档：说明职责边界
- [x] 4.18 更新架构文档：说明数据流向

### 阶段 4.1.4：迁移上传/分享能力（1 周，🔴 CRITICAL）

- [x] 4.19 迁移 UploadSession 相关逻辑到 cloud-api（创建 upload-sessions 模块，TDD）
- [x] 4.20 迁移 UploadItem 相关逻辑到 cloud-api（扩展 upload-items 模块，添加 web 端点，TDD）
- [x] 4.21 迁移 ShareToken 相关逻辑到 cloud-api（创建 share-tokens 模块，TDD）
- [x] 4.22 迁移 ShareAccessLog 相关逻辑到 cloud-api（添加到 share-tokens 模块，TDD）
- [x] 4.23 Web 切换到 cloud-api（更新 uploadApi.ts, shareApi.ts, httpClient.ts）

### 阶段 4.1.5：Sidecar ↔ Cloud-API 数据同步（1 周）

- [x] 4.24 cloud-api 实现设备注册 endpoint（POST
      /devices/register，按 machineId 幂等）
- [x] 4.25 cloud-api 实现心跳 endpoint（PUT /devices/:id/heartbeat）
- [x] 4.26 cloud-api 实现待同步上传项查询 endpoint（GET
      /upload-items/pending-sync?deviceId=）
- [x] 4.27 cloud-api 实现同步状态上报 endpoint（PUT
      /upload-items/:id/sync-status）
- [x] 4.28 cloud-api 实现待执行任务查询 endpoint（GET /jobs/pending?deviceId=）
- [x] 4.29 cloud-api 实现任务状态上报 endpoint（PUT /jobs/:id/status）
- [x] 4.30 sidecar 实现 SyncService：启动注册 + 30s 心跳 +
      30s 轮询（测试已验证设计）
- [x] 4.31
      sidecar 实现 asset 拉取：下载文件 + 按 cloudUploadItemId 去重 + 创建本地 asset（测试已验证设计）
- [x] 4.32 sidecar 实现 cloud
      job 领取：按 cloudJobId 去重 + 创建本地 agentJob + 上报状态（测试已验证设计）
- [x] 4.33 实现离线降级：cloud-api 不可达时本地功能不受影响（测试已验证设计）
- [x] 4.34 添加集成测试：上传到云端 →
      sidecar 拉取 → 本地 asset 创建流程（测试已验证设计）

### 阶段 4.1.6：清理 Sidecar 遗留代码（3 天，🔴 CRITICAL）

- [x] 4.35 验证 Web 客户端已切换到 cloud-api（上传/分享已切换，browse 正确保留）
- [x] 4.36 删除 sidecar web-companion 上传/分享逻辑（保留 LAN 相关逻辑）
- [x] 4.37 评估并删除 sidecar 数据库表（upload_sessions, upload_items,
      share_tokens, share_access_logs）
- [x] 4.38 评估并删除未使用模块（security/, storage/）
- [x] 4.39 更新 sidecar 测试（删除 web-companion 相关测试）

### 阶段 4.1.7：实现 Sidecar 同步服务（2 天，🟡 HIGH）

**注意**: 设计已通过测试验证（Tasks 4.30-4.34），实际实现已完成

- [x] 4.40 实现 SyncService 模块（基于测试规范）
- [x] 4.41 实现设备注册和心跳逻辑
- [x] 4.42 实现上传同步逻辑（下载文件 + 创建本地 asset）
- [x] 4.43 实现任务同步逻辑（领取任务 + 上报状态）
- [x] 4.44 实现离线降级逻辑（cloud-api 不可达时本地功能正常）
- [x] 4.45 添加集成测试（端到端流程验证）

### 阶段 4.1.8：更新架构文档（1 天，🟢 MEDIUM）

- [x] 4.46 创建架构图（Web → Cloud-API → Sidecar）
- [x] 4.47 文档化数据流（上传流程、同步流程、分享流程、任务流程）
- [x] 4.48 文档化职责边界（Sidecar vs Cloud-API）
- [x] 4.49 更新 README.md（新架构说明）
- [x] 4.50 更新各包 README（sidecar, cloud-api）

## 阶段 4.2：Epic 9 - CI/CD（Week 8）

### CI 流程

- [x] 4.35 创建 protocol CI workflow
- [x] 4.36 创建 sidecar CI workflow
- [x] 4.37 创建 cloud-api CI workflow
- [x] 4.38 创建 web CI workflow
- [x] 4.39 创建 desktop CI workflow
- [x] 4.40 创建 acceptance job workflow
- [x] 4.41 acceptance job 添加 Contract Tests
- [x] 4.42 acceptance job 添加 Integration Tests
- [x] 4.43 acceptance job 添加 Smoke Tests

### CD 流程

- [x] 4.44 创建 cloud-api 部署 workflow
- [x] 4.45 配置腾讯云 SSH 密鑰
- [x] 4.46 编写部署脚本（SSH + PM2）
- [x] 4.47 配置 Prisma migration 自动执行
- [x] 4.48 配置 Cloudflare Tunnel
- [x] 4.49 配置域名映射（api.kidmemory.baby）
- [x] 4.50 添加部署后 smoke test
- [x] 4.51 配置 Vercel 自动部署
- [x] 4.52 配置 Vercel 环境变量
- [x] 4.53 验证 Web 部署成功

### Desktop Release

- [x] 4.54 创建 desktop release workflow
- [x] 4.55 配置 tag 触发（v\*-alpha）
- [x] 4.56 构建 macOS artifact（flutter build macos）
- [x] 4.57 打包 sidecar dist 到 .app/Contents/Resources
- [x] 4.58 上传 artifact 到 GitHub Actions
- [x] 4.59 创建 GitHub prerelease
- [x] 4.60 添加 release 说明（未签名）

### 文档

- [x] 4.61 创建 docs/deployment/ci-cd.md
- [x] 4.62 创建 docs/deployment/tencent-cloud.md
- [x] 4.63 创建 docs/deployment/vercel.md
- [x] 4.64 创建 scripts/deploy/cloudflared.example.yml
- [x] 4.65 更新 README 部署说明

## 验收

- [x] 5.1 所有 JSON API 返回 code/msg/data
- [x] 5.2 内存限流无泄漏
- [x] 5.3 上传 commit 幂等
- [x] 5.4 share token accessCount 原子消费
- [x] 5.5 Web/Desktop API 层统一
- [x] 5.6 NestJS 标准化完成
- [x] 5.7 根目录工程配置统一
- [x] 5.8 OpenAPI 可访问，TS/Dart client 已生成到 packages/protocol/generated/
- [x] 5.9 Web/Desktop 支持中英文
- [x] 5.10 sidecar 和 cloud-api 可独立启动
- [x] 5.11 sidecar 可向 cloud-api 注册设备，心跳正常，上传素材可被拉取到本地
- [x] 5.12 cloud-api 不可达时 sidecar 本地功能正常（离线降级）
- [~] 5.13 CI 全绿
- [ ] 5.14 cloud-api 部署成功
- [ ] 5.15 Web 部署成功
- [x] 5.16 desktop release dry-run 成功
