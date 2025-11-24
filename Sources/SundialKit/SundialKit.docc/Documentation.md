# ``SundialKit``

Build network-aware apps and seamless iPhone-Apple Watch experiences.

## Overview

![SundialKit Logo](logo.jpg)

SundialKit is a modern Swift library that helps you build apps that respond intelligently to network changes and communicate effortlessly between iPhone and Apple Watch. It simplifies two of Apple's most powerful but complex frameworks: [**Network**](https://developer.apple.com/documentation/network) and [**WatchConnectivity**](https://developer.apple.com/documentation/watchconnectivity).

### Key Capabilities

* **Monitor network connectivity** - Know when WiFi/cellular changes, connection quality, and data costs
* **Communicate across devices** - Send messages between iPhone and Apple Watch seamlessly
* **Type-safe messaging** - Encode/decode messages with ``Messagable`` and ``BinaryMessagable`` protocols
* **Backwards compatible** - Supports both modern AsyncStream APIs and Combine publishers

### Available Packages

SundialKit is organized into focused packages - choose the ones you need:

**Core Packages**
- **<doc:SundialKitNetwork>** - Network connectivity monitoring using Apple's [Network framework](https://developer.apple.com/documentation/network)
- **<doc:SundialKitConnectivity>** - [WatchConnectivity](https://developer.apple.com/documentation/watchconnectivity) wrapper for iPhone-Apple Watch communication

**Observation Plugins** (choose based on your concurrency preference)
- **<doc:SundialKitStream>** - Modern AsyncStream-based observers for async/await projects
- **<doc:SundialKitCombine>** - Combine-based observers with @Published properties for SwiftUI

### Requirements

**v2.0.0+ (Current)**

- Xcode 16.0 or later
- Swift 6.1 or later
- **Core modules**: iOS 13+ / watchOS 6+ / tvOS 13+ / macOS 10.13+
- **SundialKitStream plugin**: iOS 16+ / watchOS 9+ / tvOS 16+ / macOS 13+
- **SundialKitCombine plugin**: iOS 13+ / watchOS 6+ / tvOS 13+ / macOS 10.15+

### Installation

Add SundialKit to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/brightdigit/SundialKit.git", from: "2.0.0")
]
```

### Network Monitoring

Monitor network connectivity using ``NetworkObserver`` from observation plugins. The observer tracks network status changes (WiFi, cellular, wired), connection quality (expensive, constrained), and interface availability using Apple's Network framework.

#### Quick Start

For most use cases, use the default initializer which automatically configures network monitoring:

**Using SundialKitCombine:**

```swift
import SundialKitCombine
import Combine

// Create observer with default configuration
let observer = NetworkObserver()

// Start monitoring on main queue
observer.start()

// Use @Published properties
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

**Using SundialKitStream:**

```swift
import SundialKitStream

// Create observer with default configuration
let observer = NetworkObserver()

// Start monitoring
await observer.start()

// Consume path status updates
Task {
  for await status in await observer.pathStatusStream {
    print("Network status: \(status)")
  }
}

// Check expensive status
Task {
  for await isExpensive in await observer.isExpensiveStream {
    print("Is expensive: \(isExpensive)")
  }
}
```

### Type-Safe Messaging with Messagable

The ``Messagable`` protocol enables type-safe message encoding and decoding for WatchConnectivity communication. Instead of working with raw dictionaries, you define custom message types that are automatically serialized and deserialized. This provides compile-time type safety and eliminates common runtime errors from manual dictionary handling.

> Note: Each `Messagable` type has a `key` property that identifies the message type. By default, the key uses the type's name (e.g., `"ColorMessage"`), but you can override it with a custom identifier.

```swift
struct ColorMessage: Messagable {
  static let key = "color"  // Optional: defaults to "ColorMessage"

  let red: Double
  let green: Double
  let blue: Double

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

// Use MessageDecoder to route messages to the correct type
let decoder = MessageDecoder(messagableTypes: [ColorMessage.self])

do {
  let message = try decoder.decode(receivedDictionary)
  if let colorMessage = message as? ColorMessage {
    print("Received color: RGB(\(colorMessage.red), \(colorMessage.green), \(colorMessage.blue))")
  }
} catch {
  print("Failed to decode: \(error)")
}
```

### Binary Messaging with BinaryMessagable

For efficient binary serialization of complex data structures or large payloads, use ``BinaryMessagable``. This protocol is ideal for Protobuf, MessagePack, or other binary formats, providing better performance and smaller message sizes than dictionary-based `Messagable`.

The key advantage: `BinaryMessagable` automatically implements the `Messagable` protocol, so you only need to define binary encoding/decoding methods. The framework handles dictionary conversion internally.

