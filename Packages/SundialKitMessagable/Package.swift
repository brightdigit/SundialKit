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
    .package(name: "SundialKit", path: "../../")
  ],
  targets: [
    .target(
      name: "SundialKitMessagable",
      dependencies: [
        .product(name: "SundialKit", package: "SundialKit")
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "SundialKitMessagableTests",
      dependencies: ["SundialKitMessagable"],
      swiftSettings: swiftSettings
    )
  ]
)
// swiftlint:enable explicit_acl explicit_top_level_acl
