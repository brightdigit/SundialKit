import Testing

@testable import SundialKitStream

@Suite("SundialKitStream Tests")
internal struct SundialKitStreamTests {
  @Test("Version is defined")
  internal func versionIsDefined() {
    #expect(!SundialKitStream.version.isEmpty)
  }
}
