//
//  StreamLatencyDashboardView.swift
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


extension View {
  public static var segmentedIfAvailable: some PickerStyle {
    #if !os(watchOS)
  
    return .segmented
    #else
    return .automatic
    #endif
}
}
/// Tab 2: Latency Dashboard (Stream variant)
/// Measures round-trip time (RTT) and displays latency metrics.
@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
struct StreamLatencyDashboardView: View {
  @Environment(\.connectivityObserver) private var sharedObserver
  @State private var viewModel: StreamLatencyDashboardViewModel?

  var body: some View {
    Group {
      if let viewModel {
        contentView(viewModel: viewModel)
      } else {
        ProgressView("Initializing...")
      }
    }
    .task {
      if viewModel == nil {
        viewModel = StreamLatencyDashboardViewModel(connectivityObserver: sharedObserver)
      }
    }
  }

  private func contentView(viewModel: StreamLatencyDashboardViewModel) -> some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          controlSection(viewModel: viewModel)

          if !viewModel.measurements.isEmpty {
            metricsSection(viewModel: viewModel)
            breakdownSection(viewModel: viewModel)
            graphSection(viewModel: viewModel)
          } else {
            emptyState
          }
        }
        .padding()
      }
      .navigationTitle("Latency")
    }
  }

  // MARK: - View Components

  

  private func controlSection(viewModel: StreamLatencyDashboardViewModel) -> some View {
    VStack(spacing: 16) {
      // Reachability status banner
      if !viewModel.isReachable {
        HStack {
          Image(systemName: "exclamationmark.triangle.fill")
            .foregroundColor(.orange)
          VStack(alignment: .leading, spacing: 4) {
            Text("Devices Not Reachable")
              .font(.subheadline)
              .fontWeight(.semibold)
            Text("Ensure both apps are in foreground and Bluetooth is connected")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
      }

      Picker("Payload Size", selection: Binding(
        get: { viewModel.currentPayloadSize },
        set: { viewModel.currentPayloadSize = $0 }
      )) {
        Text("Small (64B)").tag(Sundial_Demo_LatencyTestRequest.PayloadSize.small)
        Text("Medium (512B)").tag(Sundial_Demo_LatencyTestRequest.PayloadSize.medium)
        Text("Large (4KB)").tag(Sundial_Demo_LatencyTestRequest.PayloadSize.large)
      }
      .pickerStyle(StreamLatencyDashboardView.segmentedIfAvailable)

      Button(action: {
        if viewModel.isRunning {
          viewModel.stopLatencyTest()
        } else {
          viewModel.startLatencyTest()
        }
      }) {
        Label(
          viewModel.isRunning ? "Stop Test" : "Start Test",
          systemImage: viewModel.isRunning ? "stop.fill" : "play.fill"
        )
        .frame(maxWidth: .infinity)
        .padding()
        .background(viewModel.isRunning ? Color.red : (viewModel.isReachable ? Color.orange : Color.gray))
        .foregroundColor(.white)
        .cornerRadius(12)
      }
      .disabled(!viewModel.isReachable && !viewModel.isRunning)
    }
  }

  private func metricsSection(viewModel: StreamLatencyDashboardViewModel) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Live Metrics")
        .font(.headline)

      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        MetricCard(
          title: "Average RTT",
          value: formatTime(viewModel.averageRTT),
          subtitle: "ms",
          icon: "clock",
          color: .orange
        )

        MetricCard(
          title: "Min RTT",
          value: formatTime(viewModel.minRTT),
          subtitle: "ms",
          icon: "arrow.down",
          color: .green
        )

        MetricCard(
          title: "Max RTT",
          value: formatTime(viewModel.maxRTT),
          subtitle: "ms",
          icon: "arrow.up",
          color: .red
        )

        MetricCard(
          title: "Std Deviation",
          value: formatTime(viewModel.standardDeviation),
          subtitle: "ms",
          icon: "chart.bar",
          color: .purple
        )
      }
    }
  }

  private func breakdownSection(viewModel: StreamLatencyDashboardViewModel) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Time Breakdown")
        .font(.headline)

      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        MetricCard(
          title: "Encode",
          value: formatTime(viewModel.averageEncodeTime),
          subtitle: "ms",
          icon: "arrow.up.doc",
          color: .blue
        )

        MetricCard(
          title: "Network",
          value: formatTime(viewModel.averageNetworkTime),
          subtitle: "ms",
          icon: "network",
          color: .orange
        )

        MetricCard(
          title: "Decode",
          value: formatTime(viewModel.averageDecodeTime),
          subtitle: "ms",
          icon: "arrow.down.doc",
          color: .green
        )
      }
    }
  }

  private func graphSection(viewModel: StreamLatencyDashboardViewModel) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Latency Graph")
        .font(.headline)

      LatencyGraph(measurements: viewModel.measurements)
        .frame(height: 200)
    }
  }

  private var emptyState: some View {
    VStack(spacing: 16) {
      Image(systemName: "chart.line.uptrend.xyaxis")
        .font(.system(size: 60))
        .foregroundColor(.orange)

      Text("Latency Dashboard")
        .font(.title2)
        .fontWeight(.semibold)

      Text("Start a test to measure round-trip time")
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding(.vertical, 40)
  }

  // MARK: - Helpers

  private func formatTime(_ time: TimeInterval?) -> String {
    guard let time = time else { return "-" }
    return String(format: "%.1f", time * 1000)  // Convert to ms
  }
}

@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
#Preview {
  StreamLatencyDashboardView()
}
