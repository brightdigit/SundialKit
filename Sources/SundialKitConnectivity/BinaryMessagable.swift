//
//  BinaryMessagable.swift
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
import SundialKitCore

/// Protocol for binary-encoded messages (Protobuf, MessagePack, custom formats).
///
/// Inherits from ``Messagable`` and provides automatic implementation of dictionary-based
/// methods. Users only implement binary encoding/decoding methods - the framework handles
/// type discrimination and dictionary compatibility.
///
/// ```swift
/// import SwiftProtobuf
///
/// struct SensorData: BinaryMessagable {
///   // key defaults to "SensorData" (type name)
///   private var proto: SensorDataProto
///
///   var temperature: Float { proto.temperature }
///
///   // Pure protobuf encoding (no type info)
///   func encode() throws -> Data {
///     try proto.serializedData()
///   }
///
///   // Pure protobuf decoding (no type info)
///   init(from data: Data) throws {
///     proto = try SensorDataProto(serializedData: data)
///   }
///
///   // init(from parameters:) and parameters() auto-implemented!
/// }
/// ```
public protocol BinaryMessagable: Messagable {
  /// Decode from pure binary data (no type information).
  ///
  /// The framework strips type footer before calling this initializer.
  /// Users receive pure binary format matching what `encode()` returns.
  ///
  /// - Parameter data: Pure binary data representation.
  /// - Throws: SerializationError if decoding fails.
  init(from data: Data) throws

  /// Encode the message to pure binary data (no type information).
  ///
  /// The framework handles adding type discrimination via footer when sending
  /// via `sendMessageData`. Users should return pure binary format (Protobuf, etc.).
  ///
  /// - Returns: Pure binary data representation.
  /// - Throws: SerializationError if encoding fails.
  func encode() throws -> Data
}

// Default key implementation using type name
extension BinaryMessagable {
  /// Default implementation uses the type name as the key
  public static var key: String {
    String(describing: Self.self)
  }
}

// Automatic Messagable conformance for backward compatibility
extension BinaryMessagable {
  /// Auto-implemented: extracts binary data from parameters and decodes
  public init(from parameters: [String: any Sendable]) throws {
    guard let data = parameters[MessagableKeys.dataKey] as? Data else {
      throw SerializationError.missingBinaryData
    }
    try self.init(from: data)
  }

  /// Auto-implemented: wraps binary data in parameters dictionary
  public func parameters() -> [String: any Sendable] {
    guard let data = try? encode() else {
      return [:]
    }
    return [MessagableKeys.dataKey: data]
  }
}
