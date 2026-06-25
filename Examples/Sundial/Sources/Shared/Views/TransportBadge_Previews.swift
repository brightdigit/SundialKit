//
//  TransportBadge_Previews.swift
//  Sundial
//
//  Created on 10/27/25.
//  Copyright (c) 2025 BrightDigit.
//

#if DEBUG
  import SwiftUI

  // MARK: - Previews

  @available(iOS 14.8, watchOS 7.4, *)
  public struct TransportBadge_Previews: PreviewProvider {
    public static var previews: some View {
      VStack(spacing: 16) {
        // Active states
        HStack(spacing: 12) {
          TransportBadge(method: .sendMessage, isActive: true)
          TransportBadge(method: .sendMessageData, isActive: true)
          TransportBadge(method: .updateApplicationContext, isActive: true)
        }

        // Inactive states
        HStack(spacing: 12) {
          TransportBadge(method: .sendMessage, isActive: false)
          TransportBadge(method: .sendMessageData, isActive: false)
          TransportBadge(method: .updateApplicationContext, isActive: false)
        }

        // Mixed states
        VStack(alignment: .leading, spacing: 8) {
          Text("Select Transport Method:")
            .font(.caption)
            .foregroundColor(.secondary)

          HStack(spacing: 8) {
            TransportBadge(method: .sendMessage, isActive: true)
            TransportBadge(method: .sendMessageData, isActive: false)
            TransportBadge(method: .updateApplicationContext, isActive: false)
          }
        }
      }
      .padding()
      .previewLayout(.sizeThatFits)
    }
  }
#endif
