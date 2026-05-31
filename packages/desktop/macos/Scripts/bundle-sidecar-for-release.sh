#!/usr/bin/env bash
set -euo pipefail

# ---- Only run for Release ----
if [ "${CONFIGURATION:-Debug}" != "Release" ]; then
  echo "Skipping sidecar bundle: not a Release build (${CONFIGURATION:-Debug})"
  if [ -n "${SCRIPT_OUTPUT_FILE_0:-}" ]; then
    mkdir -p "$(dirname "$SCRIPT_OUTPUT_FILE_0")"
    printf 'skipped %s\n' "${CONFIGURATION:-Debug}" > "$SCRIPT_OUTPUT_FILE_0"
  fi
  exit 0
fi

# ---- Resolve paths ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
SIDECAR_SRC="$MONOREPO_ROOT/packages/sidecar"
PROTOCOL_SRC="$MONOREPO_ROOT/packages/protocol"
POSTGRES_SRC="$MONOREPO_ROOT/third_party/postgres/macos"
RESOURCES_DIR="$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH/Resources"
SIDECAR_BUNDLE_DIR="$RESOURCES_DIR/sidecar"
POSTGRES_BUNDLE_DIR="$RESOURCES_DIR/postgres"
BUILD_TEMP_DIR="$(mktemp -d)"

cleanup() { rm -rf "$BUILD_TEMP_DIR"; }
trap cleanup EXIT

# ---- Find npm ----
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.volta/bin:$HOME/.asdf/shims:${PATH:-}"

