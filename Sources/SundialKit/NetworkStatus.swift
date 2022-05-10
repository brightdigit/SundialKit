public enum NetworkStatus: String, CaseIterable {
  public struct NetworkDetails {
    let interface: NWPathStatus.Interface
    let isExpensive: Bool
    let isConstrained: Bool
  }

  case success
  case poor
  case prepared
  case unauthorized
  case denied
  case disconnected
  case clientFailure
  case serverFailure
  case unknownFailure
}
