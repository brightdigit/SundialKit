import Testing
@testable import SundialKitBinary

@Suite("SundialKitBinary Tests")
struct SundialKitBinaryTests {
  @Test("Version is defined")
  func versionIsDefined() {
    #expect(!SundialKitBinary.version.isEmpty)
  }
}
