// swift-tools-version: 5.9
// swiftlint:disable explicit_top_level_acl explicit_acl
import PackageDescription

let package = Package(
  name: "SundialKitMessagable",
  platforms: [
    .iOS(.v13),
    .watchOS(.v6)
  ],
  products: [
    .library(
      name: "SundialKitMessagable",
      targets: ["SundialKitMessagable"]
    )
  ],
  dependencies: [
    // TODO: Add SundialKit dependency
    // .package(url: "https://github.com/brightdigit/SundialKit.git", from: "2.0.0")
  ],
  targets: [
    .target(
      name: "SundialKitMessagable",
      dependencies: []
    ),
    .testTarget(
      name: "SundialKitMessagableTests",
      dependencies: ["SundialKitMessagable"]
    )
  ]
)
// swiftlint:enable explicit_top_level_acl explicit_acl
