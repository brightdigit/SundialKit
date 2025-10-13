import Testing

@testable import SundialKitStream

@Suite("SundialKitStream Tests")
struct SundialKitStreamTests {
  @Test("Version is defined")
  func versionIsDefined() {
    #expect(!SundialKitStream.version.isEmpty)
  }
}
