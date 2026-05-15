# KidMemory

<p align="center">
  <img src="docs/assets/first-bear-icon.png" alt="KidMemory Logo" width="120" />
</p>

<p align="center">
  <strong>把孩子成长素材沉淀成可搜索、可编辑、可导出的家庭作品集</strong><br/>
  Local-first memory workspace for families, built for privacy and long-term ownership.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS-111111" alt="Platform macOS" />
  <img src="https://img.shields.io/badge/Desktop-Flutter-02569B" alt="Desktop Flutter" />
  <img src="https://img.shields.io/badge/Sidecar-NestJS-E0234E" alt="Sidecar NestJS" />
  <img src="https://img.shields.io/badge/Database-PostgreSQL%20%2B%20pgvector-336791" alt="PostgreSQL pgvector" />
  <img src="https://img.shields.io/badge/Status-active-brightgreen" alt="Active project" />
</p>

## 🎯 产品简介

KidMemory 是一个本地优先（Local-first）的 AI 家庭记忆出版系统，专为保护隐私和长期拥有而设计。

**它不是另一个相册应用，也不是模板包装器。** KidMemory 旨在将孩子的画作、照片、手工、笔记和日常成长片段转化为可保存、可打印、可重访、可分享的记忆出版物。

### 核心价值

- **本地优先**：数据存储在你的设备上，完全可控
- **隐私保护**：不依赖云端服务，家庭数据安全可靠
- **AI 辅助**：智能整理和生成，但决策权始终在家长手中
- **长期保存**：结构化存储，支持备份恢复和数据迁移

### 主要功能

🔍 **智能搜索**：使用自然语言搜索家庭素材（"找有太阳的画"、"第一次海滩旅行的照片"）

📱 **多端协作**：桌面端管理 + 手机端扫码上传，无缝衔接

🤖 **AI 生成**：在受控环境中运行 AI Agent，生成高质量的家庭作品集

📚 **多格式导出**：支持 PDF、长图、可打印书籍等多种输出格式

🔒 **数据安全**：本地 PostgreSQL + pgvector，支持自托管部署

## 🧪 测试

### 快速测试（CI）

```bash
# 后端单元测试
cd packages/backend && npm run test:unit

# 前端测试
cd packages/web && npm test -- --run

# 桌面端测试（排除视觉回归）
cd packages/desktop && flutter test --exclude-tags=golden
```

### 完整测试（本地）

```bash
# 后端完整测试（需要 PostgreSQL）
cd packages/backend && npm test

# 运行所有测试
./scripts/run-all-tests.sh
```

详细测试指南请查看 [docs/testing.md](docs/testing.md)

## 🚀 快速开始

### 系统要求

- **操作系统**：macOS（推荐 Apple Silicon）
- **运行环境**：Node.js ≥22、Flutter、PostgreSQL + pgvector
- **包管理**：Homebrew

### 一键启动

```bash
# 1. 克隆项目
git clone https://github.com/xingbofeng/kidmemory.git
cd kidmemory

# 2. 配置环境变量
cp .env.example .env
# 编辑 .env 文件，配置数据库和 API 密钥

# 3. 启动数据库
brew install postgresql@16 pgvector
brew services start postgresql@16
createdb kidmemory
psql kidmemory -c "CREATE EXTENSION IF NOT EXISTS vector;"

# 4. 启动后端服务
cd packages/backend
npm install && npm run dev

# 5. 启动桌面应用（新终端窗口）
cd packages/desktop
flutter pub get && flutter run -d macos
```

### 环境配置详情

在 `.env` 文件中配置以下必需项：

```env
# 数据库配置
DATABASE_URL=postgresql://username:password@localhost:5432/kidmemory

# AI 服务配置
ANTHROPIC_API_KEY=your_claude_api_key
OPENAI_API_KEY=your_openai_api_key  # 可选

# 工作目录
AGENT_WORKSPACE_PATH=/path/to/workspace
EXPORT_PATH=/path/to/exports

# Web 伴侣配置（手机上传功能）
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
SUPABASE_STORAGE_BUCKET=kidmemory-assets
WEB_COMPANION_BASE_URL=http://localhost:3001
```

## 📱 产品演示

### 完整工作流程
![KidMemory Overview](docs/design/images/page-overview.png)

### 桌面端界面预览

| 环境设置 | 素材管理 | 生成导出 |
|---------|---------|---------|
| ![Desktop Setup](docs/design/images/desktop-setup.png) | ![Desktop Asset Library](docs/design/images/desktop-asset-library.png) | ![Desktop Generate Export](docs/design/images/desktop-generate-export.png) |

## 🏗️ 技术架构

### 系统架构

```
Flutter Desktop (macOS)
    ↓
NestJS Sidecar API
    ↓
PostgreSQL + pgvector
    ↓
Agent Workspace (隔离环境)
    ↓
HTML/PDF 渲染导出
```

### 核心设计原则

- **Agent 隔离**：AI Agent 在受控工作空间中运行，无法直接访问数据库或密钥
- **数据本地化**：所有家庭数据存储在本地，支持完全离线使用
- **结构化输出**：Agent 生成的内容必须通过 schema 验证
- **可恢复性**：完整的备份恢复机制，确保数据安全

### 项目结构

