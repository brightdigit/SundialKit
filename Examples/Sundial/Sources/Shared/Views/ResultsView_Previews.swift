//
//  ResultsView_Previews.swift
//  Sundial
//
//  Created on 10/28/25.
//  Copyright (c) 2025 BrightDigit.
//

#if DEBUG
  import SwiftUI

  // MARK: - Previews

  @available(iOS 16.0, watchOS 9.0, *)
  public struct ResultsView_Previews: PreviewProvider {
    public static var previews: some View {
      ResultsView(
        lastSentColor: ColorWithMetadata(
          color: .blue,
          timestamp: Date(),
          source: "This Device"
        ),
        lastReceivedColor: ColorWithMetadata(
          color: .red,
          timestamp: Date(),
          source: "Counterpart"
        ),
        messagesSent: 5,
        messagesReceived: 3
      )
      .padding()
    }
  }
#endif
