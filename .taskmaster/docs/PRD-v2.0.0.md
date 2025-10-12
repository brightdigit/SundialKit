# SundialKit v2.0.0 Product Requirements Document

**Version:** 1.0
**Date:** 2025-10-11
**Status:** Draft
**Author:** SundialKit Team

---

## 1. Executive Summary

SundialKit v2.0.0 represents a significant architectural evolution from a monolithic reactive communications library to a modular, plugin-based framework. This redesign enables developers to choose their preferred reactive patterns (Combine or AsyncStream) and serialization methods (Messagable dictionaries or Protobuf) while maintaining full backwards compatibility with v1.0.0.

**Modern Swift 6.1 packages** (`SundialKitStream`, `SundialKitProtobuf`) leverage actor-based concurrency, strict concurrency checking, and the latest Swift features, while **v1.0.0 compatibility packages** (`SundialKitCombine`, `SundialKitMessagable`) maintain Swift 5.9 support for seamless migration.

### Vision

Transform SundialKit into an extensible platform where:
- The core library provides robust network and WatchConnectivity implementations
- Plugin packages add reactive and serialization capabilities
- Developers compose only the features they need
- Modern Swift concurrency patterns coexist with traditional Combine approaches

### Key Goals

1. **Modularity** - Separate concerns into focused, composable packages
2. **Modern Swift** - Swift 6.1 with actor-based concurrency, AsyncStream, typed throws, and strict concurrency for modern packages
3. **Backwards Compatibility** - Maintain v1.0.0 API surface through Swift 5.9 plugin packages
4. **Flexibility** - Enable mix-and-match of reactive and serialization approaches
5. **Quality** - Migrate to Swift Testing for improved test reliability
6. **Thread Safety** - Actor-based implementations in modern packages for safe concurrent access

---

## 2. Problem Statement

### Current Limitations (v1.0.0)

1. **Monolithic Design**
   - Combine is baked into the core library
   - Cannot adopt AsyncStream without replacing Combine
   - Messagable is the only serialization option
   - Heavy dependency on Combine even for non-reactive use cases

2. **Swift Evolution Gap**
   - No async/await or AsyncStream support
   - No typed throws (uses generic `Error`)
   - Still using XCTest instead of Swift Testing
   - Not optimized for Swift 6.0+ features

3. **Limited Extensibility**
   - Cannot add alternative serialization formats without forking
   - No plugin system for community extensions
   - Tight coupling between reactive layer and domain logic

4. **Developer Experience**
   - Must adopt entire Combine stack even for simple use cases
   - Cannot incrementally migrate to modern concurrency
   - Dictionary-based messaging lacks type safety
   - No structured data format support (Protobuf, etc.)

### User Impact

- SwiftUI developers wanting to use AsyncStream are blocked
- Teams standardizing on Protobuf cannot use SundialKit's messaging
- Migration to modern Swift requires major refactoring
- Library bloat for users who don't need all features

---

## 3. Target Users & Use Cases

### Primary Users

1. **SwiftUI Developers** - Building reactive iPhone/Apple Watch apps
2. **Swift Concurrency Adopters** - Teams migrating from Combine to async/await
3. **Protobuf Users** - Organizations with standardized message schemas
4. **Existing v1.0.0 Users** - Need backwards compatibility during migration

### Use Cases

#### UC1: Modern Concurrency Adoption
**As a** SwiftUI developer
**I want to** use AsyncStream for network monitoring
**So that** I can leverage modern Swift concurrency patterns

```swift
import SundialKit
import SundialKitStream

for await status in networkMonitor.pathStatusStream {
    updateUI(status)
}
```

#### UC2: Type-Safe Messaging with Protobuf
**As a** watchOS developer
**I want to** use Protobuf for iPhone/Watch communication
**So that** I get type safety and efficient serialization

```swift
import SundialKit
import SundialKitProtobuf

let message = HeartRateUpdate(bpm: 72, timestamp: Date())
try await connectivity.send(message)
```

#### UC3: Gradual Migration from v1
**As an** existing SundialKit user
**I want to** keep my Combine code working
**So that** I can migrate incrementally without breaking changes

```swift
// v1 code continues to work
import SundialKit
import SundialKitCombine
import SundialKitMessagable

observer.pathStatusPublisher.sink { status in
    // Existing code unchanged
}
```

#### UC4: Mix-and-Match Patterns
**As a** flexible developer
**I want to** combine Combine with Protobuf
**So that** I can optimize different parts of my app

```swift
import SundialKit
import SundialKitCombine  // For network
import SundialKitProtobuf // For messaging
```

---

## 4. Architecture Vision

### Plugin-Based Architecture

SundialKit v2.0.0 adopts a **host + plugin** architecture where:
- **SundialKit** is the host providing core implementations
- **SundialKitCore** defines the plugin contract (protocols)
- **Plugin packages** extend functionality through well-defined interfaces

