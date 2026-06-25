//
//  LatencyGraph_Previews.swift
//  Sundial
//
//  Created on 10/27/25.
//  Copyright (c) 2025 BrightDigit.
//

#if DEBUG
  import SwiftUI

  // MARK: - Previews

  @available(iOS 16.0, watchOS 9.0, *)
  public struct LatencyGraph_Previews: PreviewProvider {
    public static var sampleMeasurements: [LatencyTracker.Measurement] {
      var measurements: [LatencyTracker.Measurement] = []
      for index in 0..<15 {
        let baseTime = Double(-index * 2)
        let sendTime = Date().addingTimeInterval(baseTime)
        let receiveTime = Date().addingTimeInterval(baseTime + 0.023)
        let method: TransportMethod =
          index.isMultiple(of: 3) ? .sendMessage : .sendMessageData

        let measurement = LatencyTracker.Measurement(
          sequenceNumber: index,
          sendTime: sendTime,
          receiveTime: receiveTime,
          transportMethod: method,
          payloadSize: 256,
          encodeTime: 0.002,
          decodeTime: 0.001
        )
        measurements.append(measurement)
      }
      return measurements
    }

    public static var previews: some View {
      VStack(spacing: 24) {
        // Empty state
        LatencyGraph(measurements: [], height: 150)
          .padding()

        // With measurements
        LatencyGraph(
          measurements: sampleMeasurements,
          height: 200
        )
        .padding()
      }
      .previewLayout(.sizeThatFits)
    }
  }
#endif
