//
//  NetworkObserver+Init.swift
//  SundialKitStream
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

public import SundialKitNetwork

// MARK: - Convenience Initializers
@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
extension NetworkObserver where PingType == NeverPing {
  /// Creates `NetworkObserver` without ping
  public init(monitor: MonitorType) {
    self.init(monitor: monitor, pingOrNil: nil)
  }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
extension NetworkObserver {
  /// Creates `NetworkObserver` with ping
  public init(monitor: MonitorType, ping: PingType) {
    self.init(monitor: monitor, pingOrNil: ping)
  }
}

#if canImport(Network)
  public import Network

  @available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
  extension NetworkObserver where MonitorType == NWPathMonitor, PingType == NeverPing {
    /// Creates `NetworkObserver` with default `NWPathMonitor` and no ping
    ///
    /// This is the simplest way to create a network observer for most use cases.
    /// The observer uses Apple's `NWPathMonitor` to track network connectivity
    /// changes without ping-based verification.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// import SundialKitStream
    ///
    /// let observer = NetworkObserver()
    /// await observer.start(queue: .global())
    ///
    /// for await status in observer.pathStatusStream {
    ///   print("Network status: \(status)")
    /// }
    /// ```
    public init() {
      self.init(monitor: NWPathMonitor(), pingOrNil: nil)
    }
  }
#endif
