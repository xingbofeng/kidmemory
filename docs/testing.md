# 测试指南

本文档说明 KidMemory 项目的测试策略和如何运行不同类型的测试。

## 测试分层

KidMemory 采用分层测试策略，平衡了快速反馈和完整覆盖：

```
┌─────────────────────────────────────┐
│  CI 自动化测试（快速反馈）           │
│  - Lint & Type Check                │
│  - 单元测试                          │
│  - 架构测试                          │
│  运行时间：~2-3 分钟                 │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│  本地完整测试（提交前）              │
│  - 所有单元测试                      │
│  - 集成测试（需要数据库）            │
│  - 合约测试                          │
│  运行时间：~5-10 分钟                │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│  部署前测试（可选）                  │
│  - E2E 测试                          │
│  - 性能测试                          │
│  - 视觉回归测试                      │
│  运行时间：~15-30 分钟               │
└─────────────────────────────────────┘
```

## 后端测试（packages/backend）

### 快速测试（CI）

仅运行单元测试，不需要数据库或外部依赖：

```bash
cd packages/backend
npm run test:unit
```

### 完整测试（本地）

运行所有测试，包括集成测试和合约测试：

```bash
cd packages/backend

# 运行所有测试
npm test

# 或分别运行
npm run test:unit          # 单元测试
npm run test:integration   # 集成测试（需要数据库）
npm run test:contracts     # 合约测试（需要数据库）
```

### 构建检查

CI 运行的完整构建检查：

```bash
npm run build
# 包含：
# - ESLint 检查
# - 运行时导入检查
# - 单元测试
```

### 测试文件组织

```
tests/
├── unit/                    # 单元测试（CI 运行）
│   ├── asset-import.test.ts
│   ├── book-generation.test.ts
│   └── ...
├── contracts/               # 合约测试（需要数据库）
│   └── http-contracts.test.ts
├── http/                    # HTTP 路由测试（需要数据库）
│   └── router.smoke.test.ts
└── architecture/            # 架构测试（CI 运行）
    └── architecture.test.ts
```

## 前端测试（packages/web）

### 运行测试

```bash
cd packages/web

# 运行所有测试
npm test

# 运行特定测试文件
npm test -- src/pages/landing/LandingPage.test.tsx

# 监听模式（开发时）
npm test -- --watch
```

### Lint 和类型检查

```bash
npm run lint        # ESLint
npm run type-check  # TypeScript
```

### 测试覆盖率

```bash
npm test -- --coverage
```

## 桌面端测试（packages/desktop）

### 运行测试

```bash
cd packages/desktop

# 运行所有测试（排除视觉回归测试）
flutter test --exclude-tags=golden

# 运行特定测试文件
flutter test test/app_test.dart

# 运行架构测试
flutter test test/architecture_static_test.dart
```

### 静态分析

```bash
flutter analyze
```

### 视觉回归测试（仅 macOS）

视觉回归测试使用 macOS 特定字体（PingFang SC），仅在 macOS 上运行：

```bash
# 更新 golden 文件
flutter test --update-goldens test/visual_golden_test.dart

# 验证 golden 文件
flutter test test/visual_golden_test.dart
```

**注意**：CI 环境（Linux）会自动跳过视觉回归测试。

## 集成测试前置条件

运行集成测试前，需要配置本地环境：

### 1. 启动 PostgreSQL

```bash
# macOS (Homebrew)
brew services start postgresql@16

# Linux
sudo systemctl start postgresql

# Docker
docker run -d \
  --name kidmemory-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=kidmemory_test \
  -p 5432:5432 \
  pgvector/pgvector:pg16
```

### 2. 配置测试数据库

```bash
cd packages/backend

# 创建测试数据库
createdb kidmemory_test

# 运行迁移
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/kidmemory_test \
  npx prisma migrate deploy

# 安装 pgvector 扩展
psql -d kidmemory_test -c "CREATE EXTENSION IF NOT EXISTS vector;"
```

### 3. 配置环境变量

创建 `packages/backend/.env.test`：

```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/kidmemory_test
POSTGRES_HOST=127.0.0.1
POSTGRES_PORT=5432
POSTGRES_DATABASE=kidmemory_test
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres

# 测试用的临时密钥
AGENT_CONFIG_ENCRYPTION_KEY=test-key-for-development-only
OPENAI_API_KEY=sk-test-key
ANTHROPIC_API_KEY=sk-ant-test-key
```

## CI 配置

### GitHub Actions

CI 配置位于 `.github/workflows/ci.yml`，包含三个任务：

1. **sidecar build** - 后端 lint + 单元测试
2. **web companion** - 前端 lint + type-check + 测试 + 构建
3. **desktop flutter** - Flutter analyze + 测试（排除视觉回归）

### 为什么 CI 不运行集成测试？

集成测试需要：
- PostgreSQL + pgvector 服务
- 数据库迁移
- 环境变量配置
- 较长的运行时间

这些会显著增加 CI 复杂度和运行时间。我们选择：
- **CI**：快速反馈（2-3分钟），捕获大部分问题
- **本地**：完整测试，提交前运行
- **部署前**：完整验证，包括 E2E 测试

## 测试最佳实践

### 1. 提交前检查清单

```bash
# 后端
cd packages/backend
npm run lint
npm run test:unit
npm run test:integration  # 如果修改了数据库相关代码

# 前端
cd packages/web
npm run lint
npm run type-check
npm test -- --run

# 桌面端
cd packages/desktop
flutter analyze
flutter test --exclude-tags=golden
```

### 2. 编写测试的原则

- **单元测试**：测试单个函数/类，不依赖外部服务
- **集成测试**：测试多个组件协作，可以使用真实数据库
- **合约测试**：验证 API 契约，确保前后端兼容

### 3. Mock 和 Stub

- 单元测试中 mock 外部依赖
- 集成测试中使用真实依赖
- 避免过度 mock，导致测试脱离实际

### 4. 测试命名

```typescript
// 好的命名
test('should return 404 when child not found')
test('should validate email format')

// 不好的命名
test('test1')
test('it works')
```

## 故障排查

### 测试失败：数据库连接错误

```bash
# 检查 PostgreSQL 是否运行
pg_isready

# 检查连接字符串
echo $DATABASE_URL

# 重新运行迁移
npx prisma migrate deploy
```

### 测试失败：端口已被占用

```bash
# 查找占用端口的进程
lsof -i :3000

# 杀死进程
kill -9 <PID>
```

### Flutter 测试失败：依赖问题

```bash
# 清理并重新获取依赖
flutter clean
flutter pub get

# 重新生成代码
flutter pub run build_runner build --delete-conflicting-outputs
```

## 持续改进

测试策略会随项目发展而演进：

- **短期**：保持当前分层策略，快速迭代
- **中期**：添加 E2E 测试，覆盖关键用户流程
- **长期**：考虑性能测试、安全测试、可访问性测试

## 相关文档

- [开发指南](CLAUDE.md)
- [CI 配置](.github/workflows/ci.yml)
- [架构文档](docs/product/architecture.md)
