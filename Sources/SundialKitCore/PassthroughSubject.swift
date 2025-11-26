//
// PassthroughSubject.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(Combine)
  public import Combine

  extension PassthroughSubject {
    /// Creates a publisher that emits values from a specific key path of the subject's output.
    ///
    /// - Parameter keyPath: A key path to a property of the output type.
    /// - Returns: A type-erased publisher that emits values from the specified key path.
    public func anyPublisher<T>(
      for keyPath: KeyPath<Output, T>
    ) -> AnyPublisher<T, Failure> {
      map(keyPath).eraseToAnyPublisher()
    }
  }
#endif
