# ``SundialKitStream``

Modern async/await observation plugin for SundialKit with actor-based concurrency safety.

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
  .package(url: "https://github.com/brightdigit/SundialKit.git", from: "2.0.0"),
  .package(url: "https://github.com/brightdigit/SundialKitStream.git", from: "1.0.0")
],
targets: [
  .target(
    name: "YourTarget",
    dependencies: [
      .product(name: "SundialKitStream", package: "SundialKitStream"),
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

### SwiftUI Integration with AsyncStreams

Here's a complete example showing how to use custom message types with SwiftUI and async/await:

```swift
import SwiftUI
import SundialKitStream
import SundialKitConnectivity

@MainActor
@Observable
class WatchMessenger {
  let observer: ConnectivityObserver

  var receivedColor: Color?
  var isReachable: Bool = false
  var activationState: ActivationState = .notActivated

  init() {
    // Create actor-based observer with message decoder
    observer = ConnectivityObserver(
      messageDecoder: MessageDecoder(messagableTypes: [
        ColorMessage.self,
        TemperatureReading.self
      ])
    )
  }

  func start() {
    // Listen for typed messages using AsyncStream
    Task {
      for await message in await observer.typedMessageStream() {
        if let colorMessage = message as? ColorMessage {
          receivedColor = Color(
            red: colorMessage.red,
            green: colorMessage.green,
            blue: colorMessage.blue
          )
        } else if let temp = message as? TemperatureReading {
          print("Temperature: \(temp.celsius)°C at \(temp.timestamp)")
        }
      }
    }

    // Monitor reachability
    Task {
      for await reachable in await observer.reachabilityStream() {
        isReachable = reachable
      }
    }

    // Monitor activation state
    Task {
      for await state in await observer.activationStates() {
        activationState = state
      }
    }
  }

  func activate() async throws {
    try await observer.activate()
  }

  func sendColor(red: Double, green: Double, blue: Double) async throws {
    let message = ColorMessage(red: red, green: green, blue: blue)
    let result = try await observer.send(message)
    print("Sent via: \(result.context)")
  }
}

struct WatchColorView: View {
  @State private var messenger = WatchMessenger()

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
    .task {
      try? await messenger.activate()
      messenger.start()
    }
  }
}
```

This example demonstrates:
- Creating a `MessageDecoder` with multiple custom message types
- Using AsyncStreams to consume typed messages, reachability, and activation state
- Converting received messages to SwiftUI views with the `@Observable` macro
- Sending type-safe messages from button actions
- Automatic UI updates when messages arrive or session state changes
- Structured concurrency with the `.task` modifier for lifecycle management

> Important: Dictionary-based messages have a size limit of approximately 65KB. For larger data, use ``BinaryMessagable`` for efficient serialization or consider file transfer methods.

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
