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
[![codebeat badge](https://codebeat.co/badges/c47b7e58-867c-410b-80c5-57e10140ba0f)](https://codebeat.co/projects/github-com-brightdigit-SundialKit-main)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/brightdigit/SundialKit)](https://codeclimate.com/github/brightdigit/SundialKit)
[![Code Climate technical debt](https://img.shields.io/codeclimate/tech-debt/brightdigit/SundialKit?label=debt)](https://codeclimate.com/github/brightdigit/SundialKit)
[![Code Climate issues](https://img.shields.io/codeclimate/issues/brightdigit/SundialKit)](https://codeclimate.com/github/brightdigit/SundialKit)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)


![](Assets/Readme-Sundial.gif)

![](Assets/Reachable-Sundial.gif)



# Table of Contents

   * [**Introduction**](#introduction)
   * [**Features**](#features)
   * [**Installation**](#installation)
   * [**Usage**](#usage)
      * [Network Availability](#fetching-records-using-a-query-recordsquery)
      * [Watch Connectivity](#fetching-records-by-record-name-recordslookup)
      * [Examples](#examples)
      * [Further Code Documentation](#further-code-documentation)
   * [**Roadmap**](#roadmap)
      * [~~0.1.0~~](#010)
      * [~~0.2.0~~](#020)
      * [**0.4.0**](#040)
      * [0.6.0](#060)
      * [0.8.0](#080)
      * [0.9.0](#090)
      * [v1.0.0](#v100)
   * [**License**](#license)

# Introduction

_what does this do_
_why should you use_



### Demo Example

#### Sundial App

![Sample Schema for Todo List](Assets/CloudKitDB-Demo-Schema.jpg)

# Features 

Here's what's currently implemented with this library:

- [x] Monitor network connectivity and quality
- [x] Communicate between iPhone and Apple Watch

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
2. On `init`, we use `Combine` to listen to the publisher and store the each new `pathStatus` to our `@Published` property.
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

## Communication between iPhone and Apple Watch

Besides networking, **SundialKit** also provides an easier reactive interface into `WatchConnectivity`. This includes:

1. Various connection statues like `isReachable`, `isInstalled`, etc..
2. Send messages between the iPhone and paried Apple Watch
3. Easy encoding and decoding of messages between devices into `WatchConnectivity` friendly dictionaries.

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
2. On `init`, we use `Combine` to listen to the publisher and store the each new `isReachable` to our `@Published` property.
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

```swift
import SwiftUI
import SundialKit

class WatchMessageObject : ObservableObject {
  private let connectivityObserver = ConnectivityObserver()
  
  @Published var isReachable : Bool = false
  @Published var lastReceivedMessage : String = ""
  init () {
    connectivityObserver.isReachablePublisher.receive(on: DispatchQueue.main).assign(to: &self.$isReachable)
    connectivityObserver.messageReceivedPublisher.compactMap({ (message, _) in
      message["message"] as? String
    }).receive(on: DispatchQueue.main).assign(to: &self.$lastReceivedMessage)
  }
  
  func activate () {
    try! self.connectivityObserver.activate()
  }
  
  func sendMessage(_ message: String) {
    self.connectivityObserver.sendingMessageSubject.send(["message" : message])
  }
}



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