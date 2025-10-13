#!/bin/bash
# Run linting on main directory and all subrepos
# Usage: ./Scripts/lint-all.sh [--skip-main] [--skip-subrepos]

set -euo pipefail

SKIP_MAIN=false
SKIP_SUBREPOS=false
FAILED_PACKAGES=()
SUCCESS_PACKAGES=()

# Parse arguments
for arg in "$@"; do
  case $arg in
    --skip-main)
      SKIP_MAIN=true
      shift
      ;;
    --skip-subrepos)
      SKIP_SUBREPOS=true
      shift
      ;;
    *)
      ;;
  esac
done

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUBREPOS=("SundialKitStream" "SundialKitBinary" "SundialKitCombine" "SundialKitMessagable")

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         SundialKit Monorepo Linting                           ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Function to run lint in a directory
run_lint() {
  local package_name="$1"
  local package_dir="$2"

  echo "┌────────────────────────────────────────────────────────────────┐"
  echo "│ Linting: $package_name"
  echo "└────────────────────────────────────────────────────────────────┘"

  if [ ! -f "$package_dir/Scripts/lint.sh" ]; then
    echo "⚠️  No lint.sh found in $package_dir/Scripts/"
    echo ""
    return 0
  fi

  pushd "$package_dir" > /dev/null

  if ./Scripts/lint.sh; then
    echo "✅ $package_name: Linting passed"
    SUCCESS_PACKAGES+=("$package_name")
  else
    echo "❌ $package_name: Linting failed"
    FAILED_PACKAGES+=("$package_name")
  fi

  popd > /dev/null
  echo ""
}

# Lint main directory
if [ "$SKIP_MAIN" = false ]; then
  run_lint "SundialKit (main)" "$PROJECT_ROOT"
fi

# Lint subrepos
if [ "$SKIP_SUBREPOS" = false ]; then
  for subrepo in "${SUBREPOS[@]}"; do
    subrepo_dir="$PROJECT_ROOT/Packages/$subrepo"

    if [ ! -d "$subrepo_dir" ]; then
      echo "⚠️  Subrepo directory not found: $subrepo_dir"
      echo ""
      continue
    fi

    run_lint "$subrepo" "$subrepo_dir"
  done
fi

# Print summary
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         Linting Summary                                        ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

if [ ${#SUCCESS_PACKAGES[@]} -gt 0 ]; then
  echo "✅ Passed (${#SUCCESS_PACKAGES[@]}):"
  for pkg in "${SUCCESS_PACKAGES[@]}"; do
    echo "   - $pkg"
  done
  echo ""
fi

if [ ${#FAILED_PACKAGES[@]} -gt 0 ]; then
  echo "❌ Failed (${#FAILED_PACKAGES[@]}):"
  for pkg in "${FAILED_PACKAGES[@]}"; do
    echo "   - $pkg"
  done
  echo ""
  exit 1
else
  echo "🎉 All packages passed linting!"
  exit 0
fi
