#!/bin/bash
# preview-docs.sh
# DocC documentation preview with auto-rebuild
#
# Copyright (c) 2025 BrightDigit, LLC

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
DEFAULT_PORT=8080
CATALOG_PATH=""
PORT=$DEFAULT_PORT
NO_WATCH=false
NO_SERVER=false
CLEAN=false
WATCH_PID=""
SERVER_PID=""

# Build output directories
SYMBOL_GRAPH_DIR=".build/symbol-graphs"

# Usage information
usage() {
  cat <<EOF
Usage: $(basename "$0") <catalog-path> [OPTIONS]

DocC documentation preview with auto-rebuild on file changes.

Arguments:
  <catalog-path>        Path to .docc catalog directory
                        Example: Sources/SundialKit/SundialKit.docc

Options:
  --port <number>       Preview server port (default: 8080)
  --no-watch            Build once, don't watch for changes
  --no-server           Build only, don't start preview server
  --clean               Clean build artifacts before building
  --help                Show this help message

Examples:
  $(basename "$0") Sources/SundialKit/SundialKit.docc
  $(basename "$0") Sources/SundialKit/SundialKit.docc --port 8081
  $(basename "$0") Sources/SundialKit/SundialKit.docc --no-watch

Note: This script requires fswatch for auto-rebuild functionality.
Install with: brew install fswatch
EOF
}

# Parse command-line arguments
# First positional argument is catalog path
if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]]; then
  usage
  exit 0
fi

# Check if first argument is a flag
if [[ "$1" == --* ]]; then
  echo -e "${RED}Error: First argument must be the catalog path${NC}"
  usage
  exit 1
fi

CATALOG_PATH="$1"
shift

# Parse remaining options
while [[ $# -gt 0 ]]; do
  case $1 in
    --port)
      PORT="$2"
      shift 2
      ;;
    --no-watch)
      NO_WATCH=true
      shift
      ;;
    --no-server)
      NO_SERVER=true
      shift
      ;;
    --clean)
      CLEAN=true
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      echo -e "${RED}Error: Unknown option: $1${NC}"
      usage
      exit 1
      ;;
  esac
done

# Validate catalog path exists
if [ -z "$CATALOG_PATH" ]; then
  echo -e "${RED}Error: Catalog path is required${NC}"
  usage
  exit 1
fi

if [ ! -d "$CATALOG_PATH" ]; then
  echo -e "${RED}Error: Catalog directory not found: $CATALOG_PATH${NC}"
  exit 1
fi

# Extract catalog name for output
CATALOG_NAME=$(basename "$CATALOG_PATH" .docc)

# Cleanup function
cleanup() {
  echo ""
  echo -e "${YELLOW}Shutting down...${NC}"

  if [ -n "$WATCH_PID" ]; then
    kill "$WATCH_PID" 2>/dev/null || true
  fi

  if [ -n "$SERVER_PID" ]; then
    kill "$SERVER_PID" 2>/dev/null || true
  fi

  # Kill any background jobs
  jobs -p | xargs -r kill 2>/dev/null || true

  echo -e "${GREEN}Cleanup complete${NC}"
  exit 0
}

# Register cleanup on exit
trap cleanup EXIT INT TERM

# Clean build artifacts if requested
if [ "$CLEAN" = true ]; then
  echo -e "${BLUE}Cleaning build artifacts...${NC}"
  rm -rf "$SYMBOL_GRAPH_DIR" .build/docc .build/docs
fi

# Build and extract symbol graphs
build_symbols() {
  echo ""
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}Preparing documentation for $CATALOG_NAME${NC}"
  echo -e "${BLUE}========================================${NC}"

  # Step 1: Build all targets
  echo -e "${YELLOW}Building Swift targets...${NC}"
  if ! swift build 2>&1 | grep -E "(Building|Build complete|error:|warning:)"; then
    echo -e "${RED}Error: Swift build failed${NC}"
    return 1
  fi
  echo -e "${GREEN}✓ Build complete${NC}"

  # Step 2: Extract symbol graphs
  echo -e "${YELLOW}Extracting symbol graphs...${NC}"

  # Use swift package dump-symbol-graph (writes to .build/<arch>/symbolgraph/)
  if swift package dump-symbol-graph 2>&1 | grep -q "Emitting symbol graph"; then
    # Find the symbolgraph directory (architecture-specific)
    BUILT_SYMBOL_DIR=$(find .build -type d -name "symbolgraph" 2>/dev/null | head -1)

    if [ -n "$BUILT_SYMBOL_DIR" ] && [ -d "$BUILT_SYMBOL_DIR" ]; then
      # Use the built directory directly instead of copying
      SYMBOL_GRAPH_DIR="$BUILT_SYMBOL_DIR"
      echo -e "${GREEN}✓ Symbol graphs extracted to $SYMBOL_GRAPH_DIR${NC}"
    else
      echo -e "${YELLOW}  Warning: No symbol graphs found. Documentation will only include catalog content.${NC}"
      SYMBOL_GRAPH_DIR=""
    fi
  else
    echo -e "${YELLOW}  Warning: Symbol graph extraction failed. Documentation will only include catalog content.${NC}"
    SYMBOL_GRAPH_DIR=""
  fi

  echo -e "${BLUE}========================================${NC}"
  return 0
}

