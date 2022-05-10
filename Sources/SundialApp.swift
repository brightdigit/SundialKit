import SwiftUI

@main
struct SundialApp: App {
  var body: some Scene {
    WindowGroup {
      SundialView().environmentObject(SundailObject())
    }
  }
}
