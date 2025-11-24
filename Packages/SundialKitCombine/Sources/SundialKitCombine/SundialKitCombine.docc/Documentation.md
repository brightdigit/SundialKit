# ``SundialKitCombine``

Combine-based observation plugin for SundialKit with @Published properties.

## Overview

![SundialKit Logo](logo.png)

SundialKitCombine provides observers that deliver state updates via @Published properties and Combine publishers. This plugin is designed for SwiftUI projects and apps requiring backward compatibility with iOS 13+, offering seamless integration with the Combine framework and SwiftUI's reactive data flow.

### Why Choose SundialKitCombine

If you're building a SwiftUI application and need to support iOS 13+, SundialKitCombine is the perfect choice. It leverages Combine's publisher infrastructure to provide reactive state updates that bind naturally to SwiftUI views. The @Published properties work seamlessly with SwiftUI's observation system, automatically triggering view updates when network or connectivity state changes.

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
  .package(url: "https://github.com/brightdigit/SundialKit.git", from: "2.0.0"),
  .package(url: "https://github.com/brightdigit/SundialKitCombine.git", from: "1.0.0")
],
targets: [
  .target(
    name: "YourTarget",
    dependencies: [
      .product(name: "SundialKitCombine", package: "SundialKitCombine"),
      .product(name: "SundialKitNetwork", package: "SundialKit"),  // For network monitoring
      .product(name: "SundialKitConnectivity", package: "SundialKit")  // For WatchConnectivity
    ]
  )
]
```

## Network Monitoring

Monitor network connectivity changes using ``NetworkObserver``. The observer provides @Published properties for network state that automatically update your SwiftUI views, plus Combine publishers for advanced reactive patterns.

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

### Understanding PathStatus

The ``PathStatus`` enum represents the current state of the network path:

- **`.satisfied`** - Network is available and ready to use
- **`.unsatisfied`** - No network connectivity
- **`.requiresConnection`** - Network may be available but requires user action (e.g., connecting to WiFi)
- **`.unknown`** - Initial state before first update

### Ping Integration

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

## WatchConnectivity Communication

Communicate between iPhone and Apple Watch using ``ConnectivityObserver``. The observer provides @Published properties for session state and Combine publishers for incoming messages, making WatchConnectivity straightforward in SwiftUI apps.

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

## Type-Safe Messaging

SundialKitConnectivity provides two protocols for defining custom message types: ``Messagable`` for dictionary-based messages and ``BinaryMessagable`` for efficient binary serialization. Both work seamlessly with ConnectivityObserver to provide compile-time type safety for your iPhone-Apple Watch communication.

### Dictionary-Based Messages with Messagable

The ``Messagable`` protocol enables type-safe message encoding and decoding. Instead of working with raw dictionaries, you define custom message types that are automatically serialized and deserialized:

```swift
import SundialKitConnectivity

struct ColorMessage: Messagable {
  static let key = "color"  // Identifier for this message type

  let red: Double
  let green: Double
  let blue: Double

  init(red: Double, green: Double, blue: Double) {
    self.red = red
    self.green = green
    self.blue = blue
  }

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
}
```

The `key` property identifies the message type, allowing the receiver to route it to the correct handler. The `parameters()` method converts your type to a dictionary, and the `init(from:)` initializer reconstructs it from received data.

### Binary Serialization with BinaryMessagable

For larger datasets or complex data structures, ``BinaryMessagable`` provides efficient binary serialization. This approach works seamlessly with Protocol Buffers, MessagePack, or any custom binary format:

```swift
import SundialKitConnectivity
import SwiftProtobuf

// Extend your Protobuf-generated type
extension UserProfile: BinaryMessagable {
  // key defaults to "UserProfile" (type name)

  public init(from data: Data) throws {
    try self.init(serializedData: data)  // SwiftProtobuf decoder
  }

  public func encode() throws -> Data {
    try serializedData()  // SwiftProtobuf encoder
  }

