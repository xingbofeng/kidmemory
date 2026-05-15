# KidMemory 总体技术架构

## 架构原则

- 本地优先：PostgreSQL 和本地文件系统是主数据源。
- 桌面优先：macOS Flutter 桌面端负责主要管理和生成体验。
- sidecar 边界清晰：Node.js sidecar 负责 API、数据库、对象存储、生成和导出。
- Web Companion 轻量化：手机网页只承担上传、浏览或分享，不替代桌面端。

## 应用结构

- `packages/desktop`：macOS Flutter 桌面端。
- `packages/backend`：Node.js sidecar API 与任务编排。
- `packages/web`：手机 Web Companion。

## 数据库

PostgreSQL 是主数据库。pgvector 用于语义搜索，缺失时不能阻断素材入库，只降级语义索引能力。

核心数据包括：

- children
- assets
- embedding jobs
- storage sync jobs
- export artifacts
- web companion upload sessions
- web companion upload items
- agent jobs

## 文件与对象存储

本地文件系统是最终素材归档位置。Supabase Storage 用于：

- 素材同步。
- 导出物分享。
- Web Companion 上传中转。

对象存储失败不能影响本地素材可用性。

## Web Companion 上传

0.8 之后的主链路采用后端可信上传：

1. 桌面端向 sidecar 创建上传会话。
2. sidecar 生成二维码 URL 和短效 token。
3. Web Companion 使用 token 创建上传项。
4. sidecar 分配 object key 和 signed upload target。
5. Web Companion 上传到 Supabase Storage。
6. Web Companion commit 上传项。
7. sidecar 回拉对象并导入本地素材库。
8. 桌面端轮询状态并刷新素材库。

## Agent 与导出

作品集生成使用隔离 workspace：

- input：孩子、素材和图片副本。
- templates：生成模板。
- rules：输出约束。
- output：book.json 和 book.html。

导出读取经过校验的输出，再生成 PDF 或长图。
