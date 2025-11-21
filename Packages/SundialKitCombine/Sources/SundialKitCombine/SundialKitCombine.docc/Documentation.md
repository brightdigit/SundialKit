# ``SundialKitCombine``

Combine-based observation plugin for SundialKit with @Published properties.

## Overview

![SundialKit Logo](logo.png)

SundialKitCombine provides observers that deliver state updates via @Published properties and Combine publishers. This plugin is designed for SwiftUI projects and apps requiring backward compatibility with iOS 13+, offering seamless integration with the Combine framework and SwiftUI's reactive data flow.

### Why Choose SundialKitCombine

If you're building a SwiftUI application or need to support iOS 13+, SundialKitCombine is the perfect choice. It leverages Combine's publisher infrastructure to provide reactive state updates that bind naturally to SwiftUI views. The @Published properties work seamlessly with SwiftUI's observation system, automatically triggering view updates when network or connectivity state changes.

**Choose SundialKitCombine when you:**
- Building SwiftUI applications with reactive data binding
- Need to support iOS 13+ / watchOS 6+ / tvOS 13+ / macOS 10.15+
- Prefer Combine publishers and the `.sink` pattern for reactive updates
- Want @Published properties that bind directly to SwiftUI views
- Already have Combine-based infrastructure in your app
- Need `ObservableObject` conformance for SwiftUI `@StateObject` and `@ObservedObject`

### Key Features

- **@Published Properties**: Direct binding to SwiftUI views with automatic updates
- **Combine Publishers**: Full reactive programming support with operators like `map`, `filter`, `debounce`
- **Swift 6.1 Strict Concurrency**: Zero `@unchecked Sendable` conformances - everything uses @MainActor isolation
- **SwiftUI Integration**: Native `ObservableObject` conformance for seamless view updates
- **Backward Compatible**: Supports iOS 13+ for maximum deployment flexibility

### Requirements

- Swift 6.1+
- iOS 13+ / watchOS 6+ / tvOS 13+ / macOS 10.15+
- Combine framework

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
      .product(name: "SundialKitCombine", package: "SundialKit"),
      .product(name: "SundialKitNetwork", package: "SundialKit"),  // For network monitoring
      .product(name: "SundialKitConnectivity", package: "SundialKit")  // For WatchConnectivity
    ]
  )
]
```

## Network Monitoring

Monitor network connectivity changes using the @MainActor-based ``NetworkObserver``. The observer provides @Published properties for network state that automatically update your SwiftUI views, plus Combine publishers for advanced reactive patterns.

### Basic Network Monitoring

Create a NetworkObserver and bind its @Published properties to your SwiftUI view model:

```swift
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
    observer.start()
  }
}
```

The `NWPathMonitorAdapter` wraps Apple's `NWPathMonitor` from the Network framework. When the network path changes (WiFi connects, cellular becomes available, etc.), the observer's @Published properties automatically update, triggering updates in any bound properties.

### SwiftUI Integration

Use the network observer with SwiftUI views through `@StateObject` or `@ObservedObject`:

```swift
import SwiftUI
import SundialKitCombine

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

Because both `NetworkConnectivityObject` and the observer use @MainActor isolation, all updates happen on the main thread automatically - no manual dispatch needed.

### Understanding PathStatus

The ``PathStatus`` enum represents the current state of the network path:

- **`.satisfied`** - Network is available and ready to use
- **`.unsatisfied`** - No network connectivity
- **`.requiresConnection`** - Network may be available but requires user action (e.g., connecting to WiFi)
- **`.unknown`** - Initial state before first update

### Advanced Combine Patterns

Because the observer provides Combine publishers, you can use the full power of Combine operators:

```swift
// Debounce rapid network changes
observer.$pathStatus
  .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
  .sink { status in
    print("Stable network status: \(status)")
  }
  .store(in: &cancellables)

// Combine multiple signals
Publishers.CombineLatest(observer.$isExpensive, observer.$isConstrained)
  .sink { isExpensive, isConstrained in
    if isExpensive || isConstrained {
      print("Network conditions suggest reducing data usage")
    }
  }
  .store(in: &cancellables)

// React to specific transitions
observer.$pathStatus
  .removeDuplicates()
  .sink { status in
    if status == .satisfied {
      print("Network became available - sync data")
    }
  }
  .store(in: &cancellables)
```

This reactive approach makes it easy to build sophisticated network-aware behaviors.

## WatchConnectivity Communication

Communicate between iPhone and Apple Watch using the @MainActor-based ``ConnectivityObserver``. The observer provides @Published properties for session state and Combine publishers for incoming messages, making WatchConnectivity straightforward in SwiftUI apps.

### Session Activation and State

Before sending or receiving messages, activate the WatchConnectivity session and monitor its state:

