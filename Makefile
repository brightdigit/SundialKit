.PHONY: help build test lint format clean

# Default target
help:
	@echo "Available targets:"
	@echo "  build          - Build the package"
	@echo "  test           - Run tests with code coverage"
	@echo "  lint           - Run linting and formatting checks (strict mode)"
	@echo "  format         - Format code only (no linting)"
	@echo "  clean          - Clean build artifacts"
	@echo "  help           - Show this help message"

# Build the package
build:
	@echo "🔨 Building SundialKit..."
	@swift build

# Run tests
test:
	@echo "🧪 Running tests with code coverage..."
	@swift test --enable-code-coverage

# Run linting in strict mode
lint:
	@echo "🔍 Running linting in strict mode..."
	@LINT_MODE=STRICT ./Scripts/lint.sh

# Format code only
format:
	@echo "✨ Formatting code..."
	@FORMAT_ONLY=1 ./Scripts/lint.sh

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@swift package clean
	@rm -rf .build
