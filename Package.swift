// swift-tools-version: 5.9
// swiftlint:disable explicit_top_level_acl explicit_acl
import PackageDescription

let package = Package(
  name: "SundialKit",
  platforms: [
    .iOS(.v13),
    .watchOS(.v6),
    .tvOS(.v13),
    .macOS(.v10_13)
  ],
  products: [
    .library(
      name: "SundialKit",
      targets: ["SundialKit"]
    )
  ],
  targets: [
    .target(
      name: "SundialKit",
      dependencies: []
    ),
    .testTarget(
      name: "SundialKitTests",
      dependencies: ["SundialKit"]
    )
  ]
)
