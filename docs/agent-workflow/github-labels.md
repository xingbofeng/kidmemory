# GitHub Labels

Harness 会自动创建缺失 labels。首次接入前，也可以在本机完成 `gh auth login` 后手动初始化。

## 必需 labels

```bash
gh label create "status:ready" \
  --color "2da44e" \
  --description "Ready for Harness to dispatch to Codex"

gh label create "status:doing" \
  --color "1f6feb" \
  --description "Codex is working on this issue"

gh label create "status:human-review" \
  --color "fbca04" \
  --description "PR is ready for developer review"

gh label create "status:changes-requested" \
  --color "d1242f" \
  --description "Developer requested changes in issue comments"

gh label create "status:done" \
  --color "8250df" \
  --description "Issue is complete or merged"

gh label create "needs-human-attention" \
  --color "b60205" \
  --description "Codex completed a PR but needs human attention"
```

## 类型 labels

```bash
gh label create "type:feature" \
  --color "a2eeef" \
  --description "Feature work"

gh label create "type:bug" \
  --color "d73a4a" \
  --description "Bug fix"

gh label create "type:refactor" \
  --color "c5def5" \
  --description "Refactor without behavior change"

gh label create "type:chore" \
  --color "ededed" \
  --description "Maintenance or tooling work"
```

如果 label 已存在，`gh label create` 会失败。可以忽略已存在错误，或用 `gh label edit` 调整颜色和描述。
