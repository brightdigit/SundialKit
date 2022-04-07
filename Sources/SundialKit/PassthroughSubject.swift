import Combine

extension PassthroughSubject {
  func anyPublisher<T>(for keyPath: KeyPath<Output, T>) -> AnyPublisher<T, Failure> {
    map(keyPath).eraseToAnyPublisher()
  }
}
