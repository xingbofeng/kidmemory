#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/agent-codex-tmux-run.sh --title TITLE --branch BRANCH --prompt-file FILE [options]

Options:
  --title TITLE          Human-readable task title.
  --branch BRANCH        Branch to create, for example feature/library-filter.
  --prompt-file FILE     Markdown task description to pass to Codex.
  --base BRANCH          Base branch. Default: main.
  --worktree-root DIR    Worktree parent directory. Default: ../kidmemory-agent-worktrees.
  --session NAME         tmux session name. Default: derived from branch.
  --model MODEL          Optional Codex model override.
  --help                 Show this help.

This script creates a git worktree, writes an agent task prompt, and starts a
detached tmux session that runs codex exec in the worktree.
USAGE
}

title=""
branch=""
prompt_file=""
base_branch="main"
worktree_root=""
session_name=""
model=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)
      title="${2:-}"
      shift 2
      ;;
    --branch)
      branch="${2:-}"
      shift 2
      ;;
    --prompt-file)
      prompt_file="${2:-}"
      shift 2
      ;;
    --base)
      base_branch="${2:-}"
      shift 2
      ;;
    --worktree-root)
      worktree_root="${2:-}"
      shift 2
      ;;
    --session)
      session_name="${2:-}"
      shift 2
      ;;
    --model)
      model="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$title" || -z "$branch" || -z "$prompt_file" ]]; then
  echo "Missing required --title, --branch, or --prompt-file." >&2
  usage >&2
  exit 2
fi

if [[ ! -f "$prompt_file" ]]; then
  echo "Prompt file not found: $prompt_file" >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git is required." >&2
  exit 1
fi

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux is required." >&2
  exit 1
fi

if ! command -v codex >/dev/null 2>&1; then
  echo "codex CLI is required." >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI is required because the Codex goal is expected to create a PR." >&2
  exit 1
fi

system_git="/usr/bin/git"
if [[ ! -x "$system_git" ]]; then
  system_git="$(command -v git)"
fi

system_gh="/opt/homebrew/bin/gh"
if [[ ! -x "$system_gh" ]]; then
  system_gh="$(command -v gh)"
fi

repo_root="$(git rev-parse --show-toplevel)"
repo_name="$(basename "$repo_root")"

if [[ -z "$worktree_root" ]]; then
  worktree_root="$(cd "$repo_root/.." && pwd)/${repo_name}-agent-worktrees"
fi

safe_branch="${branch//\//-}"
safe_branch="${safe_branch//[^A-Za-z0-9._-]/-}"
worktree_path="$worktree_root/$safe_branch"

if [[ -z "$session_name" ]]; then
  session_name="kidmemory-${safe_branch}"
fi

task_dir="$worktree_path/.agent-task"
goal_file="$task_dir/codex-goal.md"
events_file="$task_dir/codex-events.jsonl"
last_message_file="$task_dir/codex-last-message.md"
run_script="$task_dir/run-codex.sh"
env_file="$task_dir/runtime-env.txt"
runner_user="${USER:-counter}"
resolved_user_home="$(dscl . -read "/Users/$runner_user" NFSHomeDirectory 2>/dev/null | awk '{print $2}' || true)"
if [[ -z "$resolved_user_home" ]]; then
  resolved_user_home="$(eval echo "~$runner_user" 2>/dev/null || true)"
fi
if [[ -z "$resolved_user_home" || "$resolved_user_home" == "~$runner_user" ]]; then
  resolved_user_home="${HOME:-/Users/counter}"
fi
runner_home="$resolved_user_home"
runner_logname="${LOGNAME:-$runner_user}"
runner_shell="${SHELL:-/bin/zsh}"
runner_path="${PATH:-/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/Users/counter/.local/bin}"
runner_lang="${LANG:-C.UTF-8}"
runner_lc_all="${LC_ALL:-C.UTF-8}"
runner_lc_ctype="${LC_CTYPE:-C.UTF-8}"
runner_codex_home="${CODEX_HOME:-$runner_home/.codex}"
runner_ssh_auth_sock="${SSH_AUTH_SOCK:-}"

runner_path="${runner_path#/Users/counter/.hermes/profiles/developer/bin:}"

