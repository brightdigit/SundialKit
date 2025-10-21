//
//  BinaryMessageEncoder.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
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

public import Foundation
public import SundialKitCore

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
    let lengthRange = (data.count - 4)..<data.count
    let lengthData = data[lengthRange]
    let length = lengthData.withUnsafeBytes { $0.load(as: UInt32.self).littleEndian }

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
