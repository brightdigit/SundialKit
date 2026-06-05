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

# Check if mise is installed
if ! command -v mise &> /dev/null; then
    echo -e "${RED}Error: mise not found${NC}"
    echo "Install mise: https://mise.jdx.dev/getting-started.html"
    exit 1
fi

# Install pinned tools (reads .mise.toml). swift-protobuf provides both
# protoc and the protoc-gen-swift plugin, so no system protoc is required.
echo "Installing swift-protobuf via mise..."
(cd "$PROJECT_DIR" && mise install)

# Expose the mise-managed bin dir (contains protoc and protoc-gen-swift)
PLUGIN_DIR="$( cd "$PROJECT_DIR" && dirname "$(mise which protoc-gen-swift)" )"

# Verify protoc is available via mise
if [ ! -x "$PLUGIN_DIR/protoc" ]; then
    echo -e "${RED}Error: protoc not found in mise tools at $PLUGIN_DIR${NC}"
    echo "Ensure swift-protobuf is installed: (cd $PROJECT_DIR && mise install)"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Generate Swift code
echo "Input:  $PROTO_DIR"
echo "Output: $OUTPUT_DIR"
echo ""

# Run protoc with the mise-managed plugin in PATH
# protoc discovers protoc-gen-swift via PATH
# Visibility=Public ensures generated types are accessible from other modules
PATH="$PLUGIN_DIR:$PATH" protoc \
  --swift_out=Visibility=Public:"$OUTPUT_DIR" \
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
