//
//  LatencyDashboardView.swift
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

/// Tab 2: Latency Dashboard
@available(iOS 16.0, watchOS 9.0, *)
struct LatencyDashboardView: View {
  var body: some View {
    NavigationView {
      VStack {
        Image(systemName: "clock")
          .font(.largeTitle)
          .foregroundColor(.orange)

        Text("Latency Dashboard")
          .font(.title2)
          .fontWeight(.semibold)

        Text("Coming soon")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      .navigationTitle("Latency")
    }
  }
}

@available(iOS 17.0, watchOS 10.0, *)
#Preview {
  LatencyDashboardView()
}
