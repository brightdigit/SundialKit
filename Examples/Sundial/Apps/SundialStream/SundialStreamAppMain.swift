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
/// - Swift 6.1 strict concurrency compliant
@available(iOS 18.0, watchOS 11.0, *)
@main
struct SundialStreamAppMain: App {
  var body: some Scene {
    WindowGroup {
      StreamRootView()
    }
  }
}

/// Leads with the `ContextEngine` "Context Sync" demo and keeps the original
/// AsyncStream Message Lab one tap away.
///
/// The existing `StreamTabView` is itself a `TabView`, so it's presented as a
/// sheet rather than nested under another tab bar.
@available(iOS 18.0, watchOS 11.0, *)
struct StreamRootView: View {
  @State private var showingMessageLab = false

  var body: some View {
    NavigationStack {
      StreamContextLabView()
        .toolbar {
          ToolbarItem(placement: .primaryAction) {
            Button {
              showingMessageLab = true
            } label: {
              Label("Message Lab", systemImage: "arrow.left.arrow.right")
            }
          }
        }
        .sheet(isPresented: $showingMessageLab) {
          StreamTabView()
        }
    }
  }
}
