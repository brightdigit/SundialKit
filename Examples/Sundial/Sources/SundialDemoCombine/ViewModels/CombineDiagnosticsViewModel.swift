import Combine
import Foundation
import Observation
import SundialDemoShared
import SundialKitCombine
import SundialKitConnectivity
import SundialKitCore

/// ViewModel for the Diagnostics tab in SundialDemoCombine.
/// Monitors connection health, message history, and error logs.
@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
@Observable
@MainActor
final class CombineDiagnosticsViewModel {
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
  private var cancellables = Set<AnyCancellable>()

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

  // MARK: - Monitoring

  func startMonitoring() {
    // Activate connectivity session
    do {
      try connectivityObserver.activate()
      logInfo("ConnectivityObserver activated successfully")
    } catch {
      logError(error)
    }

    // Subscribe to activation state changes
    connectivityObserver.$activationState
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in
        self?.activationState = state
        self?.lastUpdate = Date()
      }
      .store(in: &cancellables)

    // Subscribe to reachability changes
    connectivityObserver.$isReachable
      .receive(on: DispatchQueue.main)
      .sink { [weak self] reachable in
        self?.isReachable = reachable
        self?.lastUpdate = Date()
      }
      .store(in: &cancellables)

    // Subscribe to paired app status changes
    connectivityObserver.$isPairedAppInstalled
      .receive(on: DispatchQueue.main)
      .sink { [weak self] installed in
        self?.isPairedAppInstalled = installed
      }
      .store(in: &cancellables)

    // Subscribe to message received events
    connectivityObserver.messageReceived
      .receive(on: DispatchQueue.main)
      .sink { [weak self] result in
        let message = result.message
        let size = (try? JSONSerialization.data(withJSONObject: message))?.count ?? 0
        self?.logMessageReceived(size: size)
      }
      .store(in: &cancellables)
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
