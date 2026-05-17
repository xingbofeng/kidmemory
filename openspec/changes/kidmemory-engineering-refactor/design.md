## Context

KidMemory 是一个 Local-First 的家庭成长记忆管理应用，当前架构包含：
- **Desktop（Flutter）**：macOS 桌面端，本地 UI
- **Backend（NestJS）**：本地 HTTP API + 任务编排，监听 4317 端口
- **Web（React）**：手机网页端，扫码上传、轻量浏览与分享
- **PostgreSQL + pgvector（sidecar）**：用户本地数据库，用户可感知，存储素材、embedding、书稿、Agent 状态等
- **PostgreSQL（cloud-api）**：云端数据库，存储上传会话、分享 token、设备注册、任务状态等；本地开发时连接 Supabase 托管 PG，生产部署时连接腾讯云轻量服务器内置 PG
- **Supabase Storage**：用于 Web 端 Direct Upload（手机直传文件到对象存储，需配置 RLS 防止未授权上传）

**当前问题：**
1. 协议不统一：错误码散落、响应格式混乱、Web/Desktop 手写解析
2. 接口格式不统一：部分返回 `{ ok, code, message }`，部分返回 `{ children }`，部分返回数组
3. 安全防护不完善：内存限流有泄漏、上传链路缺少幂等性、分享访问无限流
4. 工程规范缺失：手动装饰器注册、ESLint/tsconfig 分叉、缺少 OpenAPI
5. 服务职责混乱：backend 同时承担本地执行和公网协作

**架构审查发现：**
- 🔴 严重：Direct Upload 权限控制缺失、CORS 配置安全风险
- 🟠 中高：安全中间件内存泄漏、内存存储持久化缺失
- 🟡 中等：Web 端网络配置复杂、数据库连接池配置缺失、错误处理不完善

**约束条件：**
- Local-First 原则：Agent 继续本地做，敏感数据不上云
- 不引入 Redis：内存限流足够，后续需要时再升级
- 不引入 gRPC：REST API 足够，不引入 Proto；OpenAPI（code-first from NestJS）作为协议唯一真相源，生成 TS/Dart 客户端代码
- 破坏式变更：项目早期，客户端少，同仓库同步更新
- 8 周交付：分 4 个阶段，每个阶段可独立验收

**利益相关者：**
- 用户：家长，使用手机上传照片、桌面端管理素材、生成纪念书籍
- 开发者：需要清晰的协议、统一的 API 层、标准的工程规范
- 维护者：需要可观测性、可回滚、可扩展的架构

## Goals / Non-Goals

**Goals:**
1. 建立统一协议层（`packages/protocol`），作为唯一真相源
2. 所有 JSON API 统一返回 `code/msg/data` 格式
3. 修复内存限流泄漏，完善上传/分享防刷机制（内存方案）
4. Web 和 Desktop 统一 API 层，统一错误处理
5. NestJS 标准化，删除手动装饰器注册
6. 根目录统一 ESLint 和 TypeScript 配置
7. 从 NestJS 生成 OpenAPI，支持 TS/Dart client 生成
8. 全链路国际化支持（zh-CN / en-US）
9. 服务拆分：sidecar（本地）+ cloud-api（云端）
10. 完整 CI/CD 流程，包含 acceptance gate 和云部署

**Non-Goals:**
1. 不引入 Redis 或其他外部依赖（内存限流足够）
2. 不引入 gRPC（REST API 足够）
3. 不拆 agent-runtime（Agent 继续本地做）
4. 不做完整 SaaS 大后端（cloud-api 只做上传/分享/同步）
5. 不做多语言 SEO（只支持 zh-CN / en-US）
6. 不做正式 Apple 签名和公证（只做 dry-run）
7. 不做自动更新（后续再做）
8. 不改变业务功能逻辑（只做工程改造）

## Decisions

### 决策 1：协议层架构

**选择：** 新建 `packages/protocol` 作为独立包

**理由：**
- 协议是所有端的上游，必须独立维护
- 避免循环依赖（protocol 不能依赖 sidecar/web/desktop）
- 便于后续生成 OpenAPI client 和 Dart client

