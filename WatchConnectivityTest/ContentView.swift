//
//  ContentView.swift
//  WatchConnectivityTest
//
//  Created by Leo Dion on 3/30/22.
//

import SwiftUI
import WatchConnectivity

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
  var value : Int? {
    guard let components = self.cgColor?.components else {
      return nil
    }
    var value = 0
    for component in components {
      value = (value << 8) + Int(component * 255.0)
    }
    return value
    
//    var fRed : CGFloat = 0
//    var fGreen : CGFloat = 0
//    var fBlue : CGFloat = 0
//    var fAlpha: CGFloat = 0
//    if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
//        let iRed = Int(fRed * 255.0)
//        let iGreen = Int(fGreen * 255.0)
//        let iBlue = Int(fBlue * 255.0)
//        let iAlpha = Int(fAlpha * 255.0)
//
//        //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
//        let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
//        return rgb
//    } else {
//        // Could not extract RGBA components:
//        return nil
//    }
  }
}

struct ContentView: View {
  @EnvironmentObject var object : WCObject
  #if os(iOS)
  static let padding = 20.0
  #else
  static let padding = 0.0
  
  #endif
  static let colors : [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
    var body: some View {
      VStack{
        Text(object.isReachable ? "Reachable" : "Not reachable")
        Text("Hello, world!")
        HStack{
          ForEach(0..<6) { index in
            Button {
              object.sendColor(Self.colors[index])
            } label: {
              Text("   ")
            }.padding(Self.padding).background(Self.colors[index])
          }
        }

      }
            .padding().onAppear {
              if WCSession.isSupported() {
                  let session = WCSession.default
                  session.delegate = object
                session.activate()
              }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
