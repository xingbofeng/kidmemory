# KidMemory Epic 10：Sidecar MCP Tools + packages/skills + File-based Trace Logs + Free Image Provider

> 本文档整理今晚新增的完整需求与最终架构决策。  
> 目标是把 KidMemory 从“本地素材与书稿工具”推进到“隐藏式 Agent 创作工作台”，但不重做页面、不暴露复杂配置、不把产品改成纯聊天窗。

---

## 目录

1. [总览](#1-总览)
2. [背景](#2-背景)
3. [目标](#3-目标)
4. [用户故事](#4-用户故事)
5. [范围](#5-范围)
6. [不做项](#6-不做项)
7. [设计与交互](#7-设计与交互)
8. [设计图](#8-设计图)
9. [架构方案](#9-架构方案)
10. [Skill 目录与运行时设计](#10-skill-目录与运行时设计)
11. [MCP 方案：使用 @rekog/mcp-nest](#11-mcp-方案使用-rekogmcp-nest)
12. [日志与 Trace：文件日志方案](#12-日志与-trace文件日志方案)
13. [免费生图 Provider：Pollinations](#13-免费生图-providerpollinations)
14. [picturebook-maker 接入方案](#14-picturebook-maker-接入方案)
15. [Hyperframes 接入方案](#15-hyperframes-接入方案)
16. [任务拆单](#16-任务拆单)
17. [验收标准](#17-验收标准)
18. [工程结构](#18-工程结构)
19. [配置项](#19-配置项)
20. [风险与回滚](#20-风险与回滚)
21. [最终交付物](#21-最终交付物)
22. [参考调研结论](#22-参考调研结论)

---

# 1. 总览

## 1.1 最终一句话

KidMemory 新增一个隐藏式 Agent 能力层：

```txt
基于现有页面，不改设置页、不暴露 Skill / MCP / Provider 概念；
一期先把 sidecar 现有能力通过 @rekog/mcp-nest 做成 MCP tools；
Skill 内容统一放 packages/skills；
picturebook-maker 负责绘本流程；
Hyperframes 直接引入它自己的 Skill 全家桶；
Pollinations 作为免费生图入口；
desktop / sidecar 写文件日志，并用 traceId 串起全链路。
```

## 1.2 本 Epic 名称

```txt
Epic 10：Sidecar MCP Tools + packages/skills + File-based Trace Logs + Free Image Provider
```

## 1.3 本 Epic 的四个核心方向

```txt
1. Sidecar MCP Tools
   把 sidecar 现有素材、书稿、导出、诊断能力变成受控 MCP tools。

2. packages/skills
   Skill 内容从 sidecar 源码中独立出来，统一放 packages/skills。

3. File-based Trace Logs
   先不落库；desktop 和 sidecar 各自写日志目录，用 traceId 串联。

4. Free Image Provider
   使用 Pollinations 作为免费封面/预览生图入口，Cloudflare Workers AI 作为备选。
```

---

# 2. 背景

## 2.1 当前产品基础

KidMemory 当前已经具备：

```txt
- 本地 sidecar
- 本地素材库
- 孩子档案
- 素材导入
- 书稿生成
- PDF / 长图导出
- Web 上传 / 分享能力
- 本地 Agent 雏形
```

上午已经在推进的工程治理包括：

```txt
- 协议层
- code/msg/data
- NestJS 标准化
- CI/CD
- cloud-api / sidecar 拆分
- PG 防刷
```

今晚新增讨论集中在：

```txt
- 如何让产品更像 Agent 产品
- 是否要做 Skill 系统
- 如何接入 MCP
- Skill 应该放哪里
- 如何复用 NestJS 能力
- Hyperframes 怎么接
- picturebook-maker 怎么接
- 免费生图 API 怎么接
- 简单日志 / trace 怎么做
- 设计和交互是否需要变化
```

## 2.2 收敛后的判断

不做完整 Skill 平台，不做大聊天窗，不改设置页。

正确方向是：

```txt
现有页面
  +
隐藏式 Agent 能力层
  +
sidecar MCP tools
  +
packages/skills
  +
文件日志 trace
  +
免费生图 PoC
```

---

# 3. 目标

## 3.1 产品目标

让用户能在现有页面里自然触发智能能力：

```txt
- 帮我挑素材
- 生成儿童绘本
- 生成成长纪念册
- 生成回忆录视频
- 生成封面图
- 导出 PDF / 长图 / MP4
```

但用户不需要理解：

```txt
- MCP
- Skill
- Provider
- Pollinations
- Hyperframes
- pgvector
- picturebook-maker
```

用户看到的是：

```txt
智能操作入口
任务进度
确认弹窗
结果卡片
错误提示
requestId
```

## 3.2 工程目标

一期完成：

```txt
1. 使用 @rekog/mcp-nest 暴露 sidecar MCP tools
2. Skill 内容统一放 packages/skills
3. sidecar 只做 Skill loader / runtime / workspace bridge
4. picturebook-maker 作为绘本 Skill 接入
5. Hyperframes Skill 直接引入
6. Pollinations 生图脚本 / provider 接入
7. desktop / sidecar 文件日志
8. traceId 串联 desktop → sidecar → MCP → skill / provider
9. 现有页面轻量交互增强
```

## 3.3 架构目标

形成如下链路：

```txt
用户在现有页面点击智能动作
  ↓
Desktop 生成 traceId
  ↓
调用 sidecar
  ↓
sidecar 通过 @rekog/mcp-nest 暴露/调用 tools
  ↓
Hidden Skill 使用 sidecar tools
  ↓
picturebook-maker / Hyperframes / Pollinations
  ↓
生成本地产物
  ↓
UI 展示进度与结果卡片
  ↓
desktop / sidecar 日志通过 traceId 可串联
```

---

# 4. 用户故事

## 4.1 家长：智能生成绘本

作为家长，  
我希望在现有“生成 / 导出”页面点击“生成儿童绘本”，  
系统能自动从孩子素材里挑选合适内容、生成故事、生成封面并导出 PDF，  
以便我快速得到一本可以保存或分享的孩子绘本。

## 4.2 家长：明确知道外部调用边界

作为家长，  
我希望系统在调用免费生图服务前告诉我只会发送文字描述、不会上传孩子照片，  
以便我知道隐私边界并放心继续。

## 4.3 家长：看到 Agent 进度

作为家长，  
我希望生成过程中能看到：

```txt
已选择素材
已生成故事结构
正在生成封面图
等待导出 PDF
```

而不是只看到一个 loading，  
以便我知道 Agent 正在做什么。

## 4.4 家长：轻量调整

作为家长，  
我希望生成结果出来后，可以点击“重新生成封面”“导出 PDF”“生成分享链接”，  
以便继续完成作品，而不是进入复杂编辑器。

## 4.5 开发者：复用 sidecar 能力

作为开发者，  
我希望不用重写业务逻辑，直接把现有 NestJS services 包装成 MCP tools，  
以便 Agent 能调用现有素材、书稿、导出能力。

## 4.6 维护者：日志可追踪

作为维护者，  
我希望 desktop、sidecar、MCP tool、Skill、Provider 的日志能通过 traceId 串起来，  
以便用户反馈“生成失败”时能定位是哪一步失败。

## 4.7 开发者：安全边界

作为开发者，  
我希望 Agent 只能调用受控业务工具，不能执行任意 SQL / shell / 文件系统操作，  
以便保证 sidecar 的本地隐私和安全边界。

---

# 5. 范围

## 5.1 本期包含

### A. MCP tools

使用 `@rekog/mcp-nest`，把 sidecar 现有能力包装成 MCP tools。

包含：

```txt
- Asset MCP tools
- Book MCP tools
- Export MCP tools
- Config MCP tools
- Diagnostic MCP tools
- Image MCP tools
- Hyperframes MCP tool
```

### B. packages/skills

新增：

```txt
packages/skills
```

用于维护：

```txt
- picturebook-maker
- hyperframes skill 引入信息
- Skill 校验脚本
- Skill 打包脚本
- Pollinations 扩展脚本
```

### C. File-based logs

新增：

```txt
- desktop log directory
- sidecar log directory
- JSONL 日志
- traceId / requestId
- cleanup worker
- diagnostic zip 导出预留
```

### D. picturebook-maker

引入 picturebook-maker，并加入 KidMemory 约束：

```txt
- 不允许任意 shell
- 不允许上传孩子照片给免费 API
- 使用 KidMemory sidecar tools
- 生图通过 Pollinations 扩展脚本
```

### E. Hyperframes

直接引入 Hyperframes Skill 全家桶：

```txt
- 不重写内部 15 个 Skill
- 不枚举内部 registry
- sidecar 只提供 render_hyperframes_video
```

### F. 免费生图

引入：

```txt
- PollinationsImageProvider
- CloudflareWorkersAIImageProvider 预留
- OpenAICompatibleImageProvider 预留
```

一期默认：

```txt
Pollinations
```

### G. 现有页面轻量增强

包括：

```txt
- 素材库：帮我挑素材
- 生成导出页：智能生成入口
- 生成导出页：Agent 任务进度
- 生成导出页：确认调用免费生图弹窗
- 生成导出页：结果卡片
- 错误提示：展示 requestId
```

---

# 6. 不做项

本期明确不做：

```txt
1. 不做完整 Skill 平台
2. 不做 Skill marketplace
3. 不做用户可见 Skill 管理
4. 不改设置页
5. 不新增 Provider 配置页
6. 不做纯聊天窗产品
7. 不重做现有页面结构
8. 不自研 MCP 协议层
9. 不让 Agent 直接执行 SQL
10. 不让 Agent 直接执行 shell
11. 不让 Agent 读取任意本地文件
12. 不做完整 Artifact Manager
13. 不做日志入库
14. 不做 event_logs / audit_logs 表
15. 不做 OpenTelemetry / Jaeger / Tempo
16. 不做本地 FLUX / Z-Image
17. 不做逐页插图批量生成
18. 不做角色一致性系统
19. 不上传孩子照片给 Pollinations
20. 不完整重写 Hyperframes 内部 Skill
21. 不把 Bun 作为正式 sidecar runtime
22. 不把签名 / notarization 放进本 Epic
```

---

# 7. 设计与交互

## 7.1 总原则

```txt
Agent 是现有页面里的增强层，不是新产品。
```

## 7.2 页面改动原则

```txt
现有导航不变
设置页不变
分享页基本不变
生成 / 导出页轻量增强
素材库页轻量增强
```

## 7.3 素材库页面

新增按钮：

```txt
帮我挑素材
```

点击后给出目标：

```txt
适合做绘本
适合做成长纪念册
适合做回忆录视频
```

结果展示：

```txt
Agent 已为你挑选 12 张素材

[确认使用] [重新挑选] [手动调整]
```

## 7.4 生成 / 导出页面

新增三类智能动作：

```txt
生成儿童绘本
生成成长纪念册
生成回忆录视频
```

新增任务进度：

```txt
✓ 已选择 12 张素材
✓ 已生成故事结构
→ 正在生成封面图
○ 等待导出 PDF
```

新增结果卡片：

```txt
《春天的小冒险》
8 页 · 温暖童趣 · 已生成封面 · PDF 待导出

[预览绘本] [导出 PDF] [生成分享链接]
```

## 7.5 免费生图确认

调用 Pollinations 前展示：

```txt
将使用免费生图服务生成封面图。
不会上传孩子照片，只会发送文字描述。

[继续生成] [跳过封面]
```

## 7.6 错误交互

错误提示不能只写“生成失败”。

示例：

```txt
封面图生成失败

原因：免费生图服务暂时不可用。
你可以：
[重试] [跳过封面继续导出] [查看日志]

Request ID: req_xxx
```

## 7.7 技术词不外露

用户界面不显示：

```txt
MCP
Skill Registry
@rekog/mcp-nest
Pollinations provider
Hyperframes provider
pgvector
```

可以显示：

```txt
免费生图服务
正在生成视频
正在挑选素材
正在导出 PDF
```

---

# 8. 设计图

下图是本 Epic 对现有 KidMemory 页面进行轻量 Agent 增强的设计示意。  
它保持当前 KidMemory 的暖色背景、圆角白卡片、绿色主按钮、柔和阴影和儿童友好风格。

![KidMemory Agent UI Design](./assets/kidmemory_app_dashboard_mockup_design.png)

设计重点：

```txt
1. 左侧导航保持现有结构
2. 生成 / 导出页增加智能动作入口
3. 中间增加 Agent 任务进度卡
4. 下方展示结果卡片
5. 右侧展示确认调用免费生图、素材智能挑选、Lite Trace 日志
6. 设置页不改
7. 用户只看到智能操作、进度、确认和结果
```

---

# 9. 架构方案

## 9.1 总体架构

```txt
Desktop UI
  ↓ traceId
Sidecar HTTP API
  ↓
Sidecar MCP Module (@rekog/mcp-nest)
  ↓
MCP Tool Adapters
  ↓
Existing NestJS Services
  ↓
PG / pgvector / local files / export / image provider / Hyperframes
```

## 9.2 Skill 运行链路

```txt
packages/skills
  ↓
sidecar SkillLoader
  ↓
Agent workspace
  ↓
picturebook-maker / hyperframes
  ↓
MCP tools
  ↓
sidecar services
```

## 9.3 日志链路

```txt
Desktop action
  ↓ traceId
Desktop log
  ↓ X-KidMemory-Trace-Id
Sidecar request
  ↓
Sidecar log
  ↓
MCP tool log
  ↓
Skill / Provider log
```

---

# 10. Skill 目录与运行时设计

## 10.1 Skill 内容放哪里？

最终结论：

```txt
Skill 内容放 packages/skills
sidecar 只做 Skill runtime
```

## 10.2 为什么不放 sidecar 里？

```txt
1. Skill 是产品内容包，不是 sidecar 业务源码
2. picturebook-maker / Hyperframes 是外部 Skill，不适合塞进 sidecar 源码
3. 后续打包、校验、安装、同步更方便
4. 后续也可以被外部 Agent / MCP 独立使用
```

## 10.3 packages/skills 结构

```txt
packages/
  skills/
    package.json
    skill-registry.json

    skills/
      picturebook-maker/
        SKILL.md
        README.md
        templates/
        references/
        scripts/
        extensions/
          generate_pollinations_image.mjs
          README.md

      hyperframes/
        skill-source.json
        install.md

    scripts/
      validate-skills.mjs
      install-hyperframes-skill.mjs
      package-skills.mjs
```

## 10.4 sidecar runtime 结构

```txt
packages/sidecar/src/modules/skills/
  skills.module.ts
  skill-loader.service.ts
  skill-registry.service.ts
  skill-workspace.service.ts
  skill-permission.service.ts
```

## 10.5 Skill 权限原则

```txt
Agent 不直接 shell
Agent 不直接读任意文件
Agent 不直接上传孩子照片
所有外部调用通过 sidecar 受控 tool
```

---

# 11. MCP 方案：使用 @rekog/mcp-nest

## 11.1 最终结论

```txt
MCP 用 @rekog/mcp-nest
不自研 MCP server
```

## 11.2 原因

`@rekog/mcp-nest` 是 NestJS MCP Server Module，可以把 NestJS 应用里的 methods 暴露为 MCP tools / resources / prompts，并且支持 NestJS DI。它还支持 Zod validation、自动发现、HTTP/SSE、Streamable HTTP、STDIO、progress reporting、guard-based auth、per-tool authorization 等能力。

## 11.3 接入方式

业务 service 不动，只做 adapter：

```txt
DatasetService
BooksService
ConfigService
ExportService
  ↓
AssetMcpTools
BookMcpTools
ExportMcpTools
ConfigMcpTools
DiagnosticMcpTools
```

## 11.4 推荐 transport

一期建议：

```txt
Streamable HTTP
127.0.0.1:4317/mcp
```

原因：

```txt
1. 适合 desktop / sidecar 本地调用
2. 可以通过 header 传 traceId
3. 比 STDIO 更容易串 requestId / traceId
```

STDIO 可后续支持。

## 11.5 MCP 工具安全原则

暴露：

```txt
search_assets
get_asset_metadata
create_book_job
export_book_pdf
generate_cover_image_preview
render_hyperframes_video
```

不暴露：

```txt
run_sql
run_shell
read_file
write_file
delete_file
```

---

# 12. 日志与 Trace：文件日志方案

## 12.1 最终结论

本期日志：

```txt
不落库
不做 event_logs 表
不做 OpenTelemetry
只做文件日志 + traceId 串联
```

## 12.2 日志目录

### macOS

```txt
~/Library/Application Support/KidMemory/logs/
  desktop/
    2026-05-17.log
  sidecar/
    2026-05-17.log
  diagnostic/
    kidmemory-diagnostic-2026-05-17.zip
```

### Windows

```txt
%APPDATA%/KidMemory/logs/
  desktop/
  sidecar/
  diagnostic/
```

### Linux

```txt
~/.local/share/KidMemory/logs/
  desktop/
  sidecar/
  diagnostic/
```

## 12.3 日志格式

使用 JSONL：

```json
{
  "ts": "2026-05-17T12:00:00.000Z",
  "level": "info",
  "source": "sidecar",
  "event": "mcp.tool.called",
  "traceId": "trc_01hxx",
  "requestId": "req_24fc",
  "jobId": "job_abc",
  "tool": "search_assets",
  "durationMs": 42,
  "status": "ok"
}
```

## 12.4 traceId / requestId / jobId

```txt
traceId:
  一次用户动作的完整链路
  例如“生成儿童绘本”

requestId:
  一次 HTTP 请求

jobId:
  业务任务 ID
```

## 12.5 传递方式

```txt
Desktop 生成 traceId
  ↓
HTTP header: X-KidMemory-Trace-Id
  ↓
sidecar
  ↓
MCP tool
  ↓
Skill / Provider
```

## 12.6 LogCleanupWorker

规则：

```txt
保留 14 天
或最多 200MB
启动时清理一次
运行中每 6 小时清理一次
删除最旧日志
```

## 12.7 重点链路日志

### desktop

```txt
desktop.app.started
desktop.sidecar.starting
desktop.sidecar.ready
desktop.sidecar.failed
desktop.action.generate_book
desktop.action.export_pdf
desktop.action.smart_pick_assets
```

### sidecar

```txt
http.request.started
http.request.completed
http.request.failed
```

### MCP

```txt
mcp.request.received
mcp.tool.called
mcp.tool.completed
mcp.tool.failed
```

### 素材

```txt
asset.search.started
asset.search.completed
asset.metadata.updated
asset.preview.opened
```

### 书稿 / 导出

```txt
book.job.created
book.job.started
book.job.completed
book.job.failed
export.pdf.started
export.pdf.completed
export.pdf.failed
```

### 生图

```txt
image.pollinations.called
image.pollinations.completed
image.pollinations.failed
```

### Skill

```txt
picturebook.skill.loaded
picturebook.plan.created
picturebook.cover.prompt.created
picturebook.cover.generated
picturebook.failed
hyperframes.skill.loaded
hyperframes.render.started
hyperframes.render.completed
hyperframes.render.failed
```

---

# 13. 免费生图 Provider：Pollinations

## 13.1 最终结论

一期默认：

```txt
Pollinations
```

备选：

```txt
Cloudflare Workers AI
```

预留：

```txt
OpenAI-compatible image API
```

## 13.2 Pollinations 配置

```env
IMAGE_PROVIDER=pollinations
IMAGE_API_URL=https://image.pollinations.ai/prompt
IMAGE_API_KEY=
IMAGE_MODEL=pollinations
IMAGE_API_TIMEOUT_MS=60000
```

## 13.3 Cloudflare Workers AI 预留

```env
IMAGE_PROVIDER=cloudflare-workers-ai
CLOUDFLARE_ACCOUNT_ID=your_cloudflare_account_id
CLOUDFLARE_API_TOKEN=your_cloudflare_workers_ai_token
CLOUDFLARE_IMAGE_MODEL=@cf/stabilityai/stable-diffusion-xl-base-1.0
IMAGE_API_TIMEOUT_MS=60000
```

## 13.4 一期只做

```txt
generate_cover_image_preview
```

## 13.5 一期不做

```txt
逐页插图批量生成
上传孩子照片作为 reference
角色一致性
本地模型
复杂生图设置
```

## 13.6 Pollinations 扩展脚本

位置：

```txt
packages/skills/skills/picturebook-maker/extensions/generate_pollinations_image.mjs
```

职责：

```txt
1. 接收 prompt
2. 调用 Pollinations
3. 保存图片到 workspace
4. 输出图片路径和 metadata
5. 写日志
```

安全规则：

```txt
只传文字 prompt
不传孩子照片
不传本地路径
不传真实姓名/学校/地址
```

---

# 14. picturebook-maker 接入方案

## 14.1 最终结论

```txt
采用 picturebook-maker 作为绘本 Skill
但用 KidMemory 自己的 sidecar tools 和 Pollinations provider 补齐执行层
```

## 14.2 picturebook-maker 本质

它支持“生图流程”，但不内置固定第三方生图 API client。

它负责：

```txt
story question
story voice
page plan
visual system
layout rhythm
character sheet
逐页生成
逐页审核
本地文字排版
print package
```

真正的图片生成需要外部能力，例如：

```txt
Pollinations
Cloudflare Workers AI
其他图像生成 provider
```

## 14.3 KidMemory 修改点

```txt
1. 放入 packages/skills/skills/picturebook-maker
2. 增加 extensions/generate_pollinations_image.mjs
3. 在 SKILL.md 或扩展说明里写明：
   - 生图调用 KidMemory generate_cover_image_preview
   - 不直接 shell
   - 不上传孩子照片
   - 使用本地排版
```

## 14.4 一期接入边界

```txt
做：
- 绘本工作流
- 封面图 PoC
- page plan / story draft
- 本地导出 PDF

不做：
- 完整逐页生图
- 角色一致性系统
- 完整 print package
```

---

# 15. Hyperframes 接入方案

## 15.1 最终结论

```txt
直接引入 Hyperframes Skill 全家桶
KidMemory 不拆、不重写它内部 Skill
```

## 15.2 sidecar 需要提供

```txt
render_hyperframes_video
```

职责：

```txt
1. 检查 FFmpeg
2. 检查 Hyperframes
3. 读取 workspace composition
4. 调用 Hyperframes render
5. 输出 MP4
6. 写日志
```

## 15.3 一期边界

```txt
做：
- 引入 Hyperframes Skill
- render 工具
- demo / 简单 composition render
- 日志

不做：
- 完整视频脚本生成
- 自动旁白
- 自动字幕
- 自动音乐
- 完整回忆录视频生产线
```

---

# 16. 任务拆单

## Task 1：创建 packages/skills

内容：

```txt
新增 packages/skills
新增 skill-registry.json
新增 validate-skills.mjs
新增 package-skills.mjs
```

验收：

```txt
- packages/skills 可独立校验
- picturebook-maker 可以放入该目录
- hyperframes 可以登记来源
```

---

## Task 2：接入 picturebook-maker

内容：

```txt
vendor picturebook-maker 到 packages/skills/skills/picturebook-maker
补 KidMemory 使用说明
补 Pollinations extension
```

验收：

```txt
- Skill 文件完整
- 扩展脚本存在
- Skill 校验通过
```

---

## Task 3：接入 Hyperframes Skill

内容：

```txt
新增 hyperframes skill source
新增 install-hyperframes-skill.mjs
支持把 Hyperframes Skill 安装/挂载到 Agent workspace
```

验收：

```txt
- 能安装 / 挂载 Hyperframes Skill
- 不重写其内部结构
```

---

## Task 4：接入 @rekog/mcp-nest

内容：

```txt
安装 @rekog/mcp-nest
新增 SidecarMcpModule
配置本地 streamable HTTP /mcp
```

验收：

```txt
- /mcp 可启动
- inspector 能 tools/list
- get_sidecar_health 可调用
```

---

## Task 5：实现 Asset MCP Tools

内容：

```txt
list_children
get_child_profile
list_recent_assets
search_assets
search_assets_by_vector
get_asset_metadata
get_asset_preview
update_asset_metadata
```

验收：

```txt
- Agent 能搜索素材
- pgvector 搜索通过业务工具完成
- 不暴露 SQL
```

---

## Task 6：实现 Book / Export MCP Tools

内容：

```txt
create_book_job
get_book_job
list_book_jobs
export_book_pdf
export_book_long_image
```

验收：

```txt
- Agent 能创建书稿任务
- Agent 能查询任务
- Agent 能导出 PDF / 长图
```

---

## Task 7：实现 Diagnostic MCP Tools

内容：

```txt
get_config_status
get_indexing_status
get_sidecar_health
get_recent_logs
```

验收：

```txt
- Agent 能查询 sidecar 状态
- Agent 能查询最近日志摘要
```

---

## Task 8：实现文件日志系统

内容：

```txt
sidecar FileLoggerService
sidecar TraceContextService
sidecar LogCleanupWorker
desktop DesktopLogger
desktop trace_context
desktop LogCleanupWorker
```

验收：

```txt
- desktop 有日志目录
- sidecar 有日志目录
- JSONL 日志可写
- cleanup worker 生效
```

---

## Task 9：实现 traceId 串联

内容：

```txt
Desktop 生成 traceId
HTTP header 传 X-KidMemory-Trace-Id
sidecar 接收并写日志
MCP tools 继续使用 traceId
provider 调用继续使用 traceId
```

验收：

```txt
- 同一次生成绘本的日志可通过 traceId 串起来
```

---

## Task 10：实现 Pollinations Provider

内容：

```txt
PollinationsImageProvider
generate_cover_image_preview MCP tool
picturebook-maker extension script
```

验收：

```txt
- 能用 prompt 生成封面图
- 不上传孩子照片
- 调用失败有日志
```

---

## Task 11：实现 Hyperframes render tool

内容：

```txt
render_hyperframes_video
FFmpeg / Hyperframes 检查
render 日志
输出 MP4
```

验收：

```txt
- 能渲染 demo MP4
- 失败可定位
```

---

## Task 12：现有页面轻量增强

内容：

```txt
生成 / 导出页：
- 智能生成入口
- Agent 进度面板
- 确认调用免费生图
- 结果卡片
- requestId 显示

素材库：
- 帮我挑素材
```

验收：

```txt
- 视觉风格延续现有 KidMemory
- 不改设置页
- 不出现技术词
```

---

# 17. 验收标准

## 17.1 架构验收

```txt
- Skills 内容在 packages/skills
- sidecar 只做 skills runtime
- MCP 用 @rekog/mcp-nest
- 不存在自研 MCP 协议层
- 日志不落库
```

## 17.2 MCP 验收

```txt
- /mcp 可用
- tools/list 可返回工具列表
- get_sidecar_health 可调用
- search_assets 可调用
- create_book_job 可调用
- generate_cover_image_preview 可调用
```

## 17.3 安全验收

```txt
- 无 run_sql
- 无 run_shell
- 无任意 read_file
- Pollinations 不上传孩子照片
- 日志脱敏
```

## 17.4 日志验收

```txt
- desktop/sidecar 均有日志目录
- JSONL 格式正确
- traceId 可串联一次生成任务
- cleanup worker 可清理旧日志
```

## 17.5 UI 验收

```txt
- 不改设置页
- 不做大聊天窗
- 生成页有智能动作入口
- 生成页有进度卡
- 生图前有确认
- 结果以卡片展示
```

---

# 18. 工程结构

```txt
packages/
  skills/
    package.json
    skill-registry.json

    skills/
      picturebook-maker/
        SKILL.md
        README.md
        templates/
        references/
        scripts/
        extensions/
          generate_pollinations_image.mjs
          README.md

      hyperframes/
        skill-source.json
        install.md

    scripts/
      validate-skills.mjs
      install-hyperframes-skill.mjs
      package-skills.mjs

  sidecar/
    src/
      modules/
        mcp/
          sidecar-mcp.module.ts
          tools/
            asset.mcp-tools.ts
            book.mcp-tools.ts
            export.mcp-tools.ts
            config.mcp-tools.ts
            diagnostic.mcp-tools.ts
            image.mcp-tools.ts
            hyperframes.mcp-tools.ts

        skills/
          skills.module.ts
          skill-loader.service.ts
          skill-registry.service.ts
          skill-workspace.service.ts
          skill-permission.service.ts

        media/
          providers/
            image-provider.ts
            pollinations-image.provider.ts
            cloudflare-workers-ai-image.provider.ts
            openai-compatible-image.provider.ts

      infrastructure/
        logging/
          file-logger.service.ts
          trace-context.service.ts
          log-cleanup.worker.ts
          redaction.ts

  desktop/
    lib/
      core/
        logging/
          desktop_logger.dart
          trace_context.dart
          log_cleanup_worker.dart

      features/
        generate_export/
          widgets/
            smart_action_card.dart
            agent_task_panel.dart
            approval_dialog.dart
            result_artifact_card.dart

        asset_library/
          widgets/
            smart_asset_pick_panel.dart
```

---

# 19. 配置项

## 生图

```env
IMAGE_PROVIDER=pollinations
IMAGE_API_URL=https://image.pollinations.ai/prompt
IMAGE_API_KEY=
IMAGE_MODEL=pollinations
IMAGE_API_TIMEOUT_MS=60000
```

## Cloudflare Workers AI 预留

```env
IMAGE_PROVIDER=cloudflare-workers-ai
CLOUDFLARE_ACCOUNT_ID=
CLOUDFLARE_API_TOKEN=
CLOUDFLARE_IMAGE_MODEL=@cf/stabilityai/stable-diffusion-xl-base-1.0
IMAGE_API_TIMEOUT_MS=60000
```

## MCP

```env
KIDMEMORY_MCP_ENABLED=true
KIDMEMORY_MCP_HOST=127.0.0.1
KIDMEMORY_MCP_PORT=4317
KIDMEMORY_MCP_PATH=/mcp
```

## 日志

```env
KIDMEMORY_LOG_LEVEL=info
KIDMEMORY_LOG_RETENTION_DAYS=14
KIDMEMORY_LOG_MAX_MB=200
```

## Hyperframes

```env
HYPERFRAMES_ENABLED=true
HYPERFRAMES_BIN=npx hyperframes
FFMPEG_BIN=ffmpeg
```

---

# 20. 风险与回滚

## 风险

```txt
1. @rekog/mcp-nest 依赖标准 NestJS decorators，当前 sidecar 标准化不足可能影响接入
2. Pollinations 免费服务稳定性不可控
3. Hyperframes 依赖 FFmpeg / Chromium，用户环境可能缺失
4. 文件日志如果不清理会膨胀
5. traceId 在 STDIO transport 下不如 HTTP header 好传
```

## 回滚

```txt
1. MCP 模块可通过 KIDMEMORY_MCP_ENABLED=false 关闭
2. 生图 provider 不可用时跳过封面继续生成
3. Hyperframes 不可用时隐藏/禁用视频动作
4. 日志可降级为 stdout
5. UI 智能入口可通过 feature flag 隐藏
```

---

# 21. 最终交付物

完成后应交付：

```txt
1. packages/skills
2. picturebook-maker skill + Pollinations extension
3. Hyperframes skill install / mount 方案
4. @rekog/mcp-nest SidecarMcpModule
5. Asset / Book / Export / Diagnostic / Image / Hyperframes MCP tools
6. desktop + sidecar 文件日志
7. traceId 串联
8. PollinationsImageProvider
9. 生成页 Agent UI 轻量增强
10. 素材库智能挑选入口
11. 文档：skills 如何维护
12. 文档：MCP tools 如何新增
13. 文档：日志目录和诊断包
```

---

# 22. 参考调研结论

## 22.1 @rekog/mcp-nest

适合当前项目，因为它允许 NestJS 应用用 decorators 和 DI 直接暴露 MCP tools / resources / prompts。它支持 Zod validation、自动发现、forFeature 注册、Streamable HTTP、SSE、STDIO、progress reporting、guards 等能力。

## 22.2 picturebook-maker

适合作为 KidMemory 绘本 Skill 的基础。  
它不是普通生图工具，而是绘本生产流程：故事问题、故事口吻、页面计划、视觉系统、排版节奏、角色确认、逐页审核、本地文字排版和打印交付。

## 22.3 Hyperframes

适合作为 KidMemory 视频能力的基础。  
它是 agent-first 的 HTML 视频渲染框架，适合让 Agent 生成 HTML composition，然后渲染 MP4。KidMemory 不需要重写其内部 Skill。

## 22.4 dreamweaver-picturebook

适合作为免费生图 provider 的参考。  
它默认支持 Pollinations，也预留 Cloudflare Workers AI 和 OpenAI-compatible image API。

---

# 最终总结

> **Epic 10 的最终方向是：Skill 内容放 packages/skills；sidecar 使用 @rekog/mcp-nest 把现有 NestJS 能力快速暴露成 MCP tools；日志先做文件 JSONL，不落库，用 traceId 串联 desktop、sidecar、MCP、Skill、Provider；picturebook-maker 负责绘本流程并补 Pollinations 扩展；Hyperframes 直接引入 Skill 全家桶；用户侧只在现有页面看到智能动作、进度、确认和结果卡片。**
