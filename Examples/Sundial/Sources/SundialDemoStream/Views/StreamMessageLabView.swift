//
//  StreamMessageLabView.swift
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

import SundialDemoShared
import SwiftUI

/// Message Transport Lab using SundialKitStream - Tab 1
///
/// Interactive playground for testing WatchConnectivity transport methods
/// with AsyncStream-based reactive state management. Uses @Observable
/// instead of Combine publishers.
///
/// Sections:
/// 1. Payload Builder - Color picker and complexity slider
/// 2. Transport Control - Method selection and send button
/// 3. Results Display - Sent/received colors with metadata
/// 4. Connection Status - Footer with reachability and session state
@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
struct StreamMessageLabView: View {
  @Environment(\.connectivityObserver) private var sharedObserver
  @State private var viewModel: StreamMessageLabViewModel?

  var body: some View {
    Group {
      if let viewModel {
        contentView(viewModel: viewModel)
      } else {
        ProgressView("Initializing...")
      }
    }
    .task {
      // Initialize view model with shared observer on first appearance
      if viewModel == nil {
        viewModel = StreamMessageLabViewModel(connectivityObserver: sharedObserver)
      }
    }
  }

  private func contentView(viewModel: StreamMessageLabViewModel) -> some View {
    NavigationView {
      ScrollView {
        LazyVStack(spacing: 24, pinnedViews: .sectionHeaders) {
          Section {
            // Section 1: Payload Builder
            PayloadBuilderView(
              selectedColor: Binding(
                get: { viewModel.selectedColor },
                set: { viewModel.selectedColor = $0 }
              ),
              complexityLevel: Binding(
                get: { viewModel.complexityLevel },
                set: { viewModel.complexityLevel = $0 }
              ),
              onRandomize: viewModel.randomizeColor
            )

            // Section 2: Transport Control
            TransportControlView(
              selectedTransportMethod: Binding(
                get: { viewModel.selectedTransportMethod },
                set: { viewModel.selectedTransportMethod = $0 }
              ),
              effectiveTransportMethod: viewModel.effectiveTransportMethod,
              automaticTransportMethod: viewModel.automaticTransportMethod,
              isSending: viewModel.isSending,
              isReachable: viewModel.isReachable,
              onSend: viewModel.sendColor
            )

            // Section 3: Results Display
            ResultsView(
              lastSentColor: viewModel.lastSentColor,
              lastReceivedColor: viewModel.lastReceivedColor,
              messagesSent: viewModel.messagesSent,
              messagesReceived: viewModel.messagesReceived
            )

            // Error display
            if let error = viewModel.lastError {
              ErrorSectionView(error: error)
            }
          } header: {
            connectionStatusFooter(viewModel: viewModel)
          }
        }
        .padding()
      }
      .navigationTitle("Transport Lab (Stream)")
    }
  }

  // MARK: - Connection Status

  private func connectionStatusFooter(viewModel: StreamMessageLabViewModel) -> some View {
    ConnectionStatusView(
      isReachable: viewModel.isReachable,
      activationState: String(describing: viewModel.activationState),
      lastUpdate: Date()
    )
  }
}

@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
#Preview {
  StreamMessageLabView()
}
