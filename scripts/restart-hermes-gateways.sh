#!/usr/bin/env bash
set -euo pipefail

profiles=(overseer pm developer tester)

base_path="/Users/counter/.hermes/hermes-agent/venv/bin:/Users/counter/.hermes/hermes-agent/node_modules/.bin:/opt/homebrew/Cellar/node/26.0.0/bin:/Users/counter/.local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Applications/Ghostty.app/Contents/MacOS"
main_home="/Users/counter"
main_gh_config_dir="/Users/counter/.config/gh"
main_codex_home="/Users/counter/.codex"

for profile in "${profiles[@]}"; do
  pkill -f "hermes.*--profile ${profile}.*gateway run --replace" || true
done

sleep 2

for profile in "${profiles[@]}"; do
  profile_bin="/Users/counter/.hermes/profiles/${profile}/bin"
  if [[ -d "$profile_bin" ]]; then
    launch_path="${profile_bin}:${base_path}"
  else
    launch_path="${base_path}"
  fi

  nohup env PATH="$launch_path" HOME="$main_home" GH_CONFIG_DIR="$main_gh_config_dir" CODEX_HOME="$main_codex_home" HERMES_KANBAN_DISPATCH_IN_GATEWAY=0 HERMES_YOLO_MODE=1 HERMES_ACCEPT_HOOKS=1 \
    hermes --profile "$profile" gateway run --replace \
    > "/Users/counter/.hermes/profiles/${profile}/gateway.nohup.log" 2>&1 &
done

sleep 4

for profile in "${profiles[@]}"; do
  echo "--- ${profile} ---"
  pgrep -fl "hermes.*--profile ${profile}.*gateway run --replace" || true
done
