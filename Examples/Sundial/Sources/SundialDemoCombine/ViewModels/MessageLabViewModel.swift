//
//  MessageLabViewModel.swift
//  Sundial
//
//  Created on 10/27/25.
//  Copyright (c) 2025 BrightDigit.
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

import Combine
import Foundation
import os.log
import SundialDemoShared
import SundialKitCombine
import SundialKitConnectivity
import SundialKitCore
import SwiftUI

/// ViewModel for Message Transport Lab (Tab 1).
///
/// Manages message sending via WatchConnectivity using SundialKitCombine's
/// @MainActor-based ConnectivityObserver. Demonstrates binary protobuf encoding
/// with different transport methods.
///
/// Features:
/// - Payload complexity adjustment (simple color vs complex nested messages)
/// - Manual transport method selection
/// - Sent/received color tracking
/// - Real-time connection status
@available(iOS 16.0, watchOS 9.0, *)
@MainActor
final class MessageLabViewModel: ObservableObject {
  // MARK: - Published State

  /// Currently selected color for sending
  @Published var selectedColor: Color = .blue

  /// Payload complexity (0 = simple ColorMessage, 1 = ComplexMessage)
  @Published var complexityLevel: Double = 0

  /// Manual transport method override (nil = automatic)
  @Published var selectedTransportMethod: TransportMethod?

  /// Last color sent
  @Published var lastSentColor: ColorWithMetadata?

  /// Last color received
  @Published var lastReceivedColor: ColorWithMetadata?

  /// Whether a send operation is in progress
  @Published var isSending: Bool = false

  /// Last send error message
  @Published var lastError: String?

  /// Message send statistics
  @Published var messagesSent: Int = 0
  @Published var messagesReceived: Int = 0

  // MARK: - Dependencies

  /// Connectivity observer for WatchConnectivity
  private let connectivityObserver: ConnectivityObserver

  /// Cancellable subscriptions
  private var cancellables = Set<AnyCancellable>()

  // MARK: - Computed Properties

  /// Whether the counterpart is reachable for sendMessage
  var isReachable: Bool {
    connectivityObserver.isReachable
  }

  /// Current activation state
  var activationState: String {
    // ConnectivityObserver should expose this - placeholder for now
    "Activated"
  }

  /// Automatically selected transport method based on reachability
  var automaticTransportMethod: TransportMethod {
    isReachable ? .sendMessage : .updateApplicationContext
  }

  /// Effective transport method (manual override or automatic)
  var effectiveTransportMethod: TransportMethod {
    selectedTransportMethod ?? automaticTransportMethod
  }

  // MARK: - Initialization

