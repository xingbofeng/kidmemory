# KidMemory Agent 工作流

本文档是 KidMemory 当前唯一保留的 agent workflow 主文档。

仓库内不再并行维护旧的实验性流程说明；角色相关的补充材料统一收口到 `souls/` 目录中的快照文件。

目标是建立一套以 Slack 为前台、以 GitHub Issue / PR 为事实源、以 Harness 为后台调度器、以 Codex 为代码执行器的本地多 agent 开发流程。

## 总览

当前统一流程：

```text
Slack thread
  -> overseer 澄清并派发
  -> pm 产出完整任务说明
  -> GitHub Issue 创建或更新并进入 status:ready
  -> Harness 轮询 Issue
  -> 创建或复用 worktree + 分支
  -> tmux + codex exec(goal 模式)
  -> 产出一个 commit + 一个 PR
  -> tester 辅助验收
  -> 人工 review / merge
  -> Harness 清理本地 worktree
```

核心原则：

- Slack thread 是前台协作入口。
- GitHub Issue 和 PR 是长期事实源。
- Harness 是本地常驻 daemon，负责轮询和调度。
- Codex 只在独立 worktree 中执行。
- 一个 Issue 对应一个分支、一个 PR、最终一个 commit。
- 开发者前期人工 review，tester 负责辅助验收。

## 角色与职责

### 用户

- 和 `overseer` 对齐需求。
- 人工 review PR。
- 需要打回时，在 Issue 评论中写修改意见。
- 手动把 Issue 标成 `status:changes-requested`。
- 决定 merge。

### `overseer`

- 接收需求。
- 在 Slack thread 里追问关键问题。
- 需求足够清楚后，派给 `pm` 输出任务说明。
- 检查任务说明是否完整。
- 创建或更新 GitHub Issue，并标记 `status:ready`。
- PR 创建后派给 `tester` 验收。
- 不直接写代码，不直接运行 Codex。

### `pm`

- 把自然语言需求整理成完整任务说明。
- 必须补齐背景、用户故事、目标、不做什么、产品方案、设计图 / 视觉参考、技术方案、改动目录结构、验收标准、分支建议。
- 复杂任务可以协助创建或更新 GitHub Issue。
- 不直接写代码，不直接运行 Codex。

### Harness

- 常驻本地 daemon。
- 轮询 GitHub Issue。
- 依据状态、依赖关系和 FIFO 调度。
- 创建或复用 worktree、分支、tmux 会话。
- 用 goal 模式启动 Codex。
- 更新 Issue labels。
- 使用 `gh` 创建和更新 PR。
- Issue 完成后清理 worktree 和本地分支。

### `developer`

- 作为 Slack 前台开发代理。
- 接收 `overseer` 派发。
- 校验任务说明是否完整。
- 调用 [`scripts/agent-codex-tmux-run.sh`](../../scripts/agent-codex-tmux-run.sh) 启动 `tmux + codex exec`。
- 汇报 session、worktree、日志路径、PR 链接和阻塞项。
- 不在主工作区直接长时间写代码。

### Codex Worker

- 只执行当前 Issue。
- 只认 Issue、Issue comments、PR、仓库代码。
- 在独立 worktree 中实现任务。
- 尽力跑默认验证命令。
- 产出一个 commit 和一个 PR。
- 即使测试失败或实现不完整，也照常创建 PR，并在 PR 中写清楚风险。

### `tester`

- 对照任务说明、Issue、PR body、PR diff 和测试结果做辅助验收。
- 逐条检查用户故事和验收标准。
- 输出通过、需要修改或需要开发者判断。
- 不写代码，不 merge。

## 事实源

只认这些：

- GitHub Issue 最新 body
- GitHub Issue comments
- PR body
- PR diff
- PR 状态

不认这些：

- Slack 历史聊天本身
- 本地临时对话
- Codex 自己的额外猜测

## Slack 配置

### 推荐拓扑

最稳配置是：

```text
一个 Hermes profile 对应一个 Slack app / bot
```

当前角色：

