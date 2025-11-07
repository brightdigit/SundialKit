//
//  ConnectivityObserverEnvironment.swift
//  Sundial
//
//  Created on 11/7/25.
//  Copyright (c) 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#if canImport(SundialKitStream)
  import SundialDemoShared
  import SundialKitConnectivity
  import SundialKitCore
  import SundialKitStream
  import SwiftUI

  /// Environment key for sharing a single ConnectivityObserver instance across all views.
  ///
  /// This ensures only one WatchConnectivitySession is created, preventing conflicts
  /// with WCSession.default's single delegate requirement.
  @available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
  public struct ConnectivityObserverKey: EnvironmentKey {
    public static let defaultValue: ConnectivityObserver = {
      #if os(iOS) || os(watchOS)
        return ConnectivityObserver(
          messageDecoder: MessageDecoder(messagableTypes: [
            Sundial_Demo_ColorMessage.self,
            Sundial_Demo_ComplexMessage.self,
            Sundial_Demo_LatencyTestRequest.self,
            Sundial_Demo_LatencyTestReply.self,
          ])
        )
      #else
        // Fallback for unsupported platforms (shouldn't happen in practice)
        fatalError("ConnectivityObserver requires iOS or watchOS")
      #endif
    }()
  }

  @available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
  extension EnvironmentValues {
    public var connectivityObserver: ConnectivityObserver {
      get { self[ConnectivityObserverKey.self] }
      set { self[ConnectivityObserverKey.self] = newValue }
    }
  }
#endif
