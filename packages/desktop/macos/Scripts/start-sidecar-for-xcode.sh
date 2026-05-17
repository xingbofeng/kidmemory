#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
SIDECAR_SRC="$MONOREPO_ROOT/packages/sidecar"
POSTGRES_RUNTIME_SRC="$MONOREPO_ROOT/third_party/postgres/macos"

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.volta/bin:$HOME/.asdf/shims:${PATH:-}"

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

NPM="$(find_npm || true)"
if [ -z "$NPM" ]; then
  echo "error: Cannot find npm. Install Node.js 22+ and try again."
  exit 1
fi

echo "Build Sidecar: using npm at $NPM"
cd "$SIDECAR_SRC"

if [ ! -d "node_modules" ]; then
  echo "Build Sidecar: installing dependencies..."
  if [ -f "package-lock.json" ]; then
    "$NPM" ci
  else
    "$NPM" install
  fi
fi

echo "Build Sidecar: generating Prisma client..."
"$NPM" run prisma:generate

echo "Build Sidecar: compiling TypeScript for Xcode Debug runtime..."
set +e
"$NPM" exec -- tsc -p tsconfig.build.json --noEmitOnError false
TSC_EXIT=$?
set -e

if [ "$TSC_EXIT" -ne 0 ]; then
  echo "warning: Sidecar TypeScript reported errors, but Debug build will use emitted JavaScript if available."
fi

if [ ! -f "dist/main.js" ]; then
  echo "error: Sidecar build did not produce dist/main.js."
  exit "$TSC_EXIT"
fi

link_path() {
  local source="$1"
  local target="$2"
  if [ -e "$target" ] || [ -L "$target" ]; then
    rm -rf "$target"
  fi
  ln -s "$source" "$target"
}

link_sidecar_runtime_for_debug_app() {
  if [ -z "${BUILT_PRODUCTS_DIR:-}" ] || [ -z "${CONTENTS_FOLDER_PATH:-}" ]; then
    return 0
  fi

  local resources_dir="$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH/Resources"
  local sidecar_runtime_dir="$resources_dir/sidecar"
  mkdir -p "$sidecar_runtime_dir"

  link_path "$SIDECAR_SRC/dist" "$sidecar_runtime_dir/dist"
  link_path "$SIDECAR_SRC/node_modules" "$sidecar_runtime_dir/node_modules"
  link_path "$SIDECAR_SRC/package.json" "$sidecar_runtime_dir/package.json"
  link_path "$SIDECAR_SRC/prisma" "$sidecar_runtime_dir/prisma"
  if [ -f "$SIDECAR_SRC/prisma.config.ts" ]; then
    link_path "$SIDECAR_SRC/prisma.config.ts" "$sidecar_runtime_dir/prisma.config.ts"
  fi
  if [ -d "$MONOREPO_ROOT/examples" ]; then
    link_path "$MONOREPO_ROOT/examples" "$sidecar_runtime_dir/examples"
  fi

  cat > "$sidecar_runtime_dir/sidecar-manifest.json" << EOFMANIFEST
{
  "kind": "debug-linked-sidecar",
  "source": "$SIDECAR_SRC"
}
EOFMANIFEST

  if [ -d "$POSTGRES_RUNTIME_SRC/bin" ] &&
     [ -d "$POSTGRES_RUNTIME_SRC/lib" ] &&
     [ -d "$POSTGRES_RUNTIME_SRC/share" ]; then
    link_path "$POSTGRES_RUNTIME_SRC" "$resources_dir/postgres"
  fi

  echo "Build Sidecar: linked debug sidecar runtime at $sidecar_runtime_dir"
}

link_sidecar_runtime_for_debug_app

echo "Build Sidecar: dist/main.js is ready for desktop launcher."
