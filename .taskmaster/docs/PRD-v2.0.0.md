# SundialKit v2.0.0 Product Requirements Document

**Version:** 1.0
**Date:** 2025-10-11
**Status:** Draft
**Author:** SundialKit Team

---

## 1. Executive Summary

SundialKit v2.0.0 represents a significant architectural evolution from a monolithic reactive communications library to a modular, plugin-based framework. This redesign enables developers to choose their preferred reactive patterns (Combine or AsyncStream) and serialization methods (Messagable dictionaries or binary formats) while maintaining full backwards compatibility with v1.0.0.

**Modern Swift 6.1 packages** (`SundialKitStream`, `SundialKitBinary`) leverage actor-based concurrency, strict concurrency checking, and the latest Swift features, while **v1.0.0 compatibility packages** (`SundialKitCombine`, `SundialKitMessagable`) maintain Swift 5.9 support for seamless migration.

**Binary serialization** is format-agnostic - use JSON, MessagePack, CBOR, or any custom format by implementing the simple `BinarySerializable` protocol.

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
   - No structured data format support (etc.)

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
3. **Binary Serialization Users** - Teams using MessagePack, CBOR, or custom binary formats
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

#### UC2: Type-Safe Binary Messaging
**As a** watchOS developer
**I want to** use binary serialization for iPhone/Watch communication
**So that** I get type safety and efficient serialization

```swift
import SundialKit
import SundialKitBinary

// Works with any format that conforms to BinarySerializable
// (JSON, MessagePack, CBOR, custom, etc.)
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
**I want to** combine Combine with binary messaging
**So that** I can optimize different parts of my app

```swift
import SundialKit
import SundialKitCombine  // For network
import SundialKitBinary   // For binary messaging
```

---

## 4. Architecture Vision

### Plugin-Based Architecture

SundialKit v2.0.0 adopts a **host + plugin** architecture where:
- **SundialKit** is the host providing core implementations
- **SundialKitCore** defines the plugin contract (protocols)
- **Plugin packages** extend functionality through well-defined interfaces

```
┌──────────────────────────────────────────────┐
│        Main Package: SundialKit              │
│  ┌────────────────────────────────────────┐  │
│  │      SundialKitCore (Protocols)        │  │
│  └────────────────────────────────────────┘  │
│              ▲              ▲                 │
│              │              │                 │
│     ┌────────┴────┐    ┌────┴─────────┐      │
│     │ Network     │    │ Connectivity │      │
│     │ (all        │    │ (iOS/watchOS │      │
│     │ platforms)  │    │ only)        │      │
│     └─────────────┘    └──────────────┘      │
└──────────────────────────────────────────────┘
              ▲              ▲
              │              │
         ┌────┴──────┐  ┌────┴────┐
         │  Plugin   │  │ Plugin  │
         │  Pkgs     │  │ Pkgs    │
         └───────────┘  └─────────┘
```

### Package Structure

**Development Strategy:** All packages are developed in the main `brightdigit/SundialKit` monorepo. Distribution strategy (separate repos vs monorepo) will be determined after initial development is complete.

#### Core Package: `brightdigit/SundialKit`

The main package contains four targets:

**Target: `SundialKitCore`**
- Purpose: Protocol definitions for plugin system
- Contents:
  - `NetworkMonitoring` protocol
  - `ConnectivityManagement` protocol
  - `PathStatus`, `ActivationState`, and core types
  - `NetworkError`, `ConnectivityError`, `SerializationError` (typed throws)
  - Plugin extension points
- Dependencies: Foundation only
- **Swift Version**: 5.9+ (v1.0.0 compatibility)
- **Platforms**: iOS 13+, watchOS 6+, tvOS 13+, macOS 10.13+
- Audience: Plugin developers

**Target: `SundialKitNetwork`**
- Purpose: Network monitoring implementation
- Contents:
  - `NetworkMonitor` class
  - Platform-specific implementations (NWPathMonitor)
  - `PathMonitor` protocol and implementations
  - Optional `NetworkPing` integration
- Dependencies: `SundialKitCore`, Network framework
- **Swift Version**: 5.9+ (v1.0.0 compatibility)
- **Platforms**: iOS 13+, watchOS 6+, tvOS 13+, macOS 10.13+ (universal)
- Audience: All users needing network monitoring

**Target: `SundialKitConnectivity`**
- Purpose: WatchConnectivity management implementation
- Contents:
  - `ConnectivityManager` class
  - Platform-specific implementations (WCSession)
  - `ConnectivitySession` protocol and implementations
  - Activation and messaging logic
- Dependencies: `SundialKitCore`, WatchConnectivity framework
- **Swift Version**: 5.9+ (v1.0.0 compatibility)
- **Platforms**: iOS 13+, watchOS 6+ only (not macOS/tvOS)
- Audience: iOS/watchOS apps needing Watch communication

**Target: `SundialKit`** (Umbrella/Convenience)
- Purpose: Re-exports all targets for convenience
- Contents: Re-exports `SundialKitCore`, `SundialKitNetwork`, `SundialKitConnectivity`
- Dependencies: All three targets above
- **Swift Version**: 5.9+
- **Platforms**: iOS 13+, watchOS 6+ (most restrictive of all targets)
- Audience: Users who want everything with a single import

**Import Examples:**
```swift
// Import only what you need
import SundialKitCore         // Protocols and types only
import SundialKitNetwork      // Network monitoring only
import SundialKitConnectivity // WatchConnectivity only

