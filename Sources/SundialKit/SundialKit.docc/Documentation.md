# ``SundialKit``

Build network-aware apps and seamless iPhone-Apple Watch experiences.

## Overview

![SundialKit Logo](logo.jpg)

SundialKit is a modern Swift library that helps you build apps that respond intelligently to network changes and communicate effortlessly between iPhone and Apple Watch. It simplifies two of Apple's most powerful but complex frameworks: **Network** and **WatchConnectivity**.

### What Can You Build?

**Cross-Device Communication Apps**
- Send commands between iPhone and Apple Watch (play/pause, start workout, update settings)
- Build companion Watch apps with bidirectional messaging
- Automatically queue messages when devices aren't reachable
- Monitor connectivity status to enable/disable remote features in your UI
- Handle device pairing and installation status gracefully

**Network-Aware Applications**
- Detect when users switch from WiFi to cellular and adjust media quality
- Show offline indicators and cache content when network is unavailable
- Warn users about expensive connections before large downloads

**Adaptive User Experiences**
- Reduce animation quality on constrained networks
- Prefetch content only on WiFi connections
- Provide offline-first experiences that sync when connected

### Key Capabilities

* **Monitor network connectivity** - Know when WiFi/cellular changes, connection quality, and data costs
* **Communicate across devices** - Send messages between iPhone and Apple Watch seamlessly
* **Type-safe messaging** - Encode/decode messages with ``Messagable`` and ``BinaryMessagable`` protocols
* **Backwards compatible** - Supports both modern AsyncStream APIs and Combine publishers

### Available Packages

SundialKit is organized into focused packages - choose the ones you need:

**Core Packages**
- **<doc:SundialKitNetwork>** - Network connectivity monitoring using Apple's Network framework
- **<doc:SundialKitConnectivity>** - WatchConnectivity wrapper for iPhone-Apple Watch communication

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

Swift Package Manager is Apple's decentralized dependency manager. To integrate SundialKit, add it to your `Package.swift`:

#### Option A: Modern Async/Await (Recommended)

```swift
let package = Package(
  name: "YourPackage",
  platforms: [.iOS(.v16), .watchOS(.v9), .tvOS(.v16), .macOS(.v13)],
  dependencies: [
    .package(url: "https://github.com/brightdigit/SundialKit.git", from: "2.0.0")
  ],
  targets: [
    .target(
      name: "YourTarget",
      dependencies: [
        .product(name: "SundialKitStream", package: "SundialKit"),
        .product(name: "SundialKitNetwork", package: "SundialKit"),
        .product(name: "SundialKitConnectivity", package: "SundialKit")
      ]
    )
  ]
)
```

#### Option B: Combine + SwiftUI

```swift
let package = Package(
  name: "YourPackage",
  platforms: [.iOS(.v13), .watchOS(.v6), .tvOS(.v13), .macOS(.v10_15)],
  dependencies: [
    .package(url: "https://github.com/brightdigit/SundialKit.git", from: "2.0.0")
  ],
  targets: [
    .target(
      name: "YourTarget",
      dependencies: [
        .product(name: "SundialKitCombine", package: "SundialKit"),
        .product(name: "SundialKitNetwork", package: "SundialKit"),
        .product(name: "SundialKitConnectivity", package: "SundialKit")
      ]
    )
  ]
)
```

#### Option C: Umbrella Import (All Core Modules)

For accessing all core types without observation plugins:

```swift
.product(name: "SundialKit", package: "SundialKit")
```

This re-exports SundialKitCore, SundialKitNetwork, and SundialKitConnectivity.

### Network Monitoring

Monitor network connectivity using ``NetworkMonitor``, which wraps Apple's `NWPathMonitor`:

```swift
import SundialKitNetwork

// Create a monitor with optional ping support
let monitor = NetworkMonitor(
  monitor: NWPathMonitorAdapter(),
  ping: nil
)

// Add an observer for state changes
let observerId = monitor.addObserver { state in
  print("Network status: \(state.pathStatus)")
  print("Is expensive: \(state.isExpensive)")
}

// Start monitoring
monitor.start(queue: .global())

// Later, remove the observer
monitor.removeObserver(id: observerId)
```

### WatchConnectivity Communication

Use ``ConnectivitySession`` and related types for iPhone/Apple Watch communication:

```swift
import SundialKitConnectivity

// Create a session wrapper
let session = WatchConnectivitySession()

// Activate the session
try session.activate()

// Send a message
let result = try await session.sendMessage(["key": "value"])
```

### Type-Safe Messaging with Messagable

Create type-safe messages using ``Messagable``:

```swift
struct ColorMessage: Messagable {
  static let key = "color"
  let red: Double
  let green: Double
  let blue: Double

  init?(from parameters: [String: Any]?) {
    guard let params = parameters,
          let red = params["red"] as? Double,
          let green = params["green"] as? Double,
          let blue = params["blue"] as? Double else {
      return nil
    }
    self.red = red
    self.green = green
    self.blue = blue
  }

  func parameters() -> [String: Any] {
    ["red": red, "green": green, "blue": blue]
  }
}

// Decode received messages
let decoder = MessageDecoder(messagableTypes: [ColorMessage.self])
if let message = decoder.decode(receivedDictionary) as? ColorMessage {
  print("Received color: RGB(\(message.red), \(message.green), \(message.blue))")
}
```

### Binary Messaging with BinaryMessagable

For efficient binary serialization, use ``BinaryMessagable``:

```swift
struct BinaryColorMessage: BinaryMessagable {
  static let key = "binaryColor"
  let data: Data

  init(data: Data) {
    self.data = data
  }

  init?(from parameters: [String: Any]?) {
    guard let params = parameters,
          let data = params["data"] as? Data else {
      return nil
    }
    self.data = data
  }

  func parameters() -> [String: Any] {
    ["data": data]
  }

  func binaryData() throws -> Data {
    data
  }

  static func from(binaryData: Data) throws -> Self {
    Self(data: binaryData)
  }
}
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
