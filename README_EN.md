# KidMemory

<p align="center">
  <img src="docs/assets/first-bear-icon.png" alt="KidMemory Logo" width="120" />
</p>

<p align="center">
  <strong>Transform your child's growth materials into searchable, editable, and exportable family collections</strong><br/>
  Local-first memory workspace for families, built for privacy and long-term ownership.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS-111111" alt="Platform macOS" />
  <img src="https://img.shields.io/badge/Desktop-Flutter-02569B" alt="Desktop Flutter" />
  <img src="https://img.shields.io/badge/Sidecar-NestJS-E0234E" alt="Sidecar NestJS" />
  <img src="https://img.shields.io/badge/Database-PostgreSQL%20%2B%20pgvector-336791" alt="PostgreSQL pgvector" />
  <img src="https://img.shields.io/badge/Status-active-brightgreen" alt="Active project" />
</p>

## 🎯 Product Overview

KidMemory is a local-first AI publishing system for family memory, designed for privacy protection and long-term ownership.

**It's not another photo album, and it's not a template wrapper.** KidMemory is designed to turn children's drawings, photos, crafts, notes, and everyday growth fragments into memory publications that can be kept, printed, revisited, and shared with family.

### Core Values

- **Local-first**: Data stored on your devices, completely under your control
- **Privacy-focused**: No dependency on cloud services, family data stays secure
- **AI-assisted**: Smart organization and generation, but decision-making stays with parents
- **Long-term preservation**: Structured storage with backup, recovery, and data migration support

### Key Features

🔍 **Smart Search**: Use natural language to search family materials ("find drawings with the sun", "photos from first beach trip")

📱 **Multi-device Collaboration**: Desktop management + mobile QR upload, seamless integration

🤖 **AI Generation**: Run AI Agents in controlled environments to generate high-quality family collections

📚 **Multi-format Export**: Support PDF, long images, printable books, and other output formats

🔒 **Data Security**: Local PostgreSQL + pgvector, supports self-hosted deployment

## 🚀 Quick Start

### System Requirements

- **Operating System**: macOS (Apple Silicon recommended)
- **Runtime**: Node.js ≥22, Flutter, PostgreSQL + pgvector
- **Package Manager**: Homebrew

### One-click Setup

```bash
# 1. Clone the project
git clone https://github.com/xingbofeng/kidmemory.git
cd kidmemory

# 2. Configure environment variables
cp .env.example .env
# Edit .env file to configure database and API keys

# 3. Start database
brew install postgresql@16 pgvector
brew services start postgresql@16
createdb kidmemory
psql kidmemory -c "CREATE EXTENSION IF NOT EXISTS vector;"

# 4. Start sidecar service
cd packages/sidecar
npm install && npm run dev

# 5. Start desktop app (new terminal window)
cd packages/desktop
flutter pub get && flutter run -d macos
```

### Environment Configuration

Configure the following required items in your `.env` file:

```env
# Database configuration
DATABASE_URL=postgresql://username:password@localhost:5432/kidmemory

# AI service configuration
ANTHROPIC_API_KEY=your_claude_api_key
OPENAI_API_KEY=your_openai_api_key  # Optional

# Working directories
AGENT_WORKSPACE_PATH=/path/to/workspace
EXPORT_PATH=/path/to/exports

# Web Companion configuration (mobile upload feature)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
SUPABASE_STORAGE_BUCKET=kidmemory-assets
WEB_COMPANION_BASE_URL=http://localhost:3001
```

## 📱 Product Demo

### Complete Workflow
![KidMemory Overview](docs/design/images/page-overview.png)

### Desktop Interface Preview

| Environment Setup | Asset Management | Generation & Export |
|------------------|------------------|-------------------|
| ![Desktop Setup](docs/design/images/desktop-setup.png) | ![Desktop Asset Library](docs/design/images/desktop-asset-library.png) | ![Desktop Generate Export](docs/design/images/desktop-generate-export.png) |

## 🏗️ Technical Architecture

### System Architecture

```
Flutter Desktop (macOS)
    ↓
NestJS Sidecar API
    ↓
PostgreSQL + pgvector
    ↓
Agent Workspace (Isolated Environment)
    ↓
HTML/PDF Rendering & Export
```

### Core Design Principles

- **Agent Isolation**: AI Agents run in controlled workspaces, cannot directly access database or secrets
- **Data Localization**: All family data stored locally, supports complete offline usage
- **Structured Output**: Agent-generated content must pass schema validation
- **Recoverability**: Complete backup and recovery mechanisms ensure data safety

