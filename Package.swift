// swift-tools-version: 5.5
// swiftlint:disable explicit_top_level_acl explicit_acl
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
    .package(url: "https://github.com/shibapm/Komondor", from: "1.1.2"), // dev
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

#if canImport(PackageConfig)
  import PackageConfig

  let requiredCoverage: Int = 0

  let config = PackageConfiguration([
    "rocket": [
      "steps":
        [
          "hide_dev_dependencies"
        ]
    ],
    "komondor": [
      "pre-push": [
        "swift test --enable-code-coverage"
      ],
      "pre-commit": [
        "swift test --enable-code-coverage",
        "swift run swiftformat .",
        "swift run swiftlint autocorrect",
        "git add .",
        "swift run swiftformat --lint .",
        "swift run swiftlint lint"
      ]
    ]
  ]).write()
#endif
