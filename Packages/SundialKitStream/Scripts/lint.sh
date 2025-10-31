#!/bin/bash

# Remove set -e to allow script to continue running
# set -e  # Exit on any error

ERRORS=0

run_command() {
	if [ "$LINT_MODE" = "STRICT" ]; then
		"$@" || ERRORS=$((ERRORS + 1))
	else
		"$@"
	fi
}

if [ "$LINT_MODE" = "INSTALL" ]; then
	exit
fi

echo "LintMode: $LINT_MODE"

# More portable way to get script directory
if [ -z "$SRCROOT" ]; then
	SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
	PACKAGE_DIR="${SCRIPT_DIR}/.."
else
	PACKAGE_DIR="${SRCROOT}"
fi

# Detect if mise is available
if command -v mise &> /dev/null; then
    TOOL_CMD="mise exec --"
else
    echo "Error: mise is not installed"
    echo "Install mise: https://mise.jdx.dev/getting-started.html"
    exit 1
fi

if [ "$LINT_MODE" = "NONE" ]; then
	exit
elif [ "$LINT_MODE" = "STRICT" ]; then
	SWIFTFORMAT_OPTIONS="--configuration .swift-format"
	SWIFTLINT_OPTIONS="--strict"
else
	SWIFTFORMAT_OPTIONS="--configuration .swift-format"
	SWIFTLINT_OPTIONS=""
fi

pushd $PACKAGE_DIR

# Bootstrap tools (mise will install based on .mise.toml)
run_command mise install

if [ -z "$CI" ]; then
	run_command $TOOL_CMD swift-format format $SWIFTFORMAT_OPTIONS  --recursive --parallel --in-place Sources Tests
	run_command $TOOL_CMD swiftlint --fix
fi

if [ -z "$FORMAT_ONLY" ]; then
	run_command $TOOL_CMD swift-format lint --configuration .swift-format --recursive --parallel $SWIFTFORMAT_OPTIONS Sources Tests
	run_command $TOOL_CMD swiftlint lint $SWIFTLINT_OPTIONS
	# Check for compilation errors
	run_command swift build --build-tests
fi

$PACKAGE_DIR/Scripts/header.sh -d  $PACKAGE_DIR/Sources -c "Leo Dion" -o "BrightDigit" -p "SundialKitStream"

if [ -z "$CI" ]; then
	run_command $TOOL_CMD periphery scan $PERIPHERY_OPTIONS --disable-update-check
fi

popd

# Exit with error code if any errors occurred
if [ $ERRORS -gt 0 ]; then
	echo "Linting completed with $ERRORS error(s)"
	exit 1
else
	echo "Linting completed successfully"
	exit 0
fi