# Build symbols initially (only if not using docc preview's built-in watch)
if [ "$NO_SERVER" = true ]; then
  # For no-server mode, we need to build symbols and run docc convert
  if ! build_symbols; then
    echo -e "${RED}Symbol graph generation failed${NC}"
    exit 1
  fi

  echo -e "${YELLOW}Converting to DocC archive...${NC}"

  # Build docc convert command
  DOCC_CMD=(xcrun docc convert "$CATALOG_PATH"
    --fallback-display-name "$CATALOG_NAME"
    --fallback-bundle-identifier "com.brightdigit.$(echo "$CATALOG_NAME" | tr '[:upper:]' '[:lower:]')"
    --fallback-bundle-version "2.0.0"
    --output-path ".build/docs/$CATALOG_NAME.doccarchive")

  # Add symbol graphs if available
  if [ -n "$(ls -A "$SYMBOL_GRAPH_DIR" 2>/dev/null)" ]; then
    DOCC_CMD+=(--additional-symbol-graph-dir "$SYMBOL_GRAPH_DIR")
  fi

  if ! "${DOCC_CMD[@]}"; then
    echo -e "${RED}Error: DocC conversion failed${NC}"
    exit 1
  fi

  echo -e "${GREEN}✓ DocC archive created at .build/docs/$CATALOG_NAME.doccarchive${NC}"
  echo -e "${BLUE}========================================${NC}"
  exit 0
fi

# For server mode, build symbols first
if ! build_symbols; then
  echo -e "${RED}Symbol graph generation failed${NC}"
  exit 1
fi

# Start preview server using docc preview
echo ""
echo -e "${BLUE}Starting documentation preview server...${NC}"

# Build docc preview command
DOCC_PREVIEW_CMD=(xcrun docc preview "$CATALOG_PATH"
  --port "$PORT"
  --fallback-display-name "$CATALOG_NAME"
  --fallback-bundle-identifier "com.brightdigit.$(echo "$CATALOG_NAME" | tr '[:upper:]' '[:lower:]')"
  --fallback-bundle-version "2.0.0")

# Add symbol graphs if available
if [ -n "$(ls -A "$SYMBOL_GRAPH_DIR" 2>/dev/null)" ]; then
  DOCC_PREVIEW_CMD+=(--additional-symbol-graph-dir "$SYMBOL_GRAPH_DIR")
fi

# Start docc preview in background (it has its own watch mode if --no-watch is not set)
"${DOCC_PREVIEW_CMD[@]}" &
SERVER_PID=$!

# Wait for server to start
sleep 3

# Check if server is still running
if ! kill -0 "$SERVER_PID" 2>/dev/null; then
  echo -e "${RED}Error: Preview server failed to start${NC}"
  echo -e "${YELLOW}Check the output above for errors${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Preview server running${NC}"
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}📚 Documentation available at:${NC}"
echo -e "${BLUE}   http://localhost:$PORT/documentation/$(echo "$CATALOG_NAME" | tr '[:upper:]' '[:lower:]')${NC}"
echo -e "${GREEN}========================================${NC}"

# If --no-watch, docc preview will still watch the catalog
# For file watching of Swift source files, we add our own watcher
if [ "$NO_WATCH" = false ]; then
  # Check if fswatch is installed
  if ! command -v fswatch &> /dev/null; then
    echo ""
    echo -e "${YELLOW}Note: fswatch not found. Source file watching disabled.${NC}"
    echo -e "${YELLOW}Install with: brew install fswatch for auto-rebuild on source changes${NC}"
    echo -e "${BLUE}DocC will still watch the catalog for changes.${NC}"
    echo ""
    echo -e "${BLUE}Press Ctrl+C to stop the preview server${NC}"
    wait $SERVER_PID
  else
    echo ""
    echo -e "${BLUE}Watching source files for changes...${NC}"
    echo -e "${YELLOW}(Press Ctrl+C to stop)${NC}"
    echo ""

    # Watch Sources and Packages directories for Swift changes
    WATCH_PATHS=()

    if [ -d "Sources" ]; then
      WATCH_PATHS+=("Sources")
    fi

    if [ -d "Packages" ]; then
      WATCH_PATHS+=("Packages")
    fi

    if [ ${#WATCH_PATHS[@]} -eq 0 ]; then
      echo -e "${YELLOW}Warning: No Sources or Packages directories found to watch${NC}"
      echo -e "${BLUE}Press Ctrl+C to stop the preview server${NC}"
      wait $SERVER_PID
    else
      # Use fswatch to monitor Swift file changes only
      fswatch -r \
        -e ".*" \
        -i "\\.swift$" \
        "${WATCH_PATHS[@]}" | while read -r changed_file; do

        echo ""
        echo -e "${YELLOW}Swift file changed: $(basename "$changed_file")${NC}"
        echo -e "${YELLOW}Rebuilding symbol graphs...${NC}"

        # Rebuild Swift and extract new symbols
        if swift build 2>&1 | grep -E "(Building|Build complete|error:)" && \
           swift package dump-symbol-graph 2>&1 | grep -q "Emitting symbol graph"; then
          echo -e "${GREEN}✓ Symbol graphs updated${NC}"
          echo -e "${BLUE}  DocC will auto-reload the documentation${NC}"
        else
          echo -e "${RED}✗ Symbol graph update failed${NC}"
          echo -e "${YELLOW}  Fix the errors and save to rebuild${NC}"
        fi

        echo ""
        echo -e "${BLUE}Watching for changes...${NC}"
      done &
      WATCH_PID=$!

      # Wait for server (cleanup trap will handle both processes)
      wait $SERVER_PID
    fi
  fi
else
  echo ""
  echo -e "${BLUE}Press Ctrl+C to stop the preview server${NC}"
  wait $SERVER_PID
fi
