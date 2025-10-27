//
//  LatencyGraph.swift
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

import Charts
import SwiftUI

/// Line chart displaying latency measurement history.
///
/// Shows last 20 measurements with color coding by transport method.
/// Y-axis shows round-trip time in milliseconds.
///
/// Example usage:
/// ```swift
/// LatencyGraph(
///   measurements: latencyTracker.recentMeasurements,
///   height: 150
/// )
/// ```
@available(iOS 16.0, watchOS 9.0, *)
public struct LatencyGraph: View {
  /// Latency measurements to display (limited to most recent 20)
  let measurements: [LatencyTracker.Measurement]

  /// Height of the graph
  let height: CGFloat

  /// Creates a new latency graph.
  ///
  /// - Parameters:
  ///   - measurements: Array of measurements to display
  ///   - height: Height in points (default: 150)
  public init(
    measurements: [LatencyTracker.Measurement],
    height: CGFloat = 150
  ) {
    self.measurements = Array(measurements.suffix(20))
    self.height = height
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      if measurements.isEmpty {
        emptyState
      } else {
        chart
      }
    }
    .frame(height: height)
  }

  private var emptyState: some View {
    VStack(spacing: 8) {
      Image(systemName: "chart.xyaxis.line")
        .font(.largeTitle)
        .foregroundColor(.secondary)

      Text("No measurements yet")
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  @ViewBuilder
  private var chart: some View {
    Chart {
      ForEach(measurements.indices, id: \.self) { index in
        let measurement = measurements[index]
        let rttMs = measurement.roundTripTime * 1000

        LineMark(
          x: .value("Sequence", measurement.sequenceNumber),
          y: .value("RTT (ms)", rttMs)
        )
        .foregroundStyle(measurement.transportMethod.color)
        .interpolationMethod(.catmullRom)

        PointMark(
          x: .value("Sequence", measurement.sequenceNumber),
          y: .value("RTT (ms)", rttMs)
        )
        .foregroundStyle(measurement.transportMethod.color)
      }
    }
    .chartXAxis {
      AxisMarks(values: .automatic(desiredCount: 5))
    }
    .chartYAxis {
      AxisMarks(position: .leading) { value in
        AxisGridLine()
        AxisValueLabel {
          if let doubleValue = value.as(Double.self) {
            Text("\(Int(doubleValue)) ms")
              .font(.caption2)
          }
        }
      }
    }
    .chartLegend(position: .bottom, alignment: .leading, spacing: 8) {
      HStack(spacing: 12) {
        ForEach(uniqueTransportMethods, id: \.displayName) { method in
          HStack(spacing: 4) {
            Circle()
              .fill(method.color)
              .frame(width: 8, height: 8)

            Text(method.displayName)
              .font(.caption2)
          }
        }
      }
    }
  }

  private var uniqueTransportMethods: [TransportMethod] {
    var methods: [TransportMethod] = []
    var seen = Set<String>()

    for measurement in measurements {
      let key = measurement.transportMethod.displayName
      if !seen.contains(key) {
        methods.append(measurement.transportMethod)
        seen.insert(key)
      }
    }

    return methods
  }
}

#if DEBUG
  // MARK: - Previews

  @available(iOS 16.0, watchOS 9.0, *)
  struct LatencyGraph_Previews: PreviewProvider {
    static var previews: some View {
      VStack(spacing: 24) {
        // Empty state
        LatencyGraph(measurements: [], height: 150)
          .padding()
          .background(Color(.systemBackground))

        // With measurements
        LatencyGraph(
          measurements: sampleMeasurements,
          height: 200
        )
        .padding()
        .background(Color(.systemBackground))
      }
      .previewLayout(.sizeThatFits)
    }

    static var sampleMeasurements: [LatencyTracker.Measurement] {
      (0..<15).map { index in
        LatencyTracker.Measurement(
          sequenceNumber: index,
          sendTime: Date().addingTimeInterval(Double(-index * 2)),
          receiveTime: Date().addingTimeInterval(Double(-index * 2 + 0.023)),
          transportMethod: index % 3 == 0 ? .sendMessage : .sendMessageData,
          payloadSize: 256,
          encodeTime: 0.002,
          decodeTime: 0.001
        )
      }
    }
  }
#endif
