import Foundation
import Observation
import SundialDemoShared
import SundialKitConnectivity
import SundialKitCore
import SundialKitStream

/// ViewModel for the Latency Dashboard tab in SundialDemoStream.
/// Measures round-trip time (RTT) by sending ping messages and tracking replies.
@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
@Observable
@MainActor
final class StreamLatencyDashboardViewModel {
  // MARK: - Published State

  var isRunning: Bool = false
  var isReachable: Bool = false
  var currentPayloadSize: Sundial_Demo_LatencyTestRequest.PayloadSize = .small
  var latencyTracker = LatencyTracker()

  // MARK: - Computed Properties

  var measurements: [LatencyTracker.Measurement] {
    latencyTracker.measurements
  }

  var averageRTT: TimeInterval? {
    latencyTracker.averageRTT
  }

  var minRTT: TimeInterval? {
    latencyTracker.minRTT
  }

  var maxRTT: TimeInterval? {
    latencyTracker.maxRTT
  }

  var standardDeviation: TimeInterval? {
    latencyTracker.standardDeviation
  }

  var averageEncodeTime: TimeInterval? {
    guard !measurements.isEmpty else { return nil }
    let total = measurements.compactMap { $0.encodeTime }.reduce(0, +)
    return total / Double(measurements.count)
  }

  var averageNetworkTime: TimeInterval? {
    guard !measurements.isEmpty else { return nil }
    let total = measurements.compactMap { $0.networkTime }.reduce(0, +)
    return total / Double(measurements.count)
  }

  var averageDecodeTime: TimeInterval? {
    guard !measurements.isEmpty else { return nil}
    let total = measurements.compactMap { $0.decodeTime }.reduce(0, +)
    return total / Double(measurements.count)
  }

  // MARK: - Dependencies

  private let connectivityObserver: ConnectivityObserver
  private nonisolated(unsafe) var streamTask: Task<Void, Never>?
  private nonisolated(unsafe) var pingTask: Task<Void, Never>?
  private var sequenceNumber: Int64 = 0
  private var pendingRequests: [Int64: (sendTime: Date, encodeTime: TimeInterval, payloadSize: Int)] = [:]

  // MARK: - Initialization

  init(connectivityObserver: ConnectivityObserver) {
    self.connectivityObserver = connectivityObserver
    setupStreams()
  }

  deinit {
    streamTask?.cancel()
    pingTask?.cancel()
  }

  // MARK: - Setup

  private func setupStreams() {
    streamTask = Task { @MainActor in
      // Activate connectivity session
      do {
        try await connectivityObserver.activate()
        print("✅ Latency Dashboard: ConnectivityObserver activated")

        // Get initial reachability status
        isReachable = await connectivityObserver.isReachable()
        print("📡 Latency Dashboard: Initial reachability: \(isReachable)")
      } catch {
        print("❌ Latency Dashboard: Activation failed: \(error)")
      }

      // Listen for reachability changes
      Task { @MainActor in
        await consumeReachabilityChanges()
      }

      // Listen for latency replies
      await consumeLatencyReplies()
    }
  }

  private func consumeReachabilityChanges() async {
    for await reachable in await connectivityObserver.reachabilityUpdates() {
      self.isReachable = reachable
      print("📡 Latency Dashboard: Reachability changed to: \(reachable)")
    }
  }

  private func consumeLatencyReplies() async {
    print("👂 Latency: Started listening for typed messages")
    for await message in await connectivityObserver.typedMessageStream() {
      print("📨 Latency: Received typed message: \(type(of: message))")
      if let reply = message as? Sundial_Demo_LatencyTestReply {
        print("✅ Latency: Message is LatencyTestReply #\(reply.sequenceNumber)")
        handleLatencyReply(reply)
      } else {
        print("ℹ️ Latency: Message is not LatencyTestReply, ignoring")
      }
    }
  }

  // MARK: - Actions

  /// Start automated latency testing (pings every 2 seconds).
  func startLatencyTest() {
    guard !isRunning else { return }
    isRunning = true
    sequenceNumber = 0

    pingTask = Task { @MainActor in
      while !Task.isCancelled && isRunning {
        do {
          try await sendLatencyPing()
          try await Task.sleep(for: .seconds(2))
        } catch {
          print("❌ Latency ping error: \(error)")
        }
      }
    }
  }

  /// Stop automated latency testing.
  func stopLatencyTest() {
    isRunning = false
    pingTask?.cancel()
    pingTask = nil
  }

  /// Send a single latency ping.
  func sendLatencyPing() async throws {
    // Check reachability first
    let reachable = await connectivityObserver.isReachable()
    print("🔵 Latency: Current reachability status: \(reachable)")

    guard reachable else {
      print("❌ Latency: Cannot send ping - devices not reachable!")
      print("💡 Latency: Make sure both apps are in the foreground and Bluetooth is connected")
      throw ConnectivityError.notReachable
    }

    sequenceNumber += 1
    let sendTime = Date()
    print("🔵 Latency: Preparing to send ping #\(sequenceNumber)")

    let payloadSize: Int
    let payload: Data
    switch currentPayloadSize {
    case .small:
      payloadSize = 64
      payload = Data(repeating: 0, count: payloadSize)
    case .medium:
      payloadSize = 512
      payload = Data(repeating: 0, count: payloadSize)
    case .large:
      payloadSize = 4096
      payload = Data(repeating: 0, count: payloadSize)
    case .UNRECOGNIZED:
      payloadSize = 0
      payload = Data()
    }

    let request = Sundial_Demo_LatencyTestRequest.with {
      $0.sendTimestampMs = Int64(sendTime.timeIntervalSince1970 * 1000)
      $0.sequenceNumber = sequenceNumber
      $0.payloadSize = currentPayloadSize
      $0.payload = payload
    }

    let encodeStart = CFAbsoluteTimeGetCurrent()
    _ = try request.encode()
    let encodeTime = CFAbsoluteTimeGetCurrent() - encodeStart

    // Send the request
    let sendResult = try await connectivityObserver.send(request)
    print("📤 Sent latency ping #\(sequenceNumber) via \(sendResult.context)")

    // Store pending request info
    pendingRequests[sequenceNumber] = (sendTime: sendTime, encodeTime: encodeTime, payloadSize: payloadSize)
    print("💾 Stored pending request #\(sequenceNumber), total pending: \(pendingRequests.count)")
  }

  private func handleLatencyReply(_ reply: Sundial_Demo_LatencyTestReply) {
    print("📥 Received latency reply #\(reply.sequenceNumber)")

    // Find the pending request
    guard let pending = pendingRequests[reply.sequenceNumber] else {
      print("⚠️ Received reply for unknown sequence number: \(reply.sequenceNumber)")
      return
    }

    // Remove from pending
    pendingRequests.removeValue(forKey: reply.sequenceNumber)

    let receiveTime = Date()

    // Decode time is negligible for already-decoded protobuf, but we can estimate
    let decodeTime: TimeInterval = 0.0001  // Minimal time

    // Create measurement
    let measurement = LatencyTracker.Measurement(
      sequenceNumber: Int(reply.sequenceNumber),
      sendTime: pending.sendTime,
      receiveTime: receiveTime,
      transportMethod: .sendMessageData,
      payloadSize: pending.payloadSize,
      encodeTime: pending.encodeTime,
      decodeTime: decodeTime
    )

    latencyTracker.recordMeasurement(measurement)
  }
}
