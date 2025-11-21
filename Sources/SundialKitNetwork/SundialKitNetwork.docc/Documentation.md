# ``SundialKitNetwork``

Network connectivity monitoring using Apple's Network framework.

## Overview

SundialKitNetwork provides protocol-based abstractions over Apple's [Network framework](https://developer.apple.com/documentation/network), making it simple to monitor network connectivity changes in your apps. It tracks network status (WiFi, cellular, wired), connection quality (expensive, constrained), and interface availability with a clean, type-safe API.

### Key Features

* **PathMonitor abstraction** - Clean protocol wrapper over `NWPathMonitor` for testability
* **Network verification** - Optional periodic connectivity checks with ``NetworkPing``
* **Observer pattern** - Subscribe to network state changes through ``NetworkStateObserver``
* **Thread-safe** - Actor-based ``NetworkMonitor`` with proper concurrency handling
* **Platform-safe fallbacks** - ``NeverPing`` for platforms without ping support

### Requirements

- Swift 6.1 or later
- iOS 13+ / watchOS 6+ / tvOS 13+ / macOS 10.13+

### Getting Started

SundialKitNetwork provides the foundational network monitoring protocols and types. To use these in your application, you'll need to choose an observation plugin that matches your preferred concurrency model:

- **SundialKitCombine** - For SwiftUI apps using Combine publishers
- **SundialKitStream** - For modern Swift apps using actors and AsyncStreams

Both plugins provide `NetworkObserver` classes that wrap SundialKitNetwork's protocols with reactive APIs. The examples below show how to use each approach.

### Basic Usage

#### Using with SundialKitCombine

The Combine-based observer is ideal for SwiftUI applications where you want to bind network state directly to your UI.

```swift
import SundialKitCombine
import SundialKitNetwork

// Create observer with default NWPathMonitor
let observer = NetworkObserver()

// Start monitoring on main queue
observer.start()

// Use @Published properties
observer.$pathStatus
  .sink { status in
    switch status {
    case .satisfied(let interfaces):
      if interfaces.contains(.wifi) {
        print("Connected via WiFi")
      } else if interfaces.contains(.cellular) {
        print("Connected via Cellular")
      }
    case .unsatisfied(let reason):
      print("No connection: \(reason)")
    case .requiresConnection:
      print("Connection required")
    case .unknown:
      print("Unknown status")
    }
  }
  .store(in: &cancellables)

observer.$isExpensive
  .sink { isExpensive in
    if isExpensive {
      print("⚠️ Expensive network - reduce data usage")
    }
  }
  .store(in: &cancellables)
```

In this example, we create a `NetworkObserver` that uses the default `NWPathMonitor` to track network changes. The `@Published` properties automatically notify subscribers when the network state changes, making it perfect for reactive UI updates.

#### Using with SundialKitStream

The actor-based observer is ideal for modern Swift concurrency applications. It provides `AsyncStream` APIs that you can consume with `for await` loops, giving you fine-grained control over how you handle network changes.

```swift
import SundialKitStream
import SundialKitNetwork

// Create actor-based observer
let observer = NetworkObserver()

// Start monitoring
await observer.start()

// Consume path status updates using AsyncStream
Task {
  for await status in await observer.pathStatusStream {
    switch status {
    case .satisfied(let interfaces):
      if interfaces.contains(.wifi) {
        print("Connected via WiFi")
      }
    case .unsatisfied(let reason):
      print("No connection: \(reason)")
    default:
      break
    }
  }
}

// Monitor expensive status
Task {
  for await isExpensive in await observer.isExpensiveStream {
    if isExpensive {
      print("⚠️ Expensive network - reduce data usage")
    }
  }
}
```

Here, each `AsyncStream` provides a continuous flow of updates. You can create separate tasks to handle different aspects of network state, giving you maximum flexibility in how you structure your networking logic.

### Understanding PathStatus

``PathStatus`` represents the current network state:

- **`.satisfied(interfaces)`** - Network is available
  - `interfaces`: Set of available interfaces (`.wifi`, `.cellular`, `.wiredEthernet`, etc.)
- **`.unsatisfied(reason)`** - Network is unavailable
  - `reason`: Why the network is unavailable (`.notAvailable`, `.cellularDenied`, etc.)
- **`.requiresConnection`** - Connection is possible but requires user action (e.g., connecting to WiFi)
- **`.unknown`** - Status cannot be determined

### Platform Integration

SundialKitNetwork extends Apple's Network framework types to conform to its protocols:

- `NWPathMonitor` → ``PathMonitor``
- `NWPath` → ``NetworkPath``
- `NWInterface.InterfaceType` → ``PathStatus/Interface``
- `NWPath.UnsatisfiedReason` → ``PathStatus/UnsatisfiedReason``

This allows seamless integration with Apple's framework while maintaining protocol-based testability.

Whether you choose SundialKitCombine for SwiftUI integration or SundialKitStream for modern async/await patterns, SundialKitNetwork provides the underlying protocols and types that make network monitoring simple and type-safe.

## Topics

### Core Monitoring

- ``NetworkMonitor``
- ``PathMonitor``
- ``NetworkPath``
- ``PathStatus``

### Network Verification

- ``NetworkPing``
- ``NeverPing``

### Observation

- ``NetworkStateObserver``

### Platform Integration

Extensions to Apple's Network framework types.
