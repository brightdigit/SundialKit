enum MockError<T: Equatable>: Error, Equatable {
  case value(T)
}
