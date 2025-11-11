//
//  StreamMessageLabViewModel.swift
//  Sundial
//
//  Created on 11/1/25.
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

import Foundation
import Observation
import SundialDemoShared
import SundialKitConnectivity
import SundialKitCore
import SundialKitStream
import SwiftUI

/// ViewModel for Message Transport Lab using SundialKitStream.
///
/// Uses @Observable (iOS 17+) with actor-based ConnectivityObserver and AsyncStream APIs.
/// Demonstrates modern Swift concurrency patterns with strict concurrency compliance.
///
/// Features:
/// - AsyncStream consumption for reactive state updates
/// - Actor-isolated ConnectivityObserver
/// - Binary protobuf encoding with different transport methods
/// - Swift 6.1 strict concurrency compliant
@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
@Observable
@MainActor
final class StreamMessageLabViewModel {
  // MARK: - Published State

  /// Currently selected color for sending
  var selectedColor: Color = .blue

  /// Payload complexity (0 = simple ColorMessage, 1 = ComplexMessage)
  var complexityLevel: Double = 0

  /// Manual transport method override (nil = automatic)
  var selectedTransportMethod: TransportMethod?

  /// Last color sent
  var lastSentColor: ColorWithMetadata?

  /// Last color received
  var lastReceivedColor: ColorWithMetadata?

  /// Whether a send operation is in progress
  var isSending: Bool = false

  /// Last send error message
  var lastError: String?

  /// Message send statistics
  var messagesSent: Int = 0
  var messagesReceived: Int = 0

  /// Current reachability status
  var isReachable: Bool = false

  /// Current activation state
  var activationState: ActivationState = .notActivated

  /// Whether devices are paired (iOS only, always true on watchOS)
  var isPaired: Bool = {
    #if os(watchOS)
      return true
    #else
      return false
    #endif
  }()

  /// Whether companion app is installed
  var isPairedAppInstalled: Bool = false

  // MARK: - Dependencies

  /// Actor-based connectivity observer
  private let connectivityObserver: ConnectivityObserver

  /// Task for consuming streams
  private nonisolated(unsafe) var streamTask: Task<Void, Never>?

  // MARK: - Computed Properties

  /// Automatically selected transport method based on reachability
  var automaticTransportMethod: TransportMethod {
    isReachable ? .sendMessage : .updateApplicationContext
  }

  /// Effective transport method (manual override or automatic)
  var effectiveTransportMethod: TransportMethod {
    selectedTransportMethod ?? automaticTransportMethod
  }

  // MARK: - Initialization

  init(connectivityObserver: ConnectivityObserver? = nil) {
    #if os(iOS) || os(watchOS)
      self.connectivityObserver =
        connectivityObserver
        ?? ConnectivityObserver(
          messageDecoder: MessageDecoder(messagableTypes: [
            Sundial_Demo_ColorMessage.self,
            Sundial_Demo_ComplexMessage.self,
          ])
        )
    #else
      // On macOS/tvOS, we can't use the convenience init, so provide a pre-configured observer
      self.connectivityObserver = connectivityObserver ?? Self.createMacOSObserver()
    #endif
    setupStreams()
  }

  #if !os(iOS) && !os(watchOS)
    private static func createMacOSObserver() -> ConnectivityObserver {
      // This is a workaround since the convenience init is unavailable on macOS
      // Users should provide their own observer when running on macOS
      fatalError(
        "ConnectivityObserver must be explicitly provided on macOS. Create it with: ConnectivityObserver(session: NeverConnectivitySession(), messageDecoder: ...)"
      )
    }
  #endif

  deinit {
    streamTask?.cancel()
  }

  // MARK: - Setup

  private func setupStreams() {
    streamTask = Task { @MainActor in
      // Activate connectivity session
      do {
        try await connectivityObserver.activate()
        print("✅ ConnectivityObserver activated successfully")

        // Check initial state immediately after activation
        Task { @MainActor in
          try? await Task.sleep(for: .milliseconds(500))
          let reachable = await connectivityObserver.isReachable()
          let activationState = await connectivityObserver.getCurrentActivationState()
          let pairedAppInstalled = await connectivityObserver.isPairedAppInstalled()
          #if os(iOS)
            let paired = await connectivityObserver.isPaired()
          #else
            let paired = true
          #endif

          print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
          print("📊 INITIAL STATE (500ms after activation)")
          print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
          if let activationState {
            print("🔄 Activation State: \(activationState)")
          } else {
            print("🔄 Activation State: nil")
          }
          print("🔗 isPaired: \(paired)")
          print("📱 isPairedAppInstalled: \(pairedAppInstalled)")
          print("📡 isReachable: \(reachable)")
          #if os(watchOS)
            print("⌚ Watch app perspective")
          #elseif os(iOS)
            print("📱 iPhone app perspective")
          #endif
          print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        }
      } catch {
        lastError = "Failed to activate: \(error.localizedDescription)"
        print("❌ ConnectivityObserver activation failed: \(error)")
      }

      // Start consuming all streams concurrently
      await withTaskGroup(of: Void.self) { group in
        // Stream 1: Typed messages
        group.addTask {
          await self.consumeTypedMessages()
        }

        // Stream 2: Reachability
        group.addTask {
          await self.consumeReachability()
        }

        // Stream 3: Activation state
        group.addTask {
          await self.consumeActivationState()
        }

        // Stream 4: Paired status (iOS only)
        #if os(iOS)
          group.addTask {
            await self.consumePairedStatus()
          }
        #endif

        // Stream 5: Paired app installed status
        group.addTask {
          await self.consumePairedAppInstalledStatus()
        }
      }
    }
  }

