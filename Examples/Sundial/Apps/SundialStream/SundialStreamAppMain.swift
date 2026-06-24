//
//  SundialStreamAppMain.swift
//  Sundial
//
//  App entry point for SundialStream iOS/watchOS apps.
//  This file hooks up the Xcode app targets to the SundialDemoStream library.
//
//  Copyright (c) 2025 BrightDigit.
//

import SundialDemoStream
import SwiftUI

/// Entry point for SundialStream iOS and watchOS apps.
///
/// Demonstrates modern Swift concurrency patterns with SundialKitStream:
/// - Actor-based ConnectivityObserver
/// - AsyncStream for reactive state
/// - @Observable instead of Combine
/// - SundialKitStreamContext's `ContextEngine` for reliable snapshot sync
///   (the leading "Context Sync" tab of `StreamTabView`)
/// - Swift 6.1 strict concurrency compliant
@available(iOS 18.0, watchOS 11.0, *)
@main
struct SundialStreamAppMain: App {
  var body: some Scene {
    WindowGroup {
      StreamTabView()
    }
  }
}
