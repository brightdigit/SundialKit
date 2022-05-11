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

enum InterfaceItem : Int, CaseIterable, Identifiable  {
      case cellular
      case wifi
      case wiredEthernet
      case other
      case loopback
  
  var id: Int {
    return self.rawValue
  }
  
  var systemName : String {
    switch self {
      
    case .cellular:
      return "antenna.radiowaves.left.and.right"
    case .wifi:
      return "wifi"
    case .wiredEthernet:
      return "cable.connector"
    case .other:
      return "questionmark"
    case .loopback:
      return "circle"
    }
  }
  
  static var allCases: [InterfaceItem] {
    [.wiredEthernet, .wifi, .cellular, .loopback, .other]
  }
}
//  public struct Interface: OptionSet {
//    public var rawValue: Int
//
//    public init(rawValue: RawValue) {
//      self.rawValue = rawValue
//    }
//
//    public typealias RawValue = Int
//
//    public static let cellular: Self = .init(rawValue: 1)
//    public static let wifi: Self = .init(rawValue: 2)
//    public static let wiredEthernet: Self = .init(rawValue: 4)
//    public static let other: Self = .init(rawValue: 8)
//    public static let loopback: Self = .init(rawValue: 16)
//  }

extension NWPathStatus  {
  var message : String {
    switch self {
      
    case .unsatisfied(_):
      
        return "Unsatisified"
    case .satisfied(_):
      return "Satisified"
    case .requiresConnection:
      return "Requires Connection"
    case .unknown:
      return "Unknown"
    }
  }
}

extension Set where Element == InterfaceItem {
  init (interface: NWPathStatus.Interface?) {
    guard let interface = interface else {
      self.init()
      return
    }

    let items = InterfaceItem.allCases.filter { item in
      item.rawValue & interface.rawValue != 0
    }
    
    self.init(items)
  }
}

class SundailObject: ObservableObject {
  let lastColorSendingSubject = PassthroughSubject<Color, Never>()

  @Published var lastColorReceived: Color = .secondary
  @Published var lastColorSentWaiting: Color = .secondary
  @Published var lastColorSentReplied: Color = .secondary
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
  
  @Published var interfaceItems: Set<InterfaceItem> = .init()
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
    
    lastColorSendingSubject.assignOnMain(to: &self.$lastColorSentWaiting)

    wcObject.messageReceivedPublisher.compactMap(receivedMessage(_:)).assignOnMain(to: &$lastColorReceived)
    
    
    nwObject.isConstrainedPublisher.assignOnMain(to: &self.$isConstrained)
    nwObject.isExpensivePublisher.assignOnMain(to: &self.$isExpensive)
    nwObject.pathStatusPublisher.assignOnMain(to: &self.$pathStatus)
    
    $pathStatus.share().map{ status -> NWPathStatus.Interface? in
      guard case let .satisfied(interface) = status else {
        return nil
      }
      return interface
    }.map(Set.init).assignOnMain(to: &self.$interfaceItems)
    
    $pathStatus.share().map{ status -> NWPathStatus.UnsatisfiedReason? in
      guard case let .unsatisfied(reason) = status else {
        return nil
      }
      return reason
    }.assignOnMain(to: &self.$unsatisfiedReason)

    let replyReceived = wcObject.replyMessagePublisher.tryCompactMap(receivedReply(_:))

    let (replyReceivedValue, replyReceivedError) = replyReceived.neverPublishers()

    replyReceivedError.map { $0 as Error? }.assignOnMain(to: &$lastError)

    replyReceivedValue.share().map { $0.0 }.assignOnMain(to: &$lastColorSentReplied)
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
