# ``SundialKit``

Communications library across Apple platforms.

## Overview

![SundialKit Logo](logo.jpg)

**SundialKit** provides a reactive SwiftUI-friendly interface into various communication APIs.

### Features

* Monitor network connectivity and quality
* Communicate between iPhone and Apple Watch

### Requirements 

**Apple Platforms**

- Xcode 13.2.1 or later
- Swift 5.5.2 or later
- iOS 13.0 / watchOS 6.0 / tvOS 13.0 / macOS 11 or later deployment targets

### Installation

Swift Package Manager is Apple's decentralized dependency manager to integrate libraries to your Swift projects. It is now fully integrated with Xcode 13.

To integrate **SundialKit** into your project using SPM, specify it in your Package.swift file:

```swift    
let package = Package(
  ...
  dependencies: [
    .package(url: "https://github.com/brightdigit/SundialKit", from: "0.2.0")
  ],
  targets: [
      .target(
          name: "YourTarget",
          dependencies: ["SundialKit", ...]),
      ...
  ]
)
```

If this is for an Xcode project simply import the [Github repository](https://github.com/brightdigit/SundialKit) at:

```
https://github.com/brightdigit/SundialKit
```

### Listening to Networking Changes

In the past `Reachability` or `AFNetworking` has been used to judge the network connectivity of a device.**SundialKit** uses the `Network` framework to listen to changes in connectivity providing all the information available.

**SundialKit** provides a ``NetworkObserver`` which allows you the listen to variety of publishers related to the network. This is especially useful if you are using `SwiftUI` in particular. With `SwiftUI`, you can create an `ObservableObject` which contains an ``NetworkObserver``:

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

There are 3 important pieces:

1. The ``NetworkObserver`` called `connectivityObserver`
2. On `init`, we use `Combine` to listen to the publisher and store the each new ``PathStatus`` to our `@Published` property.
3. A `start` method which needs to be called to ``NetworkObserver/start(queue:)`` start listening to the `NetworkObserver`.

Therefore for our `SwiftUI` `View`, we need to `start` listening `onAppear` and can use the ``PathStatus`` property in the `View`:

```swift

struct NetworkObserverView: View {
  @StateObject var connectivityObject = NetworkConnectivityObject()
    var body: some View {
      // Use the `message` property to display text of the `pathStatus`
      Text(self.connectivityObject.pathStatus.message).onAppear{
        // start the NetworkObserver
        self.connectivityObject.start()
      }
    }
}
```

Besides ``NetworkObserver/pathStatusPublisher``, you also have access to:

* `isExpensive` via ``NetworkObserver/isExpensivePublisher``
* `isConstrained` via ``NetworkObserver/isConstrainedPublisher``

### Communication between iPhone and Apple Watch

Besides networking, **SundialKit** also provides an easier reactive interface into `WatchConnectivity`. This includes:

1. Various connection statues like `isReachable`, `isInstalled`, etc..
2. Send messages between the iPhone and paried Apple Watch
3. Easy encoding and decoding of messages between devices into `WatchConnectivity` friendly dictionaries.

Let's first talk about how `WatchConnectivity` status works.

#### Connection Status

With `WatchConnectivity` there's a variety of properties which tell you the status of connection between devices. Here's a similar example to ``NetworkObserver/pathStatusPublisher`` using ``ConnectivityObserver/isReachablePublisher``:


```swift
import SwiftUI
import SundialKit

class WatchConnectivityObject : ObservableObject {
  // our ConnectivityObserver
  let connectivityObserver = ConnectivityObserver()
  // our published property for isReachable initially set to false
  @Published var isReachable : Bool = false
  init () {
    // set the isReachable changes to our published property
    connectivityObserver
      .isReachablePublisher
      .receive(on: DispatchQueue.main)
      .assign(to: &self.$isReachable)
  }
  
  func activate () {
    // activate the WatchConnectivity session
    try! self.connectivityObserver.activate()
  }
}
```

Again, there are 3 important pieces:

1. The ``ConnectivityObserver`` called `connectivityObserver`
2. On `init`, we use `Combine` to listen to the publisher and store the each new `isReachable` via ``ConnectivityObserver/isReachablePublisher`` to our `@Published` property.
3. An ``ConnectivityObserver/activate()`` method which needs to be called to activate the session for `WatchConnectivity`.

Therefore for our `SwiftUI` `View`, we need to ``ConnectivityObserver/activate()`` the session at `onAppear` and can use the `isReachable` property in the `View`:

```swift

struct WatchConnectivityView: View {
  @StateObject var connectivityObject = WatchConnectivityObject()
  var body: some View {
    Text(
      connectivityObject.isReachable ? 
        "Reachable" : "Not Reachable"
    )
    .onAppear{
      self.connectivityObject.activate()
    }
  }
}
```

Besides `isReachable`, you also have access to:

* `activationState` via ``ConnectivityObserver/activationStatePublisher``
* `isReachable` via ``ConnectivityObserver/isReachablePublisher``
* `isPairedAppInstalled` via ``ConnectivityObserver/isPairedAppInstalledPublisher``
* `isPaired` via ``ConnectivityObserver/isPairedPublisher``

Additionally there's also a set of publishers for sending, receiving, and replying to messages between the iPhone and paired Apple Watch.

#### Using `Messagable` to Communicate

```swift

struct Message : Messagable {
  internal init(text: String) {
    self.text = text
  }
  
  static let key: String = "_message"
  
  enum Parameters : String {
    case text
  }
  
  init?(from parameters: [String : Any]?) {
    guard let text = parameters?[Parameters.text.rawValue] as? String else {
      return nil
    }
    
    self.text = text
  }
  
  func parameters() -> [String : Any] {
    return [
      Parameters.text.rawValue : self.text
    ]
  }
  
  let text : String
}

class WatchMessagableObject : ObservableObject {
  private let connectivityObserver = ConnectivityObserver()
  private let messageDecoder = MessageDecoder(messagableTypes: [Message.self])
  
  @Published var isReachable : Bool = false
  @Published var lastReceivedMessage : String = ""
  init () {
    connectivityObserver.isReachablePublisher.receive(on: DispatchQueue.main).assign(to: &self.$isReachable)
    connectivityObserver.messageReceivedPublisher
      .map(\.0)
      .compactMap(self.messageDecoder.decode)
      .compactMap{$0 as? Message}
      .map(\.text)
      .receive(on: DispatchQueue.main)
      .assign(to: &self.$lastReceivedMessage)
  }
  
  func activate () {
    try! self.connectivityObserver.activate()
  }
  
  func sendMessage(_ message: String) {
    self.connectivityObserver.sendingMessageSubject.send(Message(text: message).message())
  }
}
```
<!--
Rather than working directly with the various formats, **SyndiKit** abstracts many of the common properties of the various formats. This enables developers to be agnostic regarding the specific format.

```swift
let decoder = SynDecoder()

// decoding a RSS 2.0 feed
let empowerAppsData = Data(contentsOf: "empowerapps-show.xml")!
let empowerAppsRSSFeed = try decoder.decode(empowerAppsData)
print(empowerAppsRSSFeed.title) // Prints "Empower Apps"

// decoding a Atom feed from YouTube
let kiloLocoData = Data(contentsOf: "kilo.youtube.xml")!
let kiloLocoAtomFeed = try decoder.decode(kiloLocoData)
print(kiloLocoAtomFeed.title) // Prints "Kilo Loco"
```

For a mapping of properties:

Feedable | RSS 2.0 ``RSSFeed/channel`` | Atom ``AtomFeed`` | JSONFeed ``JSONFeed`` 
--- | --- | --- | ---
``Feedable/title`` | ``RSSChannel/title`` | ``AtomFeed/title`` | ``JSONFeed/title``
``Feedable/siteURL`` | ``RSSChannel/link`` | ``AtomFeed/siteURL``| ``JSONFeed/title``
``Feedable/summary`` | ``RSSChannel/description`` | ``AtomFeed/summary`` | ``JSONFeed/homePageUrl``
``Feedable/updated`` | ``RSSChannel/lastBuildDate`` | ``AtomFeed/pubDate`` or ``AtomFeed/published`` | `nil`
``Feedable/authors`` | ``RSSChannel/author`` | ``AtomFeed/authors`` | ``JSONFeed/author``
``Feedable/copyright`` | ``RSSChannel/copyright`` | `nil` | `nil`
``Feedable/image`` | ``RSSImage/url`` | ``AtomFeed/links``.`first` | `nil`
``Feedable/children`` | ``RSSChannel/items`` | ``AtomFeed/entries``| ``JSONFeed/items``

!-->

### License 

This code is distributed under the MIT license. See the [LICENSE](https://github.com/brightdigit/SundialKit/LICENSE) file for more info.

## Topics

### Listening to Networking Changes

- ``NetworkObserver``
- ``NetworkPath``
- ``NetworkPing``
- ``NeverPing``
- ``PathMonitor``
- ``PathStatus``

### Communication between iPhone and Apple Watch

The basic types used by **SyndiKit** for traversing the feed in abstract manner without needing the specific properties from the various feed formats. 

- ``ActivationState``
- ``ConnectivityHandler``
- ``ConnectivityMessage``
- ``ConnectivityObserver``
- ``ConnectivityReceiveContext``
- ``ConnectivityReceiveResult``
- ``ConnectivitySendContext``
- ``ConnectivitySendResult``
- ``Messagable``
- ``MessageDecoder``

### Error Handling

- ``SundialError``
