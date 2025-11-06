//
//  DiagnosticsView.swift
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

/// Tab 4: Diagnostics (Combine variant)
/// Monitors connection health, message history, and error logs.
@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
struct DiagnosticsView: View {
  @State private var viewModel = CombineDiagnosticsViewModel()

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          connectionStatusSection
          statisticsSection
          messageHistorySection
          errorLogSection
        }
        .padding()
      }
      .navigationTitle("Diagnostics")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button("Clear", action: viewModel.clearHistory)
        }
      }
    }
  }

  // MARK: - View Components

  private var connectionStatusSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Connection Status")
        .font(.headline)

      ConnectionStatusView(
        isReachable: viewModel.isReachable,
        activationState: viewModel.activationStateString,
        lastUpdate: viewModel.lastUpdate
      )
    }
  }

  private var statisticsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Statistics")
        .font(.headline)

      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        MetricCard(
          title: "Sent",
          value: "\(viewModel.messagesSent)",
          subtitle: "messages",
          icon: "arrow.up.circle",
          color: .blue
        )

        MetricCard(
          title: "Received",
          value: "\(viewModel.messagesReceived)",
          subtitle: "messages",
          icon: "arrow.down.circle",
          color: .green
        )

        MetricCard(
          title: "Success Rate",
          value: String(format: "%.1f%%", viewModel.successRate),
          subtitle: "reliability",
          icon: "checkmark.circle",
          color: .purple
        )

        MetricCard(
          title: "State",
          value: viewModel.activationStateString,
          subtitle: "activation",
          icon: "circle.fill",
          color: viewModel.activationState == .activated ? .green : .orange
        )
      }
    }
  }

  private var messageHistorySection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("Message History")
          .font(.headline)

        Spacer()

        Text("Last \(min(viewModel.messageHistory.count, 50))")
          .font(.caption)
          .foregroundColor(.secondary)
      }

      if viewModel.messageHistory.isEmpty {
        emptyHistoryView
      } else {
        VStack(spacing: 8) {
          ForEach(viewModel.messageHistory.prefix(50)) { entry in
            MessageHistoryRow(
              timestamp: entry.timestamp,
              method: entry.method,
              size: entry.size,
              rtt: entry.rtt,
              success: entry.success
            )
          }
        }
      }
    }
  }

  private var errorLogSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("Error Log")
          .font(.headline)

        Spacer()

        Text("Last \(min(viewModel.errorLog.count, 20))")
          .font(.caption)
          .foregroundColor(.secondary)
      }

      if viewModel.errorLog.isEmpty {
        emptyErrorLogView
      } else {
        VStack(spacing: 8) {
          ForEach(viewModel.errorLog.prefix(20)) { error in
            errorLogRow(error)
          }
        }
      }
    }
  }

  private var emptyHistoryView: some View {
    VStack(spacing: 8) {
      Image(systemName: "tray")
        .font(.title2)
        .foregroundColor(.secondary)

      Text("No messages yet")
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 20)
    .background(Color.secondary.opacity(0.1))
    .cornerRadius(8)
  }

  private var emptyErrorLogView: some View {
    VStack(spacing: 8) {
      Image(systemName: "checkmark.circle")
        .font(.title2)
        .foregroundColor(.green)

      Text("No errors")
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 20)
    .background(Color.green.opacity(0.1))
    .cornerRadius(8)
  }

  private func errorLogRow(_ error: ErrorEntry) -> some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: severityIcon(error.severity))
        .foregroundColor(severityColor(error.severity))
        .frame(width: 20)

      VStack(alignment: .leading, spacing: 4) {
        Text(error.description)
          .font(.subheadline)

        Text(error.timestamp, style: .time)
          .font(.caption)
          .foregroundColor(.secondary)
      }

      Spacer()
    }
    .padding()
    .background(Color.secondary.opacity(0.1))
    .cornerRadius(8)
  }

  private func severityIcon(_ severity: ErrorEntry.Severity) -> String {
    switch severity {
    case .info:
      "info.circle"
    case .warning:
      "exclamationmark.triangle"
    case .error:
      "xmark.circle"
    }
  }

  private func severityColor(_ severity: ErrorEntry.Severity) -> Color {
    switch severity {
    case .info:
      .blue
    case .warning:
      .orange
    case .error:
      .red
    }
  }
}

@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
#Preview {
  DiagnosticsView()
}
