public protocol NetworkPath {
  var isConstrained: Bool { get }
  var isExpensive: Bool { get }
  var pathStatus: PathStatus { get }
}
