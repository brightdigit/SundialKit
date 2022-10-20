/// Defines an object which can be used as a path interface.
internal protocol Interfaceable {
  /// Integer value which matches the `PathStatus.Interface` values.
  var typeValue: Int { get }
}
