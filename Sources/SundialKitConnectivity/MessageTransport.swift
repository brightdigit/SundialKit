//
//  MessageTransport.swift
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
