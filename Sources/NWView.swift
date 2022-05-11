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
      VStack{
      HStack(alignment: .bottom){
        ForEach(0..<18) { index in
          Rectangle().fill(Bar.all[index].color).scaleEffect(.init(width: 1.0, height: Bar.heightScale(atIndex: index, total: 17, start: 0.10)), anchor: .bottom)
        }
      }.frame(height: 450.0, alignment: .top).padding(40.0)
        Text(object.pathStatus.message)
        VStack(spacing: 8.0){
          HStack{
            Image(systemName: "power.dotted")
            Text("Network Demand is Expensive")
            Spacer()
          }.opacity(self.object.isExpensive ? 1.0 : 0.2)
          HStack{
            Image(systemName: "powersleep")
            Text("Network Demand is Constrained")
            Spacer()
          }.opacity(self.object.isConstrained ? 1.0 : 0.2)
        }.padding(.horizontal, 40)
        HStack(spacing: 16.0){
          ForEach(InterfaceItem.allCases) { item in
            Image(systemName: item.systemName).resizable().aspectRatio(contentMode: .fit).frame(width: 50, height: 50, alignment: .center).opacity(object.interfaceItems.contains(item) ? 1.0 : 0.2)
          }
        }.padding(40.0)
      }
    }
}

struct NWView_Previews: PreviewProvider {
    static var previews: some View {
        NWView()
    }
}
