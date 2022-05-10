import Combine
import Foundation
import SundialKit
import SwiftUI
import WatchConnectivity
import Network

struct NeverPing : NetworkPing {
  private init () {}
  var timeInterval: TimeInterval {
    .nan
  }
  
  func onPing(_ closure: @escaping (Result<Never, Never>) -> Void) {
    
  }
  
  typealias StatusType = Never
  
  
}

class SundailObject: ObservableObject {
  let lastColorSendingSubject = PassthroughSubject<Color, Never>()

  @Published var lastColorReceived: Color = .secondary
  @Published var lastColorSent: Color = .secondary
  @Published var lastColorReply: Color = .secondary
  @Published var wcObject = WCObject()
  @Published var nwObject = NWObject<NWPathMonitor, NeverPing>(monitor: NWPathMonitor(), ping: nil)
  #if os(iOS)
    @Published var isPaired = false
  #endif

  @Published var isReachable = false
  @Published var isCompanionAppInstalled = false
  @Published var activationState = ActivationState.notActivated
  @Published var lastError: Error?
  
  @Published var interface: NWPathStatus.Interface? = nil
  @Published var unsatisfiedReason : NWPathStatus.UnsatisfiedReason? = nil
  @Published var isConstrained : Bool = false
  @Published var isExpensive : Bool = false
  @Published var pathStatus : NWPathStatus = .unknown

  var cancellables = [AnyCancellable]()

  public func forceActivate() {
    try! wcObject.activate()
  }

  func sendColor(_ color: Color) {
    lastColorSendingSubject.send(color)
  }

  init() {
    wcObject.activationStatePublisher.assignOnMain(to: &$activationState)
    wcObject.isReachablePublisher.assignOnMain(to: &$isReachable)

    wcObject.isPairedAppInstalledPublisher.assignOnMain(to: &$isCompanionAppInstalled)

    #if os(iOS)
      wcObject.isPairedPublisher.assignOnMain(to: &$isPaired)
    #endif

    lastColorSendingSubject.share().compactMap(WCMessage.message(fromColor:)).subscribe(wcObject.sendingMessageSubject).store(in: &cancellables)

    wcObject.messageReceivedPublisher.compactMap(receivedMessage(_:)).assignOnMain(to: &$lastColorReceived)
    
    
    nwObject.isConstrainedPublisher.assignOnMain(to: &self.$isConstrained)
    nwObject.isExpensivePublisher.assignOnMain(to: &self.$isExpensive)
    nwObject.pathStatusPublisher.assignOnMain(to: &self.$pathStatus)
    
    $pathStatus.share().map{ status -> NWPathStatus.Interface? in
      guard case let .satisfied(interface) = status else {
        return nil
      }
      return interface
    }.assignOnMain(to: &self.$interface)
    
    $pathStatus.share().map{ status -> NWPathStatus.UnsatisfiedReason? in
      guard case let .unsatisfied(reason) = status else {
        return nil
      }
      return reason
    }.assignOnMain(to: &self.$unsatisfiedReason)

    let replyReceived = wcObject.replyMessagePublisher.tryCompactMap(receivedReply(_:))

    let (replyReceivedValue, replyReceivedError) = replyReceived.neverPublishers()

    replyReceivedError.map { $0 as Error? }.assignOnMain(to: &$lastError)

    replyReceivedValue.share().map { $0.0 }.assignOnMain(to: &$lastColorSent)
    replyReceivedValue.share().compactMap { $0.1 }.assignOnMain(to: &$lastColorReply)
  }

  func receivedReply(_ messageResult: WCMessageResult) throws -> (Color, Color?)? {
    let (sent, context) = messageResult
    let reply: WCMessage?
    switch context {
    case .applicationContext:
      reply = nil

    case let .reply(messageReply):
      reply = messageReply

    case let .failure(error):
      throw error
    }
    guard let sentColor = sent.color else {
      return nil
    }

    let replyColor = reply?.color
    return (sentColor, replyColor)
  }

  func receivedMessage(_ messageAcceptance: WCMessageAcceptance) -> Color? {
    let (message, context) = messageAcceptance
    let replyHandler = context.replyHandler
    guard let color = message.color else {
      return nil
    }
    replyHandler?(message)
    // print("Recv Updated: \(String(colorValue, radix: 16, uppercase: true))")
    // lastColorReceivedSubject.send(color)
    return color
  }
}
