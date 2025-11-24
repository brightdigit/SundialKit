// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "Sundial",
  platforms: [
    .iOS(.v16),
    .watchOS(.v9),
    .macOS(.v13)
  ],
  products: [
    // Shared library used by both variants
    .library(
      name: "SundialDemoShared",
      targets: ["SundialDemoShared"]
    ),
    // Combine variant library (used by iOS/watchOS app targets)
    .library(
      name: "SundialDemoCombine",
      targets: ["SundialDemoCombine"]
    ),
    // Stream variant library (used by iOS/watchOS app targets)
    .library(
      name: "SundialDemoStream",
      targets: ["SundialDemoStream"]
    )
  ],
  dependencies: [
    // SwiftProtobuf for binary message encoding
    .package(
      url: "https://github.com/apple/swift-protobuf.git",
      from: "1.25.0"
    ),
    // SundialKit core (parent package)
    .package(
      url: "https://github.com/brightdigit/SundialKit.git",
      branch: "v2.0.0"
    ),
    // SundialKitCombine plugin
    .package(
      url: "https://github.com/brightdigit/SundialKitCombine.git",
      branch: "v1.0.0"
    ),
    // SundialKitStream plugin
    .package(
      url: "https://github.com/brightdigit/SundialKitStream.git",
      branch: "v1.0.0"
    )
  ],
  targets: [
    // MARK: - Shared Components

    .target(
      name: "SundialDemoShared",
      dependencies: [
        .product(name: "SwiftProtobuf", package: "swift-protobuf"),
        .product(name: "SundialKitCore", package: "SundialKit"),
        .product(name: "SundialKitNetwork", package: "SundialKit"),
        .product(name: "SundialKitConnectivity", package: "SundialKit")
      ],
      path: "Sources/Shared",
      swiftSettings: [
        .enableUpcomingFeature("ExistentialAny"),
        .enableExperimentalFeature("StrictConcurrency")
      ]
    ),

    // MARK: - Combine Variant

    .target(
      name: "SundialDemoCombine",
      dependencies: [
        "SundialDemoShared",
        .product(name: "SundialKitCombine", package: "SundialKitCombine")
      ],
      path: "Sources/SundialDemoCombine",
      swiftSettings: [
        .enableUpcomingFeature("ExistentialAny"),
        .enableExperimentalFeature("StrictConcurrency")
      ]
    ),

    // MARK: - Stream Variant

    .target(
      name: "SundialDemoStream",
      dependencies: [
        "SundialDemoShared",
        .product(name: "SundialKitStream", package: "SundialKitStream")
      ],
      path: "Sources/SundialDemoStream",
      swiftSettings: [
        .enableUpcomingFeature("ExistentialAny"),
        .enableExperimentalFeature("StrictConcurrency")
      ]
    ),

    // MARK: - Tests

    .testTarget(
      name: "SundialDemoTests",
      dependencies: [
        "SundialDemoShared"
      ],
      path: "Tests"
    )
  ]
)
