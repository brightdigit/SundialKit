//
// Task+Sleep.swift
// Copyright (c) 2025 BrightDigit.
//

extension Task where Success == Never, Failure == Never {
  /// Suspends the current task for the given duration.
  /// - Parameter milliseconds: The duration to sleep for.
  /// - Throws: `CancellationError` if the task is cancelled during sleep.
  package static func sleep(forMilliseconds milliseconds: UInt64) async throws {
    if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
      try await self.sleep(for: .milliseconds(milliseconds))
    } else {
      try await self.sleep(nanoseconds: milliseconds * 1_000_000)
    }
  }
}
