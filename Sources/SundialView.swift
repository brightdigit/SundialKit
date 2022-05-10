//
//  SundialView.swift
//  Sundial
//
//  Created by Leo Dion on 5/10/22.
//

import SwiftUI

struct SundialView: View {
    var body: some View {
      TabView{
        WCView().tabItem {
          Image(systemName: "applewatch.radiowaves.left.and.right")
          Text("Watch Connectivity")
        }
      }
    }
}

struct SundialView_Previews: PreviewProvider {
    static var previews: some View {
        SundialView()
    }
}
