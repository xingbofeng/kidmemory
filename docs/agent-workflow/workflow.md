# Hermes + Harness + Codex 工作流

## 目标

建立一套轻量、可复盘、低污染的本地 agent 开发流程：

1. 用户和 Hermes 聊清楚需求。
2. Hermes 按模板创建完整 GitHub Issue，并直接标记 `status:ready`。
3. 本地 Harness 轮询 GitHub Issue。
4. Harness 为可执行 Issue 创建 worktree 和分支，并用 goal 模式启动 Codex。
5. Codex 尽力实现，产出一个 commit 和一个 PR。
6. 用户人工 review PR，并在 Issue 评论里写修改意见。
7. Harness 根据状态继续派发修复或新任务。

## 角色边界

### 用户

- 和 Hermes 对齐需求。
- 人工 review PR。
- 如果需要打回，在 Issue 评论里写修改意见。
- 手动把 Issue 标成 `status:changes-requested`。
- 决定 merge。

### Hermes

- 负责需求澄清。
- 负责把需求整理成完整 Issue。
- 可以持续修改 Issue body。
- 可以直接给 Issue 打 `status:ready`。
- 不写代码。

### Harness

Harness 是本地调度器，放在仓库外维护和运行。

运行形态：

- 常驻 daemon。
- 由用户在本机配置 cron / launchd 保活或定时启动。
- Harness 本体不提交到 KidMemory 仓库。

职责：

- 轮询 GitHub Issue。
- 按 FIFO 和依赖关系选择任务。
- 创建或复用 worktree。
- 创建或复用分支。
- 用 goal 模式启动 Codex。
- 更新 Issue 状态 label。
- 自动创建缺失的 GitHub labels。
- 使用 `gh` CLI 创建和更新 PR。
- PR merge / Issue done 后清理本地 worktree 和本地分支。

Harness 不做：

- 不判断产品方案是否正确。
- 不判断技术方案是否合理。
- 不修改需求内容。
- 不删除远端分支。

### Codex

- 只执行 Harness 派发的 Issue。
- 每次必须通过 goal 模式启动。
- 在独立 worktree 中工作。
- 一个 Issue 最终只保留一个 commit。
- 一个 Issue 对应一个 PR。
- 测试失败或实现不完整时，也照常创建或更新 PR。
- 需要人工注意时，打 `needs-human-attention`。

## 事实源

只认这些信息：

- GitHub Issue 最新 body。
- GitHub Issue comments。
- PR body。
- PR diff。
- PR 状态。

不认这些信息：

- Hermes 聊天历史。
- 本地临时聊天。
- Codex 自己的推测。

## Issue 规则

默认：

- 一个 Issue 写全。
- 一个 Issue 可以直接对应一个 PR。
- 不强制拆产品 Issue、技术 Issue、验收 Issue。

只有出现以下情况才拆：

- 一个 PR 做不完。
- 存在明确前后置依赖。
- 需要多个 agent 或多人并行。
- 单个 Issue 的验收标准过长，已经影响 review。

## 状态 label

必需状态：

- `status:ready`
- `status:doing`
- `status:human-review`
- `status:changes-requested`
- `status:done`

辅助 label：

- `needs-human-attention`
- `type:feature`
- `type:bug`
- `type:refactor`
- `type:chore`

## 状态流转

### 首次开发

```text
status:ready
  -> status:doing
  -> status:human-review
  -> status:done
```

步骤：

1. Hermes 创建完整 Issue，并标记 `status:ready`。
2. Harness 轮询到 Issue。
3. Harness 创建 worktree 和分支。
4. Harness 把 Issue 改为 `status:doing`。
5. Harness 用 goal 模式启动 Codex。
6. Codex 实现、验证、提交、创建 PR。
7. PR 创建或更新成功后，Harness 把 Issue 改为 `status:human-review`。
8. 用户 review 并 merge。
9. Issue closed 或 `status:done` 后，Harness 清理本地 worktree 和本地分支。

### 打回修复

```text
status:human-review
  -> status:changes-requested
  -> status:doing
  -> status:human-review
```

步骤：

1. 用户在 Issue 评论里写修改意见。
2. 用户手动把 Issue 标成 `status:changes-requested`。
3. Harness 优先处理 `status:changes-requested`。
4. Harness 复用同一个 worktree、分支和 PR。
5. Harness 用新的 goal 启动 Codex。
6. Codex 根据最新 Issue body、Issue comments、当前 PR diff 继续修改。
7. Codex 仍然把分支整理为一个 commit。
8. PR 更新成功后回到 `status:human-review`。

## 调度规则

### 并发

- 同一时间最多一个 `status:doing`。
- `status:human-review` 可以积压最多 10 个。
- `status:changes-requested` 修复不受 human-review 积压上限限制。

### 优先级

调度顺序：

1. `status:changes-requested`
2. `status:ready`

同一状态内按 Issue 编号从小到大 FIFO。

### 依赖判断

Issue 模板中包含：

```md
## 依赖关系

前置依赖：

- 无

后续依赖：

- 无
```

如果前置依赖列出 Issue：

- 所有前置 Issue 必须 closed，或带 `status:done`。
- PR 已创建但未 merge，不算完成。
- 前置依赖未完成时，Harness 跳过该 Issue，继续扫描下一个。
- 跳过时不评论，只写本地日志。

### 新任务派发条件

Harness 派发 `status:ready` 前检查：

- 当前没有 `status:doing`。
- `status:human-review` 数量小于 10。
- 前置依赖已完成。

Harness 派发 `status:changes-requested` 前检查：

- 当前没有 `status:doing`。
- 前置依赖已完成。
- 不受 `status:human-review` 数量限制。

## GitHub 操作

Harness 使用 `gh` CLI 操作 GitHub。

职责：

- 查询 Issue。
- 查询 Issue labels。
- 查询 Issue comments。
- 自动创建缺失 label。
- 更新 Issue labels。
- 创建 PR。
- 更新 PR metadata。

PR 创建使用：

```bash
gh pr create \
  --base main \
  --head "<branch>" \
  --title "<commit-subject>" \
  --body-file "<pr-body-file>"
```

MVP 默认创建普通 PR，不强制 Draft PR。

如果后续希望所有 Codex PR 先以 Draft 状态出现，可以在 Harness 配置中增加：

```bash
--draft
```

## Codex CLI 调用

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
