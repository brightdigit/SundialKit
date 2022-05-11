//
//  SundialView.swift
//  Sundial
//
//  Created by Leo Dion on 5/10/22.
//

import SwiftUI

struct SundialView: View {
//
//  struct AnyTabViewStyle: TabViewStyle {
//    static func _makeView<SelectionValue>(value: _GraphValue<_TabViewValue<SundialView.AnyTabViewStyle, SelectionValue>>, inputs: _ViewInputs) -> _ViewOutputs where SelectionValue : Hashable {
//      <#code#>
//    }
//
//    static func _makeViewList<SelectionValue>(value: _GraphValue<_TabViewValue<SundialView.AnyTabViewStyle, SelectionValue>>, inputs: _ViewListInputs) -> _ViewListOutputs where SelectionValue : Hashable {
//      <#code#>
//    }
//
//  }
//    let _buttonStyle: Any
//    let _makeConfiguration: (PrimitiveButtonStyleConfiguration) -> AnyView
//
//    init<ButtonStyleType: PrimitiveButtonStyle>(_ buttonStyle: ButtonStyleType) {
//      _buttonStyle = buttonStyle
//      _makeConfiguration = {
//        AnyView(buttonStyle.makeBody(configuration: $0))
//      }
//    }
//
//    func makeBody(configuration: PrimitiveButtonStyleConfiguration) -> some View {
//      _makeConfiguration(configuration)
//    }
//  }
//
//  func borderlessButtonStyle() -> AnyButtonStyle {
//    if #available(watchOSApplicationExtension 8.0, *) {
//      return AnyButtonStyle(BorderlessButtonStyle())
//    } else {
//      return AnyButtonStyle(PlainButtonStyle())
//    }
//  }
  var carouselWatch : some TabViewStyle {
    #if os(watchOS)
    return .page
    #else
    return .automatic
    #endif
  }
    var body: some View {
      TabView{
        WCView().tabItem {
          Image(systemName: "applewatch.radiowaves.left.and.right")
          Text("Connectivity")
        }
        NWView().tabItem {
          Image(systemName: "network")
          Text("Network")
        }
      }.tabViewStyle(.automatic)
      .environmentObject(SundailObject())
    }
}

struct SundialView_Previews: PreviewProvider {
    static var previews: some View {
        SundialView()
    }
}
