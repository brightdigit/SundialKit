//
// BinaryMessageEncoder.swift
// Copyright (c) 2025 BrightDigit.
//

public import Foundation
import SundialKitCore

/// Encodes and decodes binary messages with type discrimination footers.
///
/// Binary messages use a footer format to embed type information:
/// ```
/// [Pure Binary Payload][Type Key UTF-8 bytes][Type Key Length (UInt32)]
/// ```
///
/// Example with "SensorData" type:
/// ```
/// [Protobuf bytes...][S][e][n][s][o][r][D][a][t][a][10][0][0][0]
///                     ^-- UTF-8 "SensorData" --^  ^-- UInt32: 10
/// ```
///
/// This allows WatchConnectivity's `sendMessageData` to transmit pure binary
/// payloads while maintaining type discrimination for `MessageDecoder`.
public enum BinaryMessageEncoder {
  /// Encodes a BinaryMessagable into Data with type discrimination footer.
  ///
  /// - Parameter message: The message to encode
  /// - Returns: Binary data with appended type footer
  /// - Throws: SerializationError if encoding fails
  public static func encode(_ message: some BinaryMessagable) throws -> Data {
    // Get pure binary payload
    var data = try message.encode()

    // Get type key from the type (not the instance)
    let typeKey = type(of: message).key

    // Append type key as UTF-8
    let typeKeyData = Data(typeKey.utf8)
    data.append(typeKeyData)

    // Append type key length as UInt32 (little-endian)
    var length = UInt32(typeKeyData.count).littleEndian
    withUnsafeBytes(of: &length) { data.append(contentsOf: $0) }

    return data
  }

  /// Decodes binary data with type footer, extracting type key and payload.
  ///
  /// - Parameter data: Binary data with type footer
  /// - Returns: Tuple of (typeKey, payload) where payload is the pure binary data
  /// - Throws: SerializationError if decoding fails
  public static func decode(_ data: Data) throws -> (typeKey: String, payload: Data) {
    // Minimum size: 4 bytes for length
    guard data.count >= 4 else {
      throw SerializationError.invalidFormat
    }

    // Read footer length (last 4 bytes as little-endian UInt32)
    // Copy to aligned buffer to avoid misaligned pointer access
    let lengthRange = (data.count - 4)..<data.count
    var lengthBytes: UInt32 = 0
    _ = withUnsafeMutableBytes(of: &lengthBytes) { buffer in
      data.copyBytes(to: buffer, from: lengthRange)
    }
    let length = UInt32(littleEndian: lengthBytes)

    // Validate we have enough data for type key + length
    guard data.count >= Int(length) + 4 else {
      throw SerializationError.invalidFormat
    }

    // Extract type key
    let typeKeyRange = (data.count - 4 - Int(length))..<(data.count - 4)
    let typeKeyData = data[typeKeyRange]
    guard let typeKey = String(data: typeKeyData, encoding: .utf8) else {
      throw SerializationError.invalidTypeKey
    }

    // Extract pure binary payload (everything before the type key)
    let payload = data[0..<(data.count - 4 - Int(length))]

    return (typeKey, Data(payload))
  }
}
