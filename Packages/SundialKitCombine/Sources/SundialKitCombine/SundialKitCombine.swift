//
//  SundialKitCombine.swift
//  SundialKitCombine
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
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

/// SundialKitCombine provides Combine framework integration for SundialKit v2.
///
/// This package offers @MainActor-isolated observers with @Published properties
/// for reactive network monitoring and WatchConnectivity communication.
///
/// ## Features
///
/// - **NetworkObserver**: Reactive network monitoring with Combine publishers
/// - **ConnectivityObserver**: WatchConnectivity integration with Combine support
/// - **@MainActor**: All updates guaranteed on main thread for UI safety
/// - **@Published**: SwiftUI-ready observable properties
///
/// ## Example
///
/// ```swift
/// import SundialKitCombine
///
/// let observer = NetworkObserver()
/// observer.start()
///
/// observer.$pathStatus
///   .sink { status in
///     print("Network: \(status)")
///   }
///   .store(in: &cancellables)
/// ```
public enum SundialKitCombine {
  /// The version of SundialKitCombine
  public static let version = "2.0.0"
}
