# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SundialKit v2.0.0 is a Swift 6.1+ communications library for Apple platforms with a modern three-layer architecture:

**Layer 1: Core Protocols** (SundialKitCore, SundialKitNetwork, SundialKitConnectivity)
- Protocol-based abstractions over Apple's Network and WatchConnectivity frameworks
- Minimal concurrency annotations (Sendable constraints)
- No observer patterns - pure wrappers

**Layer 2: Observation Plugins** (Choose your concurrency model)
- **SundialKitStream**: Modern actor-based observers with AsyncStream APIs
- **SundialKitCombine**: @MainActor-based observers with Combine publishers

**Key Features:**
- Network connectivity monitoring using Apple's Network framework
- WatchConnectivity abstraction for iPhone/Apple Watch communication
- Multiple concurrency models: Choose actors or @MainActor based on your needs
- Swift 6.1 strict concurrency compliant (zero @unchecked Sendable in plugins)
- Full async/await support alongside Combine publishers

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

### Formatting & Linting (Mise)
SundialKit uses [mise](https://mise.jdx.dev/) to manage development tools:
- **swift-format** (swiftlang/swift-format@602.0.0) - Official Apple Swift formatter
- **SwiftLint** (realm/SwiftLint@0.61.0) - Swift style and conventions linter
- **Periphery** (peripheryapp/periphery@3.2.0) - Unused code detection

#### Install mise (macOS)
```bash
curl https://mise.run | sh
# or
brew install mise
```

#### Install Development Tools
```bash
mise install  # Installs tools from .mise.toml
```

#### Run linting script
```bash
./Scripts/lint.sh              # Normal mode
LINT_MODE=STRICT ./Scripts/lint.sh  # Strict mode (CI)
FORMAT_ONLY=1 ./Scripts/lint.sh     # Format only
```

## Architecture

### Three-Layer Architecture (v2.0.0)

SundialKit v2.0.0 uses a layered architecture separating protocols, wrappers, and observation patterns:

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: SundialKitCore (Protocols)                         │
│ - PathMonitor, NetworkPing, ConnectivitySession protocols   │
│ - Sendable-safe type aliases and errors                     │
│ - No observers, no concurrency primitives                   │
└─────────────────────────────────────────────────────────────┘
         │
    ┌────┴────┐
    │         │
┌───┴────────┐ ┌──┴──────────────┐
│ Layer 1:   │ │ Layer 1:        │
│ Network    │ │ Connectivity    │
│            │ │                 │
│ Raw        │ │ Raw             │
│ wrappers   │ │ wrappers        │
│ over       │ │ over            │
│ NWPath     │ │ WCSession       │
│ Monitor    │ │                 │
└────────────┘ └─────────────────┘
    │                  │
    └────┬─────────────┘
         │
    ┌────┴────┐
    │         │
┌───┴────────┐│       ┌──────────────┐
│ Layer 2:   ││       │ Layer 2:     │
│ Stream     ││       │ Combine      │
│            ││       │              │
│ Actors +   ││       │ @MainActor + │
│ AsyncStream││       │ Publishers   │
│ (modern)   ││       │ (SwiftUI)    │
└────────────┘│       └──────────────┘
```

#### Layer 1: Core Protocols & Wrappers

**SundialKitCore** (`Sources/SundialKitCore/`)
- Protocol definitions: `PathMonitor`, `NetworkPing`, `ConnectivitySession`, `ConnectivitySessionDelegate`
- Type-safe aliases: `ConnectivityMessage = [String: any Sendable]`
- Typed errors: `ConnectivityError`, `NetworkError`, `SerializationError`
- No concrete implementations, no observers

**SundialKitNetwork** (`Sources/SundialKitNetwork/`)
- Concrete implementations: `NWPathMonitor` extensions, `NeverPing`
- Protocol wrappers around Apple's Network framework
- **PathStatus**: Enum representing network state (satisfied, unsatisfied, requiresConnection, unknown)
  - Contains `Interface` OptionSet (cellular, wifi, wiredEthernet, loopback, other)
  - Contains `UnsatisfiedReason` enum for failure details

**SundialKitConnectivity** (`Sources/SundialKitConnectivity/`)
- Concrete implementations: `WatchConnectivitySession`, `NeverConnectivitySession`
- Protocol wrappers around Apple's WatchConnectivity framework
- Delegate pattern support via `ConnectivitySessionDelegate`
- Message encoding/decoding via `Messagable` protocol

#### Layer 2: Observation Plugins (Choose One)

**SundialKitStream** (`Packages/SundialKitStream/`) - Modern Async/Await
- **NetworkObserver**: Actor-based network monitoring
  - Generic over `PathMonitor` and `NetworkPing` protocols
  - AsyncStream APIs: `pathUpdates()`, `pathStatusStream`, `isExpensiveStream`, `pingStatusStream`
  - Call `start(queue:)` to begin monitoring
  - Zero @unchecked Sendable (naturally Sendable actors)

- **ConnectivityObserver**: Actor-based WatchConnectivity
  - AsyncStream APIs: `activationStates()`, `messageStream()`, `reachabilityStream()`
  - Async methods: `activate()`, `sendMessage(_:)` returns `ConnectivitySendResult`
  - Automatic message routing (sendMessage when reachable, updateApplicationContext when not)
  - Zero @unchecked Sendable (naturally Sendable actors)

**SundialKitCombine** (`Packages/SundialKitCombine/`) - Combine + SwiftUI
- **NetworkObserver**: @MainActor-based network monitoring
  - Generic over `PathMonitor` and `NetworkPing & Sendable` protocols
  - @Published properties: `pathStatus`, `isExpensive`, `isConstrained`, `pingStatus`
  - Call `start(queue:)` to begin monitoring (defaults to `.main`)
  - Zero @unchecked Sendable (@MainActor isolation)

- **ConnectivityObserver**: @MainActor-based WatchConnectivity
  - @Published properties: `activationState`, `isReachable`, `isPairedAppInstalled`
  - PassthroughSubject publishers: `messageReceived`, `sendResult`
  - Async methods: `activate()`, `sendMessage(_:)` returns `ConnectivitySendResult`
  - Automatic message routing
  - Zero @unchecked Sendable (@MainActor isolation)

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
- **Deployment Targets**: iOS 16, watchOS 9, tvOS 16, macOS 11.0
- Requires Combine framework (macOS 10.15+, iOS 13+, watchOS 6+, tvOS 13+)
- WatchConnectivity only available on iOS and watchOS (not macOS/tvOS)
- **Note**: v2.0.0 dropped support for Swift 5.9, 5.10, and 6.0 to enable Swift Testing framework migration

## Development Notes

### Development Tools
Development tools (formatter, linter, unused code detector) are managed via mise and defined in `.mise.toml`. The `Scripts/lint.sh` script orchestrates formatting, linting, and code quality checks. Use `make lint` for local development.

### Important Type Aliases
- `ConnectivityMessage` = `[String: any Sendable]` (Sendable-safe WatchConnectivity dictionary)
- `ConnectivityHandler` = `@Sendable (ConnectivityMessage) -> Void`
- `SuccessfulSubject<Output>` = `PassthroughSubject<Output, Never>` (in SundialKitCore for legacy support)

### Usage Examples

#### Network Monitoring with SundialKitStream (Async/Await)

```swift
import SundialKitStream
import SundialKitNetwork

// Create observer (actor-based)
let observer = NetworkObserver(
  monitor: NWPathMonitorAdapter(),
  ping: nil  // or provide a NetworkPing implementation
)

// Start monitoring
observer.start(queue: .global())

// Consume path updates using AsyncStream
Task {
  for await status in observer.pathStatusStream {
    print("Network status: \(status)")
  }
}

// Or get raw path updates
Task {
  for await path in observer.pathUpdates() {
    print("Path: \(path)")
  }
}
```

#### Network Monitoring with SundialKitCombine (Combine + SwiftUI)

```swift
import SundialKitCombine
import SundialKitNetwork
import Combine

// Create observer (@MainActor-based)
let observer = NetworkObserver(
  monitor: NWPathMonitorAdapter(),
  ping: nil
)

// Start monitoring on main queue
observer.start()

// Use @Published properties in SwiftUI
var cancellables = Set<AnyCancellable>()

observer.$pathStatus
  .sink { status in
    print("Network status: \(status)")
  }
  .store(in: &cancellables)

observer.$isExpensive
  .sink { isExpensive in
    print("Is expensive: \(isExpensive)")
  }
  .store(in: &cancellables)
```

#### WatchConnectivity with SundialKitStream (Async/Await)

```swift
import SundialKitStream
import SundialKitConnectivity

// Create observer (actor-based)
let observer = ConnectivityObserver()

// Activate session
try await observer.activate()

// Listen for messages using AsyncStream
Task {
  for await result in observer.messageStream() {
    switch result.context {
    case .replyWith(let handler):
      print("Message: \(result.message)")
      handler(["response": "acknowledged"])
    case .applicationContext:
      print("Context update: \(result.message)")
    }
  }
}

// Send messages
let result = try await observer.sendMessage(["key": "value"])
print("Sent via: \(result.context)")
```

#### WatchConnectivity with SundialKitCombine (Combine + SwiftUI)

```swift
import SundialKitCombine
import SundialKitConnectivity
import Combine

// Create observer (@MainActor-based)
let observer = ConnectivityObserver()

// Activate session
try observer.activate()

// Use publishers
var cancellables = Set<AnyCancellable>()

observer.messageReceived
  .sink { result in
    switch result.context {
    case .replyWith(let handler):
      print("Message: \(result.message)")
      handler(["response": "acknowledged"])
    case .applicationContext:
      print("Context update: \(result.message)")
    }
  }
  .store(in: &cancellables)

observer.$activationState
  .sink { state in
    print("State: \(state)")
  }
  .store(in: &cancellables)

// Send messages asynchronously
Task {
  let result = try await observer.sendMessage(["key": "value"])
  print("Sent via: \(result.context)")
}
```

### Common Pitfalls
- **Observers require explicit start/activate**: Both NetworkObserver and ConnectivityObserver need `start(queue:)` or `activate()` calls
- **Platform-specific APIs**: WatchConnectivity guarded with `@available` and `#if` (behavior differs on iOS vs watchOS)
- **Messages must be property list types**: ConnectivityMessage values must be Sendable property list types
- **Actor isolation**: When using SundialKitStream, remember to use `await` for actor-isolated properties and methods
- **Main thread access**: When using SundialKitCombine, all observer access is on MainActor (safe for UI updates)

## Repository Structure & GitHub Workflow Integration

### Monorepo Development Strategy (v2.0.0)

SundialKit v2.0.0 uses a **monorepo-first development approach** with git-subrepo:

**Repository Structure:**
- **Main Monorepo** (`brightdigit/SundialKit`): Contains SundialKitCore, SundialKitNetwork, SundialKitConnectivity, SundialKit umbrella, SundialKitBinary, and SundialKitMessagable
- **Plugin Subrepos** (in `Packages/`): SundialKitStream, SundialKitCombine
  - Linked via git-subrepo to separate repositories
  - Tracked on `v1.0.0` branch during development
- **Built-in Plugins**: SundialKitBinary and SundialKitMessagable are implemented directly in the monorepo as built-in features
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
- `Packages/SundialKitCombine` → `git@github.com:brightdigit/SundialKitCombine.git` (branch: v1.0.0)

**Built-in Plugins (not subrepos):**
- SundialKitBinary - Implemented directly in main monorepo
- SundialKitMessagable - Implemented directly in main monorepo

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

   # Or update all subrepo plugins
   git subrepo pull Packages/SundialKitStream
   git subrepo pull Packages/SundialKitCombine

   # Note: SundialKitBinary and SundialKitMessagable are built-in (not subrepos)
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
- `component:combine` - SundialKitCombine plugin (v1 compatibility, subrepo)
- `component:messagable` - SundialKitMessagable built-in (v1 compatibility, monorepo)
- `component:stream` - SundialKitStream plugin (modern async/await, subrepo)
- `component:binary` - SundialKitBinary built-in (modern serialization, monorepo)
- `component:infrastructure` - Build, CI/CD, tooling, git-subrepo
- `component:docs` - Documentation and examples
- `component:tests` - Testing infrastructure and Swift Testing migration


See `.taskmaster/CLAUDE.md` for detailed GitHub integration workflow and commands.

## Task Master AI Instructions
**Import Task Master's development workflow commands and guidelines, treat as if import is in the main CLAUDE.md file.**
@./.taskmaster/CLAUDE.md
