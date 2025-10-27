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
/// This thin wrapper will instantiate the Stream variant app from the SundialDemoStream library
/// once Phase 4 implementation is complete.
///
/// **TODO**: Update to use actual Stream app implementation when available.
@available(iOS 16.0, watchOS 9.0, *)
@main
struct SundialStreamAppMain: App {
  var body: some Scene {
    WindowGroup {
      Text("SundialStream")
        .font(.title)
      Text("Coming in Phase 4")
        .font(.caption)
        .foregroundColor(.secondary)
    }
  }
}
