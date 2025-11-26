//
// NWPathMonitor.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(Network)
  public import Network

  extension NWPathMonitor: PathMonitor {
    /// Sets the handler to be called when the network path changes.
    ///
    /// - Parameter handler: The closure to call with the new network path
    public func onPathUpdate(_ handler: @escaping @Sendable (NWPath) -> Void) {
      pathUpdateHandler = handler
    }
  }

#endif
