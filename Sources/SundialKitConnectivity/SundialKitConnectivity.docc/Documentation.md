# ``SundialKitConnectivity``

WatchConnectivity abstraction for seamless iPhone-Apple Watch communication.

## Overview

SundialKitConnectivity provides a modern, type-safe wrapper around Apple's [WatchConnectivity framework](https://developer.apple.com/documentation/watchconnectivity), making it simple to send messages between iPhone and Apple Watch. It handles session lifecycle, automatic transport selection, and provides type-safe messaging through the ``Messagable`` and ``BinaryMessagable`` protocols.

### Key Features

* **Type-safe messaging** - ``Messagable`` protocol for dictionary-based messages with compile-time safety
* **Binary serialization** - ``BinaryMessagable`` for efficient Protobuf, MessagePack, or custom binary formats
* **Automatic transport** - Intelligently chooses between `sendMessage` (reachable) and `updateApplicationContext` (background)
* **Session lifecycle** - Simplified activation and state management
* **Platform-safe fallbacks** - ``NeverConnectivitySession`` for platforms without WatchConnectivity
* **Message routing** - ``MessageDecoder`` automatically routes messages to correct types

### Requirements

- Swift 6.1 or later
- **iOS 9+ and watchOS 2+** (WatchConnectivity only available on iOS/watchOS)
- macOS and tvOS use ``NeverConnectivitySession`` fallback

### Getting Started

SundialKitConnectivity provides the foundational WatchConnectivity protocols and messaging types. To use these in your application, you'll need to choose an observation plugin that matches your preferred concurrency model:

- **SundialKitCombine** - For SwiftUI apps using Combine publishers
- **SundialKitStream** - For modern Swift apps using actors and AsyncStreams

Both plugins provide `ConnectivityObserver` classes that handle session management and message routing automatically. The examples below demonstrate how to define and send type-safe messages using each approach.

### Message-Based Communication

SundialKitConnectivity offers two ways to define messages for communication between iPhone and Apple Watch: dictionary-based messages for simple data, and binary serialization for efficient transfer of complex data structures.

#### Type-Safe Dictionary Messages

The ``Messagable`` protocol provides a simple way to define type-safe messages that are automatically converted to and from WatchConnectivity's dictionary format. This is ideal for straightforward data structures like settings, notifications, or simple state updates.

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

#### Binary Serialization with Protobuf

For larger datasets or complex data structures, ``BinaryMessagable`` provides efficient binary serialization. This approach works seamlessly with Protocol Buffers, MessagePack, or any custom binary format, significantly reducing message size compared to dictionaries.

```swift
import SundialKitConnectivity
import SwiftProtobuf

// Define your .proto file, then extend the generated type
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

**Custom binary format:**

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

With binary serialization, you can transfer complex data structures efficiently. The `BinaryMessagable` protocol automatically handles the conversion between your binary format and WatchConnectivity's dictionary format, so you get the best of both worlds: efficiency and compatibility.

### Session Management

Once you've defined your message types, you'll use a `ConnectivityObserver` to manage the WatchConnectivity session and send/receive messages. The observer handles session activation and monitors reachability.

#### Using with SundialKitCombine

The Combine-based observer is perfect for SwiftUI applications. It provides `@Published` properties for session state and Combine publishers for incoming messages, making it easy to update your UI reactively.

```swift
import SundialKitCombine
import SundialKitConnectivity
import Combine

// Create observer with message types
let observer = ConnectivityObserver(
  messageDecoder: MessageDecoder(messagableTypes: [
    ColorMessage.self,
    UserProfile.self  // Protobuf message
  ])
)

// Activate session
try observer.activate()

// Listen for typed messages
var cancellables = Set<AnyCancellable>()

observer.typedMessageReceived
  .sink { message in
    if let colorMessage = message as? ColorMessage {
      print("Color: RGB(\(colorMessage.red), \(colorMessage.green), \(colorMessage.blue))")
    } else if let profile = message as? UserProfile {
      print("User: \(profile.name)")
    }
  }
  .store(in: &cancellables)

// Monitor session state
observer.$activationState
  .sink { state in
    print("Session state: \(state)")
  }
  .store(in: &cancellables)

observer.$isReachable
  .sink { isReachable in
    print("Counterpart reachable: \(isReachable)")
  }
  .store(in: &cancellables)

// Send messages
Task {
  let message = ColorMessage(red: 1.0, green: 0.5, blue: 0.0)
  let result = try await observer.send(message)
  print("Sent via: \(result.context)")
}
```

In this example, the `MessageDecoder` routes incoming messages to the correct types based on their `key` property. You can then use type checking to handle each message type appropriately. The `@Published` properties let you bind session state directly to SwiftUI views.

#### Using with SundialKitStream

The actor-based observer is ideal for modern Swift concurrency applications. It provides `AsyncStream` APIs that you can consume with `for await` loops, giving you complete control over message handling in async contexts.

```swift
import SundialKitStream
import SundialKitConnectivity

