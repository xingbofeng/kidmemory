## ADDED Requirements

### Requirement: 必须设计本地 DB 和云端 DB 的表结构拆分

系统 SHALL 明确区分本地 DB（sidecar）和云端 DB（cloud-api）的表结构，避免职责混乱。

#### Scenario: 本地 DB 包含本地执行表
- **WHEN** 检查 sidecar schema
- **THEN** 必须包含 children、assets、asset_embeddings、embedding_jobs、candidate_pool_items、books、book_pages、agent_jobs、agent_runs、agent_configs、export_artifacts、backup_snapshots

#### Scenario: 云端 DB 包含公网协作表
- **WHEN** 检查 cloud-api schema
- **THEN** 必须包含 users、families、family_members、devices、device_tokens、upload_sessions、upload_items、cloud_assets、cloud_artifacts、share_tokens、share_access_logs、cloud_jobs、job_events、artifact_sync_jobs

#### Scenario: 本地 DB 保留敏感字段
- **WHEN** 检查 sidecar schema
- **THEN** 必须保留 localPath、imagePath、thumbnailPath、workspacePath、pdfPath、apiKeyEncrypted、embedding 等字段

#### Scenario: 云端 DB 禁止敏感字段
- **WHEN** 检查 cloud-api schema
- **THEN** 不能包含 localPath、workspacePath、apiKeyEncrypted、embedding 等字段

#### Scenario: 云端 DB 只保存 metadata
- **WHEN** 检查 cloud-api schema
- **THEN** cloud_assets 只保存 metadata（title、description、tags、contentType、sizeBytes），不保存本地路径

### Requirement: 必须设计数据同步机制

系统 SHALL 设计 sidecar 和 cloud-api 之间的数据同步机制。

#### Scenario: sidecar 拉取上传数据
- **WHEN** sidecar 定期轮询 cloud-api
- **THEN** 拉取新的 upload_items，下载文件到本地，创建 assets

#### Scenario: sidecar 上报任务状态
- **WHEN** sidecar 完成 Agent 任务
- **THEN** 上报任务状态到 cloud-api 的 cloud_jobs 表

#### Scenario: sidecar 同步 artifact metadata
- **WHEN** sidecar 生成 PDF 或长图
- **THEN** 上传 artifact metadata 到 cloud-api 的 cloud_artifacts 表

#### Scenario: 设备注册和心跳
- **WHEN** sidecar 启动
- **THEN** 注册设备到 cloud-api，定期发送心跳

### Requirement: 必须设计表结构迁移计划

系统 SHALL 设计从当前单一 DB 到拆分 DB 的迁移计划。

#### Scenario: 第一阶段：标注表归属
- **WHEN** 迁移开始
- **THEN** 在现有 schema 中标注每个表的归属（local-only / cloud-only / shared）

#### Scenario: 第二阶段：创建 cloud-api schema
- **WHEN** 标注完成
- **THEN** 创建 cloud-api 的独立 schema，只包含 cloud-only 表

#### Scenario: 第三阶段：迁移数据
- **WHEN** cloud-api schema 创建完成
- **THEN** 将 upload_sessions、share_tokens 等数据迁移到云端 DB

#### Scenario: 第四阶段：删除 sidecar 中的云端表
- **WHEN** 数据迁移完成
- **THEN** 从 sidecar schema 中删除 upload_sessions、share_tokens 等云端表

### Requirement: 必须保持数据一致性

系统 SHALL 确保拆分后的数据在 sidecar 和 cloud-api 之间保持一致。

#### Scenario: 上传数据一致性
- **WHEN** 用户上传文件到 cloud-api
- **THEN** sidecar 拉取后创建的 asset 必须与 cloud_assets 的 metadata 一致

#### Scenario: 分享数据一致性
- **WHEN** sidecar 创建分享链接
- **THEN** share_tokens 必须同步到 cloud-api

#### Scenario: 任务状态一致性
- **WHEN** sidecar 执行 Agent 任务
- **THEN** 任务状态必须实时同步到 cloud-api

### Requirement: 必须设计回滚方案

系统 SHALL 设计表结构拆分的回滚方案。

#### Scenario: 保留旧 schema 一版
- **WHEN** 拆分前
- **THEN** 备份当前完整的 schema

#### Scenario: 支持回滚到单一 DB
- **WHEN** 拆分后出现问题
- **THEN** 可以回滚到单一 DB 模式

#### Scenario: 数据迁移可逆
- **WHEN** 需要回滚
- **THEN** 可以将云端数据迁移回本地 DB

### Requirement: 必须有迁移测试

系统 SHALL 编写迁移测试，验证表结构拆分的正确性。

#### Scenario: 测试数据迁移
- **WHEN** 运行迁移脚本
- **THEN** 所有数据必须正确迁移到目标 DB

#### Scenario: 测试数据一致性
- **WHEN** 迁移完成
- **THEN** sidecar 和 cloud-api 的数据必须一致

#### Scenario: 测试回滚
- **WHEN** 执行回滚
- **THEN** 数据必须正确恢复到迁移前状态
