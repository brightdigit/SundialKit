# ``SundialKit``

Swift 6.1+ reactive communications library with modern concurrency support for Apple platforms.

## Overview

![SundialKit Logo](logo.jpg)

SundialKit v2.0.0 provides reactive interfaces for network connectivity monitoring and WatchConnectivity communication. The library uses a **three-layer architecture** that separates protocols, implementations, and observation patterns:

**Layer 1: Core Protocols & Types** (SundialKitCore)
- Protocol definitions for network and connectivity abstractions
- Sendable-safe value types and error enums
- No concrete implementations or observers

**Layer 1: Implementations** (SundialKitNetwork, SundialKitConnectivity)
- Concrete wrappers over Apple's Network and WatchConnectivity frameworks
- Message encoding/decoding with ``Messagable`` and ``BinaryMessagable``
- Platform-specific delegate handling

**Layer 2: Observation Plugins** (Choose your concurrency model)
- **SundialKitStream**: Actor-based observers with AsyncStream APIs
- **SundialKitCombine**: @MainActor observers with Combine publishers

### Features

* Monitor network connectivity and quality using Apple's Network framework
* Communicate between iPhone and Apple Watch via WatchConnectivity
* Type-safe message encoding with ``Messagable`` protocol
* Efficient binary serialization with ``BinaryMessagable`` protocol
* Swift 6.1 strict concurrency compliance
* Zero @unchecked Sendable in plugin packages

### Requirements

**v2.0.0+ (Current)**

- Xcode 16.0 or later
- Swift 6.1 or later (strict concurrency)
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

### Choosing a Concurrency Model

**SundialKitStream** (Modern Async/Await):
- Actor-based observers with natural thread safety
- AsyncStream APIs for reactive patterns
- Ideal for Swift 6.1+ projects using async/await

**SundialKitCombine** (@MainActor + Combine):
- @MainActor isolation for UI safety
- @Published properties and Combine publishers
- Compatible with iOS 13+ and SwiftUI

See the respective plugin documentation for detailed usage examples.

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