```text
overseer   总监
pm         产品经理
developer  开发者
tester     测试员
```

### 本地 profile 目录

```text
~/.hermes/profiles/overseer/
~/.hermes/profiles/pm/
~/.hermes/profiles/developer/
~/.hermes/profiles/tester/
```

每个 profile 至少包含：

```text
config.yaml
.env
SOUL.md
```

仓库中保存的角色提示词快照位于：

- [overseer.md](./souls/overseer.md)
- [pm.md](./souls/pm.md)
- [developer.md](./souls/developer.md)
- [tester.md](./souls/tester.md)

### Slack App 权限

每个 bot 的 `OAuth & Permissions -> Bot Token Scopes` 至少需要：

```text
app_mentions:read
channels:history
channels:read
chat:write
groups:history
groups:read
im:history
im:read
im:write
users:read
```

`Event Subscriptions -> Subscribe to bot events` 至少需要：

```text
app_mention
message.channels
message.groups
message.im
```

加完后需要对每个 App 执行一次 `Reinstall to Workspace`。

### 每个 profile 的 `.env`

每个 profile 的 `.env` 至少需要：

```env
SLACK_BOT_TOKEN=xoxb-...
SLACK_APP_TOKEN=xapp-...
SLACK_ALLOW_ALL_USERS=true
SLACK_ALLOWED_CHANNELS=<channel-id>
SLACK_HOME_CHANNEL=<channel-id>
GH_CONFIG_DIR=/Users/counter/.config/gh
CODEX_HOME=/Users/counter/.codex
```

说明：

- `SLACK_BOT_TOKEN`：Bot User OAuth Token。
- `SLACK_APP_TOKEN`：Socket Mode App-Level Token。
- `SLACK_ALLOW_ALL_USERS=true`：当前阶段默认放开触发用户。
- `SLACK_ALLOWED_CHANNELS`：限制仅在指定频道工作。
- `SLACK_HOME_CHANNEL`：接收系统回执和跨平台消息的 home channel。
- `GH_CONFIG_DIR`、`CODEX_HOME`：显式复用主账号登录态。

### Gateway 运行约定

统一使用 [`scripts/restart-hermes-gateways.sh`](../../scripts/restart-hermes-gateways.sh) 启动和重启四个 gateway。

脚本当前统一注入：

- `HOME=/Users/counter`
- `GH_CONFIG_DIR=/Users/counter/.config/gh`
- `CODEX_HOME=/Users/counter/.codex`
- `HERMES_YOLO_MODE=1`
- `HERMES_ACCEPT_HOOKS=1`
- `HERMES_KANBAN_DISPATCH_IN_GATEWAY=0`

当前运行约定：

- `kanban.dispatch_in_gateway=false`
- `approvals.mode=off`
- `hooks_auto_accept=true`
- 不再使用 profile 私有 `home/`

### Slack 协作规则

- 新开需求时建议明确 mention 对应 agent。
- 同一个 Slack thread 内可以持续补充需求。
- 每次只 mention 一个下游 agent。
- bot-to-bot 连续往返最多 2 轮。
- 超过 2 轮仍未收敛时，由开发者介入。
- 重要结论必须回写到 GitHub Issue 或 PR。

## GitHub Issue 规则

### 基本原则

- 默认一个 Issue 写全。
- 默认一个 Issue 对应一个 PR。
- 不强制拆产品 Issue、技术 Issue、验收 Issue。
- 只有在明显过大、存在前后置依赖、需要多 PR 或并行开发时才拆单。

### 必需状态 label

- `status:ready`
- `status:doing`
- `status:human-review`
- `status:changes-requested`
- `status:done`

### 辅助 label

- `needs-human-attention`
- `type:feature`
- `type:bug`
- `type:refactor`
- `type:chore`

### Issue 模板

