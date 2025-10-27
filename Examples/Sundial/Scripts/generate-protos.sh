#!/bin/bash
#
# generate-protos.sh
# Compile Protocol Buffer schemas to Swift
#
# Usage: ./Scripts/generate-protos.sh
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

PROTO_DIR="$PROJECT_DIR/Protos"
OUTPUT_DIR="$PROJECT_DIR/Sources/Shared/Generated"

echo -e "${GREEN}Generating Swift code from Protocol Buffers...${NC}"

# Detect OS and set Mint path
if [ "$(uname)" = "Darwin" ]; then
    DEFAULT_MINT_PATH="/opt/homebrew/bin/mint"
elif [ "$(uname)" = "Linux" ] && [ -n "$GITHUB_ACTIONS" ]; then
    DEFAULT_MINT_PATH="$GITHUB_WORKSPACE/Mint/.mint/bin/mint"
elif [ "$(uname)" = "Linux" ]; then
    DEFAULT_MINT_PATH="/usr/local/bin/mint"
else
    echo -e "${RED}Unsupported operating system${NC}"
    exit 1
fi

# Use environment MINT_CMD if set, otherwise use default path
MINT_CMD=${MINT_CMD:-$DEFAULT_MINT_PATH}

# Check if Mint is installed
if ! command -v "$MINT_CMD" &> /dev/null; then
    echo -e "${RED}Error: Mint not found at $MINT_CMD${NC}"
    echo "Install with: brew install mint"
    exit 1
fi

# Set up Mint environment
export MINT_PATH="$PROJECT_DIR/.mint"
MINT_ARGS="-n -m $PROJECT_DIR/Mintfile --silent"
MINT_RUN="$MINT_CMD run $MINT_ARGS"

# Bootstrap Mint packages
echo "Installing swift-protobuf via Mint..."
$MINT_CMD bootstrap -m "$PROJECT_DIR/Mintfile"

# Check if protoc is installed
if ! command -v protoc &> /dev/null; then
    echo -e "${RED}Error: protoc not found${NC}"
    echo "Install with: brew install protobuf"
    echo "Or download from: https://github.com/protocolbuffers/protobuf/releases"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Generate Swift code
echo "Input:  $PROTO_DIR"
echo "Output: $OUTPUT_DIR"
echo ""

# Run protoc with Mint-managed plugin in PATH
# Mint installs protoc-gen-swift to .mint/bin/ which protoc will find via PATH
PATH="$MINT_PATH/bin:$PATH" protoc \
  --swift_out="$OUTPUT_DIR" \
  --proto_path="$PROTO_DIR" \
  "$PROTO_DIR"/*.proto

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Successfully generated Swift code${NC}"
    echo ""
    echo "Generated files:"
    ls -lh "$OUTPUT_DIR"/*.pb.swift 2>/dev/null || echo "No .pb.swift files found"
else
    echo -e "${RED}✗ Failed to generate Swift code${NC}"
    exit 1
fi
