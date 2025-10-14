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
- **Testing Framework**: Swift Testing (requires Swift 6.1+) - v2.0.0 migration from XCTest
- Mock implementations prefixed with "Mock" (MockSession, MockPathMonitor, MockNetworkPing, MockMessage)
- Protocol-based abstractions enable dependency injection for testing
- Never* types (NeverPing, NeverConnectivitySession) used for platforms without certain capabilities

### Key Design Patterns

- **Protocol-oriented**: Core types are protocols (`PathMonitor`, `NetworkPing`, `ConnectivitySession`)
- **Platform availability**: Heavy use of `#if canImport(Combine)` and `@available` attributes
- **Reactive**: All state changes published via Combine publishers
- **PassthroughSubject extension**: Custom `anyPublisher(for:)` helper maps KeyPath to publisher

## Platform Support

- **Swift Version**: Swift 6.1+ required (v2.0.0+)
- **Deployment Targets**: iOS 13, watchOS 6, tvOS 13, macOS 10.13
- Requires Combine framework (macOS 10.15+, iOS 13+, watchOS 6+, tvOS 13+)
- WatchConnectivity only available on iOS and watchOS (not macOS/tvOS)
- **Note**: v2.0.0 dropped support for Swift 5.9, 5.10, and 6.0 to enable Swift Testing framework migration

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

## Repository Structure & GitHub Workflow Integration

### Monorepo Development Strategy (v2.0.0)

SundialKit v2.0.0 uses a **monorepo-first development approach** with git-subrepo:

**Repository Structure:**
- **Main Monorepo** (`brightdigit/SundialKit`): Contains SundialKitCore, SundialKitNetwork, SundialKitConnectivity, and SundialKit umbrella
- **Plugin Subrepos** (in `Packages/`): SundialKitStream, SundialKitBinary, SundialKitCombine, SundialKitMessagable
  - Linked via git-subrepo to separate repositories
  - Tracked on `v1.0.0` branch during development
- **After v2.0.0**: Sever subrepo ties and finalize distribution strategy

**Benefits:**
- Single source of truth during development
- Easy coordination across packages
- Simplified dependency management
- Flexibility to choose distribution model later

#### Git-Subrepo Workflow

**What is git-subrepo?**
Git-subrepo is a simpler alternative to git submodules for managing external repositories within a project. Unlike submodules, subrepos are automatically cloned when users clone the main repository—no special commands needed.

**Key Differences from Git Submodules:**
- Simpler command-line usage
- Users get all subrepos automatically on clone
- No need to install git-subrepo for basic repository usage
- Keeps git history clean by condensing upstream changes into single commits

**Basic Commands:**

```bash
# Clone a subrepo (initial setup - already done for plugins)
git subrepo clone <remote-url> <subdir> [-b <branch>]

# Pull upstream changes from subrepo
git subrepo pull <subdir>

# Push local changes to subrepo
git subrepo push <subdir>

# Check status of all subrepos
git subrepo status

# Check status of specific subrepo
git subrepo status <subdir>
```

**Plugin Subrepo Locations:**
- `Packages/SundialKitStream` → `git@github.com:brightdigit/SundialKitStream.git` (branch: v1.0.0)
- `Packages/SundialKitBinary` → `git@github.com:brightdigit/SundialKitBinary.git` (branch: v1.0.0)
- `Packages/SundialKitCombine` → `git@github.com:brightdigit/SundialKitCombine.git` (branch: v1.0.0)
- `Packages/SundialKitMessagable` → `git@github.com:brightdigit/SundialKitMessagable.git` (branch: v1.0.0)

**The .gitrepo File:**
Each subrepo directory contains a `.gitrepo` file that stores metadata about the upstream repository:
```ini
[subrepo]
    remote = git@github.com:brightdigit/SundialKitStream.git
    branch = v1.0.0
    commit = <upstream-commit-sha>
    parent = <local-commit-sha>
```

**Development Workflow:**

1. **Working on Plugin Code:**
   ```bash
   # Edit files in Packages/SundialKitStream/
   git add Packages/SundialKitStream/
   git commit -m "feat(stream): add new feature"

   # Push changes to the plugin's separate repository
   git subrepo push Packages/SundialKitStream
   ```

2. **Pulling Updates from Plugins:**
   ```bash
   # Pull latest changes from plugin repo
   git subrepo pull Packages/SundialKitStream

   # Or update all plugins
   git subrepo pull Packages/SundialKitStream
   git subrepo pull Packages/SundialKitBinary
   git subrepo pull Packages/SundialKitCombine
   git subrepo pull Packages/SundialKitMessagable
   ```

3. **Checking Subrepo Status:**
   ```bash
   # See status of all subrepos
   git subrepo status

   # Output shows which subrepos have local changes
   ```

**Best Practices:**
- Treat plugin code in `Packages/` like normal code changes
- Commit and push changes to main repo first, then push to subrepo
- Pull from subrepos before making modifications
- Use `git subrepo status` regularly to check sync state
- Each `git subrepo push` creates a commit in the plugin's repository

### GitHub Issues & Pull Requests (Task Master Integration)

This project uses GitHub Issues and Pull Requests integrated with Task Master:
- **Each main task** (1, 2, 3, etc.) gets a GitHub issue and feature branch
- **Subtasks** (1.1, 1.2, etc.) are tracked as task lists in the issue or as sub-issues
- **Component/Package labeling** is required for all issues and PRs
  - Issue titles prefixed with component: `[Core] Task 1: ...`, `[Network] Task 2: ...`, `[WatchConnectivity] Task 3: ...`
  - GitHub labels applied: `component:core`, `component:network`, `component:watchconnectivity`, `component:combine`, `component:stream`, etc.
  - Components documented in Task Master: `Component: Core`
- **Feature branches** follow the pattern: `feature/[component-]task-<id>-<description>`
- **Commit messages** reference component and task: `feat(core/task-1.1): description (#issue-number)`
- **Pull requests** include component scope: `feat(core): Task 1 - Description`
- **Pull requests** are created when all subtasks complete, closing the related issue

**Component Labels:**
- `component:core` - SundialKitCore protocols and types
- `component:network` - SundialKitNetwork implementation
- `component:watchconnectivity` - SundialKitConnectivity implementation
- `component:combine` - SundialKitCombine plugin (v1 compatibility)
- `component:messagable` - SundialKitMessagable plugin (v1 compatibility)
- `component:stream` - SundialKitStream plugin (modern async/await)
- `component:binary` - SundialKitBinary plugin (modern serialization)
- `component:infrastructure` - Build, CI/CD, tooling, git-subrepo
- `component:docs` - Documentation and examples
- `component:tests` - Testing infrastructure and Swift Testing migration


See `.taskmaster/CLAUDE.md` for detailed GitHub integration workflow and commands.

## Task Master AI Instructions
**Import Task Master's development workflow commands and guidelines, treat as if import is in the main CLAUDE.md file.**
@./.taskmaster/CLAUDE.md