```md
# <任务标题>

## 1. 背景

## 2. 用户故事

US1. ...
US2. ...

## 3. 目标

## 4. 不做什么

## 5. 产品方案

### 功能入口
### 用户路径
### 正常状态
### 空状态
### 错误状态
### 权限 / 可见性

## 6. 设计图 / 视觉参考

### 设计来源
### 设计范围
### 关键视觉要求
### 设计验收方式

## 7. 技术方案

### 现状
### 目标设计
### 数据流 / 调用链
### 关键类型 / API
### 错误处理
### 复用与约束

## 8. 改动目录结构

## 9. 依赖关系

前置依赖：

- 无

后续依赖：

- 无

## 10. 验收标准

AC1. ...
AC2. ...
AC3. ...

## 11. 分支建议

feature/<issue-number>-<slug>
```

要求：

- 不适用的小节必须写 `不适用`，不能留空。
- 涉及 UI、布局、交互、视觉样式时，`设计图 / 视觉参考` 必填。
- 必须写清楚 `改动目录结构`。
- 必须写清楚 `不做什么`。

## 状态机

### 首次开发

```text
status:ready
  -> status:doing
  -> status:human-review
  -> status:done
```

### 打回修复

```text
status:human-review
  -> status:changes-requested
  -> status:doing
  -> status:human-review
```

### 流转规则

1. `overseer` / `pm` 把需求整理成完整 Issue。
2. Issue 满足模板要求后，打 `status:ready`。
3. Harness 轮询到可执行 Issue，创建或复用 worktree 和分支，改为 `status:doing`。
4. Codex 完成当前轮实现并创建或更新 PR 后，Issue 进入 `status:human-review`。
5. 人工 review 通过后 merge，Issue 关闭或打 `status:done`。
6. 如果需要继续修改，用户在 Issue 评论中写要求，并手动打 `status:changes-requested`。
7. Harness 优先复用原 worktree、原分支、原 PR 继续执行。

## 调度规则

### 并发

- 同一时间最多一个 `status:doing`。
- `status:human-review` 最多允许积压 10 个。
- `status:changes-requested` 不受 `human-review` 积压上限限制。

### 优先级

1. `status:changes-requested`
2. `status:ready`

同一状态内按 Issue 编号 FIFO。

### 依赖关系

- 只认 Issue `依赖关系` 小节。
- 所有前置 Issue 必须 closed 或带 `status:done` 才能开工。
- 只有 PR 创建但未 merge，不算依赖完成。
- 依赖未满足时，Harness 跳过该 Issue，只记本地日志，不自动评论。

## Harness 执行约定

Harness 是仓库外的本地 daemon，本仓库只保留与其协作的文档和脚本约定。

Harness 职责：

- 轮询 Issue
- 自动补全缺失 labels
- 按状态、依赖关系和 FIFO 选任务
- 创建或复用 worktree
- 创建或复用分支
- 启动 tmux + `codex exec`
- 用 `gh` 创建或更新 PR
- merge / done 后清理本地 worktree 和本地分支

Harness 不负责：

- 改写需求
- 判断产品方案是否合理
- 判断技术方案是否合理
- 删除远端分支

## Codex Worker 执行规则

- 必须通过 goal 模式启动。
- 只执行当前 Issue。
- 默认遵守 Issue 中的 `技术方案` 和 `改动目录结构`。
- 如果必须超出指定范围改动，PR body 必须写 `偏离说明`，并打 `needs-human-attention`。
- 如果实现不完整、测试失败或需要人工判断，仍然创建或更新 PR。
- 最终分支相对 base branch 只保留一个 commit。
- PR body 使用中文。

默认按改动目录运行验证：

```text
packages/web:
  npm --prefix packages/web run test
  npm --prefix packages/web run build

packages/sidecar:
  npm --prefix packages/sidecar run build

packages/cloud-api:
  npm --prefix packages/cloud-api run build

packages/protocol:
  npm --prefix packages/protocol run build

packages/desktop:
  cd packages/desktop && flutter test
```

## Git 与 PR 约定

分支命名：

```text
feature/<issue-number>-<slug>
fix/<issue-number>-<slug>
refactor/<issue-number>-<slug>
chore/<issue-number>-<slug>
```

Commit 格式：

