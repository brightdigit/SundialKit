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

Monitor network connectivity using ``NetworkObserver`` from observation plugins.

> Warning: **TODO** Add more text before code samples explaining what these samples do

> Warning: **TODO** Add a default initializer for the NetworkObserver(s) which use the default NWPathMonitor and a nil Ping monitor

**Using SundialKitCombine:**

```swift
import SundialKitCombine
import SundialKitNetwork
import Combine

// Create observer with @MainActor isolation
let observer = NetworkObserver(
  monitor: NWPathMonitor(),
  ping: nil
)

// Start monitoring
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
import SundialKitNetwork

// Create actor-based observer
let observer = NetworkObserver(
  monitor: NWPathMonitor(),
  ping: nil
)

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

Create type-safe messages using ``Messagable``:

> Warning: **TODO** Add more text before code samples explaining what these samples do

> Warning: **TODO** Explain that key uses the type but is overridable

```swift
struct ColorMessage: Messagable {
  static let key = "color"
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

// Decode received messages
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

For efficient binary serialization (Protobuf, MessagePack, etc.), use ``BinaryMessagable``:

> Warning: **TODO** Add more text before code samples explaining what these samples do

> Warning: **TODO** Make the Message and BinaryMessagable different data to remove confusion

> Warning: **TODO** In the intro for BinaryMessagable explain that the example uses swift-protobuf with a link to the package documentation

> Warning: **TODO** The BinaryMessagable example uses an in-between type rather than just adding an extension on a protobuf type

```swift
struct ImageMessage: BinaryMessagable {
  static let key = "image"
  let imageData: Data

  // BinaryMessagable requirement: decode from binary data
  init(from data: Data) throws {
    // Data is already in the format you need (JPEG, PNG, Protobuf, etc.)
    self.imageData = data
  }

  // BinaryMessagable requirement: encode to binary data
  func encode() throws -> Data {
    // Return the binary representation
    imageData
  }
}

// BinaryMessagable provides automatic Messagable conformance
// No need to implement init(from parameters:) or parameters()
let decoder = MessageDecoder(messagableTypes: [ImageMessage.self])
```

### WatchConnectivity Communication

Communicate between iPhone and Apple Watch using ``ConnectivityObserver`` from observation plugins.

> Warning: **TODO** Add more text before code samples explaining what these samples do

> Warning: **TODO** In the WatchConnectivity example, have both the Message and BinaryMessagable types in the decoder

**Using SundialKitCombine:**

```swift
import SundialKitCombine
import SundialKitConnectivity
import Combine

// Create observer with message decoder
let observer = ConnectivityObserver(
  messageDecoder: MessageDecoder(messagableTypes: [ColorMessage.self])
)

// Activate session
try observer.activate()

// Listen for typed messages
var cancellables = Set<AnyCancellable>()

observer.typedMessageReceived
  .sink { message in
    if let colorMessage = message as? ColorMessage {
      print("Received color: \(colorMessage)")
    }
  }
  .store(in: &cancellables)

// Send messages
Task {
  let message = ColorMessage(/* ... */)
  let result = try await observer.send(message)
  print("Sent via: \(result.context)")
}
```

**Using SundialKitStream:**

```swift
import SundialKitStream
import SundialKitConnectivity

// Create actor-based observer
let observer = ConnectivityObserver(
  messageDecoder: MessageDecoder(messagableTypes: [ColorMessage.self])
)

// Activate session
try await observer.activate()

// Listen for typed messages using AsyncStream
Task {
  for await message in await observer.typedMessageStream() {
    if let colorMessage = message as? ColorMessage {
      print("Received color: \(colorMessage)")
    }
  }
}

// Send messages
let message = ColorMessage(/* ... */)
let result = try await observer.send(message)
print("Sent via: \(result.context)")
```

### Choosing Your Observation Plugin

**<doc:SundialKitStream>** (Modern Async/Await):
- AsyncStream-based APIs for reactive patterns
- Actor-based observers with natural thread safety
- Ideal for new projects using async/await

**<doc:SundialKitCombine>** (@MainActor + Combine):
- @Published properties and Combine publishers
- @MainActor isolation for UI safety
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
