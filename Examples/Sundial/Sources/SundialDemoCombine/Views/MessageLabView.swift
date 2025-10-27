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
  @StateObject private var viewModel = MessageLabViewModel()

  private var grayBackgroundColor: Color {
    #if os(iOS) 
      Color(uiColor: .systemGray6)
    #elseif os(macOS)
      Color(nsColor: .controlBackgroundColor)
    #else
      Color.gray.opacity(0.2)
    #endif
  }

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          // Section 1: Payload Builder
          payloadBuilderSection

          // Section 2: Transport Control
          transportControlSection

          // Section 3: Results Display
          resultsSection

          // Error display
          if let error = viewModel.lastError {
            errorSection(error)
          }
        }
        .padding()
      }
      .navigationTitle("Transport Lab")
      .safeAreaInset(edge: .bottom) {
        connectionStatusFooter
      }
    }
  }

  // MARK: - Sections

  private var payloadBuilderSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Payload Builder")
        .font(.headline)

      // Color picker
      VStack(spacing: 12) {
        HStack {
          Text("Select Color")
            .font(.subheadline)
            .foregroundColor(.secondary)

          Spacer()

          Button(action: viewModel.randomizeColor) {
            Label("Random", systemImage: "shuffle")
              .font(.caption)
          }
          .buttonStyle(.bordered)
        }

        #if os(watchOS)
          // watchOS: Use color grid since ColorPicker is not available
          colorGridPicker
        #else
          // iOS/macOS: Use standard ColorPicker
          ColorPicker("Color", selection: $viewModel.selectedColor, supportsOpacity: true)
            .labelsHidden()
        #endif

        ColorPreview(
          color: viewModel.selectedColor,
          size: 80
        )
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(grayBackgroundColor)
      )

      // Complexity slider
      VStack(spacing: 8) {
        HStack {
          Text("Payload Complexity")
            .font(.subheadline)
            .foregroundColor(.secondary)

          Spacer()

          Text(complexityLabel)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.blue)
        }

        Slider(value: $viewModel.complexityLevel, in: 0...1)

        HStack {
          Text("Simple")
            .font(.caption2)
            .foregroundColor(.secondary)

          Spacer()

          Text("Complex")
            .font(.caption2)
            .foregroundColor(.secondary)
        }
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(grayBackgroundColor)
      )
    }
  }

  private var transportControlSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Transport Control")
        .font(.headline)

      // Transport method selector
      VStack(spacing: 8) {
        HStack {
          Text("Transport Method")
            .font(.subheadline)
            .foregroundColor(.secondary)

          Spacer()

          if viewModel.selectedTransportMethod == nil {
            Text("Auto")
              .font(.caption)
              .foregroundColor(.blue)
          }
        }

        HStack(spacing: 8) {
          TransportBadge(
            method: .sendMessage,
            isActive: viewModel.effectiveTransportMethod == .sendMessage
          )
          .onTapGesture {
            viewModel.selectedTransportMethod =
              viewModel.selectedTransportMethod == .sendMessage ? nil : .sendMessage
          }

          TransportBadge(
            method: .sendMessageData,
            isActive: viewModel.effectiveTransportMethod == .sendMessageData
          )
          .onTapGesture {
            viewModel.selectedTransportMethod =
              viewModel.selectedTransportMethod == .sendMessageData ? nil : .sendMessageData
          }

          TransportBadge(
            method: .updateApplicationContext,
            isActive: viewModel.effectiveTransportMethod == .updateApplicationContext
          )
          .onTapGesture {
            viewModel.selectedTransportMethod =
              viewModel.selectedTransportMethod == .updateApplicationContext
              ? nil : .updateApplicationContext
          }
        }

        if viewModel.selectedTransportMethod == nil {
          Text("Automatic: \(viewModel.automaticTransportMethod.displayName)")
            .font(.caption2)
            .foregroundColor(.secondary)
        }
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(grayBackgroundColor)
      )

      // Send button
      Button(action: { Task { await viewModel.sendColor() } }) {
        HStack {
          if viewModel.isSending {
            ProgressView()
              .progressViewStyle(.circular)
          } else {
            Image(systemName: "paperplane.fill")
          }

          Text(viewModel.isSending ? "Sending..." : "Send Message")
            .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(viewModel.isReachable ? Color.blue : Color.orange)
        .foregroundColor(.white)
        .cornerRadius(12)
      }
      .disabled(viewModel.isSending)
    }
  }

  private var resultsSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Results")
        .font(.headline)

      HStack(spacing: 16) {
        // Sent
        VStack(spacing: 12) {
          Text("Sent")
            .font(.caption)
            .foregroundColor(.secondary)

          if let sent = viewModel.lastSentColor {
            ColorPreview(
              color: sent.color,
              timestamp: sent.timestamp,
              source: "This Device"
            )
          } else {
            ColorPreview(
              color: .gray.opacity(0.3),
              size: 60
            )
            .overlay(
              Text("—")
                .font(.title)
                .foregroundColor(.secondary)
            )
          }

          Text("\(viewModel.messagesSent)")
            .font(.caption2)
            .foregroundColor(.secondary)
        }

        Divider()

        // Received
        VStack(spacing: 12) {
          Text("Received")
            .font(.caption)
            .foregroundColor(.secondary)

          if let received = viewModel.lastReceivedColor {
            ColorPreview(
              color: received.color,
              timestamp: received.timestamp,
              source: "Counterpart"
            )
          } else {
            ColorPreview(
              color: .gray.opacity(0.3),
              size: 60
            )
            .overlay(
              Text("—")
                .font(.title)
                .foregroundColor(.secondary)
            )
          }

          Text("\(viewModel.messagesReceived)")
            .font(.caption2)
            .foregroundColor(.secondary)
        }
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(grayBackgroundColor)
      )
    }
  }

  private func errorSection(_ error: String) -> some View {
    HStack(spacing: 12) {
      Image(systemName: "exclamationmark.triangle.fill")
        .foregroundColor(.red)

      Text(error)
        .font(.caption)
        .foregroundColor(.red)

      Spacer()
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.red.opacity(0.1))
    )
  }

  private var connectionStatusFooter: some View {
    ConnectionStatusView(
      isReachable: viewModel.isReachable,
      activationState: viewModel.activationState,
      lastUpdate: Date()
    )
  }

  // MARK: - Computed Properties

  #if os(watchOS)
    private var colorGridPicker: some View {
      let colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple,
        .pink, .cyan, .mint, .indigo, .brown, .gray
      ]

      return LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 8) {
        ForEach(colors.indices, id: \.self) { index in
          Circle()
            .fill(colors[index])
            .frame(width: 40, height: 40)
            .overlay(
              Circle()
                .strokeBorder(Color.white, lineWidth: viewModel.selectedColor.isSimilar(to: colors[index]) ? 3 : 0)
            )
            .onTapGesture {
              viewModel.selectedColor = colors[index]
            }
        }
      }
    }
  #endif

  private var complexityLabel: String {
    if viewModel.complexityLevel < 0.5 {
      return "ColorMessage (16 bytes)"
    } else {
      return "ComplexMessage (256+ bytes)"
    }
  }
}

// MARK: - Color Comparison Extension

private extension Color {
  func isSimilar(to other: Color) -> Bool {
    // Simple comparison for predefined colors
    self == other
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
