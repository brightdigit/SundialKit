internal enum MockError<T: Equatable & Sendable>: Error, Equatable {
  case value(T)
}
