public protocol NWPathable {
  var isConstrained: Bool { get }
  var isExpensive: Bool { get }
  var pathStatus: NWPathStatus { get }
}
