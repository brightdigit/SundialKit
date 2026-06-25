//
//  TransportControlView_Previews.swift
//  Sundial
//
//  Created on 10/28/25.
//  Copyright (c) 2025 BrightDigit.
//

#if DEBUG
  import SwiftUI

  // MARK: - Previews

  @available(iOS 16.0, watchOS 9.0, *)
  public struct TransportControlView_Previews: PreviewProvider {
    public static var previews: some View {
      TransportControlView(
        selectedTransportMethod: .constant(nil),
        effectiveTransportMethod: .sendMessage,
        automaticTransportMethod: .sendMessage,
        isSending: false,
        isReachable: true,
        onSend: {}
      )
      .padding()
    }
  }
#endif
