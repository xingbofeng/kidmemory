# KidMemory Sidecar NestJS + Prisma 全量迁移方案

## 目标

将 `packages/backend` 从当前“半 NestJS + 手写 SQL + 大 service 聚合”的 sidecar，迁移为标准 NestJS 模块化单体，数据库访问统一改为 Prisma ORM，业务层采用 Clean Architecture / Ports & Adapters 分层。

迁移后，sidecar 是 KidMemory 的唯一后端服务边界，负责桌面端、Web Companion、Agent Runner、导出、配置、密钥和数据库编排。Web 和 Desktop 只通过稳定 HTTP API 调用 sidecar。

## 明确不做

- 不把 sidecar 迁成 Next.js API Routes。
- 不保留业务模块直接写 SQL 的长期路径。
- 不把 Prisma Client 直接暴露给 controller 或 domain。
- 不为了兼容旧内部结构保留 `final_schema.sql` 作为长期 schema 来源。
- 不允许普通生成请求继续传 raw API key。

## 最终架构

```text
packages/backend/
  prisma/
    schema.prisma
    migrations/
    seed.ts

  src/
    main.ts
    app.module.ts

    common/
      errors/
      validation/
      result/
      logging/

    infrastructure/
      database/
        prisma.service.ts
        transaction-manager.ts
        prisma-error.mapper.ts
      security/
        encryption.service.ts
        token.service.ts
      http/
        global-exception.filter.ts
        request-context.middleware.ts
      agents/
        openai-agents.runner.ts
        claude.runner.ts
      storage/
        storage-provider.port.ts
        supabase-storage.adapter.ts

    modules/
      agent-config/
        presentation/
        application/
        domain/
        ports/
        adapters/

      books/
        presentation/
        application/
        domain/
        ports/
        adapters/

      web-companion/
        upload-session/
        upload-item/
        share/
        browse/
        pullback/

      dataset/
      export/
      backup/
```

## 分层规则

### Presentation

Controller 只负责：

- 提取 path/query/body/header。
- 调用 DTO runtime validation。
- 调用 application use case。
- 将 application result 或 typed error 映射为 HTTP response。

Controller 禁止：

- 直接调用 Prisma。
- 直接调用 `pg`。
- 直接创建 SDK client。
- 直接处理文件系统 workspace。
- 返回未经过 contract 固定的 ad-hoc JSON。

### Application

Application service / use case 负责业务流程编排，例如：

- 创建上传会话。
- 提交上传项。
- 创建分享链接。
- 生成作品集。
- 测试 Agent 配置。
- 执行备份恢复。

Application 层只能依赖 port interface，不依赖 Prisma Client、OpenAI SDK、Supabase SDK 或文件系统实现。

### Domain

Domain 层保存业务实体、值对象、策略和 domain error，例如：

- `UploadSession`
- `UploadItem`
- `ShareToken`
- `AgentConfig`
- `BookGenerationJob`
- `ExportArtifact`

Domain 不知道 HTTP、Prisma、Nest、SDK、文件路径。

### Ports

Ports 是 application 对外部能力的接口：

- `AgentConfigRepository`
- `UploadSessionRepository`
- `ShareTokenRepository`
- `AssetRepository`
- `BookRepository`
- `AgentRunner`
- `StorageProvider`
- `WorkspaceStore`
- `EncryptionPort`

### Adapters

Adapters 实现 ports：

- Prisma repository adapter。
- OpenAI Agents SDK runner。
- Claude runner。
- Supabase storage adapter。
- Local filesystem workspace adapter。
- AES-GCM encryption adapter。

## NestJS 标准化

当前 sidecar 应迁移为标准 NestJS 工程：

- 使用 TypeScript 编译或 `tsx` dev runner。
- 使用标准 `@Module()`、`@Controller()`、`@Injectable()` decorator。
- 删除手写 decorator 注册辅助代码。
- 使用 Nest DI 注入所有 service、repository、runner、adapter。
- 使用 Nest testing module 做 controller/use case/repository 测试。

目标脚本：

```json
{
  "scripts": {
    "dev": "tsx watch src/main.ts",
    "build": "tsc -p tsconfig.build.json",
    "start": "node dist/main.js",
    "test": "node --test \"tests/**/*.test.ts\"",
    "prisma:generate": "prisma generate",
    "prisma:migrate": "prisma migrate deploy",
    "prisma:dev": "prisma migrate dev"
  }
}
```

