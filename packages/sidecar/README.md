# KidMemory Sidecar

`packages/sidecar` 是 KidMemory 本地 Sidecar 服务，基于 NestJS、TypeScript、Prisma 和 PostgreSQL 构建。它运行在用户设备本地，为桌面端和 Web Companion 提供本地优先的数据集、素材、生成、导出、MCP 工具和同步能力。

### 主要职责

- 管理本地孩子档案、素材、标签、示例数据集和搜索索引状态。
- 提供 Web Companion 相关接口：局域网连接、直传会话、可信上传、分享浏览和 pullback。
- 执行绘本/作品生成、PDF/长图导出、封面图生成和导出产物同步。
- 封装 MCP 工具、技能运行时、诊断工具和素材/绘本相关自动化能力。
- 管理本地配置、readiness 检查、PostgreSQL/pgvector/Storage/OpenAI 等运行环境边界。

### 目录说明

- `src/modules/`：业务模块，包括 dataset、books、config、media、mcp、skills、storage、sync、web-companion。
- `src/infrastructure/`：数据库、配置、日志、HTTP、dataset state、验证和安全基础设施。
- `prisma/`：Sidecar 本地数据库 schema 和迁移。
- `tests/unit/`：领域逻辑和模块级单元测试。
- `tests/http/`、`tests/contracts/`：HTTP 路由、MCP、契约和集成风格测试。
- `tests/integration/`：需要更完整运行环境的集成测试。
- `examples-dataset/`：示例数据集元数据、素材和预期输出。
- `docs/`：Sidecar 相关运行和安全文档。

### 常用命令

```bash
npm --prefix packages/sidecar run dev
npm --prefix packages/sidecar run build
npm --prefix packages/sidecar run test
npm --prefix packages/sidecar run test:unit
npm --prefix packages/sidecar run test:integration
npm --prefix packages/sidecar run lint
npm --prefix packages/sidecar run type-check
npm --prefix packages/sidecar run gen:openapi
```

### 开发提示

- API DTO 和 OpenAPI 输出应与 `packages/protocol` 同步。
- 涉及数据库结构时，更新 `prisma/schema.prisma` 并补充迁移/测试。
- 本包是本地权限边界，涉及文件系统、OpenAI、Supabase、MCP 或导出路径时要明确校验输入和权限。
- 新增 endpoint 或工具时，优先补充 HTTP/contract/unit 测试。
