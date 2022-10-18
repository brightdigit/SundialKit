# ``SundialKit/NetworkObserver``

Observes the status of network connectivity

## Overview

`NetworkObserver` allows you the listen to variety of publishers related to the network.
This is especially useful if you are using `SwiftUI` in particular.
With `SwiftUI`, you can create an `ObservableObject` which contains an `NetworkObserver`:

```swift
import SwiftUI
import SundialKit

class NetworkConnectivityObject : ObservableObject {
  // our NetworkObserver
  let connectivityObserver = NetworkObserver()

  // our published property for pathStatus initially set to `.unknown`
  @Published var pathStatus : PathStatus = .unknown

  init () {
    // set the pathStatus changes to our published property
    connectivityObserver
      .pathStatusPublisher
      .receive(on: DispatchQueue.main)
      .assign(to: &self.$pathStatus)
  }

  // need to start listening
  func start () {
    self.connectivityObserver.start(queue: .global())
  }
}
```

## Topics

### Getting Network Status

- ``PathStatus``
- ``PathStatus/Interface``
- ``PathStatus/UnsatisfiedReason``

### Using a Network Ping to Test Connectivity

Rather than relying on only your `PathMonitor`, you can setup a periodic ping to the network.

- ``NetworkPing``
- ``NeverPing``

### Custom Path Monitors

Typically you'll want to use `NWPathMonitor` most of the time. However if you want to build your own, that's available:

- ``PathMonitor``
- ``NetworkPath``