**依赖关系：**
```
packages/protocol
  ↓
packages/sidecar (引用 ApiCode / ApiResponse)
  ↓
packages/web (引用 ApiResponse / 生成的 TS client)
  ↓
packages/desktop (引用生成的 Dart client)
```

**替代方案：**
- ❌ 放在 sidecar 内部：会导致 web/desktop 依赖 sidecar
- ❌ 放在 monorepo 根目录：不符合 packages 结构

### 决策 2：接口统一迁移策略

**选择：** 破坏式变更（Breaking Change）- 直接切换到统一格式

**理由：**
- 项目处于早期阶段，客户端数量少（仅 Web 和 Desktop）
- 双格式支持增加维护成本和代码复杂度
- 一次性切换可以更快完成迁移
- 所有客户端代码在同一仓库，可以同步更新

**迁移步骤：**
1. **后端统一格式（1 天）**：
   - 新增 `ApiResponseInterceptor` - 所有成功响应包装为 `{ code, msg, data }`
   - 更新 `GlobalExceptionFilter` - 所有错误响应返回 `{ code, msg, data }`
   - 更新中间件错误响应格式
   - 创建 Contract Tests 验证格式

2. **客户端同步更新（1 天）**：
   - Web HTTP client 更新为统一格式解析
   - Desktop HTTP client 更新为统一格式解析
   - 更新所有 API 调用代码

3. **验证与测试（半天）**：
   - 运行所有测试
   - 手动验证关键流程
   - Contract tests 全覆盖

**替代方案：**
- ❌ 渐进式迁移（双格式支持）：维护成本高，代码混乱，延长迁移周期
- ✅ 破坏式变更：快速完成，代码简洁，适合早期项目

### 决策 3：限流方案

**选择：** 内存限流（修复泄漏 + 定时清理）

**理由：**
- 当前本地单机部署，内存方案足够
- 避免 PG 高频写入压力
- 简化实现，加快交付
- 后续需要时再升级 Redis

**实现方案：**
```typescript
class RateLimitMiddleware {
  private globalTimestamps: number[] = [];
  private ipTimestamps = new Map<string, number[]>();
  private cleanupTimer: NodeJS.Timeout;

  constructor() {
    // 每 60 秒清理一次过期数据
    this.cleanupTimer = setInterval(() => {
      this.cleanup(Date.now());
    }, 60_000);
  }

  private cleanup(now: number) {
    const cutoff = now - this.windowMs;
    
    // 清理全局时间戳
    this.globalTimestamps = this.globalTimestamps.filter(ts => ts > cutoff);
    
    // 清理 IP 时间戳
    for (const [ip, timestamps] of this.ipTimestamps.entries()) {
      const filtered = timestamps.filter(ts => ts > cutoff);
      if (filtered.length === 0) {
        this.ipTimestamps.delete(ip);
      } else {
        this.ipTimestamps.set(ip, filtered);
      }
    }
    
    // 限制最大数组长度（防御性编程）
    if (this.globalTimestamps.length > 10000) {
      this.globalTimestamps = this.globalTimestamps.slice(-5000);
    }
  }

  onModuleDestroy() {
    clearInterval(this.cleanupTimer);
  }
}
```

**替代方案：**
- ❌ PG 持久化：高频写入压力大，复杂度高
- ❌ Redis：引入新依赖，本地部署不需要
- ❌ 混合方案（内存 + 定时持久化）：复杂度高，收益低

### 决策 4：NestJS 标准化迁移顺序

**选择：** 按模块复杂度从低到高迁移

**迁移顺序：**
1. ConfigModule（最简单，1 个 Controller）
2. DatasetModule（中等，2 个 Controller）
3. BooksModule（中等，1 个 Controller）
4. WebCompanionModule（最复杂，3 个 Controller）

**理由：**
- 从简单模块开始，验证迁移方案
- 逐步积累经验，降低风险
- 每个模块迁移后立即测试

**替代方案：**
- ❌ 一次性全量迁移：风险太高
- ❌ 按功能迁移：模块边界不清晰