if [[ ! -f "$runner_codex_home/auth.json" && -f "$runner_home/.codex/auth.json" ]]; then
  runner_codex_home="$runner_home/.codex"
fi

mkdir -p "$worktree_root"

cd "$repo_root"
origin_url="$("$system_git" remote get-url origin 2>/dev/null || true)"
use_https_rewrite="false"
if [[ "$origin_url" == git@github.com:* ]] && "$system_gh" auth status -h github.com >/dev/null 2>&1; then
  use_https_rewrite="true"
fi

git_fetch_cmd=("$system_git" fetch origin "$base_branch")
if [[ "$use_https_rewrite" == "true" ]]; then
  git_fetch_cmd=(
    "$system_git"
    -c
    url."https://github.com/".insteadOf=git@github.com:
    fetch
    origin
    "$base_branch"
  )
fi
"${git_fetch_cmd[@]}"

if [[ -d "$worktree_path/.git" || -f "$worktree_path/.git" ]]; then
  echo "Reusing existing worktree: $worktree_path"
else
  "$system_git" worktree add "$worktree_path" -b "$branch" "origin/$base_branch"
fi

mkdir -p "$task_dir"

if [[ "$use_https_rewrite" == "true" ]]; then
  "$system_git" -C "$worktree_path" config url."https://github.com/".insteadOf git@github.com:
fi

cat > "$goal_file" <<EOF
# Codex 长时开发任务

你是 KidMemory 的 Codex 开发 worker。

请在当前 worktree 中完成以下任务。你需要尽力实现、运行相关验证命令、创建一个 commit、push 当前分支，并使用 gh CLI 创建 PR。

## 固定约束

- 使用中文回复和中文 PR body。
- 遵守仓库 AGENTS.md。
- 不修改与任务无关的文件。
- 不在主工作区工作，只在当前 worktree 工作。
- 最终尽量保持一个 commit。
- commit 使用中文 Conventional Commit。
- commit trailer 必须包含：Co-authored-by: OpenAI Codex <codex@openai.com>
- PR 不要自动 merge。
- 如果测试失败或实现不完整，仍然创建 PR，并在 PR body 写清楚。

## 任务标题

$title

## 建议分支

$branch

## 开发者提供的任务说明

$(cat "$prompt_file")
EOF

cat > "$run_script" <<EOF
#!/usr/bin/env bash
set -euo pipefail
export HOME="$runner_home"
export USER="$runner_user"
export LOGNAME="$runner_logname"
export SHELL="$runner_shell"
export PATH="$runner_path"
export LANG="$runner_lang"
export LC_ALL="$runner_lc_all"
export LC_CTYPE="$runner_lc_ctype"
export CODEX_HOME="$runner_codex_home"
export GH_CONFIG_DIR="$runner_home/.config/gh"
if [[ -n "$runner_ssh_auth_sock" ]]; then
  export SSH_AUTH_SOCK="$runner_ssh_auth_sock"
fi
cd "$worktree_path"
env | sort > "$env_file"
echo "[agent] worktree: $worktree_path"
echo "[agent] branch: $branch"
echo "[agent] goal: $goal_file"
echo "[agent] events: $events_file"
echo "[agent] last message: $last_message_file"
echo "[agent] env: $env_file"
codex_args=(
  exec
  --cd "$worktree_path"
  --sandbox workspace-write
  --json
  --output-last-message "$last_message_file"
)
if [[ -n "$model" ]]; then
  codex_args+=(--model "$model")
fi
codex_args+=(-)
codex "\${codex_args[@]}" < "$goal_file" > "$events_file" 2>&1
EOF

chmod +x "$run_script"

if tmux has-session -t "$session_name" 2>/dev/null; then
  echo "tmux session already exists: $session_name" >&2
  echo "Attach with: tmux attach -t $session_name" >&2
  exit 1
fi

tmux new-session -d -s "$session_name" "$run_script"

cat <<EOF
Started Codex tmux task.

Title: $title
Session: $session_name
Branch: $branch
Worktree: $worktree_path
Goal: $goal_file
Events: $events_file
Last message: $last_message_file
Runtime env: $env_file

Attach:
  tmux attach -t $session_name

Tail logs:
  tail -n 80 "$events_file"
EOF
