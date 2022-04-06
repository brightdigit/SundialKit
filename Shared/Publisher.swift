import Combine
import Foundation

extension Publisher {
  func assignOnMain(to published: inout Published<Self.Output>.Publisher) where Self.Failure == Never {
    receive(on: DispatchQueue.main).assign(to: &published)
  }

  func assignOnMain<OutputType>(_ keyPath: KeyPath<Self.Output, OutputType>, to published: inout Published<OutputType>.Publisher) where Self.Failure == Never {
    map(keyPath).assign(to: &published)
  }

  func neverPublishers() -> (AnyPublisher<Output, Never>, AnyPublisher<Failure, Never>) {
    let failurePublisher = share().map { _ in nil as Failure? }.catch { error in
      Just(error)
    }.compactMap { $0 }.eraseToAnyPublisher()

    let successPublisher = share().map { $0 as Output? }.replaceError(with: nil).compactMap { $0 }.eraseToAnyPublisher()

    return (successPublisher, failurePublisher)
  }
}
