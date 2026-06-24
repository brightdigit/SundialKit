//
//  StreamContextView.swift
//  Sundial
//
//  Hosts the "Context Sync" demo in its own navigation stack so it can be
//  presented as a tab inside `StreamTabView`.
//
//  Copyright (c) 2026 BrightDigit.
//

#if os(iOS) || os(watchOS)
  import SwiftUI

  /// Wraps the ``ContextEngine`` "Context Sync" demo in a `NavigationStack` so its
  /// title renders when hosted as a tab in ``StreamTabView``.
  @available(iOS 18.0, watchOS 11.0, *)
  struct StreamContextView: View {
    var body: some View {
      NavigationStack {
        StreamContextLabView()
      }
    }
  }
#endif
