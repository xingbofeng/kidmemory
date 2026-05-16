## ADDED Requirements

### Requirement: 必须为所有包建立 CI 流程

系统 SHALL 为 protocol、sidecar、cloud-api、web、desktop 建立独立的 CI 流程。

#### Scenario: protocol CI
- **WHEN** PR 修改 packages/protocol
- **THEN** 必须运行 protocol CI（build、test、check）

#### Scenario: sidecar CI
- **WHEN** PR 修改 packages/sidecar
- **THEN** 必须运行 sidecar CI（build、test、lint、type-check）

#### Scenario: cloud-api CI
- **WHEN** PR 修改 packages/cloud-api
- **THEN** 必须运行 cloud-api CI（build、test、lint、type-check）

#### Scenario: web CI
- **WHEN** PR 修改 packages/web
- **THEN** 必须运行 web CI（build、test、lint、type-check）

#### Scenario: desktop CI
- **WHEN** PR 修改 packages/desktop
- **THEN** 必须运行 desktop CI（analyze、test）

#### Scenario: 并行执行 CI
- **WHEN** PR 修改多个包
- **THEN** 所有相关的 CI 必须并行执行

### Requirement: 必须建立 acceptance gate

系统 SHALL 建立 acceptance job，作为所有 CI 通过后的最终验收门禁。

#### Scenario: acceptance 依赖所有 CI
- **WHEN** 运行 acceptance job
- **THEN** 必须等待所有 CI 通过后才能执行

#### Scenario: Contract tests
- **WHEN** 运行 acceptance job
- **THEN** 必须执行 contract tests，验证所有 JSON API 返回 code/msg/data

#### Scenario: Integration tests
- **WHEN** 运行 acceptance job
- **THEN** 必须执行 integration tests，验证上传/分享/素材/书稿流程

#### Scenario: Smoke tests
- **WHEN** 运行 acceptance job
- **THEN** 必须执行 smoke tests，验证核心功能可用

### Requirement: 必须自动部署 cloud-api 到腾讯云

系统 SHALL 在 main 分支 CI 全绿后，自动部署 cloud-api 到腾讯云。

#### Scenario: main 分支触发部署
- **WHEN** push 到 main 分支且 CI 全绿
- **THEN** 自动触发 cloud-api 部署

#### Scenario: SSH 部署到腾讯云
- **WHEN** 部署 cloud-api
- **THEN** 通过 SSH 连接腾讯云服务器，执行部署脚本

#### Scenario: 使用 PM2 管理进程
- **WHEN** 部署 cloud-api
- **THEN** 使用 PM2 启动/重启 cloud-api 进程

#### Scenario: 执行 Prisma migration
- **WHEN** 部署 cloud-api
- **THEN** 自动执行 `prisma migrate deploy`

#### Scenario: 部署失败时通知
- **WHEN** 部署失败
- **THEN** GitHub Actions 标记为失败，发送通知

### Requirement: 必须配置 Cloudflare Tunnel

系统 SHALL 配置 Cloudflare Tunnel，将 cloud-api 暴露到公网。

#### Scenario: 配置 Tunnel
- **WHEN** 检查部署配置
- **THEN** 必须存在 cloudflared.example.yml 配置文件

#### Scenario: 域名映射
- **WHEN** 配置 Tunnel
- **THEN** 必须将 api.kidmemory.baby 映射到 cloud-api 的本地端口

#### Scenario: HTTPS 支持
- **WHEN** 访问 api.kidmemory.baby
- **THEN** 必须支持 HTTPS

### Requirement: 必须自动部署 Web 到 Vercel

系统 SHALL 配置 Vercel 自动部署 Web 端。

#### Scenario: Vercel 自动部署
- **WHEN** push 到 main 分支
- **THEN** Vercel 自动部署 packages/web

#### Scenario: 环境变量配置
- **WHEN** 部署 Web
- **THEN** 必须配置 VITE_API_BASE_URL 等环境变量

