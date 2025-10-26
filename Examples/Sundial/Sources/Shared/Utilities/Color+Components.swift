//
//  Color+Components.swift
//  Sundial Demo
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

#if canImport(SwiftUI)
  import SwiftUI

  public extension Color {
    /// RGBA components of the color
    struct Components {
      public let red: Double
      public let green: Double
      public let blue: Double
      public let alpha: Double

      public init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
      }
    }

    /// Extract RGBA components
    var components: Components {
      #if os(watchOS) || os(iOS)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return Components(
          red: Double(red),
          green: Double(green),
          blue: Double(blue),
          alpha: Double(alpha)
        )
      #elseif os(macOS)
        let nsColor = NSColor(self)
        guard let rgbColor = nsColor.usingColorSpace(.deviceRGB) else {
          return Components(red: 0, green: 0, blue: 0, alpha: 1)
        }

        return Components(
          red: Double(rgbColor.redComponent),
          green: Double(rgbColor.greenComponent),
          blue: Double(rgbColor.blueComponent),
          alpha: Double(rgbColor.alphaComponent)
        )
      #else
        return Components(red: 0, green: 0, blue: 0, alpha: 1)
      #endif
    }

    /// Create color from components
    init(components: Components) {
      self.init(
        red: components.red,
        green: components.green,
        blue: components.blue,
        opacity: components.alpha
      )
    }
  }
#endif
