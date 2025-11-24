<p align="center">
    <img alt="SundialKit" title="SundialKit" src="Assets/logo.svg" height="200">
</p>
<h1 align="center"> SundialKit </h1>

Swift 6.1+ reactive communications library with modern concurrency support for Apple platforms.

[![SwiftPM](https://img.shields.io/badge/SPM-Linux%20%7C%20iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-success?logo=swift)](https://swift.org)
[![Twitter](https://img.shields.io/badge/twitter-@brightdigit-blue.svg?style=flat)](http://twitter.com/brightdigit)
![GitHub](https://img.shields.io/github/license/brightdigit/SundialKit)
![GitHub issues](https://img.shields.io/github/issues/brightdigit/SundialKit)
[![SundialKit](https://github.com/brightdigit/SundialKit/actions/workflows/SundialKit.yml/badge.svg)](https://github.com/brightdigit/SundialKit/actions/workflows/SundialKit.yml)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSundialKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/SundialKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSundialKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/SundialKit)


[![Codecov](https://img.shields.io/codecov/c/github/brightdigit/SundialKit)](https://codecov.io/gh/brightdigit/SundialKit)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/brightdigit/SundialKit)](https://www.codefactor.io/repository/github/brightdigit/SundialKit)


![Communication between iPhone and Apple Watch using Demo App](Assets/Readme-Sundial.gif "Communication between iPhone and Apple Watch using Demo App")

# Table of Contents

* [**Introduction**](#introduction)
* [**Features**](#features)
* [**Installation**](#installation)
* [**Usage**](#usage)
   * [**Listening to Networking Changes**](#listening-to-networking-changes)
   * [**Communication between iPhone and Apple Watch**](#communication-between-iphone-and-apple-watch)
      * [**Connection Status**](#connection-status)
      * [**Sending and Receiving Messages**](#sending-and-receiving-messages)
      * [**Using Messagable to Communicate**](#using-messagable-to-communicate)
* [**Development**](#development)
* [**License**](#license)

# Introduction

**SundialKit v2.0.0** is a modern Swift 6.1+ library that provides reactive interfaces for network connectivity and device communication across Apple platforms. Originally created for my app Heartwitch, SundialKit abstracts and simplifies Apple's _Network_ and _WatchConnectivity_ frameworks with a clean, layered architecture.

## What's New in v2.0.0

- **Swift 6.1 Strict Concurrency**: Full compliance with Swift 6 concurrency model
- **Three-Layer Architecture**: Protocols, wrappers, and observation layers cleanly separated
- **Multiple Concurrency Models**: Choose between modern async/await (SundialKitStream) or Combine (SundialKitCombine)
- **Zero @unchecked Sendable in Plugins**: Actor-based and @MainActor patterns ensure thread safety
- **Modular Design**: Import only what you need - core protocols, network monitoring, or connectivity
- **Swift Testing**: Modern test framework support (v2.0.0+)

# Features

**Core Features:**
- [x] Monitor network connectivity and quality using Apple's Network framework
- [x] Communicate between iPhone and Apple Watch via WatchConnectivity
- [x] Monitor device connectivity and pairing status
- [x] Send and receive messages between devices
- [x] Type-safe message encoding/decoding with Messagable protocol
- [x] Built-in message serialization with Messagable (dictionary-based) and BinaryMessagable protocols

**v2.0.0 Features:**
- [x] **SundialKitStream**: Actor-based observers with AsyncStream APIs
- [x] **SundialKitCombine**: @MainActor observers with Combine publishers
- [x] Protocol-oriented architecture for maximum flexibility
- [x] Sendable-safe types throughout
- [x] Comprehensive error handling with typed errors

# Installation

Swift Package Manager is Apple's decentralized dependency manager to integrate libraries to your Swift projects. It is now fully integrated with Xcode 16+.

## Choose Your Concurrency Model

SundialKit v2.0.0 offers two observation plugins - choose based on your project needs:

### Option A: Modern Async/Await (Recommended)

For new projects using async/await and Swift concurrency:

```swift
let package = Package(
  name: "YourPackage",
  platforms: [.iOS(.v16), .watchOS(.v9), .tvOS(.v16), .macOS(.v13)],
  dependencies: [
    .package(url: "https://github.com/brightdigit/SundialKit.git", from: "2.0.0"),
    .package(url: "https://github.com/brightdigit/SundialKitStream.git", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "YourTarget",
      dependencies: [
        .product(name: "SundialKitStream", package: "SundialKitStream"),
        .product(name: "SundialKitNetwork", package: "SundialKit"),
        .product(name: "SundialKitConnectivity", package: "SundialKit")
      ]
    )
  ]
)
```

### Option B: Combine + SwiftUI

For projects using Combine or needing backward compatibility with iOS 13+:

```swift
let package = Package(
  name: "YourPackage",
  platforms: [.iOS(.v13), .watchOS(.v6), .tvOS(.v13), .macOS(.v10_15)],
  dependencies: [
    .package(url: "https://github.com/brightdigit/SundialKit.git", from: "2.0.0"),
    .package(url: "https://github.com/brightdigit/SundialKitCombine.git", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "YourTarget",
      dependencies: [
        .product(name: "SundialKitCombine", package: "SundialKitCombine"),
        .product(name: "SundialKitNetwork", package: "SundialKit"),
        .product(name: "SundialKitConnectivity", package: "SundialKit")
      ]
    )
  ]
)
```

### Understanding SundialKit Architecture

SundialKit v2.0.0 has two types of features:

**Core Packages** (from `brightdigit/SundialKit`):
- `SundialKitCore`: Protocol definitions and core types
- `SundialKitNetwork`: Network connectivity monitoring with NWPathMonitor wrappers
- `SundialKitConnectivity`: WatchConnectivity abstractions with built-in message serialization
  - **Messagable protocol**: Type-safe dictionary-based messaging
  - **BinaryMessagable protocol**: Efficient binary message encoding
  - **MessageDecoder**: Type registry for decoding messages

**Plugin Packages** (separate repositories - choose your concurrency model):
- `SundialKitStream` (from `brightdigit/SundialKitStream`): Actor-based observers with AsyncStream APIs
- `SundialKitCombine` (from `brightdigit/SundialKitCombine`): Combine-based observers with @Published properties

When you import `SundialKitConnectivity`, you automatically get Messagable and BinaryMessagable features. The observation plugins (Stream and Combine) are distributed as separate packages to keep dependencies minimal.

### Core Protocols Only

For building your own observers:

```swift
.product(name: "SundialKitCore", package: "SundialKit")
```

## Requirements

### v2.0.0+
- **Swift**: 6.1+ (strict concurrency enabled)
- **Xcode**: 16.0+
- **Platforms**:
  - SundialKitStream: iOS 16+, watchOS 9+, tvOS 16+, macOS 13+
  - SundialKitCombine: iOS 13+, watchOS 6+, tvOS 13+, macOS 10.15+
  - Core modules: iOS 13+, watchOS 6+, tvOS 13+, macOS 10.13+

### v1.x (Legacy)
- **Swift**: 5.9+
- **Xcode**: 15.0+
- **Platforms**: iOS 13+, watchOS 6+, tvOS 13+, macOS 10.13+

# Usage

SundialKit v2.0.0 provides two ways to monitor network connectivity and device communication. Choose the approach that fits your project:

## Listening to Networking Changes

**SundialKit** uses Apple's `Network` framework to monitor network connectivity, providing detailed information about network status, quality, and interface types.

### Option A: Using SundialKitStream (Async/Await)

For modern Swift concurrency with async/await:

```swift
import SwiftUI
import SundialKitStream
import SundialKitNetwork

@MainActor
@Observable
class NetworkConnectivityModel {
  var pathStatus: PathStatus = .unknown
  var isExpensive: Bool = false
  var isConstrained: Bool = false

  private let observer = NetworkObserver(
    monitor: NWPathMonitorAdapter(),
    ping: nil
  )

  func start() {
    // Start monitoring on a background queue
    observer.start(queue: .global())

    // Listen to path status updates using AsyncStream
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

    // Listen to constrained network status
    Task {
      for await constrained in observer.isConstrainedStream {
        self.isConstrained = constrained
      }
    }
  }
}

struct NetworkView: View {
  @State private var model = NetworkConnectivityModel()

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

### Option B: Using SundialKitCombine (Combine + SwiftUI)

For projects using Combine or requiring iOS 13+ compatibility:

```swift
import SwiftUI
import SundialKitCombine
import SundialKitNetwork
import Combine

@MainActor
class NetworkConnectivityObject: ObservableObject {
  // NetworkObserver is @MainActor, so all access is on main thread
  let observer = NetworkObserver(
    monitor: NWPathMonitorAdapter(),
    ping: nil
  )

  // Access pathStatus directly via @Published property
  @Published var pathStatus: PathStatus = .unknown
  @Published var isExpensive: Bool = false
  @Published var isConstrained: Bool = false

  private var cancellables = Set<AnyCancellable>()

  init() {
    // Observer's @Published properties automatically update on MainActor
    observer.$pathStatus
      .assign(to: &$pathStatus)

    observer.$isExpensive
      .assign(to: &$isExpensive)

    observer.$isConstrained
      .assign(to: &$isConstrained)
  }

  func start() {
    // Start monitoring (defaults to main queue for @MainActor observer)
    observer.start()
  }
}

struct NetworkView: View {
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

**Available Network Properties:**
- `pathStatus`: Overall network status (satisfied, unsatisfied, requiresConnection, unknown)
- `isExpensive`: Whether the connection is expensive (e.g., cellular data)
- `isConstrained`: Whether the connection has constraints (e.g., low data mode)

### Verify Connectivity with ``NetworkPing``

In addition to utilizing `NWPathMonitor`, you can setup a periodic ping by implementing ``NetworkPing``. Here's an example which calls the _ipify_ API to verify there's an ip address:

```swift
struct IpifyPing : NetworkPing {
  typealias StatusType = String?

  let session: URLSession
  let timeInterval: TimeInterval

  public func shouldPing(onStatus status: PathStatus) -> Bool {
    switch status {
    case .unknown, .unsatisfied:
      return false
    case .requiresConnection, .satisfied:
      return true
    }
  }

  static let url : URL = .init(string: "https://api.ipify.org")!

  func onPing(_ closure: @escaping (String?) -> Void) {
    session.dataTask(with: IpifyPing.url) { data, _, _ in
      closure(data.flatMap{String(data: $0, encoding: .utf8)})
    }.resume()
  }
}
```

Next, in our `ObservableObject`, we can create a ``NetworkObserver`` to use this with:

```swift
  @Published var nwObject = NetworkObserver(ping:
    // use the shared `URLSession` and check every 10.0 seconds
    IpifyPing(session: .shared, timeInterval: 10.0)
   )
```

## Communication between iPhone and Apple Watch

Besides networking, **SundialKit** also provides an easier reactive interface into `WatchConnectivity`. This includes:

1. Various connection statuses like `isReachable`, `isInstalled`, etc..
2. Send messages between the iPhone and paired Apple Watch
3. Easy encoding and decoding of messages between devices into `WatchConnectivity` friendly dictionaries.

![Showing changes to `isReachable` using SundialKit](Assets/Reachable-Sundial.gif "Showing changes to `isReachable` using SundialKit")

Let's first talk about how `WatchConnectivity` status works.

### Connection Status

With `WatchConnectivity` there's a variety of properties which tell you the status of connection between devices. Here's an example using SundialKitCombine to monitor `isReachable` and `activationState`:

```swift
import SwiftUI
import SundialKitCombine
import SundialKitConnectivity
import Combine

@MainActor
class WatchConnectivityObject: ObservableObject {
  // Create the ConnectivityObserver
  let observer = ConnectivityObserver()

  // Published properties for isReachable and activationState
  @Published var isReachable: Bool = false
  @Published var activationState: ActivationState = .notActivated

  private var cancellables = Set<AnyCancellable>()

  init() {
    // Bind the observer's @Published properties to our own
    observer.$isReachable
      .assign(to: &$isReachable)

    observer.$activationState
      .assign(to: &$activationState)
  }

  func activate() throws {
    // Activate the WatchConnectivity session
    try observer.activate()
  }
}
```

There are 3 important pieces:

1. The `ConnectivityObserver` called `observer`
2. On `init`, we bind the observer's `@Published` properties to our own published properties
3. An `activate` method which needs to be called to activate the session for `WatchConnectivity`

For our `SwiftUI` `View`, we need to `activate` the session at `onAppear` and can use the published properties in the `View`:

```swift
struct WatchConnectivityView: View {
  @StateObject var connectivityObject = WatchConnectivityObject()

  var body: some View {
    VStack {
      Text("Session: \(connectivityObject.activationState.description)")
      Text(
        connectivityObject.isReachable ?
          "Reachable" : "Not Reachable"
      )
    }
    .onAppear {
      try? connectivityObject.activate()
    }
  }
}
```

Besides `isReachable` and `activationState`, you also have access to:

* `isPairedAppInstalled`
* `isPaired`
* `isCompanionAppInstalled` (watchOS only)

All of these properties are available as `@Published` properties on the `ConnectivityObserver`.

### Sending and Receiving Messages

To send and receive messages through our `ConnectivityObserver`, we use async methods and Combine publishers:

- `messageReceived` PassthroughSubject - for listening to messages
- `sendMessage(_:)` async method - for sending messages

**SundialKit** uses `[String: any Sendable]` dictionaries for sending and receiving messages, which use the typealias `ConnectivityMessage`. Let's expand upon the previous `WatchConnectivityObject` to handle messaging:

```swift
import SwiftUI
import SundialKitCombine
import SundialKitConnectivity
import Combine

@MainActor
class WatchConnectivityObject: ObservableObject {
  let observer = ConnectivityObserver()

  @Published var isReachable: Bool = false
  @Published var lastReceivedMessage: String = ""

  private var cancellables = Set<AnyCancellable>()

  init() {
    // Bind isReachable
    observer.$isReachable
      .assign(to: &$isReachable)

    // Listen for received messages
    observer.messageReceived
      .compactMap { result in
        result.message["message"] as? String
      }
      .assign(to: &$lastReceivedMessage)
  }

  func activate() throws {
    try observer.activate()
  }

  func sendMessage(_ message: String) async throws {
    // Send a message asynchronously
    let result = try await observer.sendMessage(["message": message])
    print("Message sent via: \(result.context)")
  }
}
```

We can now create a simple SwiftUI View using our updated `WatchConnectivityObject`:

```swift
struct WatchMessageDemoView: View {
  @StateObject var connectivityObject = WatchConnectivityObject()
  @State var message: String = ""

  var body: some View {
    VStack {
      Text(connectivityObject.isReachable ? "Reachable" : "Not Reachable")

      TextField("Message", text: self.$message)

      Button("Send") {
        Task {
          try? await connectivityObject.sendMessage(message)
        }
      }
      .disabled(!connectivityObject.isReachable)

      Text("Last received message:")
      Text(connectivityObject.lastReceivedMessage)
    }
    .onAppear {
      try? connectivityObject.activate()
    }
  }
}
```

Messages arrive with different contexts that indicate how they should be handled:

- **`.replyWith(handler)`** - Interactive message expecting an immediate reply. Use the handler to send a response.
- **`.applicationContext`** - Background state update delivered when devices can communicate. No reply expected.

### Using `Messagable` to Communicate

We can use type-safe messaging by implementing the `Messagable` protocol. In v2.0.0, the `ConnectivityObserver` can be configured with a `MessageDecoder` to automatically decode incoming messages.

First, create a type that implements `Messagable`:

```swift
import SundialKitConnectivity

struct Message: Messagable {
  let text: String

  // Unique key for this message type
  static let key: String = "textMessage"

  // Throwing initializer from dictionary parameters
  init(from parameters: [String: any Sendable]) throws {
    guard let text = parameters["text"] as? String else {
      throw SerializationError.missingField("text")
    }
    self.text = text
  }

  // Convert to dictionary parameters
  func parameters() -> [String: any Sendable] {
    ["text": text]
  }

  // Regular initializer for creating messages
  init(text: String) {
    self.text = text
  }
}
```

There are three requirements for implementing `Messagable`:

* `init(from:)` - Create the object from a dictionary, throwing an error if invalid
* `parameters()` - Return a dictionary with all the parameters needed to recreate the object
* `key` - A string that identifies the type and must be unique within the `MessageDecoder`

Now configure our `ConnectivityObserver` with a `MessageDecoder` and use typed messages:

```swift
import SwiftUI
import SundialKitCombine
import SundialKitConnectivity
import Combine

@MainActor
class WatchConnectivityObject: ObservableObject {
  // Create observer with MessageDecoder for typed message handling
  let observer = ConnectivityObserver(
    messageDecoder: MessageDecoder(messagableTypes: [Message.self])
  )

  @Published var isReachable: Bool = false
  @Published var lastReceivedMessage: String = ""

  private var cancellables = Set<AnyCancellable>()

  init() {
    observer.$isReachable
      .assign(to: &$isReachable)

    // Listen for typed messages
    observer.typedMessageReceived
      .compactMap { $0 as? Message }
      .map(\.text)
      .assign(to: &$lastReceivedMessage)
  }

  func activate() throws {
    try observer.activate()
  }

  func sendMessage(_ text: String) async throws {
    // Send using the typed message
    let message = Message(text: text)
    let result = try await observer.send(message)
    print("Message sent via: \(result.context)")
  }
}
```

The `MessageDecoder` automatically routes incoming messages to the correct type based on the message's `key` field, and the `typedMessageReceived` publisher emits already-decoded `Messagable` instances.

# Demo Applications

SundialKit includes two demo applications showcasing different concurrency approaches:

- **Pulse** (`Examples/Sundial/Apps/SundialCombine`) - Combine-based reactive demo with @MainActor observers
- **Flow** (`Examples/Sundial/Apps/SundialStream`) - AsyncStream/actor-based demo with modern Swift concurrency

Both apps demonstrate:
- Network connectivity monitoring
- WatchConnectivity communication between iPhone and Apple Watch
- Real-world usage patterns for SundialKit

Both apps are available for internal testing via TestFlight.

See [Examples/Sundial/DEPLOYMENT.md](Examples/Sundial/DEPLOYMENT.md) for deployment and development instructions.

# Development

SundialKit uses a Make-based workflow for building, testing, and linting the project.

## Building and Testing

```bash
make build          # Build the package
make test           # Run tests with code coverage
make lint           # Run linting and formatting (strict mode)
make format         # Format code only
make clean          # Clean build artifacts
make help           # Show all available commands
```

## Development Tools

The project uses [mise](https://mise.jdx.dev/) to manage development tools:
- **swift-format** - Official Apple Swift formatter
- **SwiftLint** - Swift style and conventions linter
- **Periphery** - Unused code detection

Install mise on macOS:
```bash
curl https://mise.run | sh
# or
brew install mise
```

Install development tools:
```bash
mise install  # Installs tools from .mise.toml
```

Run linting manually:
```bash
./Scripts/lint.sh                    # Normal mode
LINT_MODE=STRICT ./Scripts/lint.sh   # Strict mode (CI)
FORMAT_ONLY=1 ./Scripts/lint.sh      # Format only
```

# License

This code is distributed under the MIT license. See the [LICENSE](https://github.com/brightdigit/SundialKit/LICENSE) file for more info.
