//
//  SundialCombineAppMain.swift
//  Sundial
//
//  App entry point for SundialCombine iOS/watchOS apps.
//  This file hooks up the Xcode app targets to the SundialDemoCombine library.
//
//  Copyright (c) 2025 BrightDigit.
//

import SundialDemoCombine
import SwiftUI

/// Entry point for SundialCombine iOS and watchOS apps.
///
/// This thin wrapper instantiates the `SundialApp` from the SundialDemoCombine library,
/// allowing the same library code to be used by both the iOS and watchOS app targets.
@available(iOS 16.0, watchOS 9.0, *)
@main
struct SundialCombineAppMain: App {
  var body: some Scene {
    SundialApp().body
  }
}
