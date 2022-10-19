<p align="center">
    <img alt="SundialKit" title="SundialKit" src="Assets/logo.svg" height="200">
</p>
<h1 align="center"> SundialKit </h1>

Communications library across Apple platforms.

[![SwiftPM](https://img.shields.io/badge/SPM-Linux%20%7C%20iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-success?logo=swift)](https://swift.org)
[![Twitter](https://img.shields.io/badge/twitter-@brightdigit-blue.svg?style=flat)](http://twitter.com/brightdigit)
![GitHub](https://img.shields.io/github/license/brightdigit/SundialKit)
![GitHub issues](https://img.shields.io/github/issues/brightdigit/SundialKit)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/brightdigit/SundialKit/SundialKit?label=actions&logo=github)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSundialKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/SundialKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FSundialKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/SundialKit)


[![Codecov](https://img.shields.io/codecov/c/github/brightdigit/SundialKit)](https://codecov.io/gh/brightdigit/SundialKit)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/brightdigit/SundialKit)](https://www.codefactor.io/repository/github/brightdigit/SundialKit)
[![codebeat badge](https://codebeat.co/badges/54695d4b-98c8-4f0f-855e-215500163094)](https://codebeat.co/projects/github-com-brightdigit-SundialKit-main)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/brightdigit/SundialKit)](https://codeclimate.com/github/brightdigit/SundialKit)
[![Code Climate technical debt](https://img.shields.io/codeclimate/tech-debt/brightdigit/SundialKit?label=debt)](https://codeclimate.com/github/brightdigit/SundialKit)
[![Code Climate issues](https://img.shields.io/codeclimate/issues/brightdigit/SundialKit)](https://codeclimate.com/github/brightdigit/SundialKit)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)


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
* [**License**](#license)

# Introduction

For easier use in reactive user interfaces, especially with `SwiftUI` and `Combine`, I've created a library which abstracts and maps common connectivity APIs. Particularly in my app Heartwitch, I mapped the functionaly of _WatchConnectivity_ and _Network_ over to track the users ability to connect to the Internet as well as the ability for their iPhone to connect to their Apple Watch via _WatchConnectivity_

# Features 

Here's what's currently implemented with this library:

- [x] Monitor network connectivity and quality
- [x] Communicate between iPhone and Apple Watch
  - [x] Monitor connectivity between devices
  - [x] Send messages back and forth between iPhone and Apple Watch
  - [x] Abstract messages for easier _encoding_ and _decoding_

# Installation

Swift Package Manager is Apple's decentralized dependency manager to integrate libraries to your Swift projects. It is now fully integrated with Xcode 13.

To integrate **SundialKit** into your project using SPM, specify it in your Package.swift file:

```swift    
let package = Package(
  ...
  dependencies: [
    .package(url: "https://github.com/brightdigit/SundialKit.git", from: "0.2.0")
  ],
  targets: [
      .target(
          name: "YourTarget",
          dependencies: ["SundialKit", ...]),
      ...
  ]
)
```

# Usage 

## Listening to Networking Changes

In the past `Reachability` or `AFNetworking` has been used to judge the network connectivity of a device.**SundialKit** uses the `Network` framework to listen to changes in connectivity providing all the information available.

**SundialKit** provides a `NetworkObserver` which allows you the listen to variety of publishers related to the network. This is especially useful if you are using `SwiftUI` in particular. With `SwiftUI`, you can create an `ObservableObject` which contains an `NetworkObserver`:

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

1. The `NetworkObserver` called `connectivityObserver`
2. On `init`, we use `Combine` to listen to the publisher and store each new `pathStatus` to our `@Published` property.
3. A `start` method which needs to be called to start listening to the `NetworkObserver`.

Therefore for our `SwiftUI` `View`, we need to `start` listening `onAppear` and can use the `pathStatus` property in the `View`:

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

Besides `pathStatus`, you also have access to:

* `isExpensive`
* `isConstrained`

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

With `WatchConnectivity` there's a variety of properties which tell you the status of connection between devices. Here's a similar example to `pathStatus` using `isReachable`:


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

1. The `ConnectivityObserver` called `connectivityObserver`
2. On `init`, we use `Combine` to listen to the publisher and store each new `isReachable` to our `@Published` property.
3. An `activate` method which needs to be called to activate the session for `WatchConnectivity`.

Therefore for our `SwiftUI` `View`, we need to `activate` the session at `onAppear` and can use the `isReachable` property in the `View`:

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

* `activationState`
* `isReachable`
* `isPairedAppInstalled`
* `isPaired`

Additionally there's also a set of publishers for sending, receiving, and replying to messages between the iPhone and paired Apple Watch.

### Sending and Receiving Messages

To send and receive messages through our ``ConnectivityObserver`` we can access two properties:

- ``ConnectivityObserver/messageReceivedPublisher`` - for listening to messages
- ``ConnectivityObserver/sendingMessageSubject`` - for sending messages

**SundialKit** uses `[String:Any]` dictionaries for sending and receiving messages, which use the typealias ``ConnectivityMessage``. Let's expand upon the previous `WatchConnectivityObject` and use those properties: 

```swift
class WatchConnectivityObject : ObservableObject {

  // our ConnectivityObserver
  let connectivityObserver = ConnectivityObserver()

  // our published property for isReachable initially set to false
  @Published var isReachable : Bool = false

  // our published property for the last message received
  @Published var lastReceivedMessage : String = ""

  init () {
    // set the isReachable changes to our published property
    connectivityObserver
      .isReachablePublisher
      .receive(on: DispatchQueue.main)
      .assign(to: &self.$isReachable)

    // set the lastReceivedMessage based on the dictionary's _message_ key
    connectivityObserver
      .messageReceivedPublisher
      .compactMap({ received in
        received.message["message"] as? String
      })
      .receive(on: DispatchQueue.main)
      .assign(to: &self.$lastReceivedMessage)
  }
  
  func activate () {
    // activate the WatchConnectivity session
    try! self.connectivityObserver.activate()
  }

  func sendMessage(_ message: String) {
    // create a dictionary with the message in the message key
    self.connectivityObserver.sendingMessageSubject.send(["message" : message])
  }
}
```

We can now create a simple SwiftUI View using our updated `WatchConnectivityObject`:

```swift
struct WatchMessageDemoView: View {
  @StateObject var connectivityObject = WatchMessageObject()
  @State var message : String = ""
  var body: some View {
    VStack{
      Text(connectivityObject.isReachable ? "Reachable" : "Not Reachable").onAppear{
        self.connectivityObject.activate()
      }
      TextField("Message", text: self.$message)
      Button("Send") {
        self.connectivityObject.sendMessage(self.message)
      }
      
      Text("Last received message:")
      Text(self.connectivityObject.lastReceivedMessage)
    }
  }
}
```

### Using `Messagable` to Communicate

We can even abstract the ``ConnectivityMessage`` using a ``MessageDecoder``. To do this we need to create a special type which implements ``Messagable``:

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
```

There are three requirements for implementing ``Messagable``:

* ``Messagable/init(from:)`` - try to create the object based on the dictionary, return nil if it's invalid
* ``Messagable/parameters()`` - return a dictionary with all the parameters need to recreate the object
* ``Messagable/key`` - return a string which identifies the type and is unique to the ``MessageDecoder``

Now that we have our implmentation of ``Messagable``, we can use it in our `WatchConnectivityObject`:

```swift
class WatchConnectivityObject : ObservableObject {

  // our ConnectivityObserver
  let connectivityObserver = ConnectivityObserver()

  // create a `MessageDecoder` which can decode our new `Message` type
  let messageDecoder = MessageDecoder(messagableTypes: [Message.self])

  // our published property for isReachable initially set to false
  @Published var isReachable : Bool = false

  // our published property for the last message received
  @Published var lastReceivedMessage : String = ""

  init () {
    // set the isReachable changes to our published property
    connectivityObserver
      .isReachablePublisher
      .receive(on: DispatchQueue.main)
      .assign(to: &self.$isReachable)

    
    connectivityObserver
      // get the ``ConnectivityReceiveResult/message`` part of the ``ConnectivityReceiveResult``
      .map(\.message)
      // use our `messageDecoder` to call ``MessageDecoder/decode(_:)``
      .compactMap(self.messageDecoder.decode)
      // check it's our `Message`
      .compactMap{$0 as? Message}
      // get the `text` property
      .map(\.text)
      .receive(on: DispatchQueue.main)
      // set it to our published property
      .assign(to: &self.$lastReceivedMessage)
  }
  
  func activate () {
    // activate the WatchConnectivity session
    try! self.connectivityObserver.activate()
  }

  func sendMessage(_ message: String) {
    // create a dictionary using ``Messagable/message()``
    self.connectivityObserver.sendingMessageSubject.send(Message(text: message).message())
  }
}
```

# License 

This code is distributed under the MIT license. See the [LICENSE](https://github.com/brightdigit/SundialKit/LICENSE) file for more info.
