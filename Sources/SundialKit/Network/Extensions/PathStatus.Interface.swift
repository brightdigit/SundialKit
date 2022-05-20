public protocol Interfaceable {
  var typeValue: Int { get }
}

@available(macOS 10.14, *)
public extension PathStatus.Interface {
  init(interfaces: [Interfaceable]) {
    let rawValue = interfaces.map(\.typeValue).reduce(0, +)
    self.init(rawValue: rawValue)
  }
}
