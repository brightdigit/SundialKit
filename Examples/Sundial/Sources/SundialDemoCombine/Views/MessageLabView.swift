//
//  MessageLabView.swift
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

import SundialDemoShared
import SundialKitCombine
import SwiftUI

/// Message Transport Lab - Tab 1
///
/// Interactive playground for testing WatchConnectivity transport methods
/// with binary protobuf encoding. Build messages with varying complexity
/// and send via different routes.
///
/// Sections:
/// 1. Payload Builder - Color picker and complexity slider
/// 2. Transport Control - Method selection and send button
/// 3. Results Display - Sent/received colors with metadata
/// 4. Connection Status - Footer with reachability and session state
@available(iOS 16.0, watchOS 9.0, *)
struct MessageLabView: View {
  @EnvironmentObject private var sharedConnectivityObserver: ConnectivityObserver

  var body: some View {
    // Pass the shared observer to the actual content view
    MessageLabContentView(connectivityObserver: sharedConnectivityObserver)
  }
}

@available(iOS 16.0, watchOS 9.0, *)
private struct MessageLabContentView: View {
  @StateObject private var viewModel: MessageLabViewModel

  init(connectivityObserver: ConnectivityObserver) {
    _viewModel = StateObject(wrappedValue: MessageLabViewModel(connectivityObserver: connectivityObserver))
  }

  var body: some View {
    NavigationView {
      ScrollView {
        LazyVStack(spacing: 24, pinnedViews: .sectionHeaders) {
          Section {
            // Section 1: Payload Builder
            PayloadBuilderView(
              selectedColor: $viewModel.selectedColor,
              complexityLevel: $viewModel.complexityLevel,
              onRandomize: viewModel.randomizeColor
            )

            // Section 2: Transport Control
            TransportControlView(
              selectedTransportMethod: $viewModel.selectedTransportMethod,
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
            connectionStatusFooter
          }
        }
        .padding()
      }
      .navigationTitle("Transport Lab")
    }
  }

  // MARK: - Connection Status

  private var connectionStatusFooter: some View {
    ConnectionStatusView(
      isReachable: viewModel.isReachable,
      activationState: viewModel.activationState,
      lastUpdate: Date()
    )
  }
}

#if DEBUG
  // MARK: - Previews

  @available(iOS 16.0, watchOS 9.0, *)
  struct MessageLabView_Previews: PreviewProvider {
    static var previews: some View {
      MessageLabView()
    }
  }
#endif
