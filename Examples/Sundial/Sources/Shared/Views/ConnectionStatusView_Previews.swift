//
//  ConnectionStatusView_Previews.swift
//  Sundial
//
//  Created on 10/27/25.
//  Copyright (c) 2025 BrightDigit.
//

#if DEBUG
  import SwiftUI

  @available(iOS 17.0, watchOS 10.0, *)
  #Preview("Connection States") {
    VStack(spacing: 0) {
      // Reachable and activated
      ConnectionStatusView(
        isReachable: true,
        activationState: "Activated",
        lastUpdate: Date()
      )

      Divider()

      // Not reachable but activated
      ConnectionStatusView(
        isReachable: false,
        activationState: "Activated",
        lastUpdate: Date().addingTimeInterval(-120)
      )

      Divider()

      // Not activated
      ConnectionStatusView(
        isReachable: false,
        activationState: "Not Activated",
        lastUpdate: Date().addingTimeInterval(-300)
      )

      Divider()

      // Inactive
      ConnectionStatusView(
        isReachable: false,
        activationState: "Inactive",
        lastUpdate: Date().addingTimeInterval(-60)
      )
    }
  }
#endif