// Create actor-based observer
let observer = ConnectivityObserver(
  messageDecoder: MessageDecoder(messagableTypes: [
    ColorMessage.self,
    UserProfile.self
  ])
)

// Activate session
try await observer.activate()

// Listen for typed messages using AsyncStream
Task {
  for await message in await observer.typedMessageStream() {
    if let colorMessage = message as? ColorMessage {
      print("Color: RGB(\(colorMessage.red), \(colorMessage.green), \(colorMessage.blue))")
    } else if let profile = message as? UserProfile {
      print("User: \(profile.name)")
    }
  }
}

// Monitor reachability
Task {
  for await isReachable in await observer.reachabilityStream() {
    print("Counterpart reachable: \(isReachable)")
  }
}

// Send messages
let message = ColorMessage(red: 1.0, green: 0.5, blue: 0.0)
let result = try await observer.send(message)
print("Sent via: \(result.context)")
```

Here, each `AsyncStream` provides a continuous flow of updates. You can create separate tasks to handle messages, monitor reachability, and track session state independently, giving you maximum flexibility in structuring your communication logic.

### Understanding Message Transport

``MessageTransport`` determines how messages are sent:

- **`.message`** - `WCSession.sendMessage(_:replyHandler:errorHandler:)` - Fast, requires reachability
- **`.data`** - `WCSession.sendMessageData(_:replyHandler:errorHandler:)` - Fast binary, requires reachability
- **`.userInfo`** - `WCSession.transferUserInfo(_:)` - Queued transfer, works when unreachable
- **`.currentUserInfo`** - `WCSession.transferCurrentComplicationUserInfo(_:)` - High priority for complications
- **`.applicationContext`** - `WCSession.updateApplicationContext(_:)` - Latest state, overwrites previous
- **`.file`** - `WCSession.transferFile(_:metadata:)` - For large files

The observation plugins automatically choose the best transport based on reachability:
- **Reachable**: Uses `.message` or `.data` (fast, synchronous with immediate reply)
- **Unreachable**: Uses `.applicationContext` (queued for delivery when devices can communicate)

This automatic selection ensures your messages are always delivered using the most appropriate method, whether the devices are currently connected or not.

### Message Size Limits

> Important: Dictionary-based messages (`sendMessage`) have a size limit of approximately **65KB**. For larger data:
> - Use ``BinaryMessagable`` for efficient serialization
> - Consider `.file` transport for files
> - Split large messages into chunks
> - Use `.userInfo` for background transfers

See [Apple's WCSession documentation](https://developer.apple.com/documentation/watchconnectivity/wcsession) for detailed size limits.

### Receiving Messages with Context

Messages can arrive with different contexts requiring different handling:

```swift
// Using SundialKitStream
Task {
  for await result in await observer.messageStream() {
    switch result.context {
    case .replyWith(let handler):
      // Interactive message expecting reply
      print("Message: \(result.message)")
      handler(["status": "received"])

    case .applicationContext:
      // Background state update
      print("Context update: \(result.message)")
    }
  }
}
```

``ConnectivityReceiveContext`` indicates how to handle the message:
- **`.replyWith(handler)`** - Interactive message expecting a reply, use the handler to respond
- **`.applicationContext`** - One-way state update delivered in the background, no reply expected

Understanding these contexts helps you build responsive communication patterns between your iPhone and Apple Watch apps.

### Platform Availability

WatchConnectivity is **only available on iOS and watchOS**:
- ✅ **iOS 9+** - Full WatchConnectivity support
- ✅ **watchOS 2+** - Full WatchConnectivity support
- ⚠️ **macOS / tvOS** - Uses ``NeverConnectivitySession`` (no-op implementation)

Check platform availability:

```swift
#if canImport(WatchConnectivity)
  let session = WatchConnectivitySession()
#else
  let session = NeverConnectivitySession()
#endif
```

Whether you choose SundialKitCombine for SwiftUI integration or SundialKitStream for modern async/await patterns, SundialKitConnectivity provides the type-safe messaging foundation that makes iPhone-Apple Watch communication straightforward and reliable.

## Topics

### Core Session

- ``ConnectivitySession``
- ``WatchConnectivitySession``
- ``NeverConnectivitySession``
- ``ActivationState``

### Type-Safe Messaging

- ``Messagable``
- ``MessageDecoder``
- ``BinaryMessagable``
- ``BinaryMessageEncoder``

### Message Sending and Receiving

- ``ConnectivityReceiveResult``
- ``ConnectivityReceiveContext``
- ``ConnectivitySendResult``
- ``ConnectivitySendContext``
- ``MessageTransport``
- ``SendOptions``
- ``ConnectivityHandler``
- ``ConnectivityMessage``

### Observation

- ``ConnectivitySessionDelegate``
- ``ConnectivityStateObserver``

### Error Handling

- ``ConnectivityError``
- ``SerializationError``
