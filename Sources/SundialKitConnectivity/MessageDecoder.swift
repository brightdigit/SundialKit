//
// MessageDecoder.swift
// Copyright (c) 2025 BrightDigit.
//

public import Foundation
public import SundialKitCore

/// Decodes a ``ConnectivityMessage`` based on provided ``Messagable`` types.
///
/// ```swift
/// struct Message: Messagable {
///   // key defaults to "Message" (type name)
///
///   enum Parameters: String {
///     case text
///   }
///
///   init(from parameters: [String: any Sendable]) throws {
///     guard let text = parameters[Parameters.text.rawValue] as? String else {
///       throw SerializationError.missingField(Parameters.text.rawValue)
///     }
///
///     self.text = text
///   }
///
///   func parameters() -> [String: any Sendable] {
///     return [
///       Parameters.text.rawValue: self.text
///     ]
///   }
///
///   let text: String
/// }
///
/// let messageDecoder = MessageDecoder(messagableTypes: [Message.self])
/// let message = try messageDecoder.decode(connectivityMessage)
/// ```
public struct MessageDecoder: Sendable {
  private let messagableTypes: [String: any Messagable.Type]

  /// Creates a `MessageDecoder` based on a list of `Messagable` types.
  /// - Parameter messagableTypes: A list of `Messagable` types.
  public init(messagableTypes: [any Messagable.Type]) {
    self.messagableTypes = Dictionary(
      uniqueKeysWithValues: messagableTypes.map {
        ($0.key, $0)
      }
    )
  }

  /// Decodes the `ConnectivityMessage` into a `Messagable` object.
  /// - Parameter message: The `ConnectivityMessage` dictionary.
  /// - Returns: The decoded `Messagable` object.
  /// - Throws: SerializationError if decoding fails.
  public func decode(_ message: ConnectivityMessage) throws -> any Messagable {
    guard let typeKey = message[MessagableKeys.typeKey] as? String else {
      throw SerializationError.missingTypeKey
    }

    guard let type = messagableTypes[typeKey] else {
      throw SerializationError.unknownMessageType(typeKey)
    }

    let params = message[MessagableKeys.parametersKey] as? [String: any Sendable] ?? [:]
    return try type.init(from: params)
  }

  /// Decodes binary `Data` with type footer into a `BinaryMessagable` object.
  ///
  /// The binary data must include a type discrimination footer created by
  /// `BinaryMessageEncoder.encode(_:)`. The decoder extracts the type key,
  /// looks up the registered type, and decodes the pure binary payload.
  ///
  /// ## Example
  ///
  /// ```swift
  /// // Received binary data from sendMessageData
  /// let messageData: Data = ...
  ///
  /// // Decode to typed BinaryMessagable
  /// let message = try decoder.decodeBinary(messageData)
  /// if let sensor = message as? SensorData {
  ///   print("Temperature: \(sensor.temperature)")
  /// }
  /// ```
  ///
  /// - Parameter data: Binary data with type footer
  /// - Returns: The decoded `Messagable` object (guaranteed to be `BinaryMessagable`)
  /// - Throws: SerializationError if decoding fails or type is not BinaryMessagable
  public func decodeBinary(_ data: Data) throws -> any Messagable {
    // Extract type key and payload from binary footer
    let (typeKey, payload) = try BinaryMessageEncoder.decode(data)

    // Look up the registered type
    guard let type = messagableTypes[typeKey] else {
      throw SerializationError.unknownMessageType(typeKey)
    }

    // Ensure it's a BinaryMessagable type
    guard let binaryType = type as? any BinaryMessagable.Type else {
      throw SerializationError.notBinaryMessagable(typeKey)
    }

    // Decode from pure binary payload (no type footer)
    return try binaryType.init(from: payload)
  }
}
