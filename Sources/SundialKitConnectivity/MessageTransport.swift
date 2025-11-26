//
// MessageTransport.swift
// Copyright (c) 2025 BrightDigit.
//

/// The transport mechanism used to send a message.
///
/// SundialKit supports two transport types for WatchConnectivity:
/// - **Dictionary**: Traditional `sendMessage(_:)` with property list types
/// - **Binary**: Direct binary `sendMessageData(_:)` for efficient binary payloads
///
/// Transport selection is automatic based on message type:
/// - `Messagable` (non-binary) → always uses `.dictionary`
/// - `BinaryMessagable` → uses `.binary` (unless `SendOptions.forceDictionary` is set)
///
/// ## Example
///
/// ```swift
/// let result = try await observer.send(myMessage)
/// switch result.context {
/// case .reply(_, transport: .binary):
///   print("Sent via efficient binary transport")
/// case .reply(_, transport: .dictionary):
///   print("Sent via dictionary transport")
/// default:
///   break
/// }
/// ```
public enum MessageTransport: Sendable, Equatable {
  /// Dictionary-based transport using `sendMessage(_:)`.
  ///
  /// Messages are encoded as `[String: any Sendable]` dictionaries containing
  /// property list types. This is the traditional WatchConnectivity transport
  /// and is used for all `Messagable` types.
  case dictionary

  /// Binary transport using `sendMessageData(_:)`.
  ///
  /// Messages are encoded as pure `Data` with a type discrimination footer.
  /// This transport is more efficient for `BinaryMessagable` types that use
  /// binary formats like Protobuf or MessagePack.
  case binary
}
