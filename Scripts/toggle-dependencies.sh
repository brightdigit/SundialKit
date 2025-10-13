#!/bin/bash
# Toggle between local and remote SundialKit dependencies in subrepos
# Usage: ./Scripts/toggle-dependencies.sh [local|remote]

set -euo pipefail

MODE="${1:-}"
PACKAGES_DIR="Packages"
SUBREPOS=("SundialKitStream" "SundialKitBinary" "SundialKitCombine" "SundialKitMessagable")

# Remote URL for SundialKit
REMOTE_URL="https://github.com/brightdigit/SundialKit.git"
REMOTE_BRANCH="branch: \"v2.0.0\""
LOCAL_PATH="../../"

if [[ "$MODE" != "local" && "$MODE" != "remote" ]]; then
  echo "Usage: $0 [local|remote]"
  echo ""
  echo "  local  - Use local path dependencies (for monorepo development)"
  echo "  remote - Use remote URL dependencies (before git subrepo push)"
  exit 1
fi

echo "Switching dependencies to $MODE mode..."

for subrepo in "${SUBREPOS[@]}"; do
  package_file="$PACKAGES_DIR/$subrepo/Package.swift"

  if [[ ! -f "$package_file" ]]; then
    echo "⚠️  Skipping $subrepo - Package.swift not found"
    continue
  fi

  if [[ "$MODE" == "local" ]]; then
    # Switch to local path
    echo "  📦 $subrepo -> local path"
    sed -i '' \
      -e 's|\.package(url: "'"$REMOTE_URL"'", '"$REMOTE_BRANCH"')|.package(path: "'"$LOCAL_PATH"'")|g' \
      "$package_file"
  else
    # Switch to remote URL
    echo "  🌐 $subrepo -> remote URL"
    sed -i '' \
      -e 's|\.package(path: "'"$LOCAL_PATH"'")|.package(url: "'"$REMOTE_URL"'", '"$REMOTE_BRANCH"')|g' \
      "$package_file"
  fi
done

echo ""
echo "✅ Dependencies switched to $MODE mode"

if [[ "$MODE" == "local" ]]; then
  echo ""
  echo "⚠️  Note: These changes are for local development only."
  echo "   Run './Scripts/toggle-dependencies.sh remote' before committing"
  echo "   or running 'git subrepo push'"
fi
