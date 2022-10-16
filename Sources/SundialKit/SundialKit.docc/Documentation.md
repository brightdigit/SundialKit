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

- watchOS(.v6), .iOS(.v13)
- Xcode 13.2.1 or later
- Swift 5.5.2 or later
- iOS 13.0 / watchOS 6.0 / tvOS 13.0 / macOS 11 or later deployment targets

**Linux**

- Ubuntu 18.04 or later
- Swift 5.5.2 or later

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

Lorem Ipsum

```swift
import SwiftUI
import SundialKit

class NetworkConnectivityObject : ObservableObject {
  let connectivityObserver = NetworkObserver()
  
  @Published var pathStatus : PathStatus = .unknown
  init () {
    connectivityObserver.pathStatusPublisher.receive(on: DispatchQueue.main).assign(to: &self.$pathStatus)
  }
  
  func start () {
    self.connectivityObserver.start(queue: .global())
  }
}

struct NetworkObserverView: View {
  @StateObject var connectivityObject = NetworkConnectivityObject()
    var body: some View {
      Text(self.connectivityObject.pathStatus.message).onAppear{
        self.connectivityObject.start()
      }
    }
}
```

<!--
You can get started decoding your feed by creating your first ``SynDecoder``. Once you've created you decoder you can decode using ``SynDecoder/decode(_:)``:

```swift
let decoder = SynDecoder()
let empowerAppsData = Data(contentsOf: "empowerapps-show.xml")!
let empowerAppsRSSFeed = try decoder.decode(empowerAppsData)
```
-->

### Communication between iPhone and Apple Watch

Lorem Ipsum

```swift
import SwiftUI
import SundialKit

class WatchConnectivityObject : ObservableObject {
  let connectivityObserver = ConnectivityObserver()
  
  @Published var isReachable : Bool = false
  init () {
    connectivityObserver.isReachablePublisher.receive(on: DispatchQueue.main).assign(to: &self.$isReachable)
  }
  
  func activate () {
    try! self.connectivityObserver.activate()
  }
}

struct WatchConnectivityDemoView: View {
  @StateObject var connectivityObject = WatchConnectivityObject()
  var body: some View {
    Text(connectivityObject.isReachable ? "Reachable" : "Not Reachable").onAppear{
      self.connectivityObject.activate()
    }
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

- ``Interfaceable``
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
