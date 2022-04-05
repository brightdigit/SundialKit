//
//  Color.swift
//  WatchConnectivityTest
//
//  Created by Leo Dion on 4/5/22.
//

import Foundation
import SwiftUI

extension Color {
    init(_ hex: Int, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }

    var value: Int? {
        guard let components = UIColor(self).cgColor.components?.prefix(3) else {
            return nil
        }
        var value = 0
        for component in components {
            value = (value << 8) + Int(component * 255.0)
        }
        return value
    }
}
