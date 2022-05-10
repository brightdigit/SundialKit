#if canImport(Network)
  import Network

  @available(macOS 10.14, *)
  public extension NWPathStatus.Interface {
    init(interfaces: [NWInterface]) {
      let rawValue = interfaces.map(\.type.value).reduce(0, +)
      self.init(rawValue: rawValue)
    }
  }

#endif
