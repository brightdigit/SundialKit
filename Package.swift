// swift-tools-version: 5.5

import PackageDescription

let package = Package(
  name: "SundialKit",
  platforms: [.watchOS(.v6), .iOS(.v13)],
  products: [
    .library(
      name: "SundialKit",
      targets: ["SundialKit"]
    )
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.47.0"), // dev
    .package(url: "https://github.com/realm/SwiftLint", from: "0.41.0"), // dev
    .package(url: "https://github.com/shibapm/Rocket", from: "1.2.0") // dev
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
