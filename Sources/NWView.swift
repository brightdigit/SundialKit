//
//  NWView.swift
//  Sundial
//
//  Created by Leo Dion on 5/10/22.
//

import SwiftUI

struct Bar {
  let color : Color
  
  
  static let total = 18
  static let colors = [
    Color.red, Color.orange, Color.yellow,
    Color.green, Color.blue, Color.purple
  ]
  static let barsPerColor = total / colors.count
  static let all = colors.flatMap { color in
    [Bar].init(repeating: Bar(color: color), count: barsPerColor)
  }
  
  static func heightScale(atIndex index: Int, total: Int, start: CGFloat) -> CGFloat {
    let factor = Double(index) / Double(total)
    let addition = factor * (1.0 - start)
    return start + addition
  }
}
struct NWView: View {
  @EnvironmentObject var object: SundailObject
    var body: some View {
      HStack(alignment: .bottom){
        ForEach(0..<18) { index in
          Rectangle().fill(Bar.all[index].color).scaleEffect(.init(width: 1.0, height: Bar.heightScale(atIndex: index, total: 17, start: 0.10)), anchor: .bottom)
        }
      }.frame(height: 220.0, alignment: .bottom).padding(40.0)
    }
}

struct NWView_Previews: PreviewProvider {
    static var previews: some View {
        NWView()
    }
}