```
┌─────────────────────────────────────┐
│     Main Package: SundialKit        │
│  ┌───────────────────────────────┐  │
│  │   SundialKitCore (Protocols)  │  │
│  └───────────────────────────────┘  │
│              ▲                       │
│              │                       │
│  ┌───────────┴───────────────────┐  │
│  │   SundialKit (Implementation) │  │
│  │   - NetworkMonitor            │  │
│  │   - ConnectivityManager       │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
         ▲           ▲
         │           │
    ┌────┴───┐  ┌────┴────┐
    │ Plugin │  │ Plugin  │
    │ Pkgs   │  │ Pkgs    │
    └────────┘  └─────────┘
```

### Package Structure

#### Core Package: `brightdigit/SundialKit`

**Target: `SundialKitCore`**
- Purpose: Protocol definitions for plugin system
- Contents:
  - `NetworkMonitoring` protocol
  - `ConnectivityManagement` protocol
  - `PathStatus`, `ActivationState`, and core types
  - `SundialError` (with typed throws support)
  - Plugin extension points
- Dependencies: Foundation only
- **Swift Version**: 5.9+ (v1.0.0 compatibility)
- **Platforms**: iOS 13+, watchOS 6+, tvOS 13+, macOS 10.13+
- Audience: Plugin developers

**Target: `SundialKit`**
- Purpose: Concrete implementations of network and WatchConnectivity
- Contents:
  - `NetworkMonitor` class
  - `ConnectivityManager` class
  - Platform-specific implementations (NWPathMonitor, WCSession)
  - Internal monitoring logic
- Dependencies: `SundialKitCore`, Network framework, WatchConnectivity
- **Swift Version**: 5.9+ (v1.0.0 compatibility)
- **Platforms**: iOS 13+, watchOS 6+, tvOS 13+, macOS 10.13+
- Audience: All users (required)

#### Plugin Packages

**Package: `SundialKitCombine`** (v1.0.0 Compatibility)
- Purpose: Combine reactive layer
- Contents:
  - `NetworkObserver` (wraps `NetworkMonitor`, exposes publishers)
  - `ConnectivityObserver` (wraps `ConnectivityManager`, exposes publishers)
  - Publisher extensions for all state properties
  - PassthroughSubject utilities
- Dependencies: `SundialKitCore`, Combine
- **Swift Version**: 5.9+ (v1.0.0 compatibility)
- **Platforms**: iOS 13+, watchOS 6+, tvOS 13+, macOS 10.15+
- Backwards Compatibility: Provides v1.0.0 API surface

**Package: `SundialKitMessagable`** (v1.0.0 Compatibility)
- Purpose: Dictionary-based messaging for WatchConnectivity
- Contents:
  - `Messagable` protocol
  - `MessageDecoder`
  - `ConnectivityMessage` typealias
  - Dictionary serialization utilities
- Dependencies: `SundialKitCore`
- **Swift Version**: 5.9+ (v1.0.0 compatibility)
- **Platforms**: iOS 13+, watchOS 6+, tvOS 13+, macOS 10.13+
- Backwards Compatibility: Provides v1.0.0 messaging API

**Package: `SundialKitStream`** (New in v2.0.0)
- Purpose: Actor-based AsyncStream and async/await layer
- Contents:
  - `actor NetworkStream` (wraps `NetworkMonitor`, exposes AsyncStreams)
  - `actor ConnectivityStream` (wraps `ConnectivityManager`, exposes AsyncStreams)
  - AsyncSequence conformances
  - Async/await convenience methods
- Dependencies: `SundialKitCore` (no swift-async-algorithms)
- **Swift Version**: 6.1+ with strict concurrency enabled
- **Platforms**: iOS 13+, macOS 10.15+, watchOS 6+, tvOS 13+
- **Architecture**: Actor-based for thread safety, no @available guards

**Package: `SundialKitProtobuf`** (New in v2.0.0)
- Purpose: Protobuf serialization for WatchConnectivity
- Contents:
  - `ProtobufMessagable` protocol
  - Protobuf encoding/decoding extensions
  - WatchConnectivity integration
- Dependencies: `SundialKitCore`, SwiftProtobuf (latest stable)
- **Swift Version**: 6.1+ with strict concurrency enabled
- **Platforms**: Determined by latest SwiftProtobuf
- Note: Users provide their own `.proto` schemas

---

## 5. Technical Requirements

### 5.1 Core Library (`SundialKit`)

#### Network Monitoring
- [ ] Extract domain logic from `NetworkObserver` into `NetworkMonitor`
- [ ] Remove Combine dependencies from core monitoring
- [ ] Maintain protocol-based `PathMonitor` abstraction
- [ ] Support optional `NetworkPing` integration
- [ ] Expose state through protocol methods, not publishers

#### WatchConnectivity
- [ ] Extract domain logic from `ConnectivityObserver` into `ConnectivityManager`
- [ ] Remove Combine dependencies from core connectivity
- [ ] Maintain protocol-based `ConnectivitySession` abstraction
- [ ] Expose state through protocol methods, not publishers
- [ ] Support activation lifecycle

#### Error Handling (Typed Throws)
- [ ] Define specific error types for each domain:
  - `NetworkError` - Network-related failures
  - `ConnectivityError` - WatchConnectivity failures
  - `SerializationError` - Message encoding/decoding failures
