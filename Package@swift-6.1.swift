// swift-tools-version: 6.1
// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

// MARK: - Swift Settings Configuration

let swiftSettings: [SwiftSetting] = [
  // Swift 6.2 Upcoming Features
  .enableUpcomingFeature("ExistentialAny"),
  .enableUpcomingFeature("InternalImportsByDefault"),
  .enableUpcomingFeature("MemberImportVisibility"),
  .enableUpcomingFeature("FullTypedThrows"),

  // Experimental Features
  .enableExperimentalFeature("BitwiseCopyable"),
  .enableExperimentalFeature("BorrowingSwitch"),
  .enableExperimentalFeature("ExtensionMacros"),
  .enableExperimentalFeature("FreestandingExpressionMacros"),
  .enableExperimentalFeature("InitAccessors"),
  .enableExperimentalFeature("IsolatedAny"),
  .enableExperimentalFeature("MoveOnlyClasses"),
  .enableExperimentalFeature("MoveOnlyEnumDeinits"),
  .enableExperimentalFeature("MoveOnlyPartialConsumption"),
  .enableExperimentalFeature("MoveOnlyResilientTypes"),
  .enableExperimentalFeature("MoveOnlyTuples"),
  .enableExperimentalFeature("NoncopyableGenerics"),
  .enableExperimentalFeature("RawLayout"),
  .enableExperimentalFeature("ReferenceBindings"),
  .enableExperimentalFeature("SendingArgsAndResults"),
  .enableExperimentalFeature("SymbolLinkageMarkers"),
  .enableExperimentalFeature("TransferringArgsAndResults"),
  .enableExperimentalFeature("VariadicGenerics"),
  .enableExperimentalFeature("WarnUnsafeReflection"),

  // Enhanced compiler checking
  .unsafeFlags([
    "-warn-concurrency",
    "-enable-actor-data-race-checks",
    "-strict-concurrency=complete",
    "-enable-testing",
    "-Xfrontend", "-warn-long-function-bodies=100",
    "-Xfrontend", "-warn-long-expression-type-checking=100"
  ])
]

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
      dependencies: [],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "SundialKitCoreTests",
      dependencies: ["SundialKitCore"],
      swiftSettings: swiftSettings
    ),

    // MARK: - Network Module
    .target(
      name: "SundialKitNetwork",
      dependencies: ["SundialKitCore"],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "SundialKitNetworkTests",
      dependencies: ["SundialKitNetwork"],
      swiftSettings: swiftSettings
    ),

    // MARK: - Connectivity Module
    .target(
      name: "SundialKitConnectivity",
      dependencies: ["SundialKitCore"],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "SundialKitConnectivityTests",
      dependencies: ["SundialKitConnectivity"],
      swiftSettings: swiftSettings
    ),

    // MARK: - Umbrella Module
    .target(
      name: "SundialKit",
      dependencies: [
        "SundialKitCore",
        "SundialKitNetwork",
        "SundialKitConnectivity"
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "SundialKitTests",
      dependencies: ["SundialKit"],
      swiftSettings: swiftSettings
    )
  ]
)
// swiftlint:enable explicit_acl explicit_top_level_acl