```text
<type>(<scope>): <中文祈使句摘要>

Refs #<issue-number>

Co-authored-by: OpenAI Codex <codex@openai.com>
```

PR body 至少包含：

- 摘要
- 验收标准完成情况
- 测试结果
- 偏离说明
- 需要人工注意
- 关联 Issue

创建 PR 默认使用：

```bash
gh pr create \
  --base main \
  --head "<branch>" \
  --title "<commit-subject>" \
  --body-file "<pr-body-file>"
```

## 人工 Review 关注点

- PR 是否对应正确 Issue
- 是否只有一个 commit
- commit message 是否包含 `Refs #<issue-number>`
- commit message 是否包含 `Co-authored-by: OpenAI Codex <codex@openai.com>`
- PR body 是否包含 `Closes #<issue-number>` 或等价关联
- 是否逐条回应 AC
- 是否符合设计图 / 视觉参考
- 是否说明测试结果
- 是否存在无关改动
- 如果存在 `needs-human-attention`，是否写清楚原因

Harness 通过 `codex exec` 启动 Codex goal。

本机确认的 CLI 入口：

```bash
codex exec [OPTIONS] [PROMPT]
```

推荐调用方式：

```bash
codex exec \
  --cd "<worktree-path>" \
  --sandbox workspace-write \
  --ask-for-approval never \
  --json \
  --output-last-message "<worktree-path>/.harness/codex-last-message.md" \
  - < "<worktree-path>/.harness/codex-goal.md"
```

说明：

- `--cd` 指向当前 Issue 的 worktree。
- `--sandbox workspace-write` 允许 Codex 修改 worktree。
- `--ask-for-approval never` 适合本地 Harness 的非交互运行。
- `--json` 方便 Harness 记录结构化事件日志。
- `--output-last-message` 保存 Codex 最终交付说明。
- `-` 表示从 stdin 读取完整 goal prompt。

Harness 应保存：

```text
<worktree>/.harness/codex-goal.md
<worktree>/.harness/codex-events.jsonl
<worktree>/.harness/codex-last-message.md
```

示例：

```bash
codex exec \
  --cd ".worktrees/issue-123" \
  --sandbox workspace-write \
  --ask-for-approval never \
  --json \
  --output-last-message ".worktrees/issue-123/.harness/codex-last-message.md" \
  - \
  < ".worktrees/issue-123/.harness/codex-goal.md" \
  > ".worktrees/issue-123/.harness/codex-events.jsonl"
```

如果本地环境已经通过 `codex login` 完成认证，`codex exec` 默认复用本地 CLI auth。

如果以后迁移到 CI / runner，可改用环境变量认证：

```bash
CODEX_API_KEY=<api-key> codex exec --json ...
```

## Hermes 调用 Codex 的两种方式

Hermes 官方支持可选的 Codex app-server runtime：

```text
/codex-runtime codex_app_server
```

开启后，Hermes 会把 `openai/*` 和 `openai-codex/*` turns 交给 Codex CLI app-server。此时终端命令、文件编辑、sandbox、MCP 调用都在 Codex runtime 内执行，Hermes 主要负责 session、slash commands、gateway、memory / skill review 等外层能力。

启用条件：

- 已安装 Codex CLI。
- 已执行 `codex login`。
- 在 Hermes 会话里执行 `/codex-runtime codex_app_server`，或在 `~/.hermes/config.yaml` 设置：

```yaml
model:
  openai_runtime: codex_app_server
```

但本工作流 v1 不要求 Hermes 直接调用 Codex。

本工作流选择：

```text
Hermes -> 写 GitHub Issue
Harness -> 调用 codex exec
Codex -> 实现 Issue
```

原因：

- Hermes 只负责需求和 Issue，不进入代码执行链路。
- Harness 能集中处理 GitHub label、依赖、worktree、分支、PR 和重试。
- Codex goal 的输入来自 GitHub Issue / comments / PR，事实源更清楚。

也就是说：

