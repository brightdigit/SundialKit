//
// ConnectivityActivation.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(WatchConnectivity)
  public import Foundation
  public import SundialKitCore

  /// Protocol for types that support connectivity session activation.
  ///
  /// This protocol defines the interface for activating connectivity sessions,
  /// including both synchronous and asynchronous activation patterns with timeout support.
  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  public protocol ConnectivityActivation {
    /// The underlying connectivity session.
    nonisolated var session: any ConnectivitySession { get }

    /// The current activation state of the connectivity session.
    var activationState: ActivationState { get async }

    /// Storage for activation continuation during async activation.
    var activationContinuation: CheckedContinuation<Void, any Error>? { get async }

    /// Storage for activation timeout task.
    var activationTimeoutTask: Task<Void, Never>? { get async }

    /// Activates the connectivity session synchronously.
    ///
    /// - Throws: `ConnectivityError` if activation fails.
    func activate() throws

    /// Sets the activation continuation.
    ///
    /// - Parameter continuation: The continuation to store.
    func setActivationContinuation(_ continuation: CheckedContinuation<Void, any Error>) async

    /// Sets the activation timeout task.
    ///
    /// - Parameter task: The timeout task to store.
    func setActivationTimeoutTask(_ task: Task<Void, Never>) async

    /// Handles activation timeout by resuming the stored continuation with an error.
    func handleActivationTimeout() async

    /// Handles activation errors by resuming the stored continuation.
    ///
    /// - Parameter error: The error that occurred during activation.
    func handleActivationError(_ error: any Error) async
  }
#endif