// Or import everything at once
import SundialKit             // All of the above
```

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

**Package: `SundialKitBinary`** (New in v2.0.0)
- Purpose: Binary serialization for WatchConnectivity (format-agnostic)
- Contents:
  - `BinarySerializable` protocol (simple `Data` conversion)
  - WatchConnectivity binary message sending via `sendMessageData(_:)`
  - Type-safe message handling
  - No external serialization dependencies
- Dependencies: `SundialKitCore` only
- **Swift Version**: 6.1+ with strict concurrency enabled
- **Platforms**: iOS 13+, watchOS 6+, tvOS 13+, macOS 10.15+
- **Flexibility**: Works with ANY format - JSON, MessagePack, CBOR, or custom
- **Note**: Users implement `BinarySerializable` for their chosen format

---

## 5. Technical Requirements

### 5.1 Core Package Targets

#### 5.1.1 SundialKitCore (Protocols & Types)
- [ ] Define `NetworkMonitoring` protocol
- [ ] Define `ConnectivityManagement` protocol
- [ ] Define core value types (`PathStatus`, `ActivationState`)
- [ ] Define typed error enums (`NetworkError`, `ConnectivityError`, `SerializationError`)
- [ ] Mark all types as `Sendable` for Swift 6.1 compatibility (REQUIRED)
- [ ] Document plugin contracts

#### 5.1.2 SundialKitNetwork (Network Monitoring)
- [ ] Extract domain logic from `NetworkObserver` into `NetworkMonitor`
- [ ] Remove Combine dependencies from core monitoring
- [ ] Maintain protocol-based `PathMonitor` abstraction
- [ ] Support optional `NetworkPing` integration
- [ ] Expose state through protocol methods, not publishers
- [ ] Implement `NetworkMonitoring` protocol

#### 5.1.3 SundialKitConnectivity (WatchConnectivity)
- [ ] Extract domain logic from `ConnectivityObserver` into `ConnectivityManager`
- [ ] Remove Combine dependencies from core connectivity
- [ ] Maintain protocol-based `ConnectivitySession` abstraction
- [ ] Expose state through protocol methods, not publishers
- [ ] Support activation lifecycle (with platform-specific differences handled internally)
- [ ] Implement `ConnectivityManagement` protocol
- [ ] Platform-guard for iOS/watchOS only
- [ ] Handle iOS-specific delegate methods internally:
  - `sessionDidBecomeInactive` (iOS only - called when Watch app switches)
  - `sessionDidDeactivate` (iOS only - called when Watch app terminates)
  - `sessionWatchStateDidChange` (iOS only - pairing/installation changes)
- [ ] Bridge delegate-based activation to async/await using continuations
- [ ] Implement timeout for activation (if activation never completes)

#### Error Handling (Typed Throws)
- [ ] Define specific error types for each domain:
  - `NetworkError` - Network-related failures
  - `ConnectivityError` - WatchConnectivity failures
  - `SerializationError` - Message encoding/decoding failures
- [ ] Apply typed throws to all throwing methods
- [ ] Maintain backwards compatibility with generic `Error` where needed

```swift
// Example typed throws
public enum NetworkError: Error, Sendable {
    case monitoringFailed
    case invalidConfiguration
    case platformUnsupported
}

public enum ConnectivityError: Error, Sendable {
    // Session lifecycle errors
    case sessionNotSupported
    case sessionNotActivated
    case activationFailed(underlying: Error)

    // Device pairing errors
    case deviceNotPaired
    case watchAppNotInstalled
    case companionAppNotInstalled
    case missingCompanion

    // Messaging errors
    case messagingUnavailable
    case notReachable
    case messageTooBig(size: Int, limit: Int = 65536)
    case payloadUnsupportedTypes([String])
    case invalidParameter(String)

    // Reply errors
    case messageReplyFailed(underlying: Error)
    case messageReplyTimedOut

    // Delivery errors
    case deliveryFailed(underlying: Error)
    case insufficientSpace

    // File transfer errors (for future use)
    case fileAccessDenied(path: String)

    // Catch-all for unexpected WCErrors
    case underlyingError(Error)
}

