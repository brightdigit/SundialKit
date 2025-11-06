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

  init(connectivityObserver: ConnectivityObserver? = nil) {
    #if os(iOS) || os(watchOS)
      self.connectivityObserver =
        connectivityObserver
        ?? ConnectivityObserver(
          messageDecoder: MessageDecoder(messagableTypes: [
            Sundial_Demo_ColorMessage.self,
            Sundial_Demo_ComplexMessage.self,
            Sundial_Demo_LatencyTestRequest.self,
            Sundial_Demo_LatencyTestReply.self,
          ])
        )
    #else
      self.connectivityObserver = connectivityObserver ?? Self.createMacOSObserver()
    #endif
    setupStreams()
  }

  #if !os(iOS) && !os(watchOS)
    private static func createMacOSObserver() -> ConnectivityObserver {
      fatalError(
        "ConnectivityObserver must be explicitly provided on macOS. Create it with: ConnectivityObserver(session: NeverConnectivitySession(), messageDecoder: ...)"
      )
    }
  #endif

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
      } catch {
        print("❌ Latency Dashboard: Activation failed: \(error)")
      }

      // Listen for latency replies
      await consumeLatencyReplies()
    }
  }

  private func consumeLatencyReplies() async {
    for await message in await connectivityObserver.typedMessageStream() {
      if let reply = message as? Sundial_Demo_LatencyTestReply {
        handleLatencyReply(reply)
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
    sequenceNumber += 1
    let sendTime = Date()

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
    _ = try await connectivityObserver.send(request)

    // Store pending request info
    pendingRequests[sequenceNumber] = (sendTime: sendTime, encodeTime: encodeTime, payloadSize: payloadSize)

    print("📤 Sent latency ping #\(sequenceNumber)")
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