- [ ] Apply typed throws to all throwing methods
- [ ] Maintain backwards compatibility with generic `Error` where needed

```swift
// Example typed throws
public enum NetworkError: Error {
    case monitoringFailed
    case invalidConfiguration
    case platformUnsupported
}

public enum ConnectivityError: Error {
    case sessionNotSupported
    case activationFailed(underlying: Error)
    case missingCompanion
    case messagingUnavailable
}

public func activate() throws(ConnectivityError) {
    // Implementation
}
```

### 5.2 Plugin System (`SundialKitCore`)

#### Protocol Definitions
- [ ] Define `NetworkMonitoring` protocol
  - State queries (pathStatus, isExpensive, isConstrained)
  - Lifecycle methods (start, stop)
  - Change notification mechanism (callback-based, not reactive)

- [ ] Define `ConnectivityManagement` protocol
  - State queries (activationState, isReachable, isPaired, etc.)
  - Lifecycle methods (activate, deactivate)
  - Message sending (protocol-agnostic)
  - Change notification mechanism

- [ ] Define `MessageSerializing` protocol for serialization plugins

#### Core Type Sendable Conformance
- [ ] Mark all core value types as `Sendable` for Swift 6.1 compatibility:
  - `PathStatus` enum and nested types
  - `ActivationState` enum
  - `NetworkError`, `ConnectivityError`, `SerializationError` enums
  - All message-related types
  - Required for modern packages using Swift 6.1 strict concurrency

#### Extension Points
- [ ] Observable state pattern for plugin consumption
- [ ] Delegate-based change notifications
- [ ] Plugin registration/discovery (if needed)

### 5.3 Reactive Plugins

#### SundialKitCombine
- [ ] `NetworkObserver` wrapping `NetworkMonitor`
  - `pathStatusPublisher: AnyPublisher<PathStatus, Never>`
  - `isExpensivePublisher: AnyPublisher<Bool, Never>`
  - `isConstrainedPublisher: AnyPublisher<Bool, Never>`
  - `pingStatusPublisher` (if NetworkPing provided)
  - Exact v1.0.0 API compatibility

- [ ] `ConnectivityObserver` wrapping `ConnectivityManager`
  - All v1.0.0 publishers maintained
  - `sendingMessageSubject` for message sending
  - `messageReceivedPublisher`, `replyMessagePublisher`
  - Exact v1.0.0 API compatibility

#### SundialKitStream
- [ ] `NetworkStream` wrapping `NetworkMonitor` (actor-based for Swift 6.1)
  - `pathStatusStream: AsyncStream<PathStatus>`
  - `isExpensiveStream: AsyncStream<Bool>`
  - `isConstrainedStream: AsyncStream<Bool>`
  - `async func currentStatus() -> PathStatus`
  - Implemented as `actor NetworkStream` for thread safety
  - Full Swift 6.1 strict concurrency

- [ ] `ConnectivityStream` wrapping `ConnectivityManager` (actor-based for Swift 6.1)
  - `activationStateStream: AsyncStream<ActivationState>`
  - `isReachableStream: AsyncStream<Bool>`
  - `messageStream: AsyncStream<ReceivedMessage>`
  - `async func send<M: MessageSerializing>(_ message: M) throws`
  - `async func activate() throws`
  - Implemented as `actor ConnectivityStream` for thread safety
  - Full Swift 6.1 strict concurrency

### 5.4 Serialization Plugins

#### SundialKitMessagable
- [ ] Exact v1.0.0 `Messagable` protocol
- [ ] `MessageDecoder` with v1.0.0 API
- [ ] `ConnectivityMessage` typealias (`[String: Any]`)
- [ ] Extension for converting `Messagable` to/from `ConnectivityMessage`

#### SundialKitProtobuf
- [ ] `ProtobufMessagable` protocol for SwiftProtobuf messages
  - Requires conformance to SwiftProtobuf's `Message` protocol
  - Automatic binary serialization
  - Type-safe encoding/decoding

- [ ] Extensions for WatchConnectivity integration
  - Convert `Message` to WatchConnectivity-compatible format
  - Handle binary data transmission
  - Preserve message type information

- [ ] Error handling for serialization failures
  - `SerializationError.encodingFailed`
  - `SerializationError.decodingFailed`
  - `SerializationError.incompatibleType`

```swift
// Example Protobuf usage
import SundialKit
import SundialKitProtobuf

// User-defined .proto file
message HeartRateUpdate {
    int32 bpm = 1;
    int64 timestamp = 2;
}

// Swift usage
extension HeartRateUpdate: ProtobufMessagable {}

let update = HeartRateUpdate.with {
    $0.bpm = 72
    $0.timestamp = Date().timeIntervalSince1970
}

try await connectivity.send(update)
```

### 5.5 Testing Infrastructure

#### Swift Testing Migration
- [ ] Migrate all XCTest test cases to Swift Testing
  - Replace `XCTestCase` with `@Test` functions
  - Replace `XCTAssert*` with Swift Testing assertions
  - Use `@Suite` for test organization
  - Leverage parameterized testing where applicable