### 决策 5：服务拆分策略

**选择：** 先改名，再拆分，最后迁移

**拆分步骤：**
1. **阶段 1（2 天）**：改名
   - `packages/backend` → `packages/sidecar`
   - 更新所有引用路径
   - 更新 CI/CD 配置

2. **阶段 2（3 天）**：新建 cloud-api 空壳
   - 复制 sidecar 工程结构
   - 建立基础 Module（HealthModule / ConfigModule）
   - 配置独立的 Prisma schema

3. **阶段 3（1 周）**：迁移上传/分享能力
   - 迁移 UploadSession / UploadItem 相关逻辑
   - 迁移 ShareToken / ShareAccessLog 相关逻辑
   - Web 切换到 cloud-api

4. **阶段 4（2 天）**：设备同步和任务状态
   - 实现设备注册和心跳
   - 实现任务拉取和状态上报
   - sidecar 作为 worker 拉取云端任务

**理由：**
- 分阶段降低风险
- 每个阶段可独立验收
- 保持系统可用性

**替代方案：**
- ❌ 一次性拆分：风险太高，回滚困难
- ❌ 不拆分：后续扩展困难

### 决策 6：OpenAPI 生成策略

**选择：** 代码优先（Code-First），从 NestJS 生成 OpenAPI

**理由：**
- 当前已有大量 Controller 代码
- 代码是唯一真相源
- 避免手写 OpenAPI 和代码不一致

**实现方案：**

`packages/protocol/src/` 中的 TypeScript interface 是唯一人工维护的真相源，其他所有产物均由脚本自动生成。

```
packages/protocol/
  src/
    sidecar/
      upload.types.ts     ← 人工维护 TS interface（唯一真相源）
      books.types.ts
      config.types.ts
    cloud-api/
      upload.types.ts     ← 人工维护 TS interface
      share.types.ts
      device.types.ts
    common/
      api-response.ts     ← ApiResponse<T>、ApiCode
  openapi/
    sidecar.openapi.json  ← 脚本生成，不手写
    cloud-api.openapi.json
  generated/
    sidecar/
      dart/               ← 脚本生成，desktop 用
    cloud-api/
      ts/                 ← 脚本生成，web 用（备用，直接 import src 也可）
```

**各端消费方式：**
- **Web (React/TS)**：直接 `import type { Foo } from '@kidmemory/protocol'`，零构建步骤
- **sidecar (NestJS/TS)**：`implements` protocol 里的 interface，加 `@ApiProperty` 装饰器
- **Desktop (Flutter/Dart)**：使用脚本生成的 Dart 客户端

**生成脚本链路（全自动）：**
```
packages/protocol/src/sidecar/*.types.ts  (人工维护)
  ↓ sidecar class DTO implements interface + @ApiProperty
  ↓ npm run gen:openapi:sidecar
packages/protocol/openapi/sidecar.openapi.json
  ↓ npm run gen:dart:sidecar
packages/protocol/generated/sidecar/dart/   ← Desktop 用

packages/protocol/src/cloud-api/*.types.ts  (人工维护)
  ↓ cloud-api class DTO implements interface + @ApiProperty
  ↓ npm run gen:openapi:cloud-api
packages/protocol/openapi/cloud-api.openapi.json
  ↓ npm run gen:ts:cloud-api  (可选，直接 import src 也可以)
packages/protocol/generated/cloud-api/ts/   ← Web 用
```

**`packages/protocol/package.json` 出口：**
```json
{
  "exports": {
    ".": "./src/index.ts",
    "./sidecar": "./src/sidecar/index.ts",
    "./cloud-api": "./src/cloud-api/index.ts"
  }
}
```

**为何不引入 Proto：**
- Proto 的核心价值是 gRPC 传输 + 二进制序列化，不使用 gRPC 则优势不存在
- 同时维护 OpenAPI 和 Proto 两套类型会导致双倍维护成本和不一致风险
- OpenAPI + codegen 已能满足文档、代码生成、类型统一三个目标