### Project Structure

```
kidmemory/
├── packages/
│   ├── desktop/          # Flutter macOS desktop app
│   ├── sidecar/          # NestJS local orchestration API
│   ├── cloud-api/        # NestJS cloud collaboration API
│   ├── protocol/         # Shared types/OpenAPI/clients
│   └── web/              # Web Companion (mobile)
├── docs/                 # Product documentation and design assets
├── templates/            # Book templates
├── examples/             # Sample datasets
└── scripts/              # Deployment and validation scripts
```

## 🛠️ Development Guide

### Running Tests

```bash
# Sidecar tests
cd packages/sidecar && npm test

# Desktop tests
cd packages/desktop && flutter test

# Architecture tests
cd packages/sidecar && npx tsx --test tests/architecture/architecture.test.ts
```

### Development Mode

```bash
# Sidecar development server
cd packages/sidecar && npm run dev

# Desktop hot reload
cd packages/desktop && flutter run -d macos

# Web Companion development
cd packages/web && npm run dev
```

## 🚀 Deployment Guide

### Local Deployment

Suitable for personal and family use:

1. Complete environment configuration following the "Quick Start" section
2. Ensure PostgreSQL service is running properly
3. Start sidecar service and desktop application

### Self-hosted Deployment

Suitable for technical users and small teams:

```bash
# Use PM2 to manage sidecar service
npm install -g pm2
cd packages/cloud-api
pm2 start ecosystem.config.js

# Configure reverse proxy (Nginx)
# Refer to DEPLOYMENT_GUIDE.md
```

### Cloud Deployment

Supports major cloud service providers:

- **Database**: PostgreSQL + pgvector (supports Supabase, AWS RDS, Google Cloud SQL)
- **Storage**: Supabase Storage, AWS S3, local filesystem
- **Compute**: Supports Docker containerized deployment

For detailed deployment guide, please refer to:

- [CI/CD Guide](docs/deployment/ci-cd.md)
- [Tencent Cloud Deployment](docs/deployment/tencent-cloud.md)
- [Vercel Deployment](docs/deployment/vercel.md)

## 🗺️ Roadmap

- ✅ Desktop MVP and basic features
- ✅ Web Companion and sharing features
- ✅ Trusted upload and secure sharing
- 🚧 Agent reliability enhancements
- 🎯 Complete open-source stable release
- 🔮 Multi-platform support and advanced AI features

For detailed roadmap, see [docs/product/roadmap.md](docs/product/roadmap.md)

## 📚 Documentation

### User Documentation
- [Installation Guide](docs/installation/fresh-setup-guide.md) - Detailed environment configuration
- [User Manual](docs/user-guide.md) - Complete feature usage guide
- [FAQ](docs/faq.md) - Troubleshooting and best practices

### Developer Documentation
- [Development Guide](CLAUDE.md) - Claude Code working instructions
- [API Documentation](docs/api/README.md) - Sidecar & Cloud API interface documentation
- [Architecture Documentation](docs/product/architecture.md) - Technical architecture details

### Release Documentation
- [Release Readiness](docs/release-readiness.md) - Release features and acceptance status
- [Milestones](docs/milestones/) - Feature-stage records

## 🤝 Contributing

We welcome community contributions! Please check [CONTRIBUTING.md](CONTRIBUTING.md) for:

- How to report issues and suggest features
- Code contribution process and standards
- Development environment setup guide

### Commit Convention

Follow Conventional Commits format:
```
type(scope): description

feat(desktop): add bulk delete functionality
fix(sidecar): fix upload timeout issue
docs(readme): update installation guide
```

## 📄 License

This project is licensed under the [MIT License](LICENSE).

## 🔗 Links

- **Official Website**: [https://kidmemory.baby/](https://kidmemory.baby/)
- **GitHub Repository**: [https://github.com/xingbofeng/kidmemory](https://github.com/xingbofeng/kidmemory)
- **Issue Reporting**: [GitHub Issues](https://github.com/xingbofeng/kidmemory/issues)
- **Community Discussion**: [GitHub Discussions](https://github.com/xingbofeng/kidmemory/discussions)

---

<p align="center">
  <strong>Empowering family memories with AI, creating lasting value</strong><br/>
  Made with ❤️ for families who cherish memories
</p>
