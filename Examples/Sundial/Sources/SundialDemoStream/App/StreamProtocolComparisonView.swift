//
//  StreamProtocolComparisonView.swift
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

/// Tab 3: Protocol Comparison (Stream variant)
/// Compares binary protobuf encoding vs dictionary encoding efficiency.
@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
struct StreamProtocolComparisonView: View {
  @State private var viewModel = StreamProtocolComparisonViewModel()

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          if viewModel.hasRunComparison {
            comparisonResults
          } else {
            emptyState
          }

          controlSection
        }
        .padding()
      }
      .navigationTitle("Protocol")
    }
  }

  // MARK: - View Components

  private var emptyState: some View {
    VStack(spacing: 16) {
      Image(systemName: "chart.bar.doc.horizontal")
        .font(.system(size: 60))
        .foregroundColor(.purple)

      Text("Protocol Comparison")
        .font(.title2)
        .fontWeight(.semibold)

      Text("Compare binary protobuf encoding vs dictionary encoding")
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding(.vertical, 40)
  }

  private var controlSection: some View {
    VStack(spacing: 16) {
      Picker("Message Type", selection: $viewModel.selectedMessageType) {
        ForEach(MessageType.allCases) { type in
          Text(type.rawValue).tag(type)
        }
      }
      .pickerStyle(Self.segmentedIfAvailable)

      Button(action: {
        Task {
          await viewModel.runComparison()
        }
      }) {
        Label("Run Comparison", systemImage: "play.fill")
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.purple)
          .foregroundColor(.white)
          .cornerRadius(12)
      }
    }
  }

  private var comparisonResults: some View {
    VStack(spacing: 24) {
      sizeComparisonSection
      performanceSection
    }
  }

  private var sizeComparisonSection: some View {
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
          color: .orange
        )

        MetricCard(
          title: "Reduction",
          value: String(format: "%.1f%%", viewModel.sizeReduction),
          subtitle: "smaller",
          icon: "arrow.down.circle",
          color: .green
        )
        .gridCellColumns(2)
      }
    }
  }

  private var performanceSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Performance")
        .font(.headline)

      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        MetricCard(
          title: "Protobuf Encode",
          value: String(format: "%.3f", viewModel.protobufEncodeTime * 1000),
          subtitle: "ms",
          icon: "arrow.up.doc",
          color: .blue
        )

        MetricCard(
          title: "Dict Encode",
          value: String(format: "%.3f", viewModel.dictionaryEncodeTime * 1000),
          subtitle: "ms",
          icon: "arrow.up.doc",
          color: .orange
        )

        MetricCard(
          title: "Protobuf Decode",
          value: String(format: "%.3f", viewModel.protobufDecodeTime * 1000),
          subtitle: "ms",
          icon: "arrow.down.doc",
          color: .blue
        )

        MetricCard(
          title: "Dict Decode",
          value: String(format: "%.3f", viewModel.dictionaryDecodeTime * 1000),
          subtitle: "ms",
          icon: "arrow.down.doc",
          color: .orange
        )
      }
    }
  }
}

@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
#Preview {
  StreamProtocolComparisonView()
}