## Prisma 数据库策略

### 原则

- `prisma/schema.prisma` 是唯一 schema 源。
- `prisma/migrations` 是唯一迁移历史。
- 业务代码不允许手写 SQL。
- 所有 Prisma 调用必须在 repository adapter 内。
- Prisma schema 可以重构旧数据库，不要求保留旧表结构。
- 如果后续需要旧数据升级，再单独写一次性 migration/import 脚本。

### pgvector 例外

Prisma 对 pgvector 表达有限。允许一个受控例外：

```text
infrastructure/database/vector-search.adapter.ts
```

规则：

- 只封装 vector search。
- 只暴露 typed method，例如 `findSimilarAssets()`.
- 业务模块不得直接传 SQL。
- adapter 必须有 contract tests。

### 初始模型

Prisma schema 至少覆盖：

- `Child`
- `Asset`
- `AssetEmbedding`
- `Book`
- `BookPage`
- `BookGenerationJob`
- `ExportArtifact`
- `UploadSession`
- `UploadItem`
- `ShareToken`
- `ShareAccessLog`
- `AgentConfig`
- `AgentRun`
- `BackupSnapshot`

旧 `001_final_schema.sql` 应被拆解并迁移到 Prisma migrations。迁移完成后，旧 SQL 文件只允许保留在 `docs/archive` 或删除。

## 模块拆分方案

### Agent Config

职责：

- 创建、更新、删除、查询 Agent 配置。
- 加密保存 API key。
- 设置默认配置。
- 真实测试 provider 连接。
- 为 Books generation 提供默认配置。

拆分：

```text
modules/agent-config/
  presentation/agent-config.controller.ts
  presentation/agent-config.dto.ts
  application/create-agent-config.use-case.ts
  application/update-agent-config.use-case.ts
  application/test-agent-config.use-case.ts
  application/get-default-agent-config.use-case.ts
  domain/agent-config.ts
  ports/agent-config.repository.ts
  ports/agent-connection-tester.ts
  adapters/prisma-agent-config.repository.ts
```

安全要求：

- API key 使用 AES-256-GCM 加密。
- response 永远不返回 raw key。
- audit log 不记录 raw key。
- Books generation 只接收 `agentConfigId` 或使用默认配置。

### Books

职责：

- 选择素材。
- 创建生成 job。
- 创建 workspace。
- 调用 Agent Runner。
- 验证 Agent 输出。
- 保存 book、pages、export artifacts。

拆分：

```text
modules/books/
  presentation/books.controller.ts
  presentation/books.dto.ts
  application/create-book-generation-job.use-case.ts
  application/get-book-job.use-case.ts
  application/export-book-pdf.use-case.ts
  application/export-book-long-image.use-case.ts
  domain/book.ts
  domain/book-generation-job.ts
  domain/book-output-policy.ts
  ports/book.repository.ts
  ports/asset-selection.repository.ts
  ports/agent-runner.ts
  ports/workspace-store.ts
  adapters/prisma-book.repository.ts
```

Books domain 不返回 HTTP status，不读取 env，不接收 raw API key。

### Web Companion

当前 Web Companion 需要拆成四个 bounded contexts：

```text
modules/web-companion/
  upload-session/
  upload-item/
  browse/
  share/
  pullback/
```

职责边界：

- `upload-session`: 创建会话、续期、关闭、token 校验。
- `upload-item`: 创建上传项、提交、重试、状态流转。
- `browse`: session-scoped 资产和作品浏览。
- `share`: 分享链接创建、校验、撤销、访问审计。
- `pullback`: 远端对象拉回本地资产库。

安全要求：

- Session token 优先使用 `Authorization: Bearer` 或专用 header。
- Public share token 可以在 URL 中出现，但 access log 的 IP/user-agent 必须来自 request，不信任 query 参数。
- 所有 limit/page/sort/filter 做 runtime validation。
- 错误响应不能泄露内部异常 message。

### Dataset

职责：

- child 管理。
- asset metadata 管理。
- import/export sample dataset。
- asset readiness。

Dataset repository 统一走 Prisma。文件内容和缩略图仍由 storage/workspace adapter 处理。

### Export

职责：

