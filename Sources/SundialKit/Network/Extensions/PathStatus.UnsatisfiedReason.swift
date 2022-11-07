import Foundation
#if canImport(Network)
  import Network

  @available(macOS 11.0, iOS 14.2, watchOS 7.1, tvOS 14.2, *)
  public extension PathStatus.UnsatisfiedReason {
    /// Creates `UnsatisfiedReason` from a `Network` one.
    /// - Parameter reason: The `UnsatisfiedReason` from the `Network` API.
    init(_ reason: NWPath.UnsatisfiedReason) {
      switch reason {
      case .notAvailable:
        self = .notAvailable

      case .cellularDenied:
        self = .cellularDenied

      case .wifiDenied:
        self = .wifiDenied

      case .localNetworkDenied:
        self = .localNetworkDenied
      @unknown default:
        self = .unknown
      }
    }
  }
#endif
