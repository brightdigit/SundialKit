import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension PassthroughSubject {
  func anyPublisher<T>(for keyPath: KeyPath<Output, T>) -> AnyPublisher<T, Failure> {
    map(keyPath).eraseToAnyPublisher()
  }
}
