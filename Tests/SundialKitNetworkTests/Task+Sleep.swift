//
//  Task+Sleep.swift
//  SundialKit
//
//  Created by Leo Dion on 10/24/25.
//

extension Task where Success == Never, Failure == Never {
  /// Suspends the current task for the given duration.
  /// - Parameter duration: The duration to sleep for.
  internal static func sleep(forMilliseconds milliseconds: UInt64) async throws {
    if #available(watchOS 9.0, *) {
      try await self.sleep(for: .milliseconds(milliseconds))
    } else {
      try await self.sleep(nanoseconds: milliseconds * 1_000_000)
    }
  }
}