find_npm() {
  if command -v npm >/dev/null 2>&1; then command -v npm; return 0; fi
  for candidate in \
    /opt/homebrew/bin/npm \
    /usr/local/bin/npm \
    "$HOME"/.volta/bin/npm \
    "$HOME"/.asdf/shims/npm \
    "$HOME"/.nvm/versions/node/*/bin/npm; do
    if [ -x "$candidate" ]; then echo "$candidate"; return 0; fi
  done
  return 1
}

NODE_VERSION="22.15.0"
NODE_CACHE_DIR="$HOME/.cache/kidmemory-build/nodejs"
NODE_ARCHES=(arm64 x64)

host_node_arch() {
  local arch="${CURRENT_ARCH:-${NATIVE_ARCH_ACTUAL:-$(uname -m)}}"
  arch="${arch%% *}"
  if [ "$arch" = "undefined_arch" ]; then
    arch="$(uname -m)"
  fi
  case "$arch" in
    arm64) echo "arm64" ;;
    x86_64|amd64) echo "x64" ;;
    *) echo "error: Unsupported build architecture: $arch" >&2; return 1 ;;
  esac
}

node_dir_for_arch() {
  echo "$NODE_CACHE_DIR/node-v${NODE_VERSION}-darwin-$1"
}

node_bin_for_arch() {
  echo "$(node_dir_for_arch "$1")/bin/node"
}

npm_bin_for_arch() {
  echo "$(node_dir_for_arch "$1")/bin/npm"
}

download_node_for_arch() {
  local node_arch="$1"
  local node_bin
  node_bin="$(node_bin_for_arch "$node_arch")"
  if [ -x "$node_bin" ]; then
    return 0
  fi
  NODE_TARBALL="node-v${NODE_VERSION}-darwin-${node_arch}.tar.gz"
  NODE_URL="https://nodejs.org/dist/v${NODE_VERSION}/${NODE_TARBALL}"
  echo "Bundle Sidecar: downloading Node.js ${NODE_VERSION} for darwin-${node_arch}..."
  curl -fsSL --retry 3 "$NODE_URL" -o "$NODE_CACHE_DIR/$NODE_TARBALL"
  tar -xzf "$NODE_CACHE_DIR/$NODE_TARBALL" -C "$NODE_CACHE_DIR"
}

# ---- Cache Node.js binaries ----
mkdir -p "$NODE_CACHE_DIR"
for node_arch in "${NODE_ARCHES[@]}"; do
  download_node_for_arch "$node_arch"
done

HOST_NODE_ARCH="$(host_node_arch)"
HOST_NODE_BIN="$(node_bin_for_arch "$HOST_NODE_ARCH")"
HOST_NPM_BIN="$(npm_bin_for_arch "$HOST_NODE_ARCH")"
export PATH="$(dirname "$HOST_NODE_BIN"):$PATH"

NPM=""
if [ -x "$HOST_NPM_BIN" ]; then
  NPM="$HOST_NPM_BIN"
else
  NPM="$(find_npm || true)"
fi
if [ -z "$NPM" ]; then
  echo "error: Cannot find npm. Install Node.js 22+ and try again."
  exit 1
fi
echo "Bundle Sidecar: using npm at $NPM"
echo "Bundle Sidecar: using host Node at $HOST_NODE_BIN"

# ---- Validate runtime sources ----
echo "Bundle Sidecar: validating runtime sources..."
cd "$SIDECAR_SRC"

if [ ! -d "node_modules" ]; then
  if [ -f "package-lock.json" ]; then
    "$NPM" ci
  else
    "$NPM" install
  fi
fi

"$NPM" run build:prod

# Keep local protocol package available for file-based dependency installs.
cp -R "$PROTOCOL_SRC" "$BUILD_TEMP_DIR/protocol"

# ---- Prepare production dependencies ----
echo "Bundle Sidecar: installing production dependencies..."
mkdir -p "$BUILD_TEMP_DIR/sidecar"
cp "$SIDECAR_SRC/package.json" "$BUILD_TEMP_DIR/sidecar/"
if [ -f "$SIDECAR_SRC/package-lock.json" ]; then
  cp "$SIDECAR_SRC/package-lock.json" "$BUILD_TEMP_DIR/sidecar/"
fi

cd "$BUILD_TEMP_DIR/sidecar"
if [ -f "package-lock.json" ]; then
  "$NPM" ci --no-audit --no-fund
else
  "$NPM" install --no-audit --no-fund
fi

# ---- Copy into .app bundle ----
echo "Bundle Sidecar: copying into $SIDECAR_BUNDLE_DIR"
rm -rf "$SIDECAR_BUNDLE_DIR"
mkdir -p "$SIDECAR_BUNDLE_DIR"

for node_arch in "${NODE_ARCHES[@]}"; do
  cp "$(node_bin_for_arch "$node_arch")" "$SIDECAR_BUNDLE_DIR/node-darwin-$node_arch"
  chmod +x "$SIDECAR_BUNDLE_DIR/node-darwin-$node_arch"
done
if command -v lipo >/dev/null 2>&1; then
  lipo -create \
    "$SIDECAR_BUNDLE_DIR/node-darwin-arm64" \
    "$SIDECAR_BUNDLE_DIR/node-darwin-x64" \
    -output "$SIDECAR_BUNDLE_DIR/node"
  chmod +x "$SIDECAR_BUNDLE_DIR/node"
  rm "$SIDECAR_BUNDLE_DIR/node-darwin-arm64" "$SIDECAR_BUNDLE_DIR/node-darwin-x64"
else
  echo "warning: lipo not found; runtime will select architecture-specific Node binary."
fi
cp -R "$SIDECAR_SRC/dist" "$SIDECAR_BUNDLE_DIR/dist"
# Prisma schema/migrations are the canonical runtime DB assets.
if [ -d "$SIDECAR_SRC/prisma" ]; then
  cp -R "$SIDECAR_SRC/prisma" "$SIDECAR_BUNDLE_DIR/prisma"
fi
if [ -f "$SIDECAR_SRC/prisma.config.ts" ]; then
  cp "$SIDECAR_SRC/prisma.config.ts" "$SIDECAR_BUNDLE_DIR/prisma.config.ts"
fi
cp -R "$BUILD_TEMP_DIR/sidecar/node_modules" "$SIDECAR_BUNDLE_DIR/node_modules"
cp "$BUILD_TEMP_DIR/sidecar/package.json" "$SIDECAR_BUNDLE_DIR/package.json"
mkdir -p "$SIDECAR_BUNDLE_DIR/node_modules/@kidmemory"
rm -rf "$SIDECAR_BUNDLE_DIR/node_modules/@kidmemory/protocol"
cp -R "$BUILD_TEMP_DIR/protocol" "$SIDECAR_BUNDLE_DIR/node_modules/@kidmemory/"
mkdir -p "$SIDECAR_BUNDLE_DIR/examples-dataset"
cp -R "$SIDECAR_SRC/examples-dataset" "$SIDECAR_BUNDLE_DIR/examples-dataset"

# ---- Bundle PostgreSQL runtime ----
echo "Bundle Sidecar: bundling PostgreSQL runtime into $POSTGRES_BUNDLE_DIR"
if [ ! -d "$POSTGRES_SRC/bin" ] || [ ! -d "$POSTGRES_SRC/lib" ] || [ ! -d "$POSTGRES_SRC/share" ]; then
  echo "error: PostgreSQL runtime is missing at $POSTGRES_SRC."
  echo "error: expected directories: bin/, lib/, share/"
  exit 1
fi
rm -rf "$POSTGRES_BUNDLE_DIR"
mkdir -p "$POSTGRES_BUNDLE_DIR"
cp -R "$POSTGRES_SRC/bin" "$POSTGRES_BUNDLE_DIR/bin"
cp -R "$POSTGRES_SRC/lib" "$POSTGRES_BUNDLE_DIR/lib"
cp -R "$POSTGRES_SRC/share" "$POSTGRES_BUNDLE_DIR/share"
find "$POSTGRES_BUNDLE_DIR/bin" -type f -exec chmod +x {} \;
find "$POSTGRES_BUNDLE_DIR/lib" -type f -exec chmod u+w {} \;

# Rewrite Homebrew absolute dylib paths to bundled relative loader paths.
rewrite_postgres_loader_paths() {
  local root="$1"
  local file rel prefix dep base
  while IFS= read -r file; do
    rel="${file#$root/}"
    case "$rel" in
      bin/*) prefix='@loader_path/../lib' ;;
      lib/postgresql/*) prefix='@loader_path/..' ;;
      lib/*) prefix='@loader_path' ;;
      *) continue ;;
    esac
    while IFS= read -r dep; do
      [ -z "$dep" ] && continue
      base="$(basename "$dep")"
      if [ -f "$root/lib/$base" ]; then
        install_name_tool -change "$dep" "$prefix/$base" "$file" || true
      fi
    done < <(otool -L "$file" | tail -n +2 | awk '{print $1}' | grep -E '^/opt/homebrew/|^/usr/local/' || true)
  done < <(find "$root/bin" "$root/lib" -type f \( -perm -111 -o -name '*.dylib' \))
}

rewrite_postgres_loader_paths "$POSTGRES_BUNDLE_DIR"

sign_postgres_runtime() {
  local root="$1"
  local identity="${EXPANDED_CODE_SIGN_IDENTITY:-}"
  local sign_args=(--force --timestamp=none)
  if [ -n "$identity" ]; then
    sign_args+=(--sign "$identity")
  else
    sign_args+=(--sign -)
  fi
  while IFS= read -r f; do
    codesign "${sign_args[@]}" "$f"
  done < <(find "$root" -type f \( -perm -111 -o -name '*.dylib' \))
}

echo "Bundle Sidecar: signing bundled PostgreSQL runtime..."
sign_postgres_runtime "$POSTGRES_BUNDLE_DIR"

cat > "$POSTGRES_BUNDLE_DIR/postgres-manifest.json" << EOFPGMANIFEST
{
  "kind": "bundled-postgres-runtime",
  "builtAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOFPGMANIFEST

# Write manifest
cat > "$SIDECAR_BUNDLE_DIR/sidecar-manifest.json" << EOFMANIFEST
{
  "version": "${NODE_VERSION}",
  "arches": ["arm64", "x64"],
  "universalNode": $([ -x "$SIDECAR_BUNDLE_DIR/node" ] && echo "true" || echo "false"),
  "builtAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOFMANIFEST

echo "Bundle Sidecar: sidecar size $(du -sh "$SIDECAR_BUNDLE_DIR" | cut -f1)"
echo "Bundle Sidecar: postgres size $(du -sh "$POSTGRES_BUNDLE_DIR" | cut -f1)"
echo "Bundle Sidecar: complete"
if [ -n "${SCRIPT_OUTPUT_FILE_0:-}" ]; then
  mkdir -p "$(dirname "$SCRIPT_OUTPUT_FILE_0")"
  printf 'bundled %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$SCRIPT_OUTPUT_FILE_0"
fi
