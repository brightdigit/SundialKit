# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SundialKit is a reactive communications library for Apple platforms that provides:
- Network connectivity monitoring using Apple's Network framework
- WatchConnectivity abstraction for iPhone/Apple Watch communication
- Combine-based reactive publishers for SwiftUI integration

## Build & Test Commands

### Using Make (Recommended)
```bash
make build          # Build the package
make test           # Run tests with coverage
make lint           # Run linting and formatting (strict mode)
make format         # Format code only
make clean          # Clean build artifacts
make help           # Show all available commands
```

### Using Swift Directly
```bash
swift build
swift test
swift test --enable-code-coverage
swift test --filter <TestName>
```

### Formatting & Linting (Mint)
SundialKit uses [Mint](https://github.com/yonaskolb/Mint) to manage development tools:
- **swift-format** (swiftlang/swift-format@601.0.0) - Official Apple Swift formatter
- **SwiftLint** (realm/SwiftLint@0.59.1) - Swift style and conventions linter
- **Periphery** (peripheryapp/periphery@3.2.0) - Unused code detection

#### Install Mint (macOS)
```bash
brew install mint
```

#### Run linting script
```bash
./Scripts/lint.sh              # Normal mode
LINT_MODE=STRICT ./Scripts/lint.sh  # Strict mode (CI)
FORMAT_ONLY=1 ./Scripts/lint.sh     # Format only
```

## Architecture

### Two Main Subsystems

**1. Network Module** (`Sources/SundialKit/Network/`)
- **NetworkObserver**: Main observable class for network connectivity
  - Wraps `PathMonitor` (abstraction over `NWPathMonitor`)
  - Optionally integrates `NetworkPing` for periodic connectivity verification
  - Publishes: `pathStatus`, `isExpensive`, `isConstrained`, `pingStatus`
  - Must call `start(queue:)` to begin monitoring
- **PathStatus**: Enum representing network state (satisfied, unsatisfied, requiresConnection, unknown)
  - Contains `Interface` OptionSet (cellular, wifi, wiredEthernet, loopback, other)
  - Contains `UnsatisfiedReason` enum for failure details

**2. WatchConnectivity Module** (`Sources/SundialKit/WatchConnectivity/`)
- **ConnectivityObserver**: Main observable class for iPhone ↔ Apple Watch communication
  - Wraps `ConnectivitySession` (abstraction over `WCSession`)
  - Implements `ConnectivitySessionDelegate` pattern
  - Publishes: `activationState`, `isReachable`, `isPaired`, `isPairedAppInstalled`
  - Message publishing: `messageReceivedPublisher`, `replyMessagePublisher`
  - Message sending: `sendingMessageSubject` (PassthroughSubject)
  - Must call `activate()` to start the session
  - Automatically handles message routing:
    - Uses `sendMessage` when reachable
    - Falls back to `updateApplicationContext` when not reachable but paired app installed
    - Returns error when companion not available

### Message Encoding/Decoding

**Messagable Protocol**
- Allows type-safe message encoding/decoding for WatchConnectivity
- Requires: `static key` (type identifier), `init?(from:)`, `parameters()`
- Extension provides `message()` method to convert to `ConnectivityMessage` ([String:Any])

**MessageDecoder**
- Initialize with array of `Messagable.Type`
- Builds internal dictionary keyed by `Messagable.key`
- Use `decode(_:)` to convert `ConnectivityMessage` back to typed `Messagable`

### Testing Architecture

- All tests in `Tests/SundialKitTests/`
- Mock implementations prefixed with "Mock" (MockSession, MockPathMonitor, MockNetworkPing, MockMessage)
- Protocol-based abstractions enable dependency injection for testing
- Never* types (NeverPing, NeverConnectivitySession) used for platforms without certain capabilities

### Key Design Patterns

- **Protocol-oriented**: Core types are protocols (`PathMonitor`, `NetworkPing`, `ConnectivitySession`)
- **Platform availability**: Heavy use of `#if canImport(Combine)` and `@available` attributes
- **Reactive**: All state changes published via Combine publishers
- **PassthroughSubject extension**: Custom `anyPublisher(for:)` helper maps KeyPath to publisher

## Platform Support

- Minimum versions: iOS 13, watchOS 6, tvOS 13, macOS 10.13
- Requires Combine framework (macOS 10.15+, iOS 13+, watchOS 6+, tvOS 13+)
- WatchConnectivity only available on iOS and watchOS (not macOS/tvOS)

## Development Notes

### Development Tools
Development tools (formatter, linter, unused code detector) are managed via Mint and defined in `Mintfile`. The `Scripts/lint.sh` script orchestrates formatting, linting, and code quality checks. Use `make lint` for local development.

### Important Type Aliases
- `ConnectivityMessage` = `[String:Any]` (WatchConnectivity-compatible dictionary)
- `SuccessfulSubject<Output>` = `PassthroughSubject<Output, Never>`

### Common Pitfalls
- NetworkObserver and ConnectivityObserver require explicit start/activate calls
- Platform-specific APIs guarded with `@available` and `#if` (watch behavior on iOS vs watchOS)
- Messages must be property list types for WatchConnectivity compatibility