**替代方案：**
- ❌ 契约优先（Contract-First）：需要手写 OpenAPI，维护成本高
- ❌ 不生成 OpenAPI：客户端继续手写 API 调用
- ❌ Proto（无 gRPC）：增加维护负担，与 OpenAPI 重复

### 决策 7：i18n 架构

**选择：** 前后端分离的 i18n 架构

**架构：**
```
packages/protocol/errors/
  messages.zh-CN.json  # 错误码文案（后端使用）
  messages.en-US.json

packages/web/src/i18n/
  zh-CN.json           # Web UI 文案
  en-US.json

packages/desktop/lib/l10n/
  app_zh.arb           # Desktop UI 文案
  app_en.arb
```

**理由：**
- 前后端文案分离，各自维护
- 后端只返回 code，前端根据 code 翻译（可选）
- 后端 msg 作为 fallback

**替代方案：**
- ❌ 后端返回多语言文案：增加响应体积，前端无法自定义
- ❌ 前端硬编码文案：无法国际化

### 决策 8：CI/CD 架构

**选择：** 多包并行 CI + acceptance gate

**CI 流程：**
```
Pull Request
  ├─ protocol-ci (并行)
  ├─ sidecar-ci (并行)
  ├─ cloud-api-ci (并行)
  ├─ web-ci (并行)
  └─ desktop-ci (并行)
  ↓
acceptance (串行，依赖所有 CI 通过)
  ├─ Contract tests
  ├─ Integration tests
  └─ Smoke tests
```

**CD 流程：**
```
push main (CI 全绿)
  ↓
deploy cloud-api to Tencent Cloud
  ↓
smoke test api.kidmemory.baby
  ↓
notify (成功/失败)
```

**理由：**
- 并行 CI 加快反馈速度
- acceptance gate 确保集成质量
- 自动部署减少人工操作

**替代方案：**
- ❌ 串行 CI：速度慢
- ❌ 无 acceptance gate：集成问题难以发现

## Risks / Trade-offs

### 风险 1：Epic 2 破坏性变更

**风险：** 接口统一可能导致客户端大面积失败

**影响：** 高

**缓解措施：**
- 同仓库同步更新所有客户端（Web + Desktop）
- Contract tests 全覆盖
- 后端和客户端同时验证
- 保留回滚方案（Git revert）

### 风险 2：内存限流状态丢失

**风险：** 服务重启后限流状态丢失，攻击者可通过重启绕过封禁

**影响：** 中

**缓解措施：**
- 本地部署场景可接受（用户自己控制重启）
- 添加内存监控，防止泄漏
- 后续需要时再升级 Redis

### 风险 3：团队带宽不足

**风险：** 9 个 Epic 工作量巨大（8 周），团队可能无法按时交付

**影响：** 高

**缓解措施：**
- 分阶段交付，每个阶段可独立验收
- 优先级排序，P0 问题优先修复
- 必要时延后 Epic 8/9（服务拆分和 CI/CD）

### 风险 4：业务功能停滞

**风险：** 8 周都在做技术债，用户看不到价值

**影响：** 中

**缓解措施：**
- 穿插业务功能开发
- 每个阶段交付可用功能
- 及时同步进度，管理预期

### 风险 5：服务拆分复杂度

**风险：** sidecar 和 cloud-api 拆分后，数据同步、状态一致性、跨服务调用复杂度增加

**影响：** 高

**缓解措施：**
- 分阶段拆分，每个阶段可独立验收
- 先改名，再拆分，最后迁移
- 保持 sidecar 和 cloud-api 工程结构一致
- 共享代码通过 protocol 包共享，不抽 server-kit

### 风险 6：OpenAPI 生成不稳定

**风险：** DTO 从 interface 迁移到 class 工作量大，生成的 client 可能不符合项目代码风格

**影响：** 中

**缓解措施：**
- 分模块迁移 DTO
- 生成的 client 先不接入生产路径，等稳定后再替换
- 保留手写 API 层作为 fallback

### 风险 7：i18n 文案维护成本

**风险：** 双语文案维护成本高，容易遗漏

**影响：** 低

