import Testing

@testable import SundialKitBinary

@Suite("SundialKitBinary Tests")
internal struct SundialKitBinaryTests {
  @Test("Version is defined")
  internal func versionIsDefined() {
    #expect(!SundialKitBinary.version.isEmpty)
  }
}
