# ``SundialKitStream``

Modern async/await observation plugin for SundialKit with actor-based thread safety.

## Overview

SundialKitStream provides actor-based observers that deliver state updates via AsyncStream APIs. This plugin is designed for Swift 6.1+ projects using modern concurrency patterns.

### Key Features

- **Actor Isolation**: Natural thread safety without locks
- **AsyncStream APIs**: Consume state updates with `for await` loops
- **Swift 6.1 Strict Concurrency**: Zero `@unchecked Sendable` conformances
- **Composable**: Works with SundialKitNetwork and SundialKitConnectivity

### Requirements

- Swift 6.1+
- iOS 16+ / watchOS 9+ / tvOS 16+ / macOS 13+

### Network Monitoring

Monitor network connectivity with ``NetworkObserver``:

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

### WatchConnectivity Communication

Communicate between iPhone and Apple Watch with ``ConnectivityObserver``:

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

### Activation State Monitoring

Track WatchConnectivity activation states:

```swift
Task {
  for await state in observer.activationStates() {
    print("Activation state: \(state)")
  }
}
```

### Reachability Monitoring

Monitor device reachability:

```swift
Task {
  for await isReachable in observer.reachabilityStream() {
    print("Is reachable: \(isReachable)")
  }
}
```

### SwiftUI Integration

Use with `@Observable` and SwiftUI:

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