  // init(from parameters:) and parameters() auto-implemented!
}
```

**Custom binary format example:**

```swift
struct TemperatureReading: BinaryMessagable {
  let celsius: Float
  let timestamp: UInt64

  init(celsius: Float, timestamp: UInt64) {
    self.celsius = celsius
    self.timestamp = timestamp
  }

  public init(from data: Data) throws {
    guard data.count == 12 else {  // 4 + 8 bytes
      throw SerializationError.invalidDataSize
    }
    celsius = data.withUnsafeBytes { $0.load(as: Float.self) }
    timestamp = data.dropFirst(4).withUnsafeBytes { $0.load(as: UInt64.self) }
  }

  public func encode() throws -> Data {
    var data = Data()
    withUnsafeBytes(of: celsius) { data.append(contentsOf: $0) }
    withUnsafeBytes(of: timestamp) { data.append(contentsOf: $0) }
    return data
  }
}
```

### SwiftUI Integration with Type-Safe Messages

Here's a complete example showing how to use custom message types with SwiftUI and Combine:

```swift
import SwiftUI
import SundialKitCombine
import SundialKitConnectivity
import Combine

@MainActor
class WatchMessenger: ObservableObject {
  let observer: ConnectivityObserver

  @Published var receivedColor: Color?
  @Published var isReachable: Bool = false
  @Published var activationState: ActivationState = .notActivated

  private var cancellables = Set<AnyCancellable>()

  init() {
    // Create observer with message decoder supporting multiple types
    observer = ConnectivityObserver(
      messageDecoder: MessageDecoder(messagableTypes: [
        ColorMessage.self,
        TemperatureReading.self
      ])
    )

    // Bind session state
    observer.$isReachable
      .assign(to: &$isReachable)

    observer.$activationState
      .assign(to: &$activationState)

    // Listen for typed messages
    observer.typedMessageReceived
      .sink { [weak self] message in
        if let colorMessage = message as? ColorMessage {
          self?.receivedColor = Color(
            red: colorMessage.red,
            green: colorMessage.green,
            blue: colorMessage.blue
          )
        } else if let temp = message as? TemperatureReading {
          print("Temperature: \(temp.celsius)°C at \(temp.timestamp)")
        }
      }
      .store(in: &cancellables)
  }

  func activate() throws {
    try observer.activate()
  }

  func sendColor(red: Double, green: Double, blue: Double) async throws {
    let message = ColorMessage(red: red, green: green, blue: blue)
    let result = try await observer.send(message)
    print("Sent via: \(result.context)")
  }
}

struct WatchColorView: View {
  @StateObject var messenger = WatchMessenger()

  var body: some View {
    VStack(spacing: 20) {
      Text("WatchConnectivity")
        .font(.headline)

      Text("Session: \(messenger.activationState.description)")
      Text("Reachable: \(messenger.isReachable ? "Yes" : "No")")

      if let color = messenger.receivedColor {
        Rectangle()
          .fill(color)
          .frame(width: 100, height: 100)
          .cornerRadius(10)

        Text("Received Color")
          .font(.caption)
      }

      Button("Send Red") {
        Task {
          try? await messenger.sendColor(red: 1.0, green: 0.0, blue: 0.0)
        }
      }
      .disabled(!messenger.isReachable)

      Button("Send Blue") {
        Task {
          try? await messenger.sendColor(red: 0.0, green: 0.0, blue: 1.0)
        }
      }
      .disabled(!messenger.isReachable)
    }
    .padding()
    .onAppear {
      try? messenger.activate()
    }
  }
}
```

This example demonstrates:
- Creating a `MessageDecoder` with multiple custom message types
- Binding `@Published` properties from the observer to SwiftUI state
- Receiving typed messages and converting them to SwiftUI views
- Sending type-safe messages from button actions
- Automatic UI updates when messages arrive or session state changes

> Important: Dictionary-based messages have a size limit of approximately 65KB. For larger data, use ``BinaryMessagable`` for efficient serialization or consider file transfer methods.

## Topics

### Network Monitoring

- ``NetworkObserver``

### WatchConnectivity

- ``ConnectivityObserver``
