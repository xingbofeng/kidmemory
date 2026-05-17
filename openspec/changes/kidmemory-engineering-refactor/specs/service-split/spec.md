## ADDED Requirements

### Requirement: packages/backend 必须改名为 packages/sidecar

系统 SHALL 将 `packages/backend` 目录改名为 `packages/sidecar`，明确其本地执行层的职责。

#### Scenario: 目录改名
- **WHEN** 检查 packages 目录
- **THEN** 必须存在 packages/sidecar，不存在 packages/backend

#### Scenario: package.json name 更新
- **WHEN** 检查 packages/sidecar/package.json
- **THEN** name 必须为 @kidmemory/sidecar

#### Scenario: 所有引用路径更新
- **WHEN** 检查代码库
- **THEN** 所有 import 路径从 backend 改为 sidecar

#### Scenario: CI 配置更新
- **WHEN** 检查 .github/workflows
- **THEN** 所有 backend 引用改为 sidecar

### Requirement: 必须新建 packages/cloud-api

系统 SHALL 新建 `packages/cloud-api` 包，承担公网协作层职责。

#### Scenario: 创建 cloud-api 目录
- **WHEN** 检查 packages 目录
- **THEN** 必须存在 packages/cloud-api

#### Scenario: 复制 sidecar 工程结构
- **WHEN** 检查 cloud-api 结构
- **THEN** 必须与 sidecar 保持一致（src/infrastructure、src/modules、prisma 等）

#### Scenario: 独立的 package.json
- **WHEN** 检查 packages/cloud-api/package.json
- **THEN** name 必须为 @kidmemory/cloud-api

#### Scenario: 独立的 Prisma schema
- **WHEN** 检查 packages/cloud-api/prisma/schema.prisma
- **THEN** 必须有独立的 schema，不包含本地表

### Requirement: sidecar 和 cloud-api 必须使用同一技术栈

系统 SHALL 确保 sidecar 和 cloud-api 使用相同的技术栈和工程结构。

#### Scenario: 相同的 Node.js 版本
- **WHEN** 检查 package.json engines
- **THEN** 两者必须使用相同的 Node.js 版本（22+）

#### Scenario: 相同的 NestJS 版本
- **WHEN** 检查 package.json dependencies
- **THEN** 两者必须使用相同的 NestJS 版本

#### Scenario: 相同的 Prisma 版本
- **WHEN** 检查 package.json dependencies
- **THEN** 两者必须使用相同的 Prisma 版本

#### Scenario: 相同的工程结构
- **WHEN** 检查目录结构
- **THEN** src/infrastructure、src/modules、tests 等目录结构必须一致

### Requirement: 必须设计 sidecar local DB schema

系统 SHALL 设计 sidecar 的本地 DB schema，只包含本地执行相关的表。

#### Scenario: 保留本地表
- **WHEN** 检查 sidecar schema
- **THEN** 必须包含 children、assets、asset_embeddings、books、agent_jobs、agent_runs、agent_configs 等本地表

#### Scenario: 保留本地路径字段
- **WHEN** 检查 sidecar schema
- **THEN** 必须保留 localPath、imagePath、thumbnailPath、workspacePath、pdfPath 等字段

#### Scenario: 保留 embedding 字段
- **WHEN** 检查 sidecar schema
- **THEN** 必须保留 metadataEmbedding、embedding 等 vector 字段

#### Scenario: 保留 API key 字段
- **WHEN** 检查 sidecar schema
- **THEN** 必须保留 apiKeyEncrypted 等敏感字段

### Requirement: 必须设计 cloud-api cloud DB schema

系统 SHALL 设计 cloud-api 的云端 DB schema，只包含公网协作相关的表。

#### Scenario: 新增云端表
- **WHEN** 检查 cloud-api schema
- **THEN** 必须包含 users、families、family_members、devices、device_tokens、upload_sessions、upload_items、cloud_assets、cloud_artifacts、share_tokens、share_access_logs、cloud_jobs、job_events、artifact_sync_jobs 等云端表

#### Scenario: 禁止本地路径字段
- **WHEN** 检查 cloud-api schema
- **THEN** 不能包含 localPath、workspacePath 等本地路径字段

#### Scenario: 禁止 API key 字段
- **WHEN** 检查 cloud-api schema
- **THEN** 不能包含 apiKeyEncrypted 等敏感字段

#### Scenario: 禁止 embedding 字段
- **WHEN** 检查 cloud-api schema
- **THEN** 不能包含 metadataEmbedding、embedding 等 vector 字段

### Requirement: 必须标注现有 schema 中的表归属

系统 SHALL 标注现有 Prisma schema 中每个表的归属（local-only / cloud-only / shared concept）。

#### Scenario: 标注 local-only 表
- **WHEN** 检查现有 schema
- **THEN** 必须标注哪些表只属于 sidecar（如 agent_jobs、agent_runs）

#### Scenario: 标注 cloud-only 表
- **WHEN** 检查现有 schema
- **THEN** 必须标注哪些表只属于 cloud-api（如 upload_sessions、share_tokens）

#### Scenario: 标注 shared concept 表
- **WHEN** 检查现有 schema
- **THEN** 必须标注哪些表在两边都有，但字段不同（如 assets vs cloud_assets）

### Requirement: Agent 必须继续本地运行

系统 SHALL 确保 Agent 继续在 sidecar 本地运行，不迁移到 cloud-api。

#### Scenario: Agent 相关表在 sidecar
- **WHEN** 检查 sidecar schema
- **THEN** 必须包含 agent_jobs、agent_runs、agent_configs 表

#### Scenario: cloud-api 不包含 Agent 表
- **WHEN** 检查 cloud-api schema
- **THEN** 不能包含 agent_jobs、agent_runs、agent_configs 表

#### Scenario: Agent workspace 在本地
- **WHEN** Agent 运行时
- **THEN** workspace 必须在本地文件系统，不上传到云端

### Requirement: 必须更新架构文档

系统 SHALL 更新架构文档，清楚区分 sidecar 和 cloud-api 的职责。

#### Scenario: 更新架构图
- **WHEN** 检查 docs/product/architecture.md
- **THEN** 必须包含 sidecar 和 cloud-api 的架构图

#### Scenario: 说明职责边界
- **WHEN** 检查架构文档
- **THEN** 必须说明 sidecar（本地 DB、本地素材、本地 Agent、本地导出）和 cloud-api（上传、分享、设备同步、任务状态）的职责边界

#### Scenario: 说明数据流向
- **WHEN** 检查架构文档
- **THEN** 必须说明 sidecar 如何拉取 cloud-api 的上传数据、如何上报任务状态
