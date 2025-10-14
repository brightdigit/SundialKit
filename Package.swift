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
    // Core protocols and types
    .library(
      name: "SundialKitCore",
      targets: ["SundialKitCore"]
    ),
    // Network monitoring implementation
    .library(
      name: "SundialKitNetwork",
      targets: ["SundialKitNetwork"]
    ),
    // WatchConnectivity implementation
    .library(
      name: "SundialKitConnectivity",
      targets: ["SundialKitConnectivity"]
    ),
    // Umbrella product re-exporting all modules
    .library(
      name: "SundialKit",
      targets: ["SundialKit"]
    )
  ],
  targets: [
    // MARK: - Core Module
    .target(
      name: "SundialKitCore",
      dependencies: []
    ),
    .testTarget(
      name: "SundialKitCoreTests",
      dependencies: ["SundialKitCore"]
    ),

    // MARK: - Network Module
    .target(
      name: "SundialKitNetwork",
      dependencies: ["SundialKitCore"]
    ),
    .testTarget(
      name: "SundialKitNetworkTests",
      dependencies: ["SundialKitNetwork"]
    ),

    // MARK: - Connectivity Module
    .target(
      name: "SundialKitConnectivity",
      dependencies: ["SundialKitCore"]
    ),
    .testTarget(
      name: "SundialKitConnectivityTests",
      dependencies: ["SundialKitConnectivity"]
    ),

    // MARK: - Umbrella Module
    .target(
      name: "SundialKit",
      dependencies: [
        "SundialKitCore",
        "SundialKitNetwork",
        "SundialKitConnectivity"
      ]
    ),
    .testTarget(
      name: "SundialKitTests",
      dependencies: ["SundialKit"]
    )
  ]
)
// swiftlint:enable explicit_top_level_acl explicit_acl
