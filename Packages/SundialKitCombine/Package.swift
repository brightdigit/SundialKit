// swift-tools-version: 5.9
// swiftlint:disable explicit_top_level_acl explicit_acl
import PackageDescription

let package = Package(
  name: "SundialKitCombine",
  platforms: [
    .iOS(.v13),
    .watchOS(.v6),
    .tvOS(.v13),
    .macOS(.v10_15)
  ],
  products: [
    .library(
      name: "SundialKitCombine",
      targets: ["SundialKitCombine"]
    )
  ],
  dependencies: [
    // TODO: Add SundialKit dependency
    // .package(url: "https://github.com/brightdigit/SundialKit.git", from: "2.0.0")
  ],
  targets: [
    .target(
      name: "SundialKitCombine",
      dependencies: []
    ),
    .testTarget(
      name: "SundialKitCombineTests",
      dependencies: ["SundialKitCombine"]
    )
  ]
)
// swiftlint:enable explicit_top_level_acl explicit_acl
