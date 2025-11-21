# ``SundialKitStream``

Modern async/await observation plugin for SundialKit with actor-based thread safety.

## Overview

![SundialKit Logo](logo.png)

SundialKitStream provides actor-based observers that deliver state updates via AsyncStream APIs. This plugin is designed for Swift 6.1+ projects using modern concurrency patterns, offering natural thread safety through Swift's actor isolation model and seamless integration with async/await code.

### Why Choose SundialKitStream

If you're building a modern Swift application that embraces async/await and structured concurrency, SundialKitStream is the ideal choice. It leverages Swift's actor isolation to provide thread-safe state management without locks, mutexes, or manual synchronization. The AsyncStream-based APIs integrate naturally with async/await code, making it easy to consume network and connectivity updates in Task contexts.

**Choose SundialKitStream when you:**
- Want to use modern async/await patterns throughout your app
- Need actor-based thread safety without @unchecked Sendable
- Prefer consuming updates with `for await` loops
- Target iOS 16+ / watchOS 9+ / tvOS 16+ / macOS 13+
- Value compile-time concurrency safety with Swift 6.1 strict mode

### Key Features

- **Actor Isolation**: Natural thread safety without locks or manual synchronization
- **AsyncStream APIs**: Consume state updates with `for await` loops in async contexts
- **Swift 6.1 Strict Concurrency**: Zero `@unchecked Sendable` conformances - everything is properly isolated
- **Composable**: Works seamlessly with SundialKitNetwork and SundialKitConnectivity
- **Structured Concurrency**: AsyncStreams integrate naturally with Task hierarchies and cancellation

### Requirements

- Swift 6.1+
- iOS 16+ / watchOS 9+ / tvOS 16+ / macOS 13+

### Getting Started

Add SundialKit to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/brightdigit/SundialKit.git", from: "2.0.0")
],
targets: [
  .target(
    name: "YourTarget",
    dependencies: [
      .product(name: "SundialKitStream", package: "SundialKit"),
      .product(name: "SundialKitNetwork", package: "SundialKit"),  // For network monitoring
      .product(name: "SundialKitConnectivity", package: "SundialKit")  // For WatchConnectivity
    ]
  )
]
```

## Network Monitoring

Monitor network connectivity changes using the actor-based ``NetworkObserver``. The observer tracks network path status, connection quality (expensive, constrained), and optionally performs periodic connectivity verification with custom ping implementations.

### Basic Network Monitoring

The simplest way to monitor network connectivity is to create a NetworkObserver and consume its AsyncStream APIs:

```swift
import SundialKitStream
import SundialKitNetwork

@MainActor
@Observable
class NetworkModel {
  var pathStatus: PathStatus = .unknown
  var isExpensive: Bool = false

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
  }
}
```

The `NWPathMonitorAdapter` wraps Apple's `NWPathMonitor` from the Network framework, providing updates whenever the network path changes (WiFi connects/disconnects, cellular becomes available, etc.).

### Understanding PathStatus

The ``PathStatus`` enum represents the current state of the network path:

- **`.satisfied`** - Network is available and ready to use
- **`.unsatisfied`** - No network connectivity
- **`.requiresConnection`** - Network may be available but requires user action (e.g., connecting to WiFi)
- **`.unknown`** - Initial state before first update

### Monitoring Connection Quality

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

## WatchConnectivity Communication

Communicate between iPhone and Apple Watch using the actor-based ``ConnectivityObserver``. The observer manages the WatchConnectivity session lifecycle, handles automatic transport selection, and provides type-safe messaging through AsyncStream APIs.

### Session Activation

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

### Message Contexts

Messages arrive with different contexts that indicate how they should be handled:

- **`.replyWith(handler)`** - Interactive message expecting an immediate reply. Use the handler to send a response.
- **`.applicationContext`** - Background state update delivered when devices can communicate. No reply expected.

This distinction helps you build responsive communication patterns - interactive messages for user-initiated actions, context updates for background state synchronization.

### Activation State Monitoring

Track the WatchConnectivity session's activation state to understand when communication is possible:

```swift
Task {
  for await state in observer.activationStates() {
    switch state {
    case .activated:
      print("Session active - can communicate")
    case .inactive:
      print("Session inactive - waiting for activation")
    case .notActivated:
      print("Session not yet activated")
    }
  }
}
```

### Reachability Monitoring

Know when the counterpart device (iPhone or Apple Watch) is currently reachable for immediate communication:

```swift
Task {
  for await isReachable in observer.reachabilityStream() {
    if isReachable {
      print("Counterpart is reachable - messages will be delivered immediately")
    } else {
      print("Counterpart unreachable - messages queued for later delivery")
    }
  }
}
```

Reachability affects message transport - when devices are reachable, messages are sent immediately with `sendMessage`. When unreachable, messages are queued with `updateApplicationContext` for delivery when communication resumes.

## SwiftUI Integration

SundialKitStream works beautifully with SwiftUI through the `@Observable` macro. This pattern gives you actor-safe state management with minimal boilerplate:

```swift
import SwiftUI
import SundialKitStream
import SundialKitNetwork

@MainActor
@Observable
class ConnectivityModel {
  var pathStatus: PathStatus = .unknown
  var isExpensive: Bool = false
  var isConstrained: Bool = false

  private let observer = NetworkObserver(
    monitor: NWPathMonitorAdapter(),
    ping: nil
  )

  func start() {
    observer.start(queue: .global())

    Task {
      for await status in observer.pathStatusStream {
        self.pathStatus = status
      }
    }

    Task {
      for await expensive in observer.isExpensiveStream {
        self.isExpensive = expensive
      }
    }

    Task {
      for await constrained in observer.isConstrainedStream {
        self.isConstrained = constrained
      }
    }
  }
}

struct NetworkStatusView: View {
  @State private var model = ConnectivityModel()

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

The `@MainActor` annotation ensures all UI updates happen on the main thread, while the AsyncStreams run on background queues. SwiftUI's `.task` modifier handles Task lifecycle automatically - starting when the view appears and cancelling when it disappears.

### Actor-Based Architecture Benefits

By using actors for your observers and `@MainActor` for your SwiftUI models, you get:

- **Thread Safety**: Actor isolation prevents data races at compile time
- **No Manual Locking**: Swift's actor system handles synchronization automatically
- **Structured Concurrency**: Tasks are tied to view lifecycle through `.task`
- **Cancellation Support**: AsyncStreams respect Task cancellation when views disappear
- **Zero @unchecked Sendable**: Everything is properly isolated with Swift 6.1 strict concurrency

This architecture makes it impossible to accidentally update UI from background threads or create race conditions in state management.

## Topics

### Network Monitoring

- ``NetworkObserver``

### WatchConnectivity

- ``ConnectivityObserver``
- ``ConnectivityStateManager``

### Message Distribution

- ``MessageDistributor``

### Protocols

- ``StateHandling``
- ``MessageHandling``