**缓解措施：**
- CI 检查文案完整性（所有 key 都有翻译）
- 使用 i18n 工具辅助翻译
- 优先支持 zh-CN，en-US 可后续补充

## Migration Plan

### 阶段 0：安全修复（Week 0）

**目标：** 修复架构审查发现的 P0 问题

**步骤：**
1. 修复 Direct Upload 权限控制（2 天）
2. 修复 CORS 配置（4 小时）
3. 修复内存泄漏（2 小时）

**验收标准：**
- childId 不存在时返回 404
- 局域网 IP 可访问
- 内存定时清理正常工作

**回滚方案：**
- 保留旧代码一版，出问题立即回滚

### 阶段 1：基础设施（Week 1-2）

**目标：** 建立协议层、NestJS 标准化、i18n 骨架

**步骤：**
1. Epic 1：协议层（1 周）
2. Epic 5：NestJS 标准化（1 周，并行）
3. Epic 7：i18n 骨架（3 天，并行）

**验收标准：**
- `packages/protocol` 可独立 build
- sidecar 可引用 ApiCode
- Controller 使用标准装饰器
- Web/Desktop 可切换中英文

**回滚方案：**
- Epic 1：删除 protocol 包，恢复旧错误码
- Epic 5：按模块回滚，保留旧装饰器
- Epic 7：删除 i18n 配置，恢复硬编码文案

### 阶段 2：接口与安全（Week 3-4）

**目标：** 接口统一、内存限流、API 层统一

**步骤：**
1. Epic 2：接口统一（2 周，渐进式）
2. Epic 3：内存限流（3 天）
3. Epic 4：API 层（3 天）

**验收标准：**
- 所有 JSON API 返回 code/msg/data
- 内存限流无泄漏
- Web/Desktop 统一 API 层

**回滚方案：**
- Epic 2：feature flag 关闭新格式
- Epic 3：保留旧中间件作为 fallback
- Epic 4：保留旧 API 调用方式

### 阶段 3：生成与完善（Week 5-6）

**目标：** OpenAPI 生成、i18n 完善

**步骤：**
1. Epic 6：OpenAPI 生成（5 天）
2. Epic 7：i18n 完善（2 天）

**验收标准：**
- `/docs` 可打开
- OpenAPI 文件写入 protocol
- Web/Desktop 所有页面支持中英文

**回滚方案：**
- Epic 6：删除 Swagger 配置，保留手写 API
- Epic 7：删除 i18n 配置，恢复硬编码文案

### 阶段 4：服务拆分与部署（Week 7-8）

**目标：** 服务拆分、CI/CD 完善

**步骤：**
1. Epic 8：服务拆分（1 周）
2. Epic 9：CI/CD（1 周）

**验收标准：**
- sidecar 和 cloud-api 可独立启动
- PR 跑全部 CI
- main 自动部署 cloud-api

**回滚方案：**
- Epic 8：恢复 backend 包名，删除 cloud-api
- Epic 9：恢复旧 CI 配置

## Open Questions

1. **Epic 2 迁移时间表**：具体哪些模块先迁移？优先级如何排序？
   - 建议：Web 上传 → Web 分享 → Desktop 素材库 → Desktop 书稿生成

2. **Epic 3 内存限流上限**：`globalTimestamps` 数组最大长度设置为多少？
   - 建议：10000（超过后截断为 5000）

3. **Epic 6 OpenAPI client 生成工具**：使用哪个工具生成 TS/Dart client？
   - 建议：TS 使用 `openapi-typescript`，Dart 使用 `openapi-generator`

4. **Epic 8 服务拆分后的数据同步**：sidecar 如何拉取 cloud-api 的上传数据？
   - 建议：轮询 API（每 30 秒），后续可改为 WebSocket

5. **Epic 9 云部署的数据库**：cloud-api 使用哪个 PostgreSQL 实例？
   - 建议：腾讯云 PostgreSQL，独立实例

6. **团队带宽评估**：当前团队有几个人？能否按时完成 8 周工作量？
   - 需要确认：如果带宽不足，建议延后 Epic 8/9
