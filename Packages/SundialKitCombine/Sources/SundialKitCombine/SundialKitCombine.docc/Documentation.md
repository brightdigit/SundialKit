# ``SundialKitCombine``

Combine-based observation plugin for SundialKit with @Published properties.

## Overview

SundialKitCombine provides observers that deliver state updates via @Published properties and Combine publishers. This plugin is designed for SwiftUI projects and apps requiring backward compatibility with iOS 13+.

### Key Features

- **@Published Properties**: Direct binding to SwiftUI views
- **Combine Publishers**: Full reactive programming support
- **Swift 6.1 Strict Concurrency**: Zero `@unchecked Sendable` conformances

### Requirements

- Swift 6.1+
- iOS 13+ / watchOS 6+ / tvOS 13+ / macOS 10.15+
- Combine framework

### Network Monitoring

Monitor network connectivity with ``NetworkObserver``:

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

### SwiftUI Integration

Use with SwiftUI views:

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

### WatchConnectivity Communication

Communicate between iPhone and Apple Watch with ``ConnectivityObserver``:

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

### Ping Integration

Monitor network connectivity with periodic pings:

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

## Topics

### Network Monitoring

- ``NetworkObserver``

### WatchConnectivity

- ``ConnectivityObserver``