public enum SerializationError: Error, Sendable {
    case encodingFailed(underlying: Error)
    case decodingFailed(underlying: Error)
    case invalidData
    case messageKeyMismatch(expected: String, found: String?)
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

#### Core Type Sendable Conformance (REQUIRED)
- [ ] Mark all core value types as `Sendable` for Swift 6.1 compatibility:
  - `PathStatus` enum and nested types
  - `ActivationState` enum
  - `NetworkError`, `ConnectivityError`, `SerializationError` enums
  - All message-related types
  - **REQUIRED**: Essential for modern packages using Swift 6.1 strict concurrency
  - **REQUIRED**: All core types in SundialKitCore must be `Sendable`

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

#### SundialKitMessagable (v1.0.0 Compatibility)
- [ ] Exact v1.0.0 `Messagable` protocol
- [ ] `MessageDecoder` with v1.0.0 API
- [ ] `ConnectivityMessage` typealias (`[String: Any]`)
- [ ] Extension for converting `Messagable` to/from `ConnectivityMessage`

#### SundialKitBinary (New in v2.0.0)
- [ ] `BinarySerializable` protocol - simple interface for any binary format
  ```swift
  public protocol BinarySerializable: Sendable {
      func binaryData() throws -> Data
      init(binaryData: Data) throws
  }
  ```

- [ ] WatchConnectivity integration using `sendMessageData(_:replyHandler:errorHandler:)`
  - Direct binary transmission via WCSession's Data-based APIs when reachable
  - Fallback to `updateApplicationContext` with base64-encoded data when not reachable
  - No dictionary conversion overhead for immediate messages
  - Efficient for large messages (within WatchConnectivity size limits)

- [ ] Message size validation
  - Validate binary message size before sending (WatchConnectivity ~65KB limit)
  - Throw `ConnectivityError.messageTooBig(size:limit:)` if message exceeds limit
  - Consider automatic file transfer for large payloads (future: v2.1.0+)

- [ ] Type-safe message handling
  - Generic send/receive methods (fire-and-forget)
  - Generic request-reply methods (HTTP-style)
  - Automatic serialization/deserialization
  - Error handling for binary failures

- [ ] Request-Reply Pattern (HTTP-style)
  ```swift
  // Fire-and-forget
  public func send<M: BinarySerializable>(_ message: M) async throws(ConnectivityError)

  // Request-response with timeout
  public func request<Request: BinarySerializable, Response: BinarySerializable>(
      _ message: Request,
      expecting responseType: Response.Type,
      timeout: TimeInterval = 10.0
  ) async throws(ConnectivityError) -> Response
  ```

- [ ] Fallback behavior when not reachable
  - Use `sendMessageData` when reachable (direct binary)
  - Fall back to `updateApplicationContext` with base64-encoded binary data when not reachable
  - Document this behavior clearly for users
  - Throw clear error if companion not available

- [ ] Error handling for serialization failures
  - `ConnectivityError.messageTooBig(size:limit:)` - Message exceeds WatchConnectivity limit
  - `SerializationError.encodingFailed(underlying:)` - BinarySerializable.binaryData() failed
  - `SerializationError.decodingFailed(underlying:)` - BinarySerializable.init(binaryData:) failed
  - `SerializationError.invalidData` - Data is corrupted or incompatible

```swift
// Example usage with any binary format
import SundialKit
import SundialKitBinary

struct HeartRateUpdate: BinarySerializable {
    let bpm: Int32
    let timestamp: TimeInterval

    func binaryData() throws -> Data {
        // Use any serialization format
        // JSON, MessagePack, CBOR, custom, etc.
    }

    init(binaryData: Data) throws {
        // Deserialize from Data
    }
}

let update = HeartRateUpdate(bpm: 72, timestamp: Date().timeIntervalSince1970)
try await connectivity.send(update)
```

#### Example Implementations

**With Protobuf** (users implement `BinarySerializable`):
```swift
import SundialKit
import SundialKitBinary
import SwiftProtobuf

// User-defined .proto file generates HeartRateUpdate
// User adds BinarySerializable conformance:
extension HeartRateUpdate: BinarySerializable {
    public func binaryData() throws -> Data {
        try serializedData()
    }

    public init(binaryData: Data) throws {
        try self.init(serializedData: binaryData)
    }
}

let update = HeartRateUpdate.with {
    $0.bpm = 72
    $0.timestamp = Date().timeIntervalSince1970
}

try await connectivity.send(update)
```

**With JSON** (built-in Codable):
```swift
struct HeartRateUpdate: Codable, BinarySerializable {
    let bpm: Int32
    let timestamp: TimeInterval

    func binaryData() throws -> Data {
        try JSONEncoder().encode(self)
    }

    init(binaryData: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: binaryData)
    }
}
```

### 5.5 Testing Infrastructure

#### Swift Testing Migration
**REQUIRED**: All packages (Core, SundialKit, and all plugins) must use Swift Testing exclusively.

- [ ] Migrate all XCTest test cases to Swift Testing
  - Replace `XCTestCase` with `@Test` functions
  - Replace `XCTAssert*` with Swift Testing assertions
  - Use `@Suite` for test organization
  - Leverage parameterized testing where applicable
  - **Applies to all packages**: SundialKitCore, SundialKit, SundialKitCombine, SundialKitMessagable, SundialKitStream, SundialKitBinary

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
- SundialKitStream, SundialKitBinary (optional)
- No backwards compatibility constraints
- No `@available` guards - simply declare minimum platforms in Package.swift
- Leverage latest Swift features

#### Summary Table

| Package/Target | Swift Version | iOS | macOS | watchOS | tvOS | @available Guards? |
|---------------|--------------|-----|-------|---------|------|--------------------|
| **Core Package Targets** | | | | | | |
| SundialKitCore | 5.9+ | 13+ | 10.13+ | 6+ | 13+ | Yes (where needed) |
| SundialKitNetwork | 5.9+ | 13+ | 10.13+ | 6+ | 13+ | Yes (where needed) |
| SundialKitConnectivity | 5.9+ | 13+ | 13+ (iOS/watchOS only) | 6+ | N/A | Yes (where needed) |
| SundialKit (Umbrella) | 5.9+ | 13+ | N/A | 6+ | N/A | Yes (where needed) |
| **Plugin Packages** | | | | | | |
| SundialKitCombine | 5.9+ | 13+ | 10.15+ | 6+ | 13+ | Yes |
| SundialKitMessagable | 5.9+ | 13+ | 10.13+ | 6+ | 13+ | Yes (where needed) |
| SundialKitStream | 6.1+ | 13+ | 10.15+ | 6+ | 13+ | No |
| SundialKitBinary | 6.1+ | 13+ | 10.15+ | 6+ | 13+ | No |

#### Core Package Targets

**SundialKitCore:**
- iOS 13+, watchOS 6+, tvOS 13+, macOS 10.13+
- Foundation only
- Protocol definitions and types
- Must maintain v1.0.0 compatibility

**SundialKitNetwork:**
- iOS 13+, watchOS 6+, tvOS 13+, macOS 10.13+ (universal)
- Dependencies: SundialKitCore, Network framework
- Must maintain v1.0.0 compatibility
- Use `@available` guards where needed

**SundialKitConnectivity:**
- iOS 13+, watchOS 6+ only (not macOS/tvOS)
- Dependencies: SundialKitCore, WatchConnectivity
- Must maintain v1.0.0 compatibility
- Platform-specific guards for iOS/watchOS

**SundialKit (Umbrella):**
- iOS 13+, watchOS 6+ (most restrictive)
- Re-exports all three targets
- Convenience for users who want everything

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


**V1.0.0 Compatibility Layer** (SundialKitCore, SundialKit, SundialKitCombine, SundialKitMessagable):
- Minimum: Swift 5.9 (maintains v1.0.0 requirement)
- Must not introduce Swift 6.0+ requirements to maintain backwards compatibility

**Modern Packages** (SundialKitStream):
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

### 6.4 Binary Serialization Plugin Example

```swift
// SundialKitBinary (Swift 6.1)
import SundialKitCore

public protocol BinarySerializable: Sendable {
    func binaryData() throws -> Data
    init(binaryData: Data) throws
}

public enum BinarySerializationError: Error, Sendable {
    case encodingFailed(underlying: Error)
    case decodingFailed(underlying: Error)
    case invalidData
}

extension ConnectivityManager {
    public func send<M: BinarySerializable>(
        _ message: M
    ) async throws(ConnectivityError) {
        let data = try message.binaryData()
        // Use WatchConnectivity's sendMessageData (binary API)
        try await sendBinaryData(data)
    }

    public func receiveBinary<M: BinarySerializable>(
        _ type: M.Type
    ) -> AsyncStream<M> {
        AsyncStream { continuation in
            // Listen for binary data via WCSession
            onBinaryDataReceived { data in
                do {
                    let message = try M(binaryData: data)
                    continuation.yield(message)
                } catch {
                    // Handle error
                }
            }
        }
    }
}
```

### 6.5 User Implementation Examples

```swift
// Example 1: Protobuf (user-implemented)
import SwiftProtobuf
import SundialKitBinary

extension HeartRateUpdate: BinarySerializable {
    public func binaryData() throws -> Data {
        try serializedData()
    }

    public init(binaryData: Data) throws {
        try self.init(serializedData: binaryData)
    }
}

// Example 2: MessagePack (using third-party library)
import MessagePacker
import SundialKitBinary

struct SensorData: BinarySerializable {
    let temperature: Double
    let humidity: Double

    func binaryData() throws -> Data {
        // Use MessagePack library
        try pack([temperature, humidity])
    }

    init(binaryData: Data) throws {
        let unpacked: [Double] = try unpack(binaryData)
        temperature = unpacked[0]
        humidity = unpacked[1]
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
    .package(url: "https://github.com/brightdigit/SundialKitCombine", from: "1.0.0"),
    .package(url: "https://github.com/brightdigit/SundialKitMessagable", from: "1.0.0")
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
    .package(url: "https://github.com/brightdigit/SundialKitCombine", from: "1.0.0"),
    .package(url: "https://github.com/brightdigit/SundialKitStream", from: "1.0.0"),
    .package(url: "https://github.com/brightdigit/SundialKitMessagable", from: "1.0.0")
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

#### Path 3: Full Modern Stack (Binary)
```swift
// Pure async/await + Binary serialization
dependencies: [
    .package(url: "https://github.com/brightdigit/SundialKit", from: "2.0.0"),
    .package(url: "https://github.com/brightdigit/SundialKitStream", from: "1.0.0"),
    .package(url: "https://github.com/brightdigit/SundialKitBinary", from: "1.0.0")
]

import SundialKit
import SundialKitStream
import SundialKitBinary

let network = NetworkStream()
Task {
    for await status in network.pathStatusStream {
        print(status)
    }
}

// Use any binary format you want
let connectivity = ConnectivityStream()
let message = MyMessage(...)  // Implements BinarySerializable
try await connectivity.send(message)
```

---

## 8. Dependencies

### Core Package Targets

**Target: SundialKitCore**
- **Foundation**: Apple framework only
- **Swift Version**: 5.9+
- No external dependencies

**Target: SundialKitNetwork**
- **SundialKitCore**: Internal target dependency
- **Foundation**: Apple framework
- **Network**: Apple framework (iOS 12+, macOS 10.14+)
- **Swift Version**: 5.9+

**Target: SundialKitConnectivity**
- **SundialKitCore**: Internal target dependency
- **Foundation**: Apple framework
- **WatchConnectivity**: Apple framework (iOS, watchOS only)
- **Swift Version**: 5.9+

**Target: SundialKit (Umbrella)**
- **SundialKitCore**, **SundialKitNetwork**, **SundialKitConnectivity**: Internal target dependencies
- Re-exports all three targets
- **Swift Version**: 5.9+

### Plugin Packages

**Plugin: SundialKitCombine
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

### Plugin: SundialKitBinary
- **SundialKitCore**: ^2.0.0
- **Swift Version**: 6.1+
- No external dependencies (format-agnostic)
- Users implement `BinarySerializable` for their chosen format (JSON, MessagePack, etc.)

---

## 9. Success Metrics

### Technical Metrics
1. **100% v1 API Coverage** - All v1 APIs available via plugins (measured via compatibility tests)
2. **Zero Breaking Changes** - v1 code works with v2 plugins (proven by Bitness integration)
3. **Test Coverage ≥90%** - Maintain high test coverage across all packages (or best effort for solo dev)

### Quality Metrics
1. **Swift Testing Migration** - 100% of tests migrated to Swift Testing (REQUIRED for all packages)
2. **Typed Throws Coverage** - All public throwing APIs use typed throws
3. **Sendable Conformance** - All core value types conform to Sendable (REQUIRED)
4. **Swift 6.1 Strict Concurrency** - Modern packages compile without warnings under strict concurrency
5. **Actor Isolation** - All actor-based types properly isolated (actors used where needed)
6. **Documentation** - Complete API documentation for all packages
7. **Example Apps** - Working demos for each plugin combination

### Solo Developer Success Metrics
1. **Project completed without burnout** - Sustainable pace maintained throughout
2. **Deep learning achieved** - Strong understanding of Swift 6.1 concurrency patterns
3. **Bitness benefits** - Real-world app improved by v2.0.0 architecture
4. **Community validation** - At least 1-2 external users willing to test pre-release
5. **Documentation quality** - Clear enough for new users to adopt without direct support

---

## 10. Sustainability Plan (Solo Developer)

### Solo Developer Context

This project is being developed by a single developer (@leogdion) working across all roles: architect, implementer, tester, and documenter. The sustainability plan ensures successful completion without burnout while maintaining code quality.

### Burnout Prevention

- **Milestone-based progress**: No strict deadlines, focus on completing milestones
- **Regular breaks**: Take time off between major phases
- **Sustainable pace**: Work at a comfortable pace, not rush pace
- **Flexibility**: Adjust scope or approach if needed without guilt
- **Celebrate wins**: Acknowledge completion of each milestone

### Knowledge Continuity

- **Documentation-first approach**: Document architectural decisions as they're made
- **ADRs (Architecture Decision Records)**: Record significant design choices
- **Code comments**: Explain "why" not just "what" for complex logic
- **Commit messages**: Detailed descriptions of changes and reasoning
- **Progress logging**: Weekly notes on what was learned and decided

### Scope Management

Each phase includes:
- **Must Have**: Core requirements that cannot be deferred
- **Nice to Have**: Features that can be moved to v2.1.0+ if needed
- **Complexity assessment**: Honest evaluation of effort required

**Scope Control Guidelines:**
- If a task is taking 2x longer than expected, reassess its necessity
- Nice to Haves are automatically deferred to v2.1.0 unless time permits
- Use GitHub Projects/Issues to track deferred items
- Prefer "good enough" over "perfect" for v2.0.0

### Real-World Validation

**Bitness as Beta Test:**
- Integrating SundialKit v2 into [Bitness](https://github.com/brightdigit/Bitness) provides real-world validation
- Watch communication testing in production app
- Identifies missing APIs and ergonomics issues
- Proves backwards compatibility (or finds breaks early)
- Provides concrete examples for documentation

### Progress Tracking

- **GitHub Projects**: Track phases and milestones
- **Git commits**: Frequent, descriptive commits
- **GitHub Discussions**: Optional weekly progress updates
- **Task Master**: Use for task decomposition and tracking

### Community Engagement

- **RFC Process**: Post design decisions to GitHub Discussions for feedback
- **Beta period**: Invite 1-2 external developers to test pre-release
- **Issue triage**: Respond to issues within 1 week (best effort)
- **No obligation**: Community feedback is welcome but not required

### External Dependencies Management

**Preference for minimal dependencies:**
- `swift-async-algorithms`: Preference to avoid unless clearly beneficial
- Keep dependency list short for easier maintenance
- Document why each dependency exists

**Tool dependencies (Mint):**
- `swift-format`, `SwiftLint`, `Periphery` managed via Mint
- Pin versions in `Mintfile` for reproducibility

---

## 11. Implementation Phases

### Phase 1: Foundation (Milestone: v2.0.0-alpha.1)
**Estimated Effort:** Large
**Blockers:** None
**Success Criteria:** All core targets working, tests passing, protocols defined

#### Milestone 1.1: SundialKitCore Protocols & Types
**Estimated Effort:** Small

- [ ] Define `NetworkMonitoring` protocol
- [ ] Define `ConnectivityManagement` protocol
- [ ] Define core value types (`PathStatus`, `ActivationState`)
- [ ] Define typed error enums with granular cases:
  - `NetworkError` - Network-related failures
  - `ConnectivityError` - Granular WCError mapping (see Section 5.1.3)
  - `SerializationError` - Message encoding/decoding failures
- [ ] Implement `ConnectivityError.init(wcError:)` helper for WCError → ConnectivityError mapping
- [ ] Mark all types as `Sendable` (REQUIRED)
- [ ] Document plugin contracts
- [ ] Port all relevant tests to Swift Testing (REQUIRED)

#### Milestone 1.2: SundialKitNetwork Implementation
**Estimated Effort:** Medium

- [ ] Extract `NetworkMonitor` from `NetworkObserver`
- [ ] Remove Combine dependencies
- [ ] Implement observer pattern
- [ ] Implement `NetworkMonitoring` protocol
- [ ] Maintain `PathMonitor` abstraction
- [ ] Support optional `NetworkPing` integration
- [ ] Port all tests to Swift Testing (REQUIRED)

#### Milestone 1.3: SundialKitConnectivity Implementation
**Estimated Effort:** Medium

- [ ] Extract `ConnectivityManager` from `ConnectivityObserver`
- [ ] Remove Combine dependencies
- [ ] Implement observer pattern
- [ ] Implement `ConnectivityManagement` protocol
- [ ] Maintain `ConnectivitySession` abstraction
- [ ] Platform-guard for iOS/watchOS only
- [ ] Port all tests to Swift Testing (REQUIRED)

#### Milestone 1.4: SundialKit Umbrella Target
**Estimated Effort:** Small

- [ ] Re-export `SundialKitCore`, `SundialKitNetwork`, `SundialKitConnectivity`
- [ ] Verify all targets work together
- [ ] Update Package.swift with product definitions

### Phase 2: Plugin Infrastructure (Milestone: v2.0.0-alpha.2)
**Estimated Effort:** Medium
**Blockers:** Phase 1 completion
**Success Criteria:** V1 compatibility maintained, all v1 tests passing with plugins

- [ ] Create `SundialKitCombine` package
  - Port v1 `NetworkObserver` as wrapper
  - Port v1 `ConnectivityObserver` as wrapper
  - Ensure 100% v1 API compatibility
  - Comprehensive tests with Swift Testing (REQUIRED)

- [ ] Create `SundialKitMessagable` package
  - Port v1 `Messagable` protocol
  - Port v1 `MessageDecoder`
  - Ensure 100% v1 API compatibility
  - Comprehensive tests with Swift Testing (REQUIRED)

- [ ] Verification
  - Run v1 example apps with v2 + plugins
  - Verify zero code changes needed

### Phase 3: Modern Features (Milestone: v2.0.0-beta.1)
**Estimated Effort:** Large
**Blockers:** Phase 2 completion
**Success Criteria:** Modern packages working with Swift 6.1, strict concurrency enabled, actor-based implementations tested

- [ ] Add Sendable conformance to core types (REQUIRED)
  - Mark all value types as Sendable in SundialKitCore
  - Ensure compatibility with Swift 6.1 strict concurrency
  - Update documentation
  - Required for all modern packages

- [ ] Create `SundialKitStream` package (Swift 6.1 + actors)
  - `actor NetworkStream` with AsyncStreams (actor-based for thread safety)
  - `actor ConnectivityStream` with AsyncStreams (actor-based for thread safety)
  - Async/await convenience methods
  - Full Swift 6.1 strict concurrency mode enabled
  - Comprehensive tests with Swift Testing (REQUIRED)

- [ ] Create `SundialKitBinary` package (Swift 6.1)
  - `BinarySerializable` protocol (simple Data conversion)
  - WatchConnectivity integration using `sendMessageData(_:)`
  - Type-safe generic send/receive methods
  - Binary error types
  - Swift 6.1 strict concurrency mode enabled
  - Comprehensive tests with Swift Testing (REQUIRED)
  - Example implementations (JSON, custom)

### Phase 4: Documentation & Examples (Milestone: v2.0.0-rc.1)
**Estimated Effort:** Medium-Large
**Blockers:** Phase 3 completion
**Success Criteria:** Complete documentation, working examples for all use cases, migration guide tested
**Can be parallelized:** Documentation can be drafted during Phase 3

- [ ] Complete API documentation
  - DocC documentation for all packages
  - Migration guides
  - Architecture documentation
  - Plugin development guide

- [ ] Example applications
  - v1 compatibility example (Combine + Messagable)
  - Pure async/await example (Stream)
  - Binary messaging examples (JSON, MessagePack, custom)
  - Protobuf messaging example
  - Mixed approach example (Combine + Binary)

- [ ] Update README and guides
  - Update main README.md
  - Create MIGRATION.md
  - Create PLUGINS.md
  - Update CLAUDE.md

### Phase 4.5: Real-World Integration Testing (Bitness Validation)
**Estimated Effort:** Medium
**Blockers:** Phase 4 completion
**Success Criteria:** Bitness fully functional with SundialKit v2.0.0, no regressions, all watch communication working

- [ ] Integrate SundialKit v2.0.0 into Bitness
  - Replace v1 imports with v2 + plugins
  - Update watch communication code
  - Choose serialization approach (Messagable or Binary)

- [ ] Test real-world iPhone ↔ Apple Watch scenarios
  - Message sending/receiving
  - Reachability handling
  - Background communication
  - Activation lifecycle

- [ ] Identify and fix any integration issues
  - Missing APIs
  - Performance problems
  - API ergonomics issues
  - Documentation gaps

- [ ] Document integration patterns
  - Real-world usage examples from Bitness
  - Common patterns and best practices
  - Troubleshooting guide

- [ ] Optional: Create Bitness case study
  - Before/after comparison
  - Migration experience
  - Benefits realized

### Phase 5: Release (Milestone: v2.0.0)
**Estimated Effort:** Small
**Blockers:** Phase 4.5 completion (Bitness validation)
**Success Criteria:** v2.0.0 released, documentation published, community notified

- [ ] Finalize distribution strategy
  - Evaluate options: monorepo, separate repos, Swift Package Collection
  - Document chosen approach
  - Set up infrastructure if needed

- [ ] Final testing and bug fixes
- [ ] Release notes
- [ ] Tag v2.0.0 release
- [ ] Announce release

---

## 12. Open Questions & Decisions Needed

### Platform & Swift Version
- [x] **Decision**: Minimum platform versions for Core package?
  - **Decision**: iOS 13+, macOS 10.13+, watchOS 6+, tvOS 13+ (maintain v1.0.0 compatibility)
  - **Impact**: Core must use `@available` guards where needed for backwards-compatibility plugins
  - **Note**: New plugins (Stream) can set their own minimums freely

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
    - Swift 6.1 for modern packages (Stream)
  - **Impact**: Backwards compatibility maintained while enabling modern Swift features for new packages

### Package Management
- [x] **Decision**: Should plugin packages live in the same monorepo or separate repos?
  - **Decision**: Monorepo development for v2.0.0, distribution strategy TBD
  - **Development**: All packages developed in main brightdigit/SundialKit monorepo
  - **Distribution**: Decision deferred until after initial development
  - **Benefits**:
    - Easy coordination during development (monorepo)
    - Single source of truth in main repo
    - Simplified dependency management during development
  - **Repository Structure** (Development):
    - `brightdigit/SundialKit` - Main monorepo (all targets/packages)

- [x] **Decision**: Versioning strategy for plugins?
  - **Decision**:
    - **SundialKit** (core package): v2.0.0 (major version bump from v1.0.0)
    - **All plugins**: v1.0.0 (new packages, starting at 1.0.0)
      - SundialKitCombine: 1.0.0
      - SundialKitMessagable: 1.0.0
      - SundialKitStream: 1.0.0
      - SundialKitBinary: 1.0.0
  - **Rationale**: Plugins are new packages, so they start at 1.0.0. Only core SundialKit moves from 1.x to 2.x
  - **Future**: Plugins can have independent versioning after initial release

### API Design
- [x] **Decision**: Should modern package types be actors?
  - **Decision**: Yes, use actors where needed for thread safety
  - **`NetworkStream` and `ConnectivityStream`**: Yes (Swift 6.1 actor-based)
  - **`NetworkMonitor` and `ConnectivityManager`**: No (keep as classes for v1 compatibility)
  - **Rationale**: Modern packages should leverage Swift 6.1 concurrency fully
  - **Impact**: Thread-safe by default, better for concurrent workloads

- [x] **Decision**: Should core types (PathStatus, etc.) conform to Sendable?
  - **Decision**: Yes, mark all core value types as Sendable - **REQUIRED**
  - **Impact**: Required for Swift 6.1 strict concurrency in modern packages
  - **Applies to**: PathStatus, ActivationState, error types, message types, etc.

### Testing
- [x] **Decision**: Swift Testing availability on older platforms?
  - **Decision**: Swift Testing is **REQUIRED** for all packages
  - **Impact**: All packages must migrate to Swift Testing exclusively
  - **Rationale**: Modern testing infrastructure for all libraries

### Binary Serialization
- [x] **Decision**: Should we tightly couple to a specific binary format?
  - **Decision**: No - create format-agnostic `SundialKitBinary` with simple `BinarySerializable` protocol
  - **Benefits**:
    - Works with any binary format (Protobuf, JSON, MessagePack, CBOR, custom)
    - No external serialization dependencies
    - Users choose and implement their preferred format
  - **Impact**: Maximum flexibility, minimal dependencies, no version lock-in

- [x] **Decision**: How to integrate with WatchConnectivity's binary APIs?
  - **Decision**: Use `sendMessageData(_:replyHandler:errorHandler:)` for direct `Data` transmission
  - **Benefits**:
    - No dictionary conversion overhead
    - More efficient for large messages
    - Direct binary-to-binary transmission
  - **Impact**: Better performance, cleaner API

- [x] **Decision**: Should we provide example binary format implementations?
  - **Decision**: Yes, provide examples in documentation, not as separate packages
  - **Approach**: Document how to implement `BinarySerializable` for popular formats:
    - Protobuf (via SwiftProtobuf)
    - JSON (via Codable)
    - MessagePack (via third-party libraries)
    - Custom binary formats
  - **Impact**: Users get guidance without package bloat or version dependencies

---

## 13. Risks & Mitigations

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

### Risk 3: Binary Serialization Format Fragmentation
**Risk**: Users confused about which binary format to use
**Likelihood**: Low
**Impact**: Low
**Mitigation**:
- Clear documentation with format comparison guide
- Provide examples for popular formats (JSON, MessagePack)
- Recommend Protobuf for most use cases in documentation
- Simple `BinarySerializable` protocol makes any format easy to adopt

### Risk 5: Swift Testing Maturity
**Risk**: Swift Testing not stable on all platforms
**Likelihood**: Low
**Impact**: Medium
**Mitigation**:
- Keep XCTest as fallback during transition
- Gradual migration, test by test
- Monitor Swift Testing evolution

### Risk 6: Adoption Friction
**Risk**: Users stay on v1, don't adopt v2
**Likelihood**: Medium
**Impact**: Medium
**Mitigation**:
- Clear value proposition in documentation
- Show performance/code benefits
- Provide automatic migration tools where possible

### Risk 7: Distribution Strategy
**Risk**: Distribution strategy for plugins not yet finalized
**Likelihood**: Low
**Impact**: Low
**Mitigation**:
- All packages developed in main monorepo for v2.0.0
- Distribution decision can be made after implementation complete
- Monorepo-first approach simplifies development
- Can evaluate options (monorepo, separate repos, Swift Package Collection) closer to release

---

## 14. Future Considerations (Post v2.0.0)

### v2.1.0+
- SwiftUI property wrappers and macros (`@NetworkStatus`, `@ConnectivityState`)
- Enhanced debugging and logging plugins
- Additional example implementations for binary formats (MessagePack, CBOR, Cap'n Proto)
- Performance optimizations and profiling tools
- Binary compression options for large messages
- Additional WatchConnectivity transfer methods:
  - `transferUserInfo(_:)` - Background queued delivery
  - `transferFile(_:metadata:)` - Large file transfers
  - `transferCurrentComplicationUserInfo(_:)` - Priority complication updates
  - **Note**: v2.0.0 maintains v1 behavior (sendMessage + updateApplicationContext only)

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
- **Serialization Layer**: Message encoding/decoding (Messagable or Binary formats)
- **Observer Pattern**: Callback-based state change notification
- **Typed Throws**: Swift feature allowing specific error types in throws clauses

## Appendix B: References

- [Issue #23: v2.0.0 Design](https://github.com/brightdigit/SundialKit/issues/23)
- [Swift Evolution: Typed Throws](https://github.com/apple/swift-evolution/blob/main/proposals/0413-typed-throws.md)
- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [SwiftProtobuf Documentation](https://github.com/apple/swift-protobuf)
- [swift-async-algorithms](https://github.com/apple/swift-async-algorithms)
- [AsyncStream Documentation](https://developer.apple.com/documentation/swift/asyncstream)
- [git-subrepo](https://github.com/ingydotnet/git-subrepo) - Tool for managing git subrepositories

---

**Document Status**: Draft for review
**Next Review Date**: TBD
**Approvers**: @leogdion, SundialKit maintainers
**Questions/Feedback**: Open an issue at brightdigit/SundialKit
