//
//  StreamContextLabView.swift
//  Sundial
//
//  Demonstrates SundialKitStreamContext's `ContextEngine` — reliable, revisioned,
//  heartbeated latest-wins snapshot sync over WatchConnectivity's application
//  context.
//
//  Copyright (c) 2026 BrightDigit.
//

import Observation
import SundialDemoShared
import SundialKitConnectivity
import SundialKitStream
import SundialKitStreamContext
import SwiftUI

// MARK: - Model

/// Drives a ``ContextEngine`` that syncs the locally selected color to the paired
/// device and reflects the counterpart's latest color back into the UI.
///
/// `@Observable` so SwiftUI tracks both this model and the engine's published
/// `isReachable` / `isPairedAppInstalled` / error state through the computed
/// accessors below.
@available(iOS 18.0, watchOS 11.0, *)
@MainActor
@Observable
final class StreamContextLabModel {
  /// The color this device wants the counterpart to display.
  var selectedColor: Color = .blue

  /// The most recent color received from the counterpart.
  private(set) var peerColor: Color?
  /// When the counterpart color last arrived.
  private(set) var peerUpdatedAt: Date?
  /// The revision stamped on the most recent inbound snapshot.
  private(set) var peerRevision: UInt64?

  private var engine: ContextEngine<ColorSnapshot, ColorSnapshot>?

  /// Whether the counterpart app is reachable for immediate delivery.
  var isReachable: Bool { engine?.isReachable ?? false }
  /// Whether the paired device has the counterpart app installed.
  var isPairedAppInstalled: Bool { engine?.isPairedAppInstalled ?? false }

  /// A human-readable description of the latest error, if any. Activation errors
  /// take precedence — they require recreating the engine, not just retrying.
  var statusError: String? {
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
  func start() async {
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
        self?.makeSnapshot(revision: revision)
          ?? ColorSnapshot(red: 0, green: 0, blue: 1, alpha: 1, revision: revision)
      },
      onInbound: { [weak self] snapshot in
        self?.apply(snapshot)
      }
    )

    self.engine = engine
    await engine.start()
  }

  /// Stops the engine's stream and heartbeat tasks.
  func stop() {
    engine?.stop()
  }

  /// Re-sends the current color after a manual change, stamped with a fresh
  /// revision so the latest-wins context update is never deduped.
  func colorChanged() {
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

// MARK: - View

/// The "Context Sync" demo screen.
@available(iOS 18.0, watchOS 11.0, *)
struct StreamContextLabView: View {
  @State private var model = StreamContextLabModel()

  var body: some View {
    Form {
      Section("Your Color") {
        ColorPreview(color: model.selectedColor, source: "This Device")
          .frame(maxWidth: .infinity)
        PresetColorGrid(selectedColor: $model.selectedColor)
      }

      Section("Peer Color") {
        if let peerColor = model.peerColor {
          ColorPreview(
            color: peerColor,
            timestamp: model.peerUpdatedAt,
            source: "Counterpart"
          )
          .frame(maxWidth: .infinity)
          if let revision = model.peerRevision {
            LabeledContent("Revision", value: String(revision))
          }
        } else {
          Text("Waiting for a snapshot from the paired device\u{2026}")
            .foregroundStyle(.secondary)
        }
      }

      Section("Connection") {
        statusRow("Reachable", isOn: model.isReachable)
        #if os(iOS)
          statusRow("Companion App Installed", isOn: model.isPairedAppInstalled)
        #endif
      }

      if let statusError = model.statusError {
        Section("Status") {
          Text(statusError)
            .font(.footnote)
            .foregroundStyle(.red)
        }
      }

      Section {
        Text(
          "Pick a color to sync it to the paired device. `ContextEngine` stamps "
            + "each change with a monotonic revision, re-asserts on a heartbeat, "
            + "and re-syncs whenever the peer reconnects."
        )
        .font(.footnote)
        .foregroundStyle(.secondary)
      }
    }
    .navigationTitle("Context Sync")
    .onChange(of: model.selectedColor) {
      model.colorChanged()
    }
    .task {
      await model.start()
    }
    .onDisappear {
      model.stop()
    }
  }

  private func statusRow(_ title: String, isOn: Bool) -> some View {
    LabeledContent(title) {
      Image(systemName: isOn ? "checkmark.circle.fill" : "xmark.circle")
        .foregroundStyle(isOn ? .green : .secondary)
    }
  }
}

// MARK: - Preset color grid

/// A small cross-platform color picker (SwiftUI's `ColorPicker` is unavailable on
/// watchOS), so the demo runs identically on iPhone and Apple Watch.
@available(iOS 18.0, watchOS 11.0, *)
private struct PresetColorGrid: View {
  @Binding var selectedColor: Color

  private let colors: [Color] = [
    .red, .orange, .yellow, .green, .mint, .teal,
    .cyan, .blue, .indigo, .purple, .pink, .brown,
  ]

  var body: some View {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 40), spacing: 8)], spacing: 8) {
      ForEach(colors.indices, id: \.self) { index in
        Button {
          selectedColor = colors[index]
        } label: {
          Circle()
            .fill(colors[index])
            .frame(width: 40, height: 40)
            .overlay(
              Circle().strokeBorder(.primary, lineWidth: 3)
                .opacity(colors[index] == selectedColor ? 1 : 0)
            )
        }
        .buttonStyle(.plain)
      }
    }
    .padding(.vertical, 4)
  }
}
