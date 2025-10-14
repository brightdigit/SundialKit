//
//  ConnectivityManagement.swift
//  SundialKit
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

public import Foundation

/// A type alias for messages exchanged via WatchConnectivity.
///
/// Represents the dictionary-based message format required by WatchConnectivity.
/// Messages must contain only property list types (String, Number, Date, Data, Array, Dictionary).
public typealias ConnectivityMessage = [String: Any]

/// A protocol for managing connectivity between iOS and watchOS devices.
///
/// Types conforming to `ConnectivityManagement` provide the ability to establish
/// and maintain communication sessions between an iPhone and Apple Watch, send messages,
/// and monitor connection state. This protocol serves as the foundation for various
/// reactive implementations of WatchConnectivity.
///
/// ## Topics
///
/// ### Session State
/// - ``activationState``
/// - ``isReachable``
/// - ``isPaired``
/// - ``isPairedAppInstalled``
///
/// ### Lifecycle
/// - ``activate()``
///
/// ### Messaging
/// - ``sendMessage(_:replyHandler:errorHandler:)``
/// - ``updateApplicationContext(_:)``
///
/// ## Platform Availability
///
/// WatchConnectivity is available on iOS and watchOS. Some properties like ``isPaired``
/// are specific to iOS and will be unavailable on other platforms.
///
/// ## Example Usage
///
/// Basic connectivity management:
///
/// ```swift
/// class BasicConnectivityManager: ConnectivityManagement {
///     var activationState: ActivationState = .notActivated
///     var isReachable: Bool = false
///     var isPairedAppInstalled: Bool = false
///
///     #if os(iOS)
///     var isPaired: Bool = false
///     #endif
///
///     func activate() throws {
///         // Activate the session
///     }
///
///     func sendMessage(
///         _ message: ConnectivityMessage,
///         replyHandler: @escaping (ConnectivityMessage) -> Void,
///         errorHandler: @escaping (Error) -> Void
///     ) {
///         // Send message to counterpart
///     }
///
///     func updateApplicationContext(_ context: ConnectivityMessage) throws {
///         // Update application context
///     }
/// }
/// ```
public protocol ConnectivityManagement {
  /// The current activation state of the connectivity session.
  ///
  /// This property indicates whether the session is ready for communication:
  /// - `.notActivated`: Session has not been activated yet
  /// - `.inactive`: Session is transitioning to deactivated state
  /// - `.activated`: Session is active and ready for communication
  ///
  /// You must activate the session before sending messages.
  ///
  /// - SeeAlso: ``ActivationState``
  var activationState: ActivationState { get }

  /// Indicates whether the counterpart device is currently reachable.
  ///
  /// A counterpart is reachable when:
  /// - The counterpart app is running in the foreground
  /// - Both devices are within Bluetooth range
  /// - The session is activated
  ///
  /// When `true`, you can send messages using ``sendMessage(_:replyHandler:errorHandler:)``
  /// and expect immediate delivery. When `false`, use ``updateApplicationContext(_:)``
  /// to queue data for delivery when the counterpart becomes available.
  var isReachable: Bool { get }

  /// Indicates whether the companion app is installed on the paired device.
  ///
  /// - On iOS: Returns `true` if the watchOS app is installed on the paired Apple Watch
  /// - On watchOS: Returns `true` if the iOS app is installed on the paired iPhone
  ///
  /// Use this property to determine whether ``updateApplicationContext(_:)`` will
  /// successfully deliver messages when the counterpart is not reachable.
  var isPairedAppInstalled: Bool { get }

  #if os(iOS)
    /// Indicates whether an Apple Watch is currently paired with this iPhone.
    ///
    /// This property is only available on iOS. Returns `true` if an Apple Watch
    /// is paired with the device, regardless of whether the companion app is installed.
    ///
    /// - Note: This property is unavailable on watchOS, tvOS, and macOS.
    var isPaired: Bool { get }
  #endif

  /// Activates the connectivity session.
  ///
  /// Call this method to begin using WatchConnectivity. The session must be activated
  /// before you can send or receive messages. Activation is asynchronous; monitor
  /// ``activationState`` to determine when the session is ready.
  ///
  /// - Throws: An error if the session cannot be activated, such as when
  ///   WatchConnectivity is not supported on the current platform.
  ///
  /// ## Example
  ///
  /// ```swift
  /// do {
  ///     try connectivityManager.activate()
  ///     // Monitor activationState for completion
  /// } catch {
  ///     print("Failed to activate: \(error)")
  /// }
  /// ```
  func activate() throws

  /// Sends a message to the counterpart device with optional reply handling.
  ///
  /// Use this method for interactive, real-time messaging when ``isReachable`` is `true`.
  /// The message is delivered immediately and the counterpart can send a reply.
  ///
  /// - Parameters:
  ///   - message: A dictionary containing the message data. Must contain only
  ///     property list types.
  ///   - replyHandler: Called when the counterpart sends a reply. Invoked on
  ///     a background thread.
  ///   - errorHandler: Called if the message fails to send or the counterpart
  ///     doesn't reply in time. Invoked on a background thread.
  ///
  /// - Important: This method should only be called when ``isReachable`` is `true`.
  ///   For queued delivery, use ``updateApplicationContext(_:)`` instead.
  ///
  /// ## Example
  ///
  /// ```swift
  /// if connectivityManager.isReachable {
  ///     let message: ConnectivityMessage = ["action": "ping", "timestamp": Date()]
  ///     connectivityManager.sendMessage(
  ///         message,
  ///         replyHandler: { reply in
  ///             print("Received reply: \(reply)")
  ///         },
  ///         errorHandler: { error in
  ///             print("Send failed: \(error)")
  ///         }
  ///     )
  /// }
  /// ```
  func sendMessage(
    _ message: ConnectivityMessage,
    replyHandler: @escaping (ConnectivityMessage) -> Void,
    errorHandler: @escaping (any Error) -> Void
  )

  /// Updates the application context with new data.
  ///
  /// Use this method to send data that should be available to the counterpart
  /// even when it's not currently reachable. The system delivers the latest
  /// context when the counterpart app launches or becomes active.
  ///
  /// Only the most recent context is preserved; calling this method multiple times
  /// replaces the previous context rather than queuing multiple messages.
  ///
  /// - Parameter context: A dictionary containing the context data. Must contain
  ///   only property list types.
  ///
  /// - Throws: An error if the context cannot be updated, such as when the session
  ///   is not activated or the counterpart app is not installed.
  ///
  /// - Important: Check ``isPairedAppInstalled`` before calling this method to
  ///   ensure the counterpart can receive the context.
  ///
  /// ## Example
  ///
  /// ```swift
  /// if connectivityManager.isPairedAppInstalled {
  ///     let context: ConnectivityMessage = ["lastSync": Date(), "count": 42]
  ///     try connectivityManager.updateApplicationContext(context)
  /// }
  /// ```
  func updateApplicationContext(_ context: ConnectivityMessage) throws
}