#### Scenario: 预览部署
- **WHEN** PR 创建
- **THEN** Vercel 自动创建预览部署

### Requirement: 必须执行部署后 smoke test

系统 SHALL 在部署完成后执行 smoke test，验证服务可用。

#### Scenario: 测试 health 端点
- **WHEN** 部署完成
- **THEN** 必须测试 GET api.kidmemory.baby/health 返回 200

#### Scenario: 测试 OpenAPI 端点
- **WHEN** 部署完成
- **THEN** 必须测试 GET api.kidmemory.baby/docs/openapi.json 返回 200

#### Scenario: 测试无效 token
- **WHEN** 部署完成
- **THEN** 必须测试 GET api.kidmemory.baby/share/invalid-token/access 返回 14001

#### Scenario: smoke test 失败时回滚
- **WHEN** smoke test 失败
- **THEN** 自动回滚到上一个版本

### Requirement: 必须支持 desktop tag release dry-run

系统 SHALL 支持通过 tag 触发 desktop 的 release dry-run，产出 macOS artifact。

#### Scenario: tag 触发 release
- **WHEN** 创建 v*-alpha tag（如 v0.1.0-alpha.1）
- **THEN** 自动触发 desktop release workflow

#### Scenario: 构建 macOS artifact
- **WHEN** 运行 release workflow
- **THEN** 执行 `flutter build macos`，产出 .app

#### Scenario: 打包 sidecar dist
- **WHEN** 构建 macOS artifact
- **THEN** 将 sidecar 的 dist 目录打包进 .app/Contents/Resources

#### Scenario: 上传 artifact
- **WHEN** 构建完成
- **THEN** 上传 .app.zip 到 GitHub Actions artifact

#### Scenario: 创建 prerelease
- **WHEN** 构建完成
- **THEN** 创建 GitHub prerelease，附带 .app.zip

### Requirement: 不做正式签名和公证

系统 SHALL 明确 desktop release 只做 dry-run，不做正式 Apple 签名和公证。

#### Scenario: 不执行 codesign
- **WHEN** 构建 macOS artifact
- **THEN** 不执行 codesign 命令

#### Scenario: 不执行 notarization
- **WHEN** 构建 macOS artifact
- **THEN** 不执行 xcrun notarytool 命令

#### Scenario: 不创建 DMG
- **WHEN** 构建 macOS artifact
- **THEN** 只产出 .app.zip，不创建 DMG

#### Scenario: 标记为 prerelease
- **WHEN** 创建 GitHub release
- **THEN** 必须标记为 prerelease，说明未签名

### Requirement: 必须有 CI 配置文档

系统 SHALL 提供 CI/CD 配置文档，说明如何配置和使用。

#### Scenario: 文档说明 CI 流程
- **WHEN** 检查 docs/deployment/
- **THEN** 必须存在 ci-cd.md 文档，说明 CI 流程

#### Scenario: 文档说明部署流程
- **WHEN** 检查 docs/deployment/
- **THEN** 必须存在 tencent-cloud.md 和 vercel.md 文档

#### Scenario: 文档说明环境变量
- **WHEN** 检查文档
- **THEN** 必须说明所有需要配置的环境变量

#### Scenario: 文档说明回滚方案
- **WHEN** 检查文档
- **THEN** 必须说明如何回滚部署

### Requirement: 必须保持 sidecar 不部署到云端

系统 SHALL 确保 sidecar 不部署到云端，只随 Desktop 打包。

#### Scenario: sidecar 不在 CI/CD 中部署
- **WHEN** 检查 CI/CD 配置
- **THEN** sidecar 只有 CI，没有 CD

#### Scenario: sidecar 随 Desktop 打包
- **WHEN** 构建 Desktop artifact
- **THEN** sidecar 的 dist 目录打包进 .app

#### Scenario: 4317 端口不暴露公网
- **WHEN** 部署 cloud-api
- **THEN** 4317 端口不暴露到公网，只有 cloud-api 端口暴露