- [ ] Update CI/CD workflows for Swift Testing
  - Ensure GitHub Actions supports Swift Testing
  - Update code coverage reporting
  - Maintain test performance benchmarks

- [ ] Provide testing utilities for plugin developers
  - Mock implementations of core protocols
  - Test fixtures for common scenarios
  - Example test suites

### 5.6 Platform Support

Platform requirements vary by package based on their dependencies and backwards compatibility needs. SundialKit v2.0.0 uses a **two-tier strategy**:

**Tier 1: V1.0.0 Compatibility Layer** (Swift 5.9)
- SundialKitCore, SundialKit, SundialKitCombine, SundialKitMessagable
- Must maintain v1.0.0 platform support
- Use `@available` guards where needed for backwards compatibility

**Tier 2: Modern Swift Packages** (Swift 6.1)
- SundialKitStream, SundialKitProtobuf
- No backwards compatibility constraints
- No `@available` guards - simply declare minimum platforms in Package.swift
- Leverage latest Swift features

#### Summary Table

| Package | Swift Version | iOS | macOS | watchOS | tvOS | @available Guards? |
|---------|--------------|-----|-------|---------|------|--------------------|
| SundialKitCore | 5.9+ | 13+ | 10.13+ | 6+ | 13+ | Yes (where needed) |
| SundialKit | 5.9+ | 13+ | 10.13+ | 6+ | 13+ | Yes (where needed) |
| SundialKitCombine | 5.9+ | 13+ | 10.15+ | 6+ | 13+ | Yes |
| SundialKitMessagable | 5.9+ | 13+ | 10.13+ | 6+ | 13+ | Yes (where needed) |
| SundialKitStream | 6.1+ | 13+ | 10.15+ | 6+ | 13+ | No |
| SundialKitProtobuf | 6.1+ | Per SwiftProtobuf | Per SwiftProtobuf | Per SwiftProtobuf | Per SwiftProtobuf | No |

#### Core Package: SundialKit / SundialKitCore

**Minimum Platform Versions:**
- iOS 13+, watchOS 6+, tvOS 13+, macOS 10.13+
- **Must maintain v1.0.0 compatibility** for backwards-compatibility plugins

**Dependencies:**
- Foundation (system)
- Network framework (iOS 12+, macOS 10.14+)
- WatchConnectivity (iOS/watchOS only)

**Platform Considerations:**
- Core must use `@available` guards where needed to support v1.0.0 minimums
- Particularly for any concurrency features in the observer pattern

#### Plugin Package: SundialKitCombine (Backwards Compatibility)

