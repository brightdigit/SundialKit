#!/bin/bash
set -euo pipefail

# Script to generate Local.xcconfig from environment variable or template
# This is used by CI/CD to create the Local.xcconfig file with DEVELOPMENT_TEAM

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOCAL_XCCONFIG="$PROJECT_DIR/Local.xcconfig"
EXAMPLE_XCCONFIG="$PROJECT_DIR/Local.xcconfig.example"

# Check if DEVELOPMENT_TEAM is set
if [ -z "${DEVELOPMENT_TEAM:-}" ]; then
  echo "Error: DEVELOPMENT_TEAM environment variable is not set"
  echo "Usage: DEVELOPMENT_TEAM=YOUR_TEAM_ID $0"
  exit 1
fi

# Generate Local.xcconfig
echo "Generating Local.xcconfig with DEVELOPMENT_TEAM: ${DEVELOPMENT_TEAM:0:4}****"
cat > "$LOCAL_XCCONFIG" <<EOF
// Auto-generated Local.xcconfig
// Generated on: $(date)
// DO NOT COMMIT THIS FILE - it contains your Apple Developer Team ID

DEVELOPMENT_TEAM = $DEVELOPMENT_TEAM
EOF

echo "✓ Local.xcconfig created successfully at: $LOCAL_XCCONFIG"
