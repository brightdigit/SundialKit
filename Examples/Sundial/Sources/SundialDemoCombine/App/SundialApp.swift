//
//  SundialApp.swift
//  Sundial
//
//  Created on 10/27/25.
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
#if canImport(SundialKitCombine)
  import SundialKitConnectivity
  import SundialKitCore
  import SundialKitCombine
  import SundialDemoShared
#endif

/// Main entry point for the Sundial Demo (Combine variant).
///
/// This variant demonstrates SundialKit v2.0.0 with SundialKitCombine plugin,
/// using @MainActor + Combine publishers for reactive state management.
///
/// Architecture:
/// - @MainActor-based observers (NetworkObserver, ConnectivityObserver)
/// - @Published properties for SwiftUI binding
/// - Combine publishers for event streams
/// - Compatible with SundialKit v1.0.0 patterns
///
/// Compare with SundialDemoStream for modern async/await implementation.
@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
public struct SundialApp: App {
  // MARK: - Shared Dependencies

  /// Shared ConnectivityObserver instance used by all view models.
  /// This ensures only ONE WatchConnectivitySession is created,
  /// preventing conflicts with WCSession.default's single delegate.
  #if os(iOS) || os(watchOS)
    @StateObject private var sharedConnectivityObserver = ConnectivityObserver(
      messageDecoder: MessageDecoder(messagableTypes: [
        Sundial_Demo_ColorMessage.self,
        Sundial_Demo_ComplexMessage.self,
      ])
    )
  #endif

  public init() {}

  public var body: some Scene {
    WindowGroup {
      #if os(iOS) || os(watchOS)
        SundialTabView()
          .environmentObject(sharedConnectivityObserver)
      #else
        SundialTabView()
      #endif
    }
  }
}
