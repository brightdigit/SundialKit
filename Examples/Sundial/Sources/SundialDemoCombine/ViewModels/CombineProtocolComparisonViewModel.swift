import Combine
import Foundation
import Observation
import SundialDemoShared
import SundialKitConnectivity
import SwiftProtobuf

/// ViewModel for the Protocol Comparison tab in SundialDemoCombine.
/// Compares binary protobuf encoding vs dictionary encoding for message efficiency.
@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
@MainActor
final class CombineProtocolComparisonViewModel: ObservableObject {
  // MARK: - Published State

  @Published var selectedMessageType: MessageType = .simple
  @Published var protobufSize: Int = 0
  @Published var dictionarySize: Int = 0
  @Published var protobufEncodeTime: TimeInterval = 0
  @Published var dictionaryEncodeTime: TimeInterval = 0
  @Published var protobufDecodeTime: TimeInterval = 0
  @Published var dictionaryDecodeTime: TimeInterval = 0
  @Published var hasRunComparison: Bool = false

  // MARK: - Computed Properties

  var sizeReduction: Double {
    guard dictionarySize > 0 else { return 0 }
    return Double(dictionarySize - protobufSize) / Double(dictionarySize) * 100
  }

  var encodingSpeedup: Double {
    guard dictionaryEncodeTime > 0 else { return 0 }
    return dictionaryEncodeTime / protobufEncodeTime
  }

  var decodingSpeedup: Double {
    guard dictionaryDecodeTime > 0 else { return 0 }
    return dictionaryDecodeTime / protobufDecodeTime
  }

  // MARK: - Public Methods

  /// Run encoding comparison between protobuf and dictionary formats.
  func runComparison() async {
    let message = generateSampleMessage()

    // Measure protobuf encoding
    let (protobufData, protobufEncTime) = await measureProtobufEncoding(message)
    protobufSize = protobufData.count
    protobufEncodeTime = protobufEncTime

    // Measure dictionary encoding
    let (dictionaryData, dictEncTime) = await measureDictionaryEncoding(message)
    dictionarySize = dictionaryData.count
    dictionaryEncodeTime = dictEncTime

    // Measure protobuf decoding
    protobufDecodeTime = await measureProtobufDecoding(protobufData, messageType: selectedMessageType)

    // Measure dictionary decoding
    dictionaryDecodeTime = await measureDictionaryDecoding(dictionaryData)

    hasRunComparison = true
  }

  // MARK: - Private Methods

  private func generateSampleMessage() -> any BinaryMessagable {
    switch selectedMessageType {
    case .simple:
      Sundial_Demo_ColorMessage.with {
        $0.red = 0.8
        $0.green = 0.4
        $0.blue = 0.2
        $0.alpha = 1.0
      }
    case .complex:
      Sundial_Demo_ComplexMessage.with {
        $0.messageID = UUID().uuidString
        $0.createdAtMs = Int64(Date().timeIntervalSince1970 * 1000)
        $0.color = Sundial_Demo_ColorMessage.with {
          $0.red = 0.5
          $0.green = 0.7
          $0.blue = 0.9
          $0.alpha = 1.0
        }
        $0.customData = Data("test_data".utf8)
      }
    }
  }

  private func measureProtobufEncoding(_ message: any BinaryMessagable) async -> (Data, TimeInterval) {
    let start = CFAbsoluteTimeGetCurrent()
    let data = (try? message.encode()) ?? Data()
    let duration = CFAbsoluteTimeGetCurrent() - start
    return (data, duration)
  }

  private func measureDictionaryEncoding(_ message: any BinaryMessagable) async -> (Data, TimeInterval) {
    let start = CFAbsoluteTimeGetCurrent()
    let dict = message.parameters()
    let data = (try? JSONSerialization.data(withJSONObject: dict)) ?? Data()
    let duration = CFAbsoluteTimeGetCurrent() - start
    return (data, duration)
  }

  private func measureProtobufDecoding(_ data: Data, messageType: MessageType) async -> TimeInterval {
    let start = CFAbsoluteTimeGetCurrent()
    switch messageType {
    case .simple:
      _ = try? Sundial_Demo_ColorMessage(serializedData: data)
    case .complex:
      _ = try? Sundial_Demo_ComplexMessage(serializedData: data)
    }
    return CFAbsoluteTimeGetCurrent() - start
  }

  private func measureDictionaryDecoding(_ data: Data) async -> TimeInterval {
    let start = CFAbsoluteTimeGetCurrent()
    _ = try? JSONSerialization.jsonObject(with: data)
    return CFAbsoluteTimeGetCurrent() - start
  }
}
