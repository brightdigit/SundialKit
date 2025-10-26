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

# Check if protoc is installed
if ! command -v protoc &> /dev/null; then
    echo -e "${RED}Error: protoc not found${NC}"
    echo "Install with: brew install protobuf swift-protobuf"
    exit 1
fi

# Check if swift-protobuf plugin is available
if ! command -v protoc-gen-swift &> /dev/null; then
    echo -e "${YELLOW}Warning: protoc-gen-swift not found${NC}"
    echo "Install with: brew install swift-protobuf"
    echo "Or build from source: https://github.com/apple/swift-protobuf"
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Generate Swift code
echo "Input:  $PROTO_DIR"
echo "Output: $OUTPUT_DIR"
echo ""

protoc \
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
