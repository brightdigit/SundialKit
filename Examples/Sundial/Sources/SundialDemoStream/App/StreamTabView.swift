//
//  StreamTabView.swift
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

/// Main tab container for the Sundial Stream Demo.
///
/// Demonstrates SundialKit v2.0.0 with modern async/await and AsyncStream patterns:
///
/// 1. **Transport Lab** - Send messages with actor-based ConnectivityObserver
///    - AsyncStream-based reactive state
///    - @Observable instead of @Published
///    - Swift 6.1 strict concurrency compliant
///
/// 2. **Latency Dashboard** - Coming soon
/// 3. **Protocol Comparison** - Coming soon
/// 4. **Diagnostics** - Coming soon
@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
public struct StreamTabView: View {
  public init() {}

  public var body: some View {
    TabView {
      StreamMessageLabView()
        .tabItem {
          Label("Transport", systemImage: "arrow.left.arrow.right")
        }

      StreamLatencyDashboardView()
        .tabItem {
          Label("Latency", systemImage: "clock")
        }

      StreamProtocolComparisonView()
        .tabItem {
          Label("Protocol", systemImage: "chart.bar")
        }

      StreamDiagnosticsView()
        .tabItem {
          Label("Diagnostics", systemImage: "wrench.and.screwdriver")
        }
    }
  }
}

@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
#Preview {
  StreamTabView()
}