  #if os(iOS) || os(watchOS)
    init(
      connectivityObserver: ConnectivityObserver = .init(
        messageDecoder: MessageDecoder(messagableTypes: [
          Sundial_Demo_ColorMessage.self,
          Sundial_Demo_ComplexMessage.self
        ])
      )
    ) {
      self.connectivityObserver = connectivityObserver

      // Activate connectivity session (synchronous on @MainActor)
      do {
        try connectivityObserver.activate()
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
          DemoLogger.shared.info("ConnectivityObserver activated successfully")
        }
      } catch {
        lastError = "Failed to activate: \(error.localizedDescription)"
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
          DemoLogger.shared.error("ConnectivityObserver activation failed: \(error)")
        }
      }

      setupSubscriptions()
    }
  #else
    init(
      connectivityObserver: ConnectivityObserver = .init(
        session: NeverConnectivitySession()
      )
    ) {
      self.connectivityObserver = connectivityObserver

      // Activate connectivity session (synchronous on @MainActor)
      do {
        try connectivityObserver.activate()
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
          DemoLogger.shared.info("ConnectivityObserver activated successfully")
        }
      } catch {
        lastError = "Failed to activate: \(error.localizedDescription)"
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
          DemoLogger.shared.error("ConnectivityObserver activation failed: \(error)")
        }
      }

      setupSubscriptions()
    }
  #endif

  // MARK: - Setup

  private func setupSubscriptions() {
    // Subscribe to typed binary messages (decoded protobuf messages)
    connectivityObserver.typedMessageReceived
      .sink { [weak self] message in
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
          DemoLogger.shared.debug("Received typed message: \(type(of: message))")
        }
        self?.handleReceivedTypedMessage(message)
      }
      .store(in: &cancellables)

    // Subscribe to reachability changes
    connectivityObserver.$isReachable
      .sink { [weak self] isReachable in
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
          DemoLogger.shared.info("Reachability changed: \(isReachable)")
          DemoLogger.shared.debug("isPairedAppInstalled: \(self?.connectivityObserver.isPairedAppInstalled ?? false)")
          DemoLogger.shared.debug("activationState: \(String(describing: self?.connectivityObserver.activationState))")
        }
      }
      .store(in: &cancellables)

    // Subscribe to activation state changes
    connectivityObserver.$activationState
      .sink { state in
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
          DemoLogger.shared.info("Activation state changed: \(state)")
        }
      }
      .store(in: &cancellables)
  }

  // MARK: - Actions

  /// Send the currently selected color using effective transport method.
  func sendColor() async {
    guard !isSending else {
      if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
        DemoLogger.shared.debug("Already sending, skipping")
      }
      return
    }

    if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
      DemoLogger.shared.debug("Starting send operation...")
    }
    isSending = true
    defer {
      isSending = false
      if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
        DemoLogger.shared.debug("Send operation complete, isSending reset to false")
      }
    }

    lastError = nil

    do {
      if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
        DemoLogger.shared.debug("Building message for color: \(selectedColor)")
      }
      let message = try buildMessage()
      if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
        DemoLogger.shared.debug("Message built successfully, type: \(type(of: message))")
      }

      if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
        DemoLogger.shared.debug("Sending message...")
      }
      let result = try await connectivityObserver.send(message)
      if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
        DemoLogger.shared.info("Message sent successfully via: \(result.context)")
      }

      // Update state
      lastSentColor = ColorWithMetadata(
        color: selectedColor,
        timestamp: Date(),
        source: "This Device"
      )
      messagesSent += 1
      if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
        DemoLogger.shared.debug("UI state updated - messagesSent: \(messagesSent)")
      }
    } catch {
      lastError = error.localizedDescription
      if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
        DemoLogger.shared.error("Send error: \(error)")
        DemoLogger.shared.error("Error description: \(error.localizedDescription)")
      }
    }
  }

  /// Generate a random color.
  func randomizeColor() {
    selectedColor = Color(
      red: .random(in: 0...1),
      green: .random(in: 0...1),
      blue: .random(in: 0...1)
    )
  }

  // MARK: - Private Helpers

  private func buildMessage() throws -> any BinaryMessagable {
    if complexityLevel < 0.5 {
      // Simple ColorMessage
      return try buildColorMessage()
    } else {
      // Complex nested message
      return try buildComplexMessage()
    }
  }

  private func buildColorMessage() throws -> Sundial_Demo_ColorMessage {
    let components = selectedColor.rgbaComponents

    var message = Sundial_Demo_ColorMessage()
    message.red = Float(components.red)
    message.green = Float(components.green)
    message.blue = Float(components.blue)
    message.alpha = Float(components.alpha)
    message.timestampMs = Date().millisecondsSince1970

    return message
  }

  private func buildComplexMessage() throws -> Sundial_Demo_ComplexMessage {
    let components = selectedColor.rgbaComponents

    var message = Sundial_Demo_ComplexMessage()

    // Primary color
    var primaryColor = Sundial_Demo_ColorMessage()
    primaryColor.red = Float(components.red)
    primaryColor.green = Float(components.green)
    primaryColor.blue = Float(components.blue)
    primaryColor.alpha = Float(components.alpha)
    primaryColor.timestampMs = Date().millisecondsSince1970
    message.color = primaryColor

    // Device info
    var deviceInfo = Sundial_Demo_ComplexMessage.DeviceInfo()
    #if os(iOS)
      deviceInfo.deviceID = "iOS-Device"
    #elseif os(watchOS)
      deviceInfo.deviceID = "watchOS-Device"
    #else
      deviceInfo.deviceID = "Unknown-Device"
    #endif
    deviceInfo.osVersion = "17.0"
    deviceInfo.appVersion = "1.0.0"
    deviceInfo.locale = Locale.current.identifier
    deviceInfo.bootTimeMs = Date().millisecondsSince1970
    message.deviceInfo = deviceInfo

    // Color history (3 random colors)
    message.colorHistory = (0..<3).map { _ in
      var historyColor = Sundial_Demo_ColorMessage()
      historyColor.red = Float.random(in: 0...1)
      historyColor.green = Float.random(in: 0...1)
      historyColor.blue = Float.random(in: 0...1)
      historyColor.alpha = 1.0
      historyColor.timestampMs = Date().millisecondsSince1970
      return historyColor
    }

    // Sensor data (5 random readings)
    message.sensors = (0..<5).map { _ in
      var sensor = Sundial_Demo_ComplexMessage.SensorData()
      sensor.temperature = Float.random(in: -10...40)  // Celsius
      sensor.humidity = Float.random(in: 0...100)      // Percentage
      sensor.pressure = Float.random(in: 980...1050)   // hPa
      sensor.readingTimeMs = Date().millisecondsSince1970
      return sensor
    }

    message.messageID = "msg_\(UUID().uuidString.prefix(8))"
    message.createdAtMs = Date().millisecondsSince1970

    return message
  }

  private func handleReceivedTypedMessage(_ message: any Messagable) {
    if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
      DemoLogger.shared.debug("Received typed message: \(type(of: message))")
    }

    // Extract color from the message based on its type
    let colorComponents: (red: Double, green: Double, blue: Double, alpha: Double)?

    if let colorMessage = message as? Sundial_Demo_ColorMessage {
      colorComponents = (
        red: Double(colorMessage.red),
        green: Double(colorMessage.green),
        blue: Double(colorMessage.blue),
        alpha: Double(colorMessage.alpha)
      )
    } else if let complexMessage = message as? Sundial_Demo_ComplexMessage {
      let color = complexMessage.color
      colorComponents = (
        red: Double(color.red),
        green: Double(color.green),
        blue: Double(color.blue),
        alpha: Double(color.alpha)
      )
    } else {
      if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
        DemoLogger.shared.debug("Unknown message type: \(type(of: message))")
      }
      colorComponents = nil
    }

    // Update UI with received color
    if let components = colorComponents {
      lastReceivedColor = ColorWithMetadata(
        color: Color(
          red: components.red,
          green: components.green,
          blue: components.blue,
          opacity: components.alpha
        ),
        timestamp: Date(),
        source: "Counterpart Device"
      )
      messagesReceived += 1
      if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
        DemoLogger.shared.debug("Updated received color: \(components)")
      }
    }
  }
}
