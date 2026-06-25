//
//  StreamContextLabView.swift
//  Sundial
//
//  The "Context Sync" demo screen for SundialKitStreamContext's `ContextEngine`.
//
//  Copyright (c) 2026 BrightDigit.
//

#if os(iOS) || os(watchOS)
  import SundialDemoShared
  import SwiftUI

  /// The "Context Sync" demo screen.
  @available(iOS 18.0, watchOS 11.0, *)
  internal struct StreamContextLabView: View {
    @State private var model = StreamContextLabModel()

    internal var body: some View {
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
#endif
