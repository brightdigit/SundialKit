//
//  Color+Components.swift
//  Sundial Demo
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

#if canImport(SwiftUI)
  import SwiftUI

  extension Color {
    /// RGBA components of the color
    public struct Components {
      /// The red channel, in the range `0...1`.
      public let red: Double
      /// The green channel, in the range `0...1`.
      public let green: Double
      /// The blue channel, in the range `0...1`.
      public let blue: Double
      /// The alpha (opacity) channel, in the range `0...1`.
      public let alpha: Double

      /// Creates a set of RGBA components.
      ///
      /// - Parameters:
      ///   - red: The red channel, in the range `0...1`.
      ///   - green: The green channel, in the range `0...1`.
      ///   - blue: The blue channel, in the range `0...1`.
      ///   - alpha: The alpha (opacity) channel, in the range `0...1`.
      public init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
      }
    }

    /// Standard gray background color used throughout the app
    /// Uses platform-specific system colors for better integration
    public static var grayBackgroundColor: Color {
      #if os(iOS)
        Color(uiColor: .systemGray6)
      #elseif os(macOS)
        Color(nsColor: .controlBackgroundColor)
      #else
        Color(white: 0.15)  // Opaque dark charcoal gray for watchOS
      #endif
    }

    /// Standard card/window background color (white/system background)
    /// Uses platform-specific system colors for better integration
    public static var cardBackgroundColor: Color {
      #if os(iOS)
        Color(uiColor: .systemBackground)
      #elseif os(macOS)
        Color(nsColor: .windowBackgroundColor)
      #else
        Color.white
      #endif
    }

    /// Semi-transparent gray background for subtle elements
    public static var subtleBackgroundColor: Color {
      grayBackgroundColor.opacity(0.5)
    }

    /// Extract RGBA components
    public var components: Components {
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

    /// Alias for components property
    public var rgbaComponents: Components {
      components
    }

    /// Create color from components
    public init(components: Components) {
      self.init(
        red: components.red,
        green: components.green,
        blue: components.blue,
        opacity: components.alpha
      )
    }
  }
#endif
