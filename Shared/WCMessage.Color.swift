import SwiftUI

extension WCMessage {
  enum Properties {
    static let colorValue = "colorValue"
  }

  static func message(fromColor color: Color) -> WCMessage? {
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
