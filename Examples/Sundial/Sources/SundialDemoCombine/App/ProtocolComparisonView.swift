//
//  ProtocolComparisonView.swift
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

extension View {
  fileprivate static var segmentedIfAvailable: some PickerStyle {
    #if !os(watchOS)
      return .segmented
    #else
      return .automatic
    #endif
  }
}

/// Tab 3: Protocol Comparison (Combine variant)
/// Compares binary protobuf encoding vs dictionary encoding.
@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
struct ProtocolComparisonView: View {
  @State private var viewModel = CombineProtocolComparisonViewModel()
  @State private var isRunning = false

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          controlSection

          if viewModel.hasRunComparison {
            resultsSection
          } else {
            emptyState
          }
        }
        .padding()
      }
      .navigationTitle("Protocol")
    }
  }

  // MARK: - View Components

  private var controlSection: some View {
    VStack(spacing: 16) {
      Picker("Message Type", selection: $viewModel.selectedMessageType) {
        ForEach(MessageType.allCases) { type in
          Text(type.rawValue).tag(type)
        }
      }
      .pickerStyle(Self.segmentedIfAvailable)

      Button(action: {
        isRunning = true
        Task {
          await viewModel.runComparison()
          isRunning = false
        }
      }) {
        Label(
          isRunning ? "Running..." : "Run Comparison",
          systemImage: isRunning ? "hourglass" : "play.fill"
        )
        .frame(maxWidth: .infinity)
        .padding()
        .background(isRunning ? Color.gray : Color.orange)
        .foregroundColor(.white)
        .cornerRadius(12)
      }
      .disabled(isRunning)
    }
  }

  private var resultsSection: some View {
    VStack(spacing: 24) {
      // Size comparison
      VStack(alignment: .leading, spacing: 12) {
        Text("Size Comparison")
          .font(.headline)

        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
          MetricCard(
            title: "Protobuf",
            value: "\(viewModel.protobufSize)",
            subtitle: "bytes",
            icon: "doc.binary",
            color: .blue
          )

          MetricCard(
            title: "Dictionary",
            value: "\(viewModel.dictionarySize)",
            subtitle: "bytes",
            icon: "doc.text",
            color: .purple
          )
        }

        // Size reduction percentage
        if viewModel.sizeReduction > 0 {
          HStack {
            Image(systemName: "arrow.down.circle.fill")
              .foregroundColor(.green)
            Text("Size Reduction: \(String(format: "%.1f%%", viewModel.sizeReduction))")
              .font(.subheadline)
              .fontWeight(.medium)
          }
          .padding()
          .frame(maxWidth: .infinity)
          .background(Color.green.opacity(0.1))
          .cornerRadius(8)
        }
      }

      // Encoding time comparison
      VStack(alignment: .leading, spacing: 12) {
        Text("Encoding Performance")
          .font(.headline)

        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
          MetricCard(
            title: "Protobuf",
            value: formatTime(viewModel.protobufEncodeTime),
            subtitle: "ms",
            icon: "speedometer",
            color: .blue
          )

          MetricCard(
            title: "Dictionary",
            value: formatTime(viewModel.dictionaryEncodeTime),
            subtitle: "ms",
            icon: "speedometer",
            color: .purple
          )
        }

        if viewModel.encodingSpeedup > 1 {
          HStack {
            Image(systemName: "bolt.fill")
              .foregroundColor(.orange)
            Text("Encoding Speedup: \(String(format: "%.1fx", viewModel.encodingSpeedup))")
              .font(.subheadline)
              .fontWeight(.medium)
          }
          .padding()
          .frame(maxWidth: .infinity)
          .background(Color.orange.opacity(0.1))
          .cornerRadius(8)
        }
      }

      // Decoding time comparison
      VStack(alignment: .leading, spacing: 12) {
        Text("Decoding Performance")
          .font(.headline)

        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
          MetricCard(
            title: "Protobuf",
            value: formatTime(viewModel.protobufDecodeTime),
            subtitle: "ms",
            icon: "speedometer",
            color: .blue
          )

          MetricCard(
            title: "Dictionary",
            value: formatTime(viewModel.dictionaryDecodeTime),
            subtitle: "ms",
            icon: "speedometer",
            color: .purple
          )
        }

        if viewModel.decodingSpeedup > 1 {
          HStack {
            Image(systemName: "bolt.fill")
              .foregroundColor(.orange)
            Text("Decoding Speedup: \(String(format: "%.1fx", viewModel.decodingSpeedup))")
              .font(.subheadline)
              .fontWeight(.medium)
          }
          .padding()
          .frame(maxWidth: .infinity)
          .background(Color.orange.opacity(0.1))
          .cornerRadius(8)
        }
      }
    }
  }

  private var emptyState: some View {
    VStack(spacing: 16) {
      Image(systemName: "chart.bar.xaxis")
        .font(.system(size: 60))
        .foregroundColor(.orange)

      Text("Protocol Comparison")
        .font(.title2)
        .fontWeight(.semibold)

      Text("Compare binary protobuf vs dictionary encoding")
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding(.vertical, 40)
  }

  // MARK: - Helpers

  private func formatTime(_ time: TimeInterval) -> String {
    String(format: "%.3f", time * 1000)  // Convert to ms
  }
}

@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
#Preview {
  ProtocolComparisonView()
}
