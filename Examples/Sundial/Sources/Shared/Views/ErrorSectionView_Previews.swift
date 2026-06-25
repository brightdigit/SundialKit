//
//  ErrorSectionView_Previews.swift
//  Sundial
//
//  Created on 10/28/25.
//  Copyright (c) 2025 BrightDigit.
//

#if DEBUG
  import SwiftUI

  // MARK: - Previews

  @available(iOS 16.0, watchOS 9.0, *)
  public struct ErrorSectionView_Previews: PreviewProvider {
    public static var previews: some View {
      ErrorSectionView(error: "Failed to send message: Connection timeout")
        .padding()
    }
  }
#endif
