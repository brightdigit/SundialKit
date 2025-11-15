#!/bin/bash
# Ensure Package.swift uses remote SundialKit dependency
# Used in CI to guarantee remote URLs are configured

set -euo pipefail

REMOTE_URL="https://github.com/brightdigit/SundialKit.git"
REMOTE_BRANCH="branch: \"48-demo-applications-part-3\""
LOCAL_PATH="../../"

PACKAGE_FILE="Package.swift"

if [[ ! -f "$PACKAGE_FILE" ]]; then
  echo "❌ Package.swift not found"
  exit 1
fi

# Check if already using remote URL
if grep -q "\.package(name: \"SundialKit\", url: \"$REMOTE_URL\"" "$PACKAGE_FILE"; then
  echo "✅ Already using remote dependency"
  exit 0
fi

# Switch from local to remote
if grep -q "\.package(name: \"SundialKit\", path:" "$PACKAGE_FILE"; then
  echo "🔄 Switching to remote dependency..."
  # Cross-platform sed: use -i with empty string on macOS, without on Linux
  # Use multiline format to avoid SwiftLint line length warnings
  REPLACEMENT=".package(\n      name: \"SundialKit\",\n      url: \"$REMOTE_URL\",\n      $REMOTE_BRANCH\n    )"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' \
      -e 's|\.package(name: "SundialKit", path: "'"$LOCAL_PATH"'")|'"$REPLACEMENT"'|g' \
      "$PACKAGE_FILE"
  else
    sed -i \
      -e 's|\.package(name: "SundialKit", path: "'"$LOCAL_PATH"'")|'"$REPLACEMENT"'|g' \
      "$PACKAGE_FILE"
  fi
  echo "✅ Switched to remote dependency"
else
  echo "⚠️  Unknown dependency format in Package.swift"
  exit 1
fi
