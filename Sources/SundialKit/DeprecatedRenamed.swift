import Foundation

#if canImport(Combine)
  @available(iOS 14.2, watchOS 7.1, macOS 11.0, *)
  @available(*, deprecated, renamed: "NetworkObject")
  public typealias NWObject = NetworkObserver

  @available(macOS 10.15, *)
  @available(*, deprecated, renamed: "ConnectivityObserver")
  public typealias WCObject = ConnectivityObserver
#endif

@available(*, deprecated, renamed: "PathStatus")
public typealias NWPathStatus = PathStatus

@available(*, deprecated, renamed: "ConnectivityMessage")
public typealias WCMessage = ConnectivityMessage

@available(*, deprecated, renamed: "ConnectivitySendResult")
public typealias WCMessageResult = ConnectivitySendResult

@available(*, deprecated, renamed: "ConnectivityReceiveResult")
public typealias WCMessageAcceptance = ConnectivityReceiveResult
