# SundialKitStream

<p align="center">
    <img alt="SundialKit" title="SundialKit" src="Sources/SundialKitStream/SundialKitStream.docc/Resources/logo.png" height="150">
</p>

Modern async/await observation plugin for SundialKit with actor-based concurrency safety.

[![SwiftPM](https://img.shields.io/badge/SPM-Linux%20%7C%20iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-success?logo=swift)](https://swift.org)
[![Twitter](https://img.shields.io/badge/twitter-@brightdigit-blue.svg?style=flat)](http://twitter.com/brightdigit)
![GitHub](https://img.shields.io/github/license/brightdigit/SundialKitStream)

## Overview

**SundialKitStream** provides actor-based observers that deliver state updates via AsyncStream APIs. This plugin is designed for Swift 6.1+ projects using modern concurrency patterns, offering natural thread safety through Swift's actor isolation model and seamless integration with async/await code.

Part of **[SundialKit](https://github.com/brightdigit/SundialKit) v2.0.0** - A Swift 6.1+ reactive communications library for Apple platforms.

## Why Choose SundialKitStream

If you're building a modern Swift application that embraces async/await and structured concurrency, SundialKitStream is the ideal choice. It leverages Swift's actor isolation to provide thread-safe state management without locks, mutexes, or manual synchronization. The AsyncStream-based APIs integrate naturally with async/await code, making it easy to consume network and connectivity updates in Task contexts.

**Choose SundialKitStream when you:**
- Want to use modern async/await patterns throughout your app
- Need actor-based thread safety without @unchecked Sendable
- Prefer consuming updates with `for await` loops
- Target iOS 16+ / watchOS 9+ / tvOS 16+ / macOS 13+
- Value compile-time concurrency safety with Swift 6.1 strict mode

## Key Features

- **Actor Isolation**: Natural thread safety without locks or manual synchronization
- **AsyncStream APIs**: Consume state updates with `for await` loops in async contexts
- **Swift 6.1 Strict Concurrency**: Zero `@unchecked Sendable` conformances - everything is properly isolated
- **Composable**: Works seamlessly with SundialKitNetwork and SundialKitConnectivity
- **Structured Concurrency**: AsyncStreams integrate naturally with Task hierarchies and cancellation

## Requirements

- **Swift**: 6.1+
- **Xcode**: 16.0+
- **Platforms**:
  - iOS 16+
  - watchOS 9+
  - tvOS 16+
  - macOS 13+

## Installation

Add SundialKitStream to your `Package.swift`:

```swift
let package = Package(
  name: "YourPackage",
  platforms: [.iOS(.v16), .watchOS(.v9), .tvOS(.v16), .macOS(.v13)],
  dependencies: [
    .package(url: "https://github.com/brightdigit/SundialKit.git", from: "2.0.0"),
    .package(url: "https://github.com/brightdigit/SundialKitStream.git", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "YourTarget",
      dependencies: [
        .product(name: "SundialKitStream", package: "SundialKitStream"),
        .product(name: "SundialKitNetwork", package: "SundialKit"),       // For network monitoring
        .product(name: "SundialKitConnectivity", package: "SundialKit")   // For WatchConnectivity
      ]
    )
  ]
)
```

## Usage

### Network Monitoring

Monitor network connectivity changes using the actor-based `NetworkObserver`. The observer tracks network path status, connection quality (expensive, constrained), and optionally performs periodic connectivity verification with custom ping implementations.

#### Basic Network Monitoring

```swift
import SundialKitStream
import SundialKitNetwork
import SwiftUI

@MainActor
@Observable
class NetworkModel {
  var pathStatus: PathStatus = .unknown
  var isExpensive: Bool = false
  var isConstrained: Bool = false

  private let observer = NetworkObserver(
    monitor: NWPathMonitorAdapter(),
    ping: nil
  )

  func start() {
    observer.start(queue: .global())

    // Listen to path status updates
    Task {
      for await status in observer.pathStatusStream {
        self.pathStatus = status
      }
    }

    // Listen to expensive network status
    Task {
      for await expensive in observer.isExpensiveStream {
        self.isExpensive = expensive
      }
    }

    // Listen to constrained network status
    Task {
      for await constrained in observer.isConstrainedStream {
        self.isConstrained = constrained
      }
    }
  }
}

// Use in SwiftUI
struct NetworkView: View {
  @State private var model = NetworkModel()

  var body: some View {
    VStack {
      Text("Status: \(model.pathStatus.description)")
      Text("Expensive: \(model.isExpensive ? "Yes" : "No")")
      Text("Constrained: \(model.isConstrained ? "Yes" : "No")")
    }
    .task {
      model.start()
    }
  }
}
```

The `NWPathMonitorAdapter` wraps Apple's `NWPathMonitor` from the Network framework, providing updates whenever the network path changes (WiFi connects/disconnects, cellular becomes available, etc.).

#### Understanding PathStatus

The `PathStatus` enum represents the current state of the network path:

- **`.satisfied`** - Network is available and ready to use
- **`.unsatisfied`** - No network connectivity
- **`.requiresConnection`** - Network may be available but requires user action (e.g., connecting to WiFi)
- **`.unknown`** - Initial state before first update

#### Monitoring Connection Quality

Beyond basic connectivity, you can track whether the current network connection is expensive (cellular data) or constrained (low data mode):

```swift
// Monitor all quality indicators
Task {
  for await isExpensive in observer.isExpensiveStream {
    if isExpensive {
      // User is on cellular data - consider reducing data usage
      print("Warning: Using cellular data")
    }
  }
}

Task {
  for await isConstrained in observer.isConstrainedStream {
    if isConstrained {
      // User has Low Data Mode enabled - minimize data usage
      print("Low Data Mode active")
    }
  }
}
```

This information helps you build adaptive applications that respect users' data plans and preferences.

### WatchConnectivity Communication

Communicate between iPhone and Apple Watch using the actor-based `ConnectivityObserver`. The observer manages the WatchConnectivity session lifecycle, handles automatic transport selection, and provides type-safe messaging through AsyncStream APIs.

#### Session Activation

Before sending or receiving messages, you must activate the WatchConnectivity session:

```swift
import SundialKitStream
import SundialKitConnectivity

actor WatchCommunicator {
  private let observer = ConnectivityObserver()

  func activate() async throws {
    try await observer.activate()
  }

  func listenForMessages() async {
    for await result in observer.messageStream() {
      switch result.context {
      case .replyWith(let handler):
        print("Received: \(result.message)")
        handler(["response": "acknowledged"])
      case .applicationContext:
        print("Context update: \(result.message)")
      }
    }
  }

  func sendMessage(_ message: ConnectivityMessage) async throws -> ConnectivitySendResult {
    try await observer.sendMessage(message)
  }
}
```

The `activate()` method initializes the WatchConnectivity session and waits for it to become ready. Once activated, you can send and receive messages.

#### Message Contexts

Messages arrive with different contexts that indicate how they should be handled:

- **`.replyWith(handler)`** - Interactive message expecting an immediate reply. Use the handler to send a response.
- **`.applicationContext`** - Background state update delivered when devices can communicate. No reply expected.

This distinction helps you build responsive communication patterns - interactive messages for user-initiated actions, context updates for background state synchronization.

#### SwiftUI Integration with WatchConnectivity

Use the connectivity observer in SwiftUI with the `@Observable` macro:

```swift
import SwiftUI
import SundialKitStream
import SundialKitConnectivity

@MainActor
@Observable
class WatchModel {
  var activationState: ActivationState = .notActivated
  var isReachable: Bool = false
  var lastMessage: String = ""

  private let observer = ConnectivityObserver()

  func start() async throws {
    try await observer.activate()

    // Monitor activation state
    Task {
      for await state in observer.activationStates() {
        self.activationState = state
      }
    }

    // Monitor reachability
    Task {
      for await reachable in observer.reachabilityStream() {
        self.isReachable = reachable
      }
    }

    // Listen for messages
    Task {
      for await result in observer.messageStream() {
        if let text = result.message["text"] as? String {
          self.lastMessage = text
        }
      }
    }
  }

  func sendMessage(_ text: String) async throws {
    let result = try await observer.sendMessage(["text": text])
    print("Sent via: \(result.context)")
  }
}

struct WatchView: View {
  @State private var model = WatchModel()
  @State private var messageText = ""

  var body: some View {
    VStack {
      Text("Session: \(model.activationState.description)")
      Text("Reachable: \(model.isReachable ? "Yes" : "No")")

      TextField("Message", text: $messageText)

      Button("Send") {
        Task {
          try? await model.sendMessage(messageText)
        }
      }
      .disabled(!model.isReachable)

      Text("Last message: \(model.lastMessage)")
    }
    .task {
      try? await model.start()
    }
  }
}
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
actor WatchCommunicator {
  private let observer = ConnectivityObserver(
    messageDecoder: MessageDecoder(messagableTypes: [ColorMessage.self])
  )

  func listenForColorMessages() async throws {
    for await message in observer.typedMessageStream() {
      if let colorMsg = message as? ColorMessage {
        print("Received color: RGB(\(colorMsg.red), \(colorMsg.green), \(colorMsg.blue))")
      }
    }
  }

  func sendColor(_ color: ColorMessage) async throws {
    let result = try await observer.send(color)
    print("Color sent via: \(result.context)")
  }
}
```

## Architecture

SundialKitStream is part of SundialKit's three-layer architecture:

**Layer 1: Core Protocols** (SundialKitCore, SundialKitNetwork, SundialKitConnectivity)
- Protocol-based abstractions over Apple's Network and WatchConnectivity frameworks
- No observer patterns - pure wrappers

**Layer 2: Observation Plugin** (SundialKitStream - this package)
- Actor-based observers with AsyncStream APIs
- Modern async/await patterns
- Natural Sendable conformance without @unchecked

## Comparison with SundialKitCombine

| Feature | SundialKitStream | SundialKitCombine |
|---------|------------------|-------------------|
| **Concurrency Model** | Actor-based | @MainActor-based |
| **State Updates** | AsyncStream | @Published properties |
| **Thread Safety** | Actor isolation | @MainActor isolation |
| **Platform Support** | iOS 16+, watchOS 9+, tvOS 16+, macOS 13+ | iOS 13+, watchOS 6+, tvOS 13+, macOS 10.15+ |
| **Use Case** | Modern async/await apps | Combine-based apps, SwiftUI with ObservableObject |

## Documentation

For comprehensive documentation, see:
- [SundialKitStream Documentation](https://swiftpackageindex.com/brightdigit/SundialKitStream/documentation)
- [SundialKit Main Documentation](https://swiftpackageindex.com/brightdigit/SundialKit/documentation)

## Related Packages

- **[SundialKit](https://github.com/brightdigit/SundialKit)** - Main package with core protocols and implementations
- **[SundialKitCombine](https://github.com/brightdigit/SundialKitCombine)** - Combine-based observation plugin

## License

This code is distributed under the MIT license. See the [LICENSE](https://github.com/brightdigit/SundialKitStream/LICENSE) file for more info.

## Contributing

SundialKitStream is part of the SundialKit v2.0.0 monorepo during development. For issues, feature requests, or contributions, please visit the [main SundialKit repository](https://github.com/brightdigit/SundialKit).
