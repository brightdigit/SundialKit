//
//  ConnectivitySendContext.swift
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

public import SundialKitCore

/// Result from sending a message
public enum ConnectivitySendContext: Sendable {
  /// Sent via application context
  case applicationContext(transport: MessageTransport)
  /// Sent via message with reply received
  case reply(ConnectivityMessage, transport: MessageTransport)
  /// Failure
  case failure(any Error)
}

extension ConnectivitySendContext {
  /// Creates a send context from a result.
  /// - Parameters:
  ///   - result: The result of sending a message
  ///   - transport: The transport mechanism used (defaults to `.dictionary`)
  public init(
    _ result: Result<ConnectivityMessage, any Error>, transport: MessageTransport = .dictionary
  ) {
    switch result {
    case .success(let message):
      self = .reply(message, transport: transport)

    case .failure(let error):
      self = .failure(error)
    }
  }
}