**Minimum Platform Versions:**
- iOS 13+, watchOS 6+, tvOS 13+, macOS 10.15+
- **Must match v1.0.0 API platform support**
- Note: macOS 10.15+ is required for Combine (slightly higher than v1.0.0's macOS 10.13+)

**Dependencies:**
- SundialKitCore ^2.0.0
- Combine (Apple framework, iOS 13+, macOS 10.15+)

**Platform Considerations:**
- Must maintain exact v1.0.0 platform compatibility
- Use `@available` guards extensively to match v1.0.0 behavior
- Cannot break existing code that targets v1.0.0 minimums

#### Plugin Package: SundialKitMessagable (Backwards Compatibility)

**Minimum Platform Versions:**
- iOS 13+, watchOS 6+, tvOS 13+, macOS 10.13+
- **Must match v1.0.0 platform requirements exactly**

**Dependencies:**
- SundialKitCore ^2.0.0
- No external dependencies

**Platform Considerations:**
- Must maintain exact v1.0.0 platform compatibility
- Use `@available` guards where needed to match v1.0.0 behavior
- Critical for zero-breaking-change migration

#### Plugin Package: SundialKitStream (New in v2.0.0)

**Minimum Platform Versions:**
- iOS 13+, watchOS 6+, tvOS 13+, macOS 10.15+
- **New package - no backwards compatibility constraints**
- Platforms set to match AsyncStream/concurrency requirements

**Dependencies:**
- SundialKitCore ^2.0.0
- swift-async-algorithms (optional)

**Swift Version:**
- Minimum: Swift 6.1
- Leverages modern Swift concurrency and typed throws

**Platform Considerations:**
- **Does NOT use `@available` guards** - simply declares minimum platforms in Package.swift
- Clean, modern Swift 6.1 implementation
- No backwards compatibility concerns
- If using swift-async-algorithms, follow its minimum platform requirements

**Recommendation:** Don't use swift-async-algorithms unless advanced features are needed; keep dependencies minimal.

#### Plugin Package: SundialKitProtobuf (New in v2.0.0)

**Minimum Platform Versions:**
- Determined by latest [SwiftProtobuf](https://github.com/apple/swift-protobuf) requirements
- Pinned to latest stable SwiftProtobuf release
- Effectively: max(SundialKitCore platforms, latest SwiftProtobuf platforms)
- **New package - no backwards compatibility constraints**

**Dependencies:**
- SundialKitCore ^2.0.0
- SwiftProtobuf (latest stable version)

**Swift Version:**
- Minimum: Swift 6.1
- Leverages modern Swift features for type safety and concurrency

**Platform Considerations:**
- **Does NOT use `@available` guards** - simply declares minimum platforms in Package.swift
- Minimum platforms determined by latest SwiftProtobuf dependency
- Pin to latest stable SwiftProtobuf version
- Clean, modern Swift 6.1 implementation
- No backwards compatibility concerns

#### Swift Version

**V1.0.0 Compatibility Layer** (SundialKitCore, SundialKit, SundialKitCombine, SundialKitMessagable):
- Minimum: Swift 5.9 (maintains v1.0.0 requirement)
- Must not introduce Swift 6.0+ requirements to maintain backwards compatibility

**Modern Packages** (SundialKitStream, SundialKitProtobuf):
- Minimum: Swift 6.1
- Leverages latest Swift features for typed throws, concurrency, and modern patterns
- No backwards compatibility constraints

---

## 6. API Design

### 6.1 Core Layer Example

```swift
// SundialKitCore - Protocol definition
public protocol NetworkMonitoring {
    var pathStatus: PathStatus { get }
    var isExpensive: Bool { get }
    var isConstrained: Bool { get }

    func start(queue: DispatchQueue)
    func stop()
    func addObserver(_ observer: NetworkStateObserver)
}

public protocol NetworkStateObserver: AnyObject {
    func networkMonitor(_ monitor: NetworkMonitoring, didUpdatePathStatus status: PathStatus)
    func networkMonitor(_ monitor: NetworkMonitoring, didUpdateIsExpensive expensive: Bool)
    func networkMonitor(_ monitor: NetworkMonitoring, didUpdateIsConstrained constrained: Bool)
}

// SundialKit - Implementation
public final class NetworkMonitor: NetworkMonitoring {
    private let pathMonitor: PathMonitor
    private var observers: [Weak<NetworkStateObserver>] = []

    public var pathStatus: PathStatus { /* ... */ }
    public var isExpensive: Bool { /* ... */ }
    public var isConstrained: Bool { /* ... */ }

    public func start(queue: DispatchQueue) { /* ... */ }
    public func stop() { /* ... */ }
    public func addObserver(_ observer: NetworkStateObserver) { /* ... */ }
}
```

### 6.2 Combine Plugin Example

```swift
// SundialKitCombine
import Combine
import SundialKitCore

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public final class NetworkObserver: ObservableObject {
    private let monitor: NetworkMonitoring
    private var cancellables: Set<AnyCancellable> = []

    @Published public private(set) var pathStatus: PathStatus = .unknown
    @Published public private(set) var isExpensive: Bool = false
    @Published public private(set) var isConstrained: Bool = false

    public var pathStatusPublisher: AnyPublisher<PathStatus, Never> {
        $pathStatus.eraseToAnyPublisher()
    }

    public init(monitor: NetworkMonitoring) {
        self.monitor = monitor
        // Bridge observer pattern to Combine
    }

    public func start(queue: DispatchQueue) {
        monitor.start(queue: queue)
    }
}
```

### 6.3 AsyncStream Plugin Example

```swift
// SundialKitStream (Swift 6.1 with actors)
import SundialKitCore

public actor NetworkStream {
    private let monitor: NetworkMonitoring

    public init(monitor: NetworkMonitoring) {
        self.monitor = monitor
    }

    public var pathStatusStream: AsyncStream<PathStatus> {
        AsyncStream { continuation in
            let observer = PathStatusObserver { status in
                continuation.yield(status)
            }
            monitor.addObserver(observer)
            continuation.onTermination = { _ in
                monitor.stop()
            }
            monitor.start(queue: .global())
        }
    }

    public func currentPathStatus() async -> PathStatus {
        monitor.pathStatus
    }
}
```

**Key Features:**
- Actor-based for automatic thread safety
- No `@available` guards needed (declares minimum platforms in Package.swift)
- Swift 6.1 strict concurrency enabled
- All async operations are actor-isolated

### 6.4 Protobuf Plugin Example

```swift
// SundialKitProtobuf
import SwiftProtobuf
import SundialKitCore

public protocol ProtobufMessagable: SwiftProtobuf.Message {
    // Marker protocol
}

extension ConnectivityManager {
    public func send<M: ProtobufMessagable>(
        _ message: M
    ) throws(ConnectivityError) {
        let data = try message.serializedData()
        let dictionary: [String: Any] = [
            "_protobuf_type": String(describing: M.self),
            "_protobuf_data": data
        ]
        try sendRawMessage(dictionary)
    }

    public func decode<M: ProtobufMessagable>(
        _ type: M.Type,
        from message: [String: Any]
    ) throws(SerializationError) -> M {
        guard let data = message["_protobuf_data"] as? Data else {
            throw .decodingFailed
        }
        return try M(serializedData: data)
    }
}
```

---

## 7. Backwards Compatibility & Migration

### 7.1 V1.0.0 Compatibility Matrix

| v1.0.0 Component | v2.0.0 Equivalent | Package Required |
|------------------|-------------------|------------------|
| `NetworkObserver` | `NetworkObserver` | `SundialKitCombine` |
| `ConnectivityObserver` | `ConnectivityObserver` | `SundialKitCombine` |
| `Messagable` protocol | `Messagable` protocol | `SundialKitMessagable` |
| `MessageDecoder` | `MessageDecoder` | `SundialKitMessagable` |
| `PathStatus` | `PathStatus` | `SundialKitCore` |
| All publishers | All publishers | `SundialKitCombine` |

### 7.2 Migration Paths

#### Path 1: Maintain v1 (No Changes)
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/brightdigit/SundialKit", from: "2.0.0"),
    .package(url: "https://github.com/brightdigit/SundialKitCombine", from: "2.0.0"),
    .package(url: "https://github.com/brightdigit/SundialKitMessagable", from: "2.0.0")
]

// Code remains unchanged from v1
import SundialKit
import SundialKitCombine
import SundialKitMessagable

let observer = NetworkObserver()
observer.pathStatusPublisher.sink { status in
    print(status)
}
```

#### Path 2: Gradual Async Adoption
```swift
// Start with Combine for network, AsyncStream for connectivity
dependencies: [
    .package(url: "https://github.com/brightdigit/SundialKit", from: "2.0.0"),
    .package(url: "https://github.com/brightdigit/SundialKitCombine", from: "2.0.0"),
    .package(url: "https://github.com/brightdigit/SundialKitStream", from: "2.0.0"),
    .package(url: "https://github.com/brightdigit/SundialKitMessagable", from: "2.0.0")
]

// Network: still Combine
let networkObserver = NetworkObserver()

// Connectivity: new AsyncStream approach
let connectivityMonitor = ConnectivityStream()
Task {
    for await isReachable in connectivityMonitor.isReachableStream {
        print("Reachable: \(isReachable)")
    }
}
```

#### Path 3: Full Modern Stack
```swift
// Pure async/await + Protobuf
dependencies: [
    .package(url: "https://github.com/brightdigit/SundialKit", from: "2.0.0"),
    .package(url: "https://github.com/brightdigit/SundialKitStream", from: "2.0.0"),
    .package(url: "https://github.com/brightdigit/SundialKitProtobuf", from: "2.0.0")
]

import SundialKit
import SundialKitStream
import SundialKitProtobuf

let network = NetworkStream()
Task {
    for await status in network.pathStatusStream {
        print(status)
    }
}

let connectivity = ConnectivityStream()
let message = MyProtoMessage()
try await connectivity.send(message)
```

### 7.3 Deprecation Strategy

**v2.0.0 Release:**
- No deprecations
- All v1 APIs available through plugins
- Encourage adoption via documentation

**v2.1.0+ (Future):**
- Soft deprecation warnings in Combine plugins
- Migration guides prominently featured
- Continue maintaining all plugins

**v3.0.0 (Future):**
- Consider making Combine/Messagable optional
- Potentially drop older platform versions
- AsyncStream as primary reactive approach

---

## 8. Dependencies

### Core Package (`SundialKit`)
- **SundialKitCore**: Internal target dependency
- **Foundation**: Apple framework
- **Network**: Apple framework (iOS 12+, macOS 10.14+)
- **WatchConnectivity**: Apple framework (iOS, watchOS only)
- **Swift Version**: 5.9+

### Plugin: SundialKitCombine
- **SundialKitCore**: ^2.0.0
- **Combine**: Apple framework (iOS 13+, macOS 10.15+)
- **Swift Version**: 5.9+

### Plugin: SundialKitStream
- **SundialKitCore**: ^2.0.0
- **swift-async-algorithms**: Optional (recommended not to use unless needed)
- **Swift Version**: 6.1+
- Uses Swift Concurrency (AsyncStream, async/await)

### Plugin: SundialKitMessagable
- **SundialKitCore**: ^2.0.0
- **Swift Version**: 5.9+
- No external dependencies

### Plugin: SundialKitProtobuf
- **SundialKitCore**: ^2.0.0
- **SwiftProtobuf**: Latest stable version (pinned)
- **Swift Version**: 6.1+

---

## 9. Success Metrics

### Technical Metrics
1. **100% v1 API Coverage** - All v1 APIs available via plugins
2. **Zero Breaking Changes** - v1 code works with v2 plugins
3. **Test Coverage ≥90%** - Maintain high test coverage across all packages
4. **Build Time Impact <10%** - Modular structure should not significantly increase build times
5. **Binary Size** - Users only pay for features they use (smaller binaries)

### Adoption Metrics
1. **Plugin Usage** - Track which plugins are most popular
2. **Migration Rate** - % of users adopting async plugins within 6 months
3. **Issue Reduction** - Fewer issues related to Combine/reactive complexity
4. **Community Contributions** - Enable community-built plugins

### Quality Metrics
1. **Swift Testing Migration** - 100% of tests migrated
2. **Typed Throws Coverage** - All public throwing APIs use typed throws
3. **Sendable Conformance** - All core value types conform to Sendable
4. **Swift 6.1 Strict Concurrency** - Modern packages compile without warnings under strict concurrency
5. **Actor Isolation** - All actor-based types properly isolated
6. **Documentation** - Complete API documentation for all packages
7. **Example Apps** - Working demos for each plugin combination

---

## 10. Implementation Phases

### Phase 1: Foundation (Milestone: v2.0.0-alpha.1)
**Timeline: 4-6 weeks**

- [ ] Extract `NetworkMonitor` from `NetworkObserver`
  - Remove Combine dependencies
  - Implement observer pattern
  - Create `NetworkMonitoring` protocol
  - Port all tests to Swift Testing

- [ ] Extract `ConnectivityManager` from `ConnectivityObserver`
  - Remove Combine dependencies
  - Implement observer pattern
  - Create `ConnectivityManagement` protocol
  - Port all tests to Swift Testing

- [ ] Implement typed throws
  - Define error types
  - Apply to all throwing methods
  - Update error handling documentation

- [ ] Create `SundialKitCore` target
  - Define all protocols
  - Move shared types
  - Document plugin contracts

### Phase 2: Plugin Infrastructure (Milestone: v2.0.0-alpha.2)
**Timeline: 3-4 weeks**

- [ ] Create `SundialKitCombine` package
  - Port v1 `NetworkObserver` as wrapper
  - Port v1 `ConnectivityObserver` as wrapper
  - Ensure 100% v1 API compatibility
  - Comprehensive tests

- [ ] Create `SundialKitMessagable` package
  - Port v1 `Messagable` protocol
  - Port v1 `MessageDecoder`
  - Ensure 100% v1 API compatibility
  - Comprehensive tests

- [ ] Verification
  - Run v1 example apps with v2 + plugins
  - Verify zero code changes needed
  - Performance benchmarking

### Phase 3: Modern Features (Milestone: v2.0.0-beta.1)
**Timeline: 4-6 weeks**

- [ ] Add Sendable conformance to core types
  - Mark all value types as Sendable in SundialKitCore
  - Ensure compatibility with Swift 6.1 strict concurrency
  - Update documentation

- [ ] Create `SundialKitStream` package (Swift 6.1 + actors)
  - `actor NetworkStream` with AsyncStreams
  - `actor ConnectivityStream` with AsyncStreams
  - Async/await convenience methods
  - Full Swift 6.1 strict concurrency mode enabled
  - Comprehensive tests with Swift Testing

- [ ] Create `SundialKitProtobuf` package (Swift 6.1)
  - `ProtobufMessagable` protocol
  - Serialization/deserialization
  - Integration with `ConnectivityManager`
  - Example `.proto` files and usage
  - Swift 6.1 strict concurrency mode enabled
  - Comprehensive tests

### Phase 4: Documentation & Examples (Milestone: v2.0.0-rc.1)
**Timeline: 2-3 weeks**

- [ ] Complete API documentation
  - DocC documentation for all packages
  - Migration guides
  - Architecture documentation
  - Plugin development guide

- [ ] Example applications
  - v1 compatibility example
  - Pure async/await example
  - Protobuf messaging example
  - Mixed approach example

- [ ] Update README and guides
  - Update main README.md
  - Create MIGRATION.md
  - Create PLUGINS.md
  - Update CLAUDE.md

### Phase 5: Release (Milestone: v2.0.0)
**Timeline: 1-2 weeks**

- [ ] Final testing and bug fixes
- [ ] Performance optimization
- [ ] Release notes
- [ ] Coordinate plugin releases
- [ ] Announce release

---

## 11. Open Questions & Decisions Needed

### Platform & Swift Version
- [x] **Decision**: Minimum platform versions for Core package?
  - **Decision**: iOS 13+, macOS 10.13+, watchOS 6+, tvOS 13+ (maintain v1.0.0 compatibility)
  - **Impact**: Core must use `@available` guards where needed for backwards-compatibility plugins
  - **Note**: New plugins (Stream, Protobuf) can set their own minimums freely

- [x] **Decision**: Should SundialKitStream depend on swift-async-algorithms?
  - **Decision**: No external dependency (keep dependencies minimal)
  - **Impact**: Use built-in AsyncStream only; cleaner dependency graph

- [x] **Decision**: SundialKitStream minimum platforms and Swift version?
  - **Decision**: iOS 13+, macOS 10.15+, watchOS 6+, tvOS 13+ with Swift 6.1+
  - **Impact**: No @available guards needed; clean modern implementation
  - **Note**: New package with no backwards compatibility constraints

- [x] **Decision**: Swift version split strategy?
  - **Decision**:
    - Swift 5.9 for v1.0.0 compatibility layer (Core, SundialKit, Combine, Messagable)
    - Swift 6.1 for modern packages (Stream, Protobuf)
  - **Impact**: Backwards compatibility maintained while enabling modern Swift features for new packages

- [x] **Decision**: SwiftProtobuf version for SundialKitProtobuf?
  - **Decision**: Pin to latest stable SwiftProtobuf release
  - **Impact**: Always use most recent SwiftProtobuf features and platform support

### Package Management
- [ ] **Decision**: Should plugin packages live in the same monorepo or separate repos?
  - **Option A**: Monorepo (easier coordination, single versioning)
  - **Option B**: Separate repos (true independence, complex coordination)
  - **Recommendation**: Start with monorepo, extract later if needed

- [ ] **Decision**: Versioning strategy for plugins?
  - **Option A**: Lock-step versioning (all 2.0.0 together)
  - **Option B**: Independent versioning
  - **Recommendation**: Lock-step for simplicity

### API Design
- [ ] **Decision**: Should modern package types be actors?
  - **`NetworkStream` and `ConnectivityStream`**: Yes (Swift 6.1 actor-based)
  - **`NetworkMonitor` and `ConnectivityManager`**: No (keep as classes for v1 compatibility)
  - **Rationale**: Modern packages should leverage Swift 6.1 concurrency fully
  - **Impact**: Thread-safe by default, better for concurrent workloads

- [ ] **Decision**: Should core types (PathStatus, etc.) conform to Sendable?
  - **Decision**: Yes, mark all core value types as Sendable
  - **Impact**: Required for Swift 6.1 strict concurrency in modern packages
  - **Applies to**: PathStatus, ActivationState, error types, etc.

### Testing
- [ ] **Decision**: Swift Testing availability on older platforms?
  - **Investigation needed**: Minimum platform for Swift Testing
  - **Fallback**: Keep XCTest tests until Swift Testing mature

### Protobuf
- [ ] **Decision**: Should we provide standard `.proto` schemas?
  - **Option A**: Users bring their own (current plan)
  - **Option B**: Provide reference schemas
  - **Recommendation**: Option A, document common patterns

---

## 12. Risks & Mitigations

### Risk 1: Plugin Complexity
**Risk**: Users confused by multiple packages
**Likelihood**: Medium
**Impact**: High
**Mitigation**:
- Excellent documentation with decision trees
- Clear examples for common use cases
- Provide starter templates

### Risk 2: Backwards Compatibility Breaks
**Risk**: Subtle differences between v1 and v2+plugins
**Likelihood**: Medium
**Impact**: Critical
**Mitigation**:
- Comprehensive compatibility tests
- Run v1 test suite against v2+plugins
- Beta period with community feedback

### Risk 3: SwiftProtobuf Dependency
**Risk**: SwiftProtobuf changes breaking SundialKitProtobuf
**Likelihood**: Low
**Impact**: Medium
**Mitigation**:
- Pin to stable SwiftProtobuf version
- Abstract critical interfaces
- Provide migration path if needed

### Risk 4: Swift Testing Maturity
**Risk**: Swift Testing not stable on all platforms
**Likelihood**: Low
**Impact**: Medium
**Mitigation**:
- Keep XCTest as fallback during transition
- Gradual migration, test by test
- Monitor Swift Testing evolution

### Risk 5: Adoption Friction
**Risk**: Users stay on v1, don't adopt v2
**Likelihood**: Medium
**Impact**: Medium
**Mitigation**:
- Clear value proposition in documentation
- Show performance/code benefits
- Provide automatic migration tools where possible

---

## 13. Future Considerations (Post v2.0.0)

### v2.1.0+
- SwiftUI property wrappers and macros (`@NetworkStatus`, `@ConnectivityState`)
- Enhanced debugging and logging plugins
- Additional serialization plugins (JSON, MessagePack?)
- Performance optimizations and profiling tools

### v3.0.0
- Potential platform minimum bump (iOS 15+?)
- AsyncStream as primary reactive approach (deprecate Combine plugins)
- Migrate Core layer to Swift 6.1 (breaking change for v1 compatibility layer)
- Consider actor-based Core implementations

---

## Appendix A: Glossary

- **Plugin**: A separate package that extends SundialKit functionality
- **Host**: The main SundialKit package that plugins extend
- **Core**: Protocol definitions in SundialKitCore
- **Reactive Layer**: Combine or AsyncStream abstractions over core implementations
- **Serialization Layer**: Message encoding/decoding (Messagable or Protobuf)
- **Observer Pattern**: Callback-based state change notification
- **Typed Throws**: Swift feature allowing specific error types in throws clauses

## Appendix B: References

- [Issue #23: v2.0.0 Design](https://github.com/brightdigit/SundialKit/issues/23)
- [Swift Evolution: Typed Throws](https://github.com/apple/swift-evolution/blob/main/proposals/0413-typed-throws.md)
- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [SwiftProtobuf Documentation](https://github.com/apple/swift-protobuf)
- [swift-async-algorithms](https://github.com/apple/swift-async-algorithms)
- [AsyncStream Documentation](https://developer.apple.com/documentation/swift/asyncstream)

---

**Document Status**: Draft for review
**Next Review Date**: TBD
**Approvers**: @leogdion, SundialKit maintainers
**Questions/Feedback**: Open an issue at brightdigit/SundialKit
