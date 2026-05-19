# Agent 工作流

本目录记录 KidMemory 的本地 agentic development workflow。

核心原则：

- GitHub Issue 是事实源。
- Hermes 负责和用户聊清楚需求，并按模板创建 `status:ready` Issue。
- Harness 是本地常驻 daemon，放在仓库外运行，不放入本仓库。
- Harness 使用 `gh` CLI 操作 GitHub，使用 `codex exec` 启动 Codex goal。
- Hermes 也可开启 `codex_app_server` runtime，但本工作流 v1 不依赖这条路径。
- Codex 只执行 Harness 派发的 ready Issue，不判断需求是否 ready。
- 前期由用户人工 review PR，稳定后再考虑 Reviewer Agent。

文档：

- [workflow.md](workflow.md)：最终工作流和状态机。
- [issue-template.md](issue-template.md)：详细 Issue 模板。
- [github-labels.md](github-labels.md)：GitHub labels 初始化清单。
- [prompts/hermes-issue-writer.md](prompts/hermes-issue-writer.md)：Hermes 生成 Issue 的提示词。
- [prompts/codex-goal-worker.md](prompts/codex-goal-worker.md)：Codex goal 模式执行提示词。
- [prompts/human-review-checklist.md](prompts/human-review-checklist.md)：人工 review 清单。

图片：

- [../images/agent-workflow-overview.png](../images/agent-workflow-overview.png)

注意：图片用于快速理解整体流程；最终规则以本目录 Markdown 文档为准。
