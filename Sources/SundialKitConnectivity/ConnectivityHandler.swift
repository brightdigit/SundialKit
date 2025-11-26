//
// ConnectivityHandler.swift
// Copyright (c) 2025 BrightDigit.
//

public import SundialKitCore

/// Handles a message received.
public typealias ConnectivityHandler = @Sendable (ConnectivityMessage) -> Void
