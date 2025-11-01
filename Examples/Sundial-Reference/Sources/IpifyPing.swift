//
//  IpifyPing.swift
//  Sundial
//
//  Created by Leo Dion on 10/17/22.
//

import Foundation
import SundialKit

struct IpifyPing : NetworkPing {
  typealias StatusType = String?
  
  let session: URLSession
  let timeInterval: TimeInterval
  
  public func shouldPing(onStatus status: PathStatus) -> Bool {
    switch status {
    case .unknown, .unsatisfied:
      return false
    case .requiresConnection, .satisfied:
      return true
    }
  }
  
  static let url : URL = .init(string: "https://api.ipify.org")!
  
  func onPing(_ closure: @escaping (String?) -> Void) {
    session.dataTask(with: IpifyPing.url) { data, _, _ in
      closure(data.flatMap{String(data: $0, encoding: .utf8)})
    }.resume()
  }
}
