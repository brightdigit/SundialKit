//
//  SundialStreamAppMain.swift
//  Sundial
//
//  App entry point for SundialStream iOS/watchOS apps.
//  This file hooks up the Xcode app targets to the SundialDemoStream library.
//
//  Copyright (c) 2025 BrightDigit.
//

import SundialDemoShared
import SundialDemoStream
import SundialKitConnectivity
import SundialKitCore
import SundialKitStream
import SwiftUI

/// Entry point for SundialStream iOS and watchOS apps.
///
/// Demonstrates modern Swift concurrency patterns with SundialKitStream:
/// - Actor-based ConnectivityObserver
/// - AsyncStream for reactive state
/// - @Observable instead of Combine
/// - Swift 6.1 strict concurrency compliant
@available(iOS 17.0, watchOS 10.0, *)
@main
struct SundialStreamAppMain: App {
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
              print("🚀 App: Initializing LatencyResponderService")
              latencyResponder = LatencyResponderService(connectivityObserver: sharedConnectivityObserver)
              print("✅ App: LatencyResponderService initialized")
            }
          }
      #else
        StreamTabView()
      #endif
    }
  }
}
