import SundialKit
import SwiftUI

extension ConnectivityMessage {
  enum Properties {
    static let colorValue = "colorValue"
  }

  static func message(fromColor color: Color) -> ConnectivityMessage? {
    guard let value = color.value else {
      return nil
    }
    return [Properties.colorValue: value]
  }

  var color: Color? {
    guard let value = self["colorValue"] as? Int else {
      return nil
    }
    return Color(value)
  }
}
