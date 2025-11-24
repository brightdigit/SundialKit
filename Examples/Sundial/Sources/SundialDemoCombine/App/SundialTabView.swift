//
//  SundialTabView.swift
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

/// Main tab container for the Sundial Demo.
///
/// Four tabs demonstrating different aspects of SundialKit v2.0.0:
///
/// 1. **Transport Lab** - Send messages via different transport methods
///    - Build ColorMessage and ComplexMessage payloads
///    - Select transport method (sendMessage, sendMessageData, updateApplicationContext)
///    - View sent/received colors
///
/// 2. **Latency Dashboard** - Round-trip time measurement and analysis
///    - Real-time RTT display
///    - Statistics (avg, min, max, stddev)
///    - Latency breakdown (encode/network/decode)
///    - Historical graph
///
/// 3. **Protocol Comparison** - Binary protobuf vs dictionary encoding
///    - Size comparison (protobuf shows 75%+ reduction)
///    - Encoding/decoding performance
///    - Complexity scaling demonstration
///
/// 4. **Diagnostics** - Connection health and message history
///    - Reachability status
///    - Session activation state
///    - Message transmission log
///    - Error reporting
@available(iOS 16.0, watchOS 9.0, *)
public struct SundialTabView: View {
  public init() {}

  public var body: some View {
    TabView {
      MessageLabView()
        .tabItem {
          Label("Transport", systemImage: "arrow.left.arrow.right")
        }

      LatencyDashboardView()
        .tabItem {
          Label("Latency", systemImage: "clock")
        }

      ProtocolComparisonView()
        .tabItem {
          Label("Protocol", systemImage: "chart.bar")
        }

      DiagnosticsView()
        .tabItem {
          Label("Diagnostics", systemImage: "wrench.and.screwdriver")
        }
    }
  }
}

@available(iOS 17.0, watchOS 10.0, *)
#Preview {
  SundialTabView()
}
