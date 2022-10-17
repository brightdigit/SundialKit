# ``SundialKit/ConnectivityObserver``

Class for communication between the Apple Watch and iPhone.

## Discussion

`ConnectivityObserver` allows you to listen to changes in `WatchConnectivity` as well as communicate with the other device (iPhone or Apple Watch)

There's a variety of properties which tell you the status of connection between devices. Here's a similar example to ``NetworkObserver/pathStatusPublisher`` using ``ConnectivityObserver/isReachablePublisher``:

```swift
import SwiftUI
import SundialKit

class WatchMessageObject : ObservableObject {
  // our ConnectivityObserver
  private let connectivityObserver = ConnectivityObserver()
  
  // a published property for when the other device is reachable
  @Published var isReachable : Bool = false

  // the last message received through WatchConnectivity
  @Published var lastReceivedMessage : String = ""

  init () {
    // on the main DispatchQueue set each change to reachability
    connectivityObserver
      .isReachablePublisher
      .receive(on: DispatchQueue.main)
      .assign(to: &self.$isReachable)

    // get the dictionary of the last message and pull the message component
    connectivityObserver
      .messageReceivedPublisher
      .compactMap({ received in
        received.message["message"] as? String
      })
      .receive(on: DispatchQueue.main)
      .assign(to: &self.$lastReceivedMessage)
  }
  
  // activate the WatchConnectivity session
  func activate () {
    try! self.connectivityObserver.activate()
  }
  
  // send a message through WatchConnectivity
  func sendMessage(_ message: String) {
    self.connectivityObserver.sendingMessageSubject.send(["message" : message])
  }
}
```

## Topics

### Activating the Session

- ``init()``
- ``activate()``

### Getting the Connection Status

- ``activationStatePublisher``
- ``isPairedPublisher``
- ``isPairedAppInstalledPublisher``
- ``isReachablePublisher``

### Communicating with other device

- ``sendingMessageSubject``
- ``messageReceivedPublisher``
- ``replyMessagePublisher``