```swift
import SundialKitCombine
import SundialKitConnectivity
import Combine

@MainActor
class WatchConnectivityObject: ObservableObject {
  let observer = ConnectivityObserver()

  @Published var isReachable: Bool = false
  @Published var activationState: ActivationState = .notActivated

  private var cancellables = Set<AnyCancellable>()

  init() {
    observer.$isReachable
      .assign(to: &$isReachable)

    observer.$activationState
      .assign(to: &$activationState)

    // Listen for received messages
    observer.messageReceived
      .sink { result in
        switch result.context {
        case .replyWith(let handler):
          print("Received: \(result.message)")
          handler(["response": "acknowledged"])
        case .applicationContext:
          print("Context update: \(result.message)")
        }
      }
      .store(in: &cancellables)
  }

  func activate() throws {
    try observer.activate()
  }

  func sendMessage(_ message: ConnectivityMessage) async throws {
    let result = try await observer.sendMessage(message)
    print("Sent via: \(result.context)")
  }
}
```

The activation state tells you when the session is ready for communication, while reachability indicates whether the counterpart device is currently available for immediate messaging.

### Message Contexts

Messages arrive with different contexts that indicate how they should be handled:

- **`.replyWith(handler)`** - Interactive message expecting an immediate reply. Use the handler to send a response.
- **`.applicationContext`** - Background state update delivered when devices can communicate. No reply expected.

This distinction helps you build responsive communication patterns - interactive messages for user-initiated actions, context updates for background state synchronization.

### SwiftUI Integration with WatchConnectivity

Use the connectivity observer in SwiftUI views to display session status and send messages:

```swift
struct WatchMessageView: View {
  @StateObject var watch = WatchConnectivityObject()

  var body: some View {
    VStack {
      Text("Session: \(watch.activationState.description)")
      Text("Reachable: \(watch.isReachable ? "Yes" : "No")")

      Button("Send Message") {
        Task {
          try? await watch.sendMessage(["greeting": "Hello from iPhone!"])
        }
      }
      .disabled(!watch.isReachable)
    }
    .onAppear {
      try? watch.activate()
    }
  }
}
```

The @Published properties automatically update the UI when session state changes, and the button is enabled/disabled based on reachability.

### Reactive Message Handling

Use Combine operators to process incoming messages reactively:

```swift
// Filter for specific message types
observer.messageReceived
  .filter { $0.message["type"] as? String == "notification" }
  .sink { result in
    print("Received notification: \(result.message)")
  }
  .store(in: &cancellables)

// Map messages to typed models
observer.messageReceived
  .compactMap { result -> UserAction? in
    guard let action = result.message["action"] as? String else { return nil }
    return UserAction(action: action)
  }
  .sink { userAction in
    print("User action: \(userAction)")
  }
  .store(in: &cancellables)

// Throttle high-frequency updates
observer.messageReceived
  .filter { $0.context == .applicationContext }
  .throttle(for: .seconds(5), scheduler: DispatchQueue.main, latest: true)
  .sink { result in
    print("Context update (throttled): \(result.message)")
  }
  .store(in: &cancellables)
```

Combine's operators give you fine-grained control over how messages are processed and delivered to your app.

## Ping Integration

Monitor network connectivity with periodic pings to verify actual internet access beyond path availability:

```swift
import SundialKitCombine
import SundialKitNetwork

struct IpifyPing: NetworkPing, Sendable {
  typealias StatusType = String?

  let session: URLSession
  let timeInterval: TimeInterval

  func shouldPing(onStatus status: PathStatus) -> Bool {
    switch status {
    case .unknown, .unsatisfied:
      return false
    case .requiresConnection, .satisfied:
      return true
    }
  }

  func onPing(_ closure: @escaping (String?) -> Void) {
    let url = URL(string: "https://api.ipify.org")!
    session.dataTask(with: url) { data, _, _ in
      closure(data.flatMap { String(data: $0, encoding: .utf8) })
    }.resume()
  }
}

@MainActor
class PingNetworkObject: ObservableObject {
  let observer: NetworkObserver<NWPathMonitorAdapter, IpifyPing>

  @Published var ipAddress: String?

  init() {
    observer = NetworkObserver(
      monitor: NWPathMonitorAdapter(),
      ping: IpifyPing(session: .shared, timeInterval: 10.0)
    )

    observer.$pingStatus
      .assign(to: &$ipAddress)
  }

  func start() {
    observer.start()
  }
}
```

The ping verifies actual internet connectivity by making a real network request. This catches cases where the network path is technically satisfied but internet access is blocked (captive portals, DNS issues, etc.).

### @MainActor and Thread Safety

All SundialKitCombine observers use @MainActor isolation, ensuring:

- **Main Thread Updates**: All @Published property changes happen on the main thread automatically
- **SwiftUI Safety**: No need to manually dispatch to main queue before updating UI
- **Compile-Time Guarantees**: Swift 6.1 strict concurrency prevents threading issues at compile time
- **Zero @unchecked Sendable**: Everything is properly isolated without workarounds

This makes it safe to bind observer properties directly to SwiftUI views without additional synchronization code.

## Topics

### Network Monitoring

- ``NetworkObserver``

### WatchConnectivity

- ``ConnectivityObserver``
