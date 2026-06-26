//
//  StreamContextLabModel.swift
//  Sundial
//
//  Drives the "Context Sync" demo's ``ContextEngine`` — reliable, revisioned,
//  heartbeated latest-wins snapshot sync over WatchConnectivity's application
//  context.
//
//  Copyright (c) 2026 BrightDigit.
//

#if os(iOS) || os(watchOS)
  import Foundation
  import Observation
  import SundialDemoShared
  import SundialKitConnectivity
  import SundialKitContext
  import SundialKitStream
  import SwiftUI

  /// Drives a ``ContextEngine`` that syncs the locally selected color to the paired
  /// device and reflects the counterpart's latest color back into the UI.
  ///
  /// `@Observable` so SwiftUI tracks both this model and the engine's published
  /// `isReachable` / `isPairedAppInstalled` / error state through the computed
  /// accessors below.
  @available(iOS 18.0, watchOS 11.0, *)
  @MainActor
  @Observable
  internal final class StreamContextLabModel {
    /// The color this device wants the counterpart to display.
    internal var selectedColor: Color = .blue

    /// The most recent color received from the counterpart.
    internal private(set) var peerColor: Color?
    /// When the counterpart color last arrived.
    internal private(set) var peerUpdatedAt: Date?
    /// The revision stamped on the most recent inbound snapshot.
    internal private(set) var peerRevision: UInt64?

    private var engine: ContextEngine<ColorSnapshot, ColorSnapshot>?

    /// Whether the counterpart app is reachable for immediate delivery.
    internal var isReachable: Bool { engine?.isReachable ?? false }
    /// Whether the paired device has the counterpart app installed.
    internal var isPairedAppInstalled: Bool { engine?.isPairedAppInstalled ?? false }

    /// A human-readable description of the latest error, if any. Activation errors
    /// take precedence — they require recreating the engine, not just retrying.
    internal var statusError: String? {
      if let error = engine?.lastActivationError {
        return "Activation failed: \(error.localizedDescription)"
      }
      if let error = engine?.lastSendError {
        return "Send failed: \(error.localizedDescription)"
      }
      return nil
    }

    /// Creates the engine (once), then subscribes, activates, and starts the
    /// heartbeat. Safe to call repeatedly — only the first call does work.
    internal func start() async {
      guard engine == nil else {
        return
      }

      let observer = ConnectivityObserver(
        messageDecoder: MessageDecoder(messagableTypes: [ColorSnapshot.self])
      )

      let engine = ContextEngine<ColorSnapshot, ColorSnapshot>(
        observer: observer,
        heartbeat: .seconds(3),
        reassertOnReachable: true,
        makeOutbound: { [weak self] revision in
          guard let self else {
            // The model owns the engine, so the engine never outlives `self` and
            // this closure is only invoked while `self` is alive. The fallback is
            // unreachable; assert to surface any future ownership regression.
            assertionFailure("makeOutbound invoked after StreamContextLabModel was deallocated")
            return ColorSnapshot(red: 0, green: 0, blue: 0, alpha: 0, revision: revision)
          }
          return self.makeSnapshot(revision: revision)
        },
        onInbound: { [weak self] snapshot in
          self?.apply(snapshot)
        }
      )

      self.engine = engine
      await engine.start()
    }

    /// Stops the engine's stream and heartbeat tasks.
    internal func stop() {
      engine?.stop()
    }

    /// Re-sends the current color after a manual change, stamped with a fresh
    /// revision so the latest-wins context update is never deduped.
    internal func colorChanged() {
      engine?.assertNow()
    }

    private func makeSnapshot(revision: UInt64) -> ColorSnapshot {
      let components = selectedColor.rgbaComponents
      return ColorSnapshot(
        red: components.red,
        green: components.green,
        blue: components.blue,
        alpha: components.alpha,
        revision: revision
      )
    }

    private func apply(_ snapshot: ColorSnapshot) {
      peerColor = Color(
        components: .init(
          red: snapshot.red,
          green: snapshot.green,
          blue: snapshot.blue,
          alpha: snapshot.alpha
        )
      )
      peerUpdatedAt = Date()
      peerRevision = snapshot.revision
    }
  }
#endif
