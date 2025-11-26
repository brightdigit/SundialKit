//
// WatchConnectivitySessionProtocol.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(WatchConnectivity)

  import WatchConnectivity
  internal typealias WatchConnectivitySessionProtocol =
    ConnectivitySession & WCSessionDelegate
#endif
