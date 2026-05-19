# 人工 Review 清单

前期不启用 Reviewer Agent，由用户人工 review PR。

## Review 输入

只看这些事实源：

- GitHub Issue 最新 body。
- Issue comments。
- PR body。
- PR diff。
- 测试结果。

## 检查项

- [ ] PR 是否对应正确 Issue。
- [ ] PR 标题是否等于 commit subject。
- [ ] commit 是否只有一个。
- [ ] commit message 是否包含 `Refs #<issue-number>`。
- [ ] commit message 是否包含 `Co-authored-by: OpenAI Codex <codex@openai.com>`。
- [ ] PR body 是否包含 `Closes #<issue-number>`。
- [ ] PR 是否逐条回应 AC1、AC2、AC3。
- [ ] 如果 Issue 涉及设计图 / 视觉参考，PR 是否符合设计范围和关键视觉要求。
- [ ] 如果需要截图对比或浏览器 / 桌面端验证，PR 是否说明验证结果。
- [ ] 实际改动是否符合 Issue 的「改动目录结构」。
- [ ] 如果超出改动目录，是否写了「偏离说明」。
- [ ] 是否存在 `needs-human-attention`。
- [ ] 如果存在 `needs-human-attention`，PR body 是否写清楚原因。
- [ ] 测试失败是否可接受。
- [ ] 是否有无关改动。
- [ ] 是否需要 Hermes 更新 Issue body 后再让 Codex 继续修。

## 通过

如果可以合并：

1. Merge PR。
2. Issue 自动 closed，或手动打 `status:done`。
3. Harness 后续清理本地 worktree 和本地分支。

## 打回

如果需要修改：

1. 在 Issue 评论里写修改意见。
2. 手动把 Issue 标成 `status:changes-requested`。
3. Harness 会复用同一 worktree、分支和 PR，启动新的 Codex goal。

评论建议格式：

```md
请继续修改，重点：

- AC2 没满足：
- 这里需要保持旧行为：
- 请不要改动：
```
