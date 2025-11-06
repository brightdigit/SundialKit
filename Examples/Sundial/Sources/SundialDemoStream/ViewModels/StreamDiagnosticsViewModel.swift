import Foundation
import Observation
import SundialDemoShared
import SundialKitConnectivity
import SundialKitCore
import SundialKitStream

/// ViewModel for the Diagnostics tab in SundialDemoStream.
/// Monitors connection health, message history, and error logs.
@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
@Observable
@MainActor
final class StreamDiagnosticsViewModel {
  // MARK: - Published State

  var messageHistory: [MessageHistoryEntry] = []
  var errorLog: [ErrorEntry] = []
  var activationState: ActivationState = .notActivated
  var isReachable: Bool = false
  var isPairedAppInstalled: Bool = false
  var messagesSent: Int = 0
  var messagesReceived: Int = 0
  var lastUpdate: Date = Date()

  // MARK: - Computed Properties

  var successRate: Double {
    let total = messagesSent
    guard total > 0 else { return 0 }
    let successful = messageHistory.filter { $0.success }.count
    return Double(successful) / Double(total) * 100
  }

  var activationStateString: String {
    switch activationState {
    case .notActivated:
      "Not Activated"
    case .inactive:
      "Inactive"
    case .activated:
      "Activated"
    @unknown default:
      "Unknown"
    }
  }

  // MARK: - Dependencies

  private let connectivityObserver: ConnectivityObserver
  private nonisolated(unsafe) var streamTask: Task<Void, Never>?

  // MARK: - Constants

  private let maxHistoryEntries = 50
  private let maxErrorEntries = 20

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
    startMonitoring()
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
  }

  // MARK: - Monitoring

  func startMonitoring() {
    streamTask = Task { @MainActor in
      // Activate connectivity session
      do {
        try await connectivityObserver.activate()
        logInfo("ConnectivityObserver activated successfully")
      } catch {
        logError(error)
      }

      // Start consuming all streams concurrently
      await withTaskGroup(of: Void.self) { group in
        // Stream 1: Activation state
        group.addTask {
          await self.consumeActivationState()
        }

        // Stream 2: Reachability
        group.addTask {
          await self.consumeReachability()
        }

        // Stream 3: Raw messages
        group.addTask {
          await self.consumeRawMessages()
        }
      }

      // Get paired app status once (not a stream)
      isPairedAppInstalled = await connectivityObserver.isPairedAppInstalled()
    }
  }

  private func consumeActivationState() async {
    for await state in await connectivityObserver.activationStates() {
      activationState = state
      lastUpdate = Date()
    }
  }

  private func consumeReachability() async {
    for await reachable in await connectivityObserver.reachabilityUpdates() {
      isReachable = reachable
      lastUpdate = Date()
    }
  }

  private func consumeRawMessages() async {
    for await result in await connectivityObserver.messageStream() {
      let message = result.message
      let size = (try? JSONSerialization.data(withJSONObject: message))?.count ?? 0

      logMessageReceived(size: size)
    }
  }

  // MARK: - Logging

  func logMessageSent(method: TransportMethod, size: Int, success: Bool, rtt: TimeInterval? = nil) {
    let entry = MessageHistoryEntry(
      method: method,
      size: size,
      rtt: rtt,
      success: success
    )

    messageHistory.insert(entry, at: 0)
    if messageHistory.count > maxHistoryEntries {
      messageHistory.removeLast()
    }

    if success {
      messagesSent += 1
    }
  }

  func logMessageReceived(size: Int) {
    messagesReceived += 1
  }

  func logError(_ error: any Error) {
    let entry = ErrorEntry(
      description: error.localizedDescription,
      severity: .error
    )
    errorLog.insert(entry, at: 0)
    if errorLog.count > maxErrorEntries {
      errorLog.removeLast()
    }
  }

  func logInfo(_ message: String) {
    let entry = ErrorEntry(
      description: message,
      severity: .info
    )
    errorLog.insert(entry, at: 0)
    if errorLog.count > maxErrorEntries {
      errorLog.removeLast()
    }
  }

  func clearHistory() {
    messageHistory.removeAll()
    errorLog.removeAll()
    messagesSent = 0
    messagesReceived = 0
  }
}
