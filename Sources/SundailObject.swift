import Combine
import Foundation
import SundialKit
import SwiftUI
import WatchConnectivity
import Network


struct IpifyPing : NetworkPing {
  public func shouldPing(onStatus status: NWPathStatus) -> Bool {
    switch status {
    case .unknown, .unsatisfied:
      return false
    case .requiresConnection, .satisfied:
      return true
    }
  }
  
  let session: URLSession
  let timeInterval: TimeInterval
  
  static let url : URL = .init(string: "https://api.ipify.org")!
  
  func onPing(_ closure: @escaping (String?) -> Void) {
    session.dataTask(with: IpifyPing.url) { data, _, _ in
      closure(data.flatMap{String(data: $0, encoding: .utf8)})
    }.resume()
  }
  
  typealias StatusType = String?
  
  
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
  @Published var nwObject = NWObject<NWPathMonitor, IpifyPing>(monitor: NWPathMonitor(), ping: IpifyPing(session: .shared, timeInterval: 10.0))
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
  @Published var pingStatus : Bool? = nil
  @Published var nwDate : Date? = nil
  @Published var nwQuality : Double = 0

  var cancellables = [AnyCancellable]()

  public func forceActivate() {
    nwObject.start(queue: .global())
    try! wcObject.activate()
  }

  func sendColor(_ color: Color) {
    lastColorSendingSubject.send(color)
  }
  
  static func qualityScore(pathStatus: NWPathStatus,pingStatus: Bool?,  isConstrained: Bool, isExpensive: Bool) -> Double {
    var value = 1.0
    switch pathStatus {
    case .unsatisfied(_), .unknown:
      return 0
    case .satisfied(let interface):
      if !interface.contains(.wiredEthernet) && !interface.contains(.wifi) {
        value *= 0.75
      }
    case .requiresConnection:
      value *= 0.5
    }
    
    if pingStatus != true {
      value *= 0.9
    }
    
    if isConstrained {
      value *= 0.5
    }
    
    if isExpensive {
      value *= 0.5
    }
    return value
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
    nwObject.pingStatusPublisher.map{ $0 != nil }.assignOnMain(to: &self.$pingStatus)
    
    
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
    
    
    Publishers.CombineLatest4(
      $pathStatus.share(),
      $pingStatus.share(),
      $isConstrained.share(),
      $isExpensive.share()
    ).map(Self.qualityScore)
      .assignOnMain(to: &$nwQuality)
    
    $pathStatus.share().combineLatest(self.$pingStatus.share()).map{ _ in Date() as Date? }.assignOnMain(to: &self.$nwDate)

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