```
kidmemory/
├── packages/
│   ├── desktop/          # Flutter macOS 桌面应用
│   ├── backend/          # NestJS API 服务
│   └── web/              # Web 伴侣（手机端）
├── docs/                 # 产品文档和设计资源
├── templates/            # 书籍模板
├── examples/             # 示例数据集
└── scripts/              # 部署和验证脚本
```

## 🛠️ 开发指南

### 运行测试

```bash
# 后端测试
cd packages/backend && npm test

# 桌面端测试
cd packages/desktop && flutter test

# 架构测试
cd packages/backend && node --test tests/architecture/architecture.test.ts
```

### 开发模式

```bash
# 后端开发服务器
cd packages/backend && npm run dev

# 桌面端热重载
cd packages/desktop && flutter run -d macos

# Web 伴侣开发
cd packages/web && npm run dev
```

## 🚀 部署指南

### 本地部署

适合个人和家庭使用：

1. 按照“快速开始”完成环境配置
2. 确保 PostgreSQL 服务正常运行
3. 启动后端服务和桌面应用

### 自部署（服务器 + PM2 + GitHub Actions）

适合技术用户和小团队。

1. 服务器一次性准备

```bash
# 服务器上安装 Node/PM2/PostgreSQL，克隆仓库
git clone https://github.com/<your-org>/kidmemory.git
cd kidmemory/packages/backend
cp .env.example .env
# 编辑 .env
```

2. GitHub Secrets（用于自动部署）

- `HOST`：服务器 IP
- `USERNAME`：服务器登录用户
- `SSH_KEY`：部署私钥
- `PROJECT_PATH`：服务器项目路径（例如 `/home/ubuntu/kidmemory`）

3. 首次手动部署

```bash
cd /home/<user>/kidmemory/packages/backend
npm install
npm run build

cd ../web
if [ -f package.json ]; then npm install && npm run build; fi

cd ../..
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

4. 日常发布流程

- 推送到 `main` 后由 GitHub Actions 触发部署
- 服务器拉取代码并重启 PM2 进程
- 失败时查看 Actions 日志和 `pm2 logs`

5. 常见故障排查

```bash
pm2 status
pm2 logs kidmemory-backend
sudo systemctl status postgresql
psql -d kidmemory -c "SELECT * FROM pg_extension WHERE extname='vector';"
```

### 云端部署

支持主流云服务商：

- **数据库**：PostgreSQL + pgvector（Supabase / AWS RDS / Cloud SQL）
- **存储**：Supabase Storage、AWS S3、本地文件系统
- **计算**：Docker 或 VM

## 🧰 脚本清单（scripts/*）

- `scripts/check-sidecar-runtime-imports.mjs`：检查 sidecar 运行时可导入性（build 流程关键脚本）
- `scripts/verify-environment.mjs`：快速环境检查（Node/Flutter/Postgres/端口）
- `scripts/verify-asset-workflow.mjs`：资产导入→生成→导出链路验证
- `scripts/run-all-tests.sh`：聚合运行后端/桌面/web 测试（CI/本地）
- `scripts/pre-release-check.sh`：发布前综合检查（测试/安全/构建）
- `scripts/security-check.sh`：依赖漏洞与常见安全模式扫描
- `scripts/health-check.sh`：项目健康巡检（结构、依赖、测试状态）
- `scripts/setup-dev-env.sh`：开发机环境初始化
- `scripts/dashboard.sh`：本地状态仪表板输出

## 🗺️ 发展路线图

- ✅ 桌面 MVP 和基础功能
- ✅ Web 伴侣和分享功能
- ✅ 可信上传和安全分享
- 🚧 Agent 稳定性增强
- 🎯 完整开源稳定发布
- 🔮 多平台支持、高级 AI 功能

详细路线图请查看 [docs/product/roadmap.md](docs/product/roadmap.md)

## 📚 文档资源

### 用户文档
- [安装指南](docs/installation/fresh-setup-guide.md) - 详细的环境配置说明
- [用户手册](docs/user-guide.md) - 完整的功能使用指南
- [常见问题](docs/faq.md) - 疑难解答和最佳实践

### 开发文档
- [开发指南](CLAUDE.md) - Claude Code 工作指导
- [API 文档](docs/api/README.md) - 后端 API 接口说明
- [架构文档](docs/product/architecture.md) - 技术架构详解

### 发布文档
- [发布准备](docs/release-readiness.md) - 发布特性与验收状态
- [历史里程碑](docs/milestones/) - 功能阶段记录

## 🤝 参与贡献

我们欢迎社区贡献！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解：

- 如何报告问题和建议功能
- 代码贡献流程和规范
- 开发环境搭建指南

### 提交规范

遵循 Conventional Commits 格式：
```
type(scope): description

feat(desktop): 添加批量删除功能
fix(sidecar): 修复上传超时问题
docs(readme): 更新安装指南
```

## 📄 开源协议

本项目采用 [MIT License](LICENSE) 开源协议。

## 🔗 相关链接

- **官方网站**：[https://kidmemory.baby/](https://kidmemory.baby/)
- **GitHub 仓库**：[https://github.com/xingbofeng/kidmemory](https://github.com/xingbofeng/kidmemory)
- **问题反馈**：[GitHub Issues](https://github.com/xingbofeng/kidmemory/issues)
- **讨论社区**：[GitHub Discussions](https://github.com/xingbofeng/kidmemory/discussions)

---

<p align="center">
  <strong>用 AI 的力量，为家庭记忆赋予永恒的价值</strong><br/>
  Made with ❤️ for families who cherish memories
</p>
