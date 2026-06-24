// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "Sundial",
  platforms: [
    // Raised to satisfy the SundialKitStream `atleast-beta.6` branch, which the
    // SundialKitStreamContext demo depends on (iOS 18 / watchOS 11 / macOS 15).
    .iOS(.v18),
    .watchOS(.v11),
    .macOS(.v15)
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
      from: "2.0.0-alpha.1"
    ),
    // SundialKitCombine plugin
    .package(
      url: "https://github.com/brightdigit/SundialKitCombine.git",
      from: "1.0.0-alpha.1"
    ),
    // SundialKitStream plugin — pinned to the branch that adds the
    // SundialKitStreamContext (`ContextEngine`) product, not yet released.
    .package(
      url: "https://github.com/brightdigit/SundialKitStream.git",
      branch: "atleast-beta.6"
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
        .product(name: "SundialKitCore", package: "SundialKit"),
        .product(name: "SundialKitConnectivity", package: "SundialKit"),
        .product(name: "SundialKitStream", package: "SundialKitStream"),
        .product(name: "SundialKitStreamContext", package: "SundialKitStream")
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
