//
// MockError.swift
// Copyright (c) 2025 BrightDigit.
//

internal enum MockError<T: Equatable & Sendable>: Error, Equatable {
  case value(T)
}
