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
CATALOG_PATHS=()
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
Usage: $(basename "$0") <catalog-path> [<catalog-path>...] [OPTIONS]

DocC documentation preview with auto-rebuild on file changes.
Supports multiple catalogs served from a single preview server.

Arguments:
  <catalog-path>        Path to .docc catalog directory (one or more)
                        Example: Sources/SundialKit/SundialKit.docc

Options:
  --port <number>       Preview server port (default: 8080)
  --no-watch            Build once, don't watch for changes
  --no-server           Build only, don't start preview server
  --clean               Clean build artifacts before building
  --help                Show this help message

Examples:
  $(basename "$0") Sources/SundialKit/SundialKit.docc
  $(basename "$0") Sources/SundialKit/SundialKit.docc Sources/SundialKitCore/SundialKitCore.docc
  $(basename "$0") Sources/SundialKit/SundialKit.docc --port 8081
  $(basename "$0") Sources/SundialKit/SundialKit.docc --no-watch

Note: This script requires fswatch for auto-rebuild functionality.
Install with: brew install fswatch
EOF
}

# Parse command-line arguments
# Collect catalog paths and options
if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]]; then
  usage
  exit 0
fi

# Parse all arguments
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
    --*)
      echo -e "${RED}Error: Unknown option: $1${NC}"
      usage
      exit 1
      ;;
    *)
      # Positional argument - catalog path
      if [ ! -d "$1" ]; then
        echo -e "${RED}Error: Catalog directory not found: $1${NC}"
        exit 1
      fi
      CATALOG_PATHS+=("$1")
      shift
      ;;
  esac
done

# Validate at least one catalog path provided
if [ ${#CATALOG_PATHS[@]} -eq 0 ]; then
  echo -e "${RED}Error: At least one catalog path is required${NC}"
  usage
  exit 1
fi

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
  echo -e "${BLUE}Preparing documentation${NC}"
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

# Build a single catalog as DocC archive
build_catalog() {
  local catalog_path="$1"
  local output_dir="$2"
  local catalog_name=$(basename "$catalog_path" .docc)

  # Ensure output directory exists
  mkdir -p "$output_dir"

  echo -e "${YELLOW}Building $catalog_name documentation...${NC}"

  # Build docc convert command
  local docc_cmd=(xcrun docc convert "$catalog_path"
    --fallback-display-name "$catalog_name"
    --fallback-bundle-identifier "com.brightdigit.$(echo "$catalog_name" | tr '[:upper:]' '[:lower:]')"
    --fallback-bundle-version "2.0.0"
    --transform-for-static-hosting
    --hosting-base-path "/$catalog_name.doccarchive"
    --output-path "$output_dir/$catalog_name.doccarchive")

  # Add symbol graphs if available
  if [ -n "$(ls -A "$SYMBOL_GRAPH_DIR" 2>/dev/null)" ]; then
    docc_cmd+=(--additional-symbol-graph-dir "$SYMBOL_GRAPH_DIR")
  fi

  if ! "${docc_cmd[@]}" 2>&1 | grep -v "^$"; then
    echo -e "${RED}Error: DocC conversion failed for $catalog_name${NC}"
    return 1
  fi

  echo -e "${GREEN}✓ $catalog_name.doccarchive created${NC}"
  return 0
}

# Build symbols initially
if ! build_symbols; then
  echo -e "${RED}Symbol graph generation failed${NC}"
  exit 1
fi

# NO-SERVER MODE: Build all catalogs and exit
if [ "$NO_SERVER" = true ]; then
  echo ""
  echo -e "${YELLOW}Converting to DocC archives...${NC}"

  # Build each catalog
  for catalog_path in "${CATALOG_PATHS[@]}"; do
    if ! build_catalog "$catalog_path" ".build/docs"; then
      echo -e "${RED}Failed to build $(basename "$catalog_path")${NC}"
      exit 1
    fi
  done

  echo ""
  echo -e "${GREEN}✓ All DocC archives created in .build/docs/${NC}"
  echo -e "${BLUE}========================================${NC}"
  exit 0
fi

# PREVIEW MODE: Build all catalogs and serve with Python HTTP server
echo ""
echo -e "${YELLOW}Building DocC archives for preview...${NC}"

# Create preview output directory
PREVIEW_DIR=".build/docs-preview"
mkdir -p "$PREVIEW_DIR"

# Build each catalog
for catalog_path in "${CATALOG_PATHS[@]}"; do
  if ! build_catalog "$catalog_path" "$PREVIEW_DIR"; then
    echo -e "${RED}Failed to build $(basename "$catalog_path")${NC}"
    exit 1
  fi
done

echo ""
echo -e "${BLUE}Starting documentation preview server...${NC}"

# Start Python HTTP server in preview directory
cd "$PREVIEW_DIR"
python3 -m http.server "$PORT" > /dev/null 2>&1 &
SERVER_PID=$!
cd - > /dev/null

# Wait for server to start
sleep 2

# Check if server is still running
if ! kill -0 "$SERVER_PID" 2>/dev/null; then
  echo -e "${RED}Error: Preview server failed to start${NC}"
  echo -e "${YELLOW}Check if port $PORT is already in use${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Preview server running${NC}"
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}📚 Documentation available at:${NC}"
for catalog_path in "${CATALOG_PATHS[@]}"; do
  catalog_name=$(basename "$catalog_path" .docc)
  catalog_name_lower=$(echo "$catalog_name" | tr '[:upper:]' '[:lower:]')
  echo -e "${BLUE}   http://localhost:$PORT/$catalog_name.doccarchive/documentation/$catalog_name_lower${NC}"
done
echo -e "${GREEN}========================================${NC}"

# Watch mode for live updates
if [ "$NO_WATCH" = false ]; then
  # Check if fswatch is installed
  if ! command -v fswatch &> /dev/null; then
    echo ""
    echo -e "${YELLOW}Note: fswatch not found. Source file watching disabled.${NC}"
    echo -e "${YELLOW}Install with: brew install fswatch for auto-rebuild on source changes${NC}"
    echo ""
    echo -e "${BLUE}Press Ctrl+C to stop the preview server${NC}"
    wait $SERVER_PID
  else
    echo ""
    echo -e "${BLUE}Watching source files for changes...${NC}"
    echo -e "${YELLOW}(Press Ctrl+C to stop)${NC}"
    echo ""

    # Watch Sources, Packages, and .docc directories
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
      # Use fswatch to monitor Swift and markdown changes
      fswatch -r \
        -e ".*" \
        -i "\\.swift$" \
        -i "\\.md$" \
        "${WATCH_PATHS[@]}" | while read -r changed_file; do

        echo ""
        echo -e "${YELLOW}File changed: $(basename "$changed_file")${NC}"
        echo -e "${YELLOW}Rebuilding documentation...${NC}"

        # Rebuild Swift and extract new symbols
        if swift build 2>&1 | grep -E "(Building|Build complete|error:)" && \
           swift package dump-symbol-graph 2>&1 | grep -q "Emitting symbol graph"; then

          # Rebuild all catalogs
          for catalog_path in "${CATALOG_PATHS[@]}"; do
            catalog_name=$(basename "$catalog_path" .docc)
            if build_catalog "$catalog_path" "$PREVIEW_DIR" > /dev/null 2>&1; then
              echo -e "${GREEN}✓ $catalog_name updated${NC}"
            else
              echo -e "${RED}✗ $catalog_name update failed${NC}"
            fi
          done

          echo -e "${BLUE}  Refresh your browser to see changes${NC}"
        else
          echo -e "${RED}✗ Build failed${NC}"
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
