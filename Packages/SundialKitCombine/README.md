# SundialKitCombine

<p align="center">
    <img alt="SundialKit" title="SundialKit" src="https://raw.githubusercontent.com/brightdigit/SundialKit/main/Assets/logo.svg" height="150">
</p>

Combine-based observation plugin for SundialKit with @Published properties and reactive publishers.

[![SwiftPM](https://img.shields.io/badge/SPM-Linux%20%7C%20iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-success?logo=swift)](https://swift.org)
[![Twitter](https://img.shields.io/badge/twitter-@brightdigit-blue.svg?style=flat)](http://twitter.com/brightdigit)
![GitHub](https://img.shields.io/github/license/brightdigit/SundialKitCombine)

## Overview

**SundialKitCombine** provides observers that deliver state updates via @Published properties and Combine publishers. This plugin is designed for SwiftUI projects and apps requiring backward compatibility with iOS 13+, offering seamless integration with the Combine framework and SwiftUI's reactive data flow.

Part of **[SundialKit](https://github.com/brightdigit/SundialKit) v2.0.0** - A Swift 6.1+ reactive communications library for Apple platforms.

## Why Choose SundialKitCombine

If you're building a SwiftUI application and need to support iOS 13+, SundialKitCombine is the perfect choice. It leverages Combine's publisher infrastructure to provide reactive state updates that bind naturally to SwiftUI views. The @Published properties work seamlessly with SwiftUI's observation system, automatically triggering view updates when network or connectivity state changes.

**Choose SundialKitCombine when you:**
- Building SwiftUI applications with reactive data binding
- Need to support iOS 13+ / watchOS 6+ / tvOS 13+ / macOS 10.15+
- Prefer Combine publishers and the `.sink` pattern for reactive updates
- Want @Published properties that bind directly to SwiftUI views
- Already have Combine-based infrastructure in your app
- Need `ObservableObject` conformance for SwiftUI `@StateObject` and `@ObservedObject`

## Key Features

- **@Published Properties**: Direct binding to SwiftUI views with automatic updates
- **Combine Publishers**: Full reactive programming support with operators like `map`, `filter`, `debounce`
- **Swift 6.1 Strict Concurrency**: Zero `@unchecked Sendable` conformances - everything uses @MainActor isolation
- **SwiftUI Integration**: Native `ObservableObject` conformance for seamless view updates
- **Backward Compatible**: Supports iOS 13+ for maximum deployment flexibility

## Requirements

- **Swift**: 6.1+
- **Xcode**: 16.0+
- **Platforms**:
  - iOS 13+
  - watchOS 6+
  - tvOS 13+
  - macOS 10.15+
- **Framework**: Combine

## Installation

Add SundialKitCombine to your `Package.swift`:

```swift
let package = Package(
  name: "YourPackage",
  platforms: [.iOS(.v13), .watchOS(.v6), .tvOS(.v13), .macOS(.v10_15)],
  dependencies: [
    .package(url: "https://github.com/brightdigit/SundialKit.git", from: "2.0.0"),
    .package(url: "https://github.com/brightdigit/SundialKitCombine.git", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "YourTarget",
      dependencies: [
        .product(name: "SundialKitCombine", package: "SundialKitCombine"),
        .product(name: "SundialKitNetwork", package: "SundialKit"),       // For network monitoring
        .product(name: "SundialKitConnectivity", package: "SundialKit")   // For WatchConnectivity
      ]
    )
  ]
)
```

## Usage

### Network Monitoring

Monitor network connectivity changes using `NetworkObserver`. The observer provides @Published properties for network state that automatically update your SwiftUI views, plus Combine publishers for advanced reactive patterns.

#### Basic Network Monitoring

Create a NetworkObserver and bind its @Published properties to your SwiftUI view model:

```swift
import SwiftUI
import SundialKitCombine
import SundialKitNetwork
import Combine

@MainActor
class NetworkConnectivityObject: ObservableObject {
  let observer = NetworkObserver(
    monitor: NWPathMonitorAdapter(),
    ping: nil
  )

  @Published var pathStatus: PathStatus = .unknown
  @Published var isExpensive: Bool = false
  @Published var isConstrained: Bool = false

  private var cancellables = Set<AnyCancellable>()

  init() {
    // Bind observer's @Published properties
    observer.$pathStatus
      .assign(to: &$pathStatus)

    observer.$isExpensive
      .assign(to: &$isExpensive)

    observer.$isConstrained
      .assign(to: &$isConstrained)
  }

  func start() {
    // Start monitoring (defaults to main queue for @MainActor observer)
    observer.start()
  }
}

// Use in SwiftUI
struct NetworkStatusView: View {
  @StateObject var connectivity = NetworkConnectivityObject()

  var body: some View {
    VStack {
      Text("Status: \(connectivity.pathStatus.description)")
      Text("Expensive: \(connectivity.isExpensive ? "Yes" : "No")")
      Text("Constrained: \(connectivity.isConstrained ? "Yes" : "No")")
    }
    .onAppear {
      connectivity.start()
    }
  }
}
```

The `NWPathMonitorAdapter` wraps Apple's `NWPathMonitor` from the Network framework. When the network path changes (WiFi connects, cellular becomes available, etc.), the observer's @Published properties automatically update, triggering updates in any bound properties.

#### Understanding PathStatus

The `PathStatus` enum represents the current state of the network path:

- **`.satisfied`** - Network is available and ready to use
- **`.unsatisfied`** - No network connectivity
- **`.requiresConnection`** - Network may be available but requires user action (e.g., connecting to WiFi)
- **`.unknown`** - Initial state before first update

#### Advanced Reactive Patterns

Use Combine operators to create sophisticated reactive behaviors:

```swift
import Combine

@MainActor
class NetworkConnectivityObject: ObservableObject {
  let observer = NetworkObserver(
    monitor: NWPathMonitorAdapter(),
    ping: nil
  )

  @Published var connectionQuality: String = "Unknown"
  private var cancellables = Set<AnyCancellable>()

  init() {
    // Combine multiple network properties into derived state
    Publishers.CombineLatest3(
      observer.$pathStatus,
      observer.$isExpensive,
      observer.$isConstrained
    )
    .map { status, expensive, constrained in
      switch (status, expensive, constrained) {
      case (.satisfied, false, false):
        return "Excellent"
      case (.satisfied, true, false):
        return "Good (Cellular)"
      case (.satisfied, _, true):
        return "Limited (Low Data Mode)"
      case (.unsatisfied, _, _):
        return "Offline"
      default:
        return "Unknown"
      }
    }
    .assign(to: &$connectionQuality)
  }

  func start() {
    observer.start()
  }
}
```

### WatchConnectivity Communication

Communicate between iPhone and Apple Watch using `ConnectivityObserver`. The observer manages the WatchConnectivity session lifecycle, handles automatic transport selection, and provides type-safe messaging through @Published properties and Combine publishers.

#### Session Activation and Message Handling

```swift
import SwiftUI
import SundialKitCombine
import SundialKitConnectivity
import Combine

@MainActor
class WatchConnectivityObject: ObservableObject {
  let observer = ConnectivityObserver()

  @Published var isReachable: Bool = false
  @Published var activationState: ActivationState = .notActivated
  @Published var lastMessage: String = ""

  private var cancellables = Set<AnyCancellable>()

  init() {
    // Bind observer's @Published properties
    observer.$isReachable
      .assign(to: &$isReachable)

    observer.$activationState
      .assign(to: &$activationState)

    // Listen for received messages
    observer.messageReceived
      .compactMap { result in
        result.message["text"] as? String
      }
      .assign(to: &$lastMessage)
  }

  func activate() throws {
    try observer.activate()
  }

  func sendMessage(_ text: String) async throws {
    let result = try await observer.sendMessage(["text": text])
    print("Message sent via: \(result.context)")
  }
}

// Use in SwiftUI
struct WatchMessageView: View {
  @StateObject var watch = WatchConnectivityObject()
  @State private var messageText = ""

  var body: some View {
    VStack {
      Text("Session: \(watch.activationState.description)")
      Text("Reachable: \(watch.isReachable ? "Yes" : "No")")

      TextField("Message", text: $messageText)

      Button("Send") {
        Task {
          try? await watch.sendMessage(messageText)
        }
      }
      .disabled(!watch.isReachable)

      Text("Last message: \(watch.lastMessage)")
    }
    .onAppear {
      try? watch.activate()
    }
  }
}
```

#### Message Contexts

Messages arrive with different contexts that indicate how they should be handled:

- **`.replyWith(handler)`** - Interactive message expecting an immediate reply. Use the handler to send a response.
- **`.applicationContext`** - Background state update delivered when devices can communicate. No reply expected.

```swift
// Handle message contexts
observer.messageReceived
  .sink { result in
    switch result.context {
    case .replyWith(let handler):
      print("Interactive message: \(result.message)")
      handler(["response": "acknowledged"])
    case .applicationContext:
      print("Background update: \(result.message)")
    }
  }
  .store(in: &cancellables)
```

### Type-Safe Messaging with Messagable

For type-safe messaging, use the `Messagable` protocol with `MessageDecoder`:

```swift
import SundialKitConnectivity

// Define a typed message
struct ColorMessage: Messagable {
  let red: Double
  let green: Double
  let blue: Double

  static let key = "color"

  init(from parameters: [String: any Sendable]) throws {
    guard let red = parameters["red"] as? Double,
          let green = parameters["green"] as? Double,
          let blue = parameters["blue"] as? Double else {
      throw SerializationError.missingField("color components")
    }
    self.red = red
    self.green = green
    self.blue = blue
  }

  func parameters() -> [String: any Sendable] {
    ["red": red, "green": green, "blue": blue]
  }

  init(red: Double, green: Double, blue: Double) {
    self.red = red
    self.green = green
    self.blue = blue
  }
}

// Configure observer with MessageDecoder
@MainActor
class WatchConnectivityObject: ObservableObject {
  let observer = ConnectivityObserver(
    messageDecoder: MessageDecoder(messagableTypes: [ColorMessage.self])
  )

  @Published var lastColor: ColorMessage?
  private var cancellables = Set<AnyCancellable>()

  init() {
    // Listen for typed messages
    observer.typedMessageReceived
      .compactMap { $0 as? ColorMessage }
      .assign(to: &$lastColor)
  }

  func activate() throws {
    try observer.activate()
  }

  func sendColor(_ color: ColorMessage) async throws {
    let result = try await observer.send(color)
    print("Color sent via: \(result.context)")
  }
}
```

### Reactive Message Filtering

Use Combine operators to process incoming messages reactively:

```swift
// Filter for specific message types
observer.messageReceived
  .filter { $0.message["type"] as? String == "notification" }
  .sink { result in
    print("Received notification: \(result.message)")
  }
  .store(in: &cancellables)

// Debounce frequent updates
observer.messageReceived
  .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
  .sink { result in
    print("Debounced message: \(result.message)")
  }
  .store(in: &cancellables)

// Transform messages
observer.messageReceived
  .map { $0.message["count"] as? Int ?? 0 }
  .filter { $0 > 10 }
  .sink { count in
    print("High count received: \(count)")
  }
  .store(in: &cancellables)
```

## Architecture

SundialKitCombine is part of SundialKit's three-layer architecture:

**Layer 1: Core Protocols** (SundialKitCore, SundialKitNetwork, SundialKitConnectivity)
- Protocol-based abstractions over Apple's Network and WatchConnectivity frameworks
- No observer patterns - pure wrappers

**Layer 2: Observation Plugin** (SundialKitCombine - this package)
- @MainActor-based observers with @Published properties
- Combine publishers for reactive programming
- Natural SwiftUI integration with ObservableObject

## Comparison with SundialKitStream

| Feature | SundialKitCombine | SundialKitStream |
|---------|-------------------|------------------|
| **Concurrency Model** | @MainActor-based | Actor-based |
| **State Updates** | @Published properties | AsyncStream |
| **Thread Safety** | @MainActor isolation | Actor isolation |
| **Platform Support** | iOS 13+, watchOS 6+, tvOS 13+, macOS 10.15+ | iOS 16+, watchOS 9+, tvOS 16+, macOS 13+ |
| **Use Case** | Combine-based apps, SwiftUI with ObservableObject | Modern async/await apps |

## Documentation

For comprehensive documentation, see:
- [SundialKitCombine Documentation](https://swiftpackageindex.com/brightdigit/SundialKitCombine/documentation)
- [SundialKit Main Documentation](https://swiftpackageindex.com/brightdigit/SundialKit/documentation)

## Related Packages

- **[SundialKit](https://github.com/brightdigit/SundialKit)** - Main package with core protocols and implementations
- **[SundialKitStream](https://github.com/brightdigit/SundialKitStream)** - Async/await observation plugin

## License

This code is distributed under the MIT license. See the [LICENSE](https://github.com/brightdigit/SundialKitCombine/LICENSE) file for more info.

## Contributing

SundialKitCombine is part of the SundialKit v2.0.0 monorepo during development. For issues, feature requests, or contributions, please visit the [main SundialKit repository](https://github.com/brightdigit/SundialKit).
