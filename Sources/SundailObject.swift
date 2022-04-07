import Combine
import Foundation
import SundialKit
import SwiftUI
import WatchConnectivity

class SundailObject: ObservableObject {
  let lastColorSendingSubject = PassthroughSubject<Color, Never>()

  @Published var lastColorReceived: Color = .secondary
  @Published var lastColorSent: Color = .secondary
  @Published var lastColorReply: Color = .secondary
  @Published var wcObject = WCObject()

  #if os(iOS)
    @Published var isPaired = false
  #endif

  @Published var isReachable = false
  @Published var isCompanionAppInstalled = false
  @Published var activationState = WCSessionActivationState.notActivated
  @Published var lastError: Error?

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

    case .noCompanion:
      throw MissingCompanionError()
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