**Example using [swift-protobuf](https://github.com/apple/swift-protobuf):**

```swift
import SwiftProtobuf

// Define your message in a .proto file, then extend the generated type
extension UserProfile: BinaryMessagable {
  // key defaults to "UserProfile" (type name)

  // Only implement these two binary methods
  public init(from data: Data) throws {
    try self.init(serializedData: data)  // SwiftProtobuf decoder
  }

  public func encode() throws -> Data {
    try serializedData()  // SwiftProtobuf encoder
  }

  // init(from parameters:) and parameters() are auto-implemented!
}

// Use with MessageDecoder just like Messagable types
let decoder = MessageDecoder(messagableTypes: [
  UserProfile.self  // BinaryMessagable works seamlessly
])
```

**Simple binary example (custom format):**

```swift
struct TemperatureReading: BinaryMessagable {
  let celsius: Float
  let timestamp: UInt64

  init(celsius: Float, timestamp: UInt64) {
    self.celsius = celsius
    self.timestamp = timestamp
  }

  // Decode from raw binary data
  public init(from data: Data) throws {
    guard data.count == 12 else {  // 4 bytes + 8 bytes
      throw SerializationError.invalidDataSize
    }
    celsius = data.withUnsafeBytes { $0.load(as: Float.self) }
    timestamp = data.dropFirst(4).withUnsafeBytes { $0.load(as: UInt64.self) }
  }

  // Encode to raw binary data
  public func encode() throws -> Data {
    var data = Data()
    withUnsafeBytes(of: celsius) { data.append(contentsOf: $0) }
    withUnsafeBytes(of: timestamp) { data.append(contentsOf: $0) }
    return data
  }
}
```

### WatchConnectivity Communication

Communicate between iPhone and Apple Watch using ``ConnectivityObserver`` from observation plugins. The observer handles WatchConnectivity session management, message routing, and automatic transport selection based on device reachability.

> Important: Dictionary-based messages have a size limit of approximately 65KB when using `sendMessage`. See [Apple's WatchConnectivity documentation](https://developer.apple.com/documentation/watchconnectivity/wcsession) for details on message size limits.

**Using SundialKitCombine:**

```swift
import SundialKitCombine
import SundialKitConnectivity
import Combine

// Create observer with message decoder supporting multiple types
let observer = ConnectivityObserver(
  messageDecoder: MessageDecoder(messagableTypes: [
    ColorMessage.self,      // Dictionary-based message
    UserProfile.self        // Binary protobuf message
  ])
)

// Activate session
try observer.activate()

// Listen for typed messages
var cancellables = Set<AnyCancellable>()

observer.typedMessageReceived
  .sink { message in
    // Handle different message types
    if let colorMessage = message as? ColorMessage {
      print("Received color: \(colorMessage)")
    } else if let profile = message as? UserProfile {
      print("Received profile: \(profile.name)")
    }
  }
  .store(in: &cancellables)

// Send messages
Task {
  let message = ColorMessage(red: 1.0, green: 0.5, blue: 0.0)
  let result = try await observer.send(message)
  print("Sent via: \(result.context)")
}
```

**Using SundialKitStream:**

```swift
import SundialKitStream
import SundialKitConnectivity

// Create actor-based observer supporting multiple message types
let observer = ConnectivityObserver(
  messageDecoder: MessageDecoder(messagableTypes: [
    ColorMessage.self,      // Dictionary-based message
    UserProfile.self        // Binary protobuf message
  ])
)

// Activate session
try await observer.activate()

// Listen for typed messages using AsyncStream
Task {
  for await message in await observer.typedMessageStream() {
    // Handle different message types
    if let colorMessage = message as? ColorMessage {
      print("Received color: \(colorMessage)")
    } else if let profile = message as? UserProfile {
      print("Received profile: \(profile.name)")
    }
  }
}

// Send messages
let message = ColorMessage(red: 1.0, green: 0.5, blue: 0.0)
let result = try await observer.send(message)
print("Sent via: \(result.context)")
```

### Choosing Your Observation Plugin

**<doc:SundialKitStream>** (Modern Async/Await):
- AsyncStream-based APIs for reactive patterns
- Actor-based observers with natural thread safety
- Ideal for new projects using async/await

**<doc:SundialKitCombine>** (Combine Publishers):
- @Published properties and Combine publishers
- Compatible with iOS 13+ and SwiftUI projects

Both plugins work with the same core <doc:SundialKitNetwork> and <doc:SundialKitConnectivity> packages - just choose the observation style that fits your project.

## Topics

### Core Types

- ``PathStatus``
- ``ActivationState``
- ``ConnectivityMessage``

### Core Protocols

- ``NetworkMonitoring``
- ``ConnectivityManagement``
- ``PathMonitor``
- ``NetworkPath``
- ``NetworkPing``
- ``Interfaceable``

### Network Monitoring

- ``NetworkMonitor``
- ``NetworkStateObserver``
- ``NeverPing``

### WatchConnectivity

- ``ConnectivitySession``
- ``ConnectivitySessionDelegate``
- ``ConnectivityStateObserver``
- ``NeverConnectivitySession``

### Message Sending and Receiving

- ``ConnectivityReceiveResult``
- ``ConnectivityReceiveContext``
- ``ConnectivitySendResult``
- ``ConnectivitySendContext``
- ``MessageTransport``
- ``SendOptions``
- ``ConnectivityHandler``

### Type-Safe Messaging

- ``Messagable``
- ``MessageDecoder``
- ``BinaryMessagable``
- ``BinaryMessageEncoder``

### Error Handling

- ``NetworkError``
- ``ConnectivityError``
- ``SerializationError``
- ``SundialError``

### Utilities

- ``ObserverRegistry``
