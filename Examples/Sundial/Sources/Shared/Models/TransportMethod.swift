//
//  TransportMethod.swift
//  Sundial Demo
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

import Foundation

/// Transport methods available for WatchConnectivity messaging
public enum TransportMethod: String, Sendable, Codable, CaseIterable, Identifiable {
  /// Direct message with reply handler (requires reachability)
  case sendMessage

  /// Application context update (queued delivery)
  case updateApplicationContext

  /// Binary-only message data (no type wrapper)
  case sendMessageData

  public var id: String { rawValue }

  /// Human-readable display name
  public var displayName: String {
    switch self {
    case .sendMessage:
      "Send Message"
    case .updateApplicationContext:
      "App Context"
    case .sendMessageData:
      "Binary Data"
    }
  }

  /// Short description of the transport method
  public var description: String {
    switch self {
    case .sendMessage:
      "Interactive messaging with reply support. Requires reachability."
    case .updateApplicationContext:
      "Queued delivery. Only latest context preserved."
    case .sendMessageData:
      "Binary-only transport. Minimal overhead."
    }
  }

  /// Icon name for SF Symbols
  public var iconName: String {
    switch self {
    case .sendMessage:
      "arrow.left.arrow.right.circle"
    case .updateApplicationContext:
      "tray.and.arrow.down"
    case .sendMessageData:
      "bolt.circle"
    }
  }

  /// Whether this method requires reachability
  public var requiresReachability: Bool {
    switch self {
    case .sendMessage, .sendMessageData:
      true
    case .updateApplicationContext:
      false
    }
  }

  /// Whether this method supports reply handlers
  public var supportsReply: Bool {
    switch self {
    case .sendMessage, .sendMessageData:
      true
    case .updateApplicationContext:
      false
    }
  }
}