- PDF 导出。
- Long image 导出。
- 导出 artifact 记录。
- 导出路径安全校验。

Export 不应该混在 Books domain 内。

### Backup

职责：

- 生成备份 manifest。
- 导出 Prisma 数据。
- 打包本地文件资产。
- 恢复到新数据库。
- 校验版本兼容性。

Backup 是迁移后验证数据库结构合理性的关键模块。

## API 兼容策略

外部 HTTP API 尽量兼容当前 web/desktop 调用，内部允许全量重构。

策略：

- 先用 contract tests 锁住当前 endpoint、status code、response JSON。
- 每迁移一个 controller，必须先跑 contract tests。
- 如果必须破坏 API，新增 v2 endpoint，不直接改旧 endpoint。
- Desktop/Web 调用迁移完成后，再删除旧 endpoint。

## 错误模型

统一错误类型：

```text
ValidationError
UnauthorizedError
ForbiddenError
NotFoundError
ConflictError
DomainRuleViolationError
ExternalProviderError
InfrastructureError
```

Global exception filter 规则：

- 4xx 返回稳定 code 和用户可理解 message。
- 5xx 返回固定 `INTERNAL_ERROR`，不暴露内部 message。
- 日志包含 request id、module、operation、error cause。
- 日志必须脱敏 token、API key、signed URL。

## 安全基线

必须完成：

- API key 真实 AES-256-GCM 加密。
- share/session token 使用安全随机数并存 hash。
- token 比较使用 `crypto.timingSafeEqual`。
- CORS origin 在 release 模式必须显式配置。
- Helmet 保持启用；公开 web endpoint 按需启用 CSP。
- request body limit 使用 Express/Nest parser，而不是只检查 `content-length`。
- 所有 DTO 使用 Zod 或 class-validator 做 runtime validation。
- 禁止日志输出 raw token、raw API key、signed upload URL。

## 测试策略

### Unit Tests

覆盖 domain policy 和 use case：

- token 过期。
- share access limit。
- upload item 状态机。
- agent config default 切换。
- book output validation。

Unit tests 不连数据库，不启动 Nest app。

### Repository Contract Tests

每个 Prisma repository 必须有 contract tests，使用测试 PostgreSQL：

- create/find/update/delete。
- transaction rollback。
- unique constraint。
- relation include/select。
- JSON field round trip。

### Migration Smoke Tests

必须使用真实 PostgreSQL：

- 空库执行 `prisma migrate deploy`。
- Prisma Client 能查询所有核心模型。
- seed 能创建最小 child/asset/config。
- 重复启动不会重复建约束失败。

### HTTP Contract Tests

使用 Nest testing module：

- request validation。
- status code。
- response shape。
- auth/session/share token 行为。
- error code。

### E2E Release Gate

最终 release gate：

```bash
cd packages/backend && npm run build
cd packages/backend && npm test
cd packages/backend && npm run test:db
cd packages/web && npm test -- --run
cd packages/web && npm run build
cd packages/desktop && flutter analyze
cd packages/desktop && flutter test
```

## 迁移阶段

### Phase 0: Contract Freeze

目标：冻结当前外部行为，避免重构时无意识破坏 web/desktop。

交付：

- HTTP contract tests。
- 当前 endpoint 清单。
- 当前 response schema。
- 当前数据库实体清单。

验收：

- contract tests 能在旧实现上通过。

### Phase 1: Nest Runtime Standardization

目标：把 sidecar 变成标准 NestJS 工程。

交付：

- 标准 decorators。
- 标准 DI。
- 标准 build/start/dev/test 脚本。
- 移除手动 decorator 注册。

验收：

- `npm run build` 生成 dist。
- `npm test` 通过。
- sidecar 能从 `dist/main.js` 启动。

### Phase 2: Prisma Foundation

目标：建立 Prisma schema、Client、migration 和 transaction 基础。

交付：

- `prisma/schema.prisma`。
- 首个 Prisma migration。
- `PrismaService`。
- `TransactionManager`。
- repository base testing harness。

验收：

- 空库 migrate 成功。
- Prisma Client generate 成功。
- migration smoke test 通过。

### Phase 3: Security And Agent Config

目标：先迁最敏感模块，移除密钥安全缺陷。

交付：

- AES-256-GCM encryption。
- Prisma AgentConfig repository。
- Agent config use cases。
- Desktop 所需 API。
- provider 真实连接测试。