  private func consumeTypedMessages() async {
    for await message in await connectivityObserver.typedMessageStream() {
      print("📨 Received typed message: \(type(of: message))")
      handleReceivedTypedMessage(message)
    }
  }

  private func consumeReachability() async {
    for await reachable in await connectivityObserver.reachabilityUpdates() {
      print("📡 Reachability changed: \(reachable)")
      isReachable = reachable
    }
  }

  private func consumeActivationState() async {
    for await state in await connectivityObserver.activationStates() {
      print("🔄 Activation state changed: \(state)")
      activationState = state
    }
  }

  #if os(iOS)
    private func consumePairedStatus() async {
      for await paired in await connectivityObserver.pairedUpdates() {
        print("🔗 Paired status changed: \(paired)")
        isPaired = paired
      }
    }
  #endif

  private func consumePairedAppInstalledStatus() async {
    for await installed in await connectivityObserver.pairedAppInstalledUpdates() {
      print("📱 Paired app installed status changed: \(installed)")
      isPairedAppInstalled = installed
    }
  }

  // MARK: - Actions

  /// Send the currently selected color using effective transport method.
  func sendColor() async {
    guard !isSending else {
      print("⚠️ Already sending, skipping")
      return
    }

    print("📤 Starting send operation...")
    isSending = true
    defer {
      isSending = false
      print("✅ Send operation complete, isSending reset to false")
    }

    lastError = nil

    do {
      print("🎨 Building message for color: \(selectedColor)")
      let message = try buildMessage()
      print("📦 Message built successfully, type: \(type(of: message))")

      // Capture live state immediately before send
      let liveReachable = await connectivityObserver.isReachable()
      let liveActivation = await connectivityObserver.getCurrentActivationState()
      let livePairedAppInstalled = await connectivityObserver.isPairedAppInstalled()
      #if os(iOS)
        let livePaired = await connectivityObserver.isPaired()
      #else
        let livePaired = true
      #endif

      // Print diagnostic information immediately before send
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
      print("📊 CONNECTIVITY STATE (LIVE)")
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
      if let liveActivation {
        print("🔄 Activation State: \(liveActivation)")
      } else {
        print("🔄 Activation State: not yet activated")
      }
      print("🔗 isPaired: \(livePaired)")
      print("📱 isPairedAppInstalled: \(livePairedAppInstalled)")
      print("📡 isReachable: \(liveReachable)")
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

      print("🚀 Sending message via \(effectiveTransportMethod)...")

      // Route to appropriate transport method
      switch effectiveTransportMethod {
      case .updateApplicationContext:
        // Convert message to context and send via updateApplicationContext
        print("📦 Converting message to application context...")
        let context = message.message()
        try await connectivityObserver.updateApplicationContext(context)
        print("✅ Message sent successfully via updateApplicationContext")

        // Update state
        lastSentColor = ColorWithMetadata(
          color: selectedColor,
          timestamp: Date(),
          source: "This Device"
        )
        messagesSent += 1
        print("✅ UI state updated - messagesSent: \(messagesSent)")

      case .sendMessage, .sendMessageData:
        // Send via interactive message (requires reachability)
        let result = try await connectivityObserver.send(message)
        print("✅ Message sent successfully via: \(result.context)")
        if let transport = result.context.transport {
          print("📊 Actual transport used: \(transport)")
        }

        // Update state
        lastSentColor = ColorWithMetadata(
          color: selectedColor,
          timestamp: Date(),
          source: "This Device"
        )
        messagesSent += 1
        print("✅ UI state updated - messagesSent: \(messagesSent)")
      }
    } catch {
      lastError = error.localizedDescription
      print("❌ Send error: \(error)")
      print("❌ Error description: \(error.localizedDescription)")
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
      sensor.humidity = Float.random(in: 0...100)  // Percentage
      sensor.pressure = Float.random(in: 980...1050)  // hPa
      sensor.readingTimeMs = Date().millisecondsSince1970
      return sensor
    }

    message.messageID = "msg_\(UUID().uuidString.prefix(8))"
    message.createdAtMs = Date().millisecondsSince1970

    return message
  }

  private func handleReceivedTypedMessage(_ message: any Messagable) {
    print("Received typed message: \(type(of: message))")

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
      print("Unknown message type: \(type(of: message))")
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
      print("Updated received color: \(components)")
    }
  }
}