```text
Hermes codex_app_server runtime = Hermes 内部把模型 turn 交给 Codex runtime
Harness codex exec = Harness 外部启动一个独立 Codex goal worker
```

本仓库 MVP 采用后者。

## 分支和 worktree

每个 Issue 使用独立 worktree：

```text
.worktrees/issue-<issue-number>
```

分支名以 Issue body 的「分支建议」为准。

示例：

```text
feature/123-memory-timeline
fix/124-missing-memory-metadata
refactor/125-protocol-event-schema
chore/126-update-test-fixtures
```

如果 Issue body 的「分支建议」和 type label 冲突：

- 以「分支建议」为准。

每次创建新 worktree / 新分支前，Harness 必须拉取最新远端 base branch：

```bash
git fetch origin main
git worktree add ".worktrees/issue-<issue-number>" \
  -b "<branch>" \
  origin/main
```

默认 base branch：

```text
main
```

## Commit 规则

一个 Issue 最终只保留一个 commit。

commit message 使用中文 Conventional Commit：

```text
<type>(<scope>): <中文祈使句摘要>

Refs #<issue-number>

Co-authored-by: OpenAI Codex <codex@openai.com>
```

示例：

```text
feat(web): 添加记忆时间线筛选

Refs #123

Co-authored-by: OpenAI Codex <codex@openai.com>
```

打回修复时，Codex 可以 amend 或 soft reset，但最终分支相对 base branch 只保留一个 commit。

允许：

```text
feature/*
fix/*
refactor/*
chore/*
```

这些 agent 分支可使用 `push --force-with-lease` 维持单 commit。

禁止：

- 对 `main` force push。
- 对 release 分支 force push。
- 对非 agent 工作分支 force push。

## PR 规则

PR 标题等于 commit subject。

PR body 使用中文：

```md
## 摘要

- 

## 验收标准完成情况

- AC1：
- AC2：
- AC3：

## 测试结果

- `命令`：通过 / 失败 / 未运行

## 偏离说明

- 无

## 需要人工注意

- 无

## 关联 Issue

Closes #123
```

如果实现不完整、测试失败或存在不确定项：

- 仍然创建或更新 PR。
- 打 `needs-human-attention`。
- 在「需要人工注意」里写明。

如果实际改动超出 Issue 的「改动目录结构」：

- 必须写「偏离说明」。
- 必须打 `needs-human-attention`。

## 默认验证命令

Issue 不包含测试要求模块。Codex 根据实际改动目录自动选择包级验证命令。

默认规则：

```text
packages/web:
  npm --prefix packages/web run test
  npm --prefix packages/web run build

packages/sidecar:
  npm --prefix packages/sidecar run build

packages/cloud-api:
  npm --prefix packages/cloud-api run build

packages/protocol:
  npm --prefix packages/protocol run build

packages/desktop:
  cd packages/desktop && flutter test
```

跨包改动时运行多个对应命令。

验证失败不阻断 PR，但必须：

- 打 `needs-human-attention`。
- 在 PR body 写清楚失败命令和摘要。

## 设计图 / 视觉参考

如果 Issue 涉及 UI、交互、视觉样式、页面布局或组件状态，必须填写「设计图 / 视觉参考」模块。

该模块需要说明：

- 设计来源：Figma、截图、文档或其他引用。
- 设计范围：本 Issue 需要实现和明确不实现的设计范围。
- 关键视觉要求：布局、文案、颜色、字体、间距、动效、响应式。
- 设计验收方式：是否需要截图对比、浏览器 / 桌面端手动验证、需要覆盖哪些状态。

Codex 执行 UI 任务时必须读取该模块。

如果设计图无法访问、截图缺失或无法完成设计验收：

- 仍然创建或更新 PR。
- 打 `needs-human-attention`。
- 在 PR body 写入「需要人工注意」。

## 清理规则

PR merge / Issue done 后，Harness 清理：

- 本地 worktree。
- 本地分支。

Harness 不删除远端分支。远端分支删除交给 GitHub 仓库设置处理。

清理失败时：

- 不强删。
- 记录日志。
- 等人工处理。
