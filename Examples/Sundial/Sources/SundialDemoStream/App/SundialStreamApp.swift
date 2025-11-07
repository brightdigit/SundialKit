//
//  SundialStreamApp.swift
//  Sundial
//
//  Created on 11/1/25.
//  Copyright (c) 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import SwiftUI
#if canImport(SundialKitStream)
  import SundialKitConnectivity
  import SundialKitCore
  import SundialKitStream
  import SundialDemoShared
#endif

/// Sundial Demo App using SundialKitStream.
///
/// Demonstrates modern Swift concurrency patterns:
/// - Actor-based ConnectivityObserver
/// - AsyncStream for reactive state
/// - @Observable instead of Combine
/// - Swift 6.1 strict concurrency compliant
@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
struct SundialStreamApp: App {
  // MARK: - Shared Dependencies

  /// Shared ConnectivityObserver instance used by all view models.
  /// This ensures only ONE WatchConnectivitySession is created,
  /// preventing conflicts with WCSession.default's single delegate.
  #if os(iOS) || os(watchOS)
    @State private var sharedConnectivityObserver = ConnectivityObserver(
      messageDecoder: MessageDecoder(messagableTypes: [
        Sundial_Demo_ColorMessage.self,
        Sundial_Demo_ComplexMessage.self,
        Sundial_Demo_LatencyTestRequest.self,
        Sundial_Demo_LatencyTestReply.self,
      ])
    )

    /// App-level latency responder service.
    /// Automatically replies to latency test requests from the paired device.
    @State private var latencyResponder: LatencyResponderService?
  #endif

  var body: some Scene {
    WindowGroup {
      #if os(iOS) || os(watchOS)
        StreamTabView()
          .environment(\.connectivityObserver, sharedConnectivityObserver)
          .task {
            // Initialize latency responder service on app startup
            if latencyResponder == nil {
              latencyResponder = LatencyResponderService(connectivityObserver: sharedConnectivityObserver)
            }
          }
      #else
        StreamTabView()
      #endif
    }
  }
}
