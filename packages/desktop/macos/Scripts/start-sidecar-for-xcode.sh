#!/usr/bin/env bash
set -euo pipefail

PORT="${KIDMEMORY_SIDECAR_PORT:-4317}"
HOST="${KIDMEMORY_SIDECAR_HOST:-127.0.0.1}"
LOG_FILE="${TMPDIR:-/tmp}/kidmemory-sidecar-xcode.log"
PID_FILE="${TMPDIR:-/tmp}/kidmemory-sidecar-xcode.pid"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIDECAR_DIR="$(cd "$SCRIPT_DIR/../../../sidecar" && pwd)"

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.volta/bin:$HOME/.asdf/shims:${PATH:-}"

# Expand nvm paths if any
for nvm_bin in "$HOME"/.nvm/versions/node/*/bin; do
  if [ -d "$nvm_bin" ]; then
    PATH="$nvm_bin:$PATH"
  fi
done

find_npm() {
  if command -v npm >/dev/null 2>&1; then
    command -v npm
    return 0
  fi

  for candidate in \
    /opt/homebrew/bin/npm \
    /usr/local/bin/npm \
    "$HOME"/.volta/bin/npm \
    "$HOME"/.asdf/shims/npm \
    "$HOME"/.nvm/versions/node/*/bin/npm; do
    if [ -x "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done

  return 1
}

postgres_ready() {
  for pg_isready_bin in \
    /opt/homebrew/opt/postgresql@16/bin/pg_isready \
    /usr/local/opt/postgresql@16/bin/pg_isready \
    /opt/homebrew/bin/pg_isready \
    /usr/local/bin/pg_isready; do
    if [ -x "$pg_isready_bin" ] && "$pg_isready_bin" -h 127.0.0.1 -p 5432 >/dev/null 2>&1; then
      return 0
    fi
  done

  if command -v pg_isready >/dev/null 2>&1 && pg_isready -h 127.0.0.1 -p 5432 >/dev/null 2>&1; then
    return 0
  fi

  if command -v brew >/dev/null 2>&1 && brew services list 2>/dev/null | grep -Eq '^postgresql(@[0-9]+)?[[:space:]]+started\b'; then
    return 0
  fi

  return 1
}

is_child_of() {
  local child_pid="$1"
  local parent_pid="$2"
  local cursor="$child_pid"
  while [ -n "$cursor" ] && [ "$cursor" != "1" ]; do
    if [ "$cursor" = "$parent_pid" ]; then
      return 0
    fi
    cursor="$(ps -o ppid= -p "$cursor" 2>/dev/null | tr -d '[:space:]' || true)"
  done
  return 1
}

stop_managed_sidecar() {
  local root_pid="$1"
  local port_pid="$2"
  echo "Restarting previously managed KidMemory sidecar (pid $root_pid, listener $port_pid)"
  kill "$root_pid" "$port_pid" >/dev/null 2>&1 || true
  for _ in $(seq 1 20); do
    if ! /usr/sbin/lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
      rm -f "$PID_FILE"
      return 0
    fi
    sleep 0.1
  done
  kill -9 "$root_pid" "$port_pid" >/dev/null 2>&1 || true
  rm -f "$PID_FILE"
}

# ---- Check if already running ----
EXISTING_PID=$(/usr/sbin/lsof -nP -iTCP:"$PORT" -sTCP:LISTEN -t 2>/dev/null | head -n 1 || true)
MANAGED_PID="$(cat "$PID_FILE" 2>/dev/null || true)"
if [ -n "$EXISTING_PID" ]; then
  if [ -n "$MANAGED_PID" ] && ps -p "$MANAGED_PID" >/dev/null 2>&1 && is_child_of "$EXISTING_PID" "$MANAGED_PID"; then
    stop_managed_sidecar "$MANAGED_PID" "$EXISTING_PID"
  elif command -v curl >/dev/null 2>&1 && curl -fsS "http://$HOST:$PORT/health" 2>/dev/null | grep -q "kidmemory-sidecar"; then
    echo "KidMemory sidecar is already listening on $HOST:$PORT (PID $EXISTING_PID)"
    exit 0
  else
    echo "Port $HOST:$PORT is already occupied by PID $EXISTING_PID, but it is not a KidMemory sidecar."
    echo "Stop that process before running KidMemory from Xcode."
    exit 0
  fi
fi

# Start sidecar even when PostgreSQL is not ready; the sidecar API returns the
# readiness diagnostics that the Flutter setup page needs.
if ! postgres_ready; then
  echo "PostgreSQL is not running on 127.0.0.1:5432; starting sidecar anyway."
fi

# ---- Find npm ----
NPM_BIN="$(find_npm || true)"
if [ -z "$NPM_BIN" ]; then
  echo "KidMemory sidecar cannot find npm in Xcode's environment."
  echo "Install Node.js 22+ via Homebrew, Volta, asdf, or nvm."
  exit 0
fi
echo "npm: $NPM_BIN"

# ---- Install dependencies if missing ----
if [ ! -d "$SIDECAR_DIR/node_modules" ]; then
  echo "Installing sidecar dependencies..."
  if [ -f "$SIDECAR_DIR/package-lock.json" ]; then
    cd "$SIDECAR_DIR" && "$NPM_BIN" ci
  else
    cd "$SIDECAR_DIR" && "$NPM_BIN" install
  fi
fi

# ---- Start sidecar ----
echo "Starting KidMemory sidecar on $HOST:$PORT"
echo "Log: $LOG_FILE"

(
  cd "$SIDECAR_DIR"
  nohup env \
    KIDMEMORY_SIDECAR_HOST="$HOST" \
    KIDMEMORY_SIDECAR_PORT="$PORT" \
    "$NPM_BIN" run dev >>"$LOG_FILE" 2>&1 </dev/null &
  echo $! >"$PID_FILE"
)

for _ in $(seq 1 40); do
  if /usr/sbin/lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
    echo "KidMemory sidecar started with pid $(cat "$PID_FILE")"
    exit 0
  fi
  sleep 0.25
done

echo "KidMemory sidecar did not listen on $HOST:$PORT yet. Check $LOG_FILE"