验收：

- 不再返回 raw API key。
- 不再使用 mock auth tag。
- Agent config tests 和 HTTP contract tests 通过。

### Phase 4: Web Companion

目标：拆分并迁移 upload/session/share/browse/pullback。

交付：

- UploadSession use cases。
- UploadItem use cases。
- Share use cases。
- Browse use cases。
- Prisma repositories。
- token/header 策略。

验收：

- Trusted upload 流程通过。
- Browse/share tests 通过。
- Public share access audit 使用真实 request metadata。

### Phase 5: Books, Agent Runner, Export

目标：迁移生成主路径并彻底移除 raw key 请求依赖。

交付：

- Book generation use case。
- OpenAI Agents SDK runner adapter。
- Workspace adapter。
- Export module。
- Prisma Book/Job/Artifact repositories。

验收：

- 创建生成 job 不接收 raw API key。
- 默认 AgentConfig 接入生成主路径。
- Book/export contract tests 通过。

### Phase 6: Dataset And Backup

目标：完成资产、child、backup/restore 的 ORM 化。

交付：

- Dataset repositories。
- Backup manifest。
- Backup export/import。
- Restore validation。

验收：

- sample dataset 可导入。
- backup 后可恢复到新库。
- restored app 能完成 browse/generate/export 最小流程。

### Phase 7: Legacy Removal And Release Gate

目标：删除旧 SQL 和旧 DB service 业务路径。

交付：

- 删除业务层 `pg.query`。
- 删除 `001_final_schema.sql` 运行路径。
- 删除旧 agent-config duplicate service。
- 更新 README 和 release docs。

验收：

- `rg "db\\.query|pg\\.Pool|001_final_schema|body\\.agentConfig" packages/backend/src` 没有业务路径命中。
- 全量 release gate 通过。

## 风险与缓解

### 数据库迁移风险

风险：Prisma schema 与现有 final schema 不一致，导致 fresh install 或升级失败。

缓解：

- 允许数据库重构，先以 fresh schema 正确为目标。
- 旧数据迁移作为独立 import 脚本处理。
- migration smoke test 使用真实 PostgreSQL。

### ORM 表达力风险

风险：pgvector 和特殊索引无法完全由 Prisma 表达。

缓解：

- 普通 CRUD 全部 Prisma。
- vector search 只允许一个 infra adapter 封装。
- adapter 有 contract tests。

### 行为回归风险

风险：大 service 拆分后遗漏隐含行为。

缓解：

- Phase 0 先冻结 HTTP contract。
- 每个模块先写 characterization tests。
- 每迁移一个 endpoint，旧 contract 必须继续通过。

### 启动和打包风险

风险：从 `node src/main.ts` 迁移到编译产物后，桌面 sidecar 打包脚本需要调整。

缓解：

- Phase 1 同步更新 dev/build/start。
- Release packaging 在 Phase 7 作为硬验收。

### 安全回归风险

风险：token、API key、signed URL 在重构中进入日志或响应。

缓解：

- 建立 redaction logger。
- 增加安全回归测试。
- Global exception filter 不返回内部 5xx message。

## 验收定义

迁移完成必须同时满足：

- backend 是标准 NestJS 工程。
- 数据库 schema 和 migrations 由 Prisma 管理。
- 业务模块没有直接 SQL。
- controller/application/domain/infrastructure 边界清楚。
- Agent config 是生成主路径唯一密钥来源。
- Web Companion 无 mock 数据主路径。
- Books generation 使用完整 Agent Runner adapter。
- Fresh PostgreSQL migrate 通过。
- Backup/restore 能恢复可运行数据集。
- backend/web/desktop 全量测试通过。

## 推荐执行方式

采用子 Agent 分阶段实施，但每阶段只允许不重叠文件集：

- Worker A: Nest runtime + common infrastructure。
- Worker B: Prisma schema + repositories。
- Worker C: Agent Config + security。
- Worker D: Web Companion。
- Worker E: Books + Export。
- Worker F: Dataset + Backup。

主控 Agent 每阶段负责：

- 合并结果。
- 跑 contract tests。
- 审查是否出现跨层依赖。
- 提交小步 Conventional Commit。

每阶段完成后立即提交，避免在长迁移中积累不可审查变更。
