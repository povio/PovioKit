// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "PovioKit",
  platforms: [
    .iOS(.v17),
    .macOS(.v14)
  ],
  products: [
    .library(name: "PovioKitCore", targets: ["PovioKitCore"]),
    .library(name: "PovioKitUtilities", targets: ["PovioKitUtilities"]),
    .library(name: "PovioKitUIKit", targets: ["PovioKitUIKit"]),
    .library(name: "PovioKitSwiftUI", targets: ["PovioKitSwiftUI"]),
    .library(name: "PovioKitAppKit", targets: ["PovioKitAppKit"]),
    .library(name: "PovioKitAsync", targets: ["PovioKitAsync"]),
  ],
  dependencies: [
    .package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "8.0.0")),
  ],
  targets: [
    .target(
      name: "PovioKitCore",
      path: "Sources/Core",
      resources: [.copy("../PrivacyInfo.xcprivacy")]
    ),
    .target(
      name: "PovioKitUIKit",
      dependencies: [
        "PovioKitCore",
        "PovioKitUtilities",
        "Kingfisher"
      ],
      path: "Sources/UI/UIKit",
      resources: [.copy("../../PrivacyInfo.xcprivacy")]
    ),
    .target(
      name: "PovioKitSwiftUI",
      dependencies: [
        "PovioKitCore",
        "Kingfisher"
      ],
      path: "Sources/UI/SwiftUI",
      resources: [.copy("../../PrivacyInfo.xcprivacy")]
    ),
    .target(
      name: "PovioKitAppKit",
      dependencies: [
        "PovioKitCore",
      ],
      path: "Sources/UI/AppKit",
      resources: [.copy("../../PrivacyInfo.xcprivacy")]
    ),
    .target(
      name: "PovioKitUtilities",
      dependencies: [
        "PovioKitCore",
      ],
      path: "Sources/Utilities",
      resources: [.copy("../PrivacyInfo.xcprivacy")]
    ),
    .target(
      name: "PovioKitAsync",
      dependencies: [],
      path: "Sources/Async",
      resources: [.copy("../PrivacyInfo.xcprivacy")]
    ),
    .testTarget(
      name: "Tests",
      dependencies: [
        "PovioKitCore",
        "PovioKitUIKit",
        "PovioKitSwiftUI",
        "PovioKitAppKit",
        "PovioKitUtilities",
        "PovioKitAsync",
      ],
      resources: [
        .process("Resources/")
      ]
    ),
  ]
)

// MARK: - Documentation build opt-in
//
// `swift-docc-plugin` is required only to run `swift package generate-documentation`
// (used by the Docs CI workflow to publish GitHub Pages). It is *not* linked by any
// target, so keeping it as an unconditional dependency would force every PovioKit
// consumer to resolve it (and its transitive `swift-docc-symbolkit`) in their own
// package graph for no runtime benefit.
//
// To generate docs from the CLI, export `POVIOKIT_BUILD_DOCS=1` before invoking SwiftPM:
//
//     POVIOKIT_BUILD_DOCS=1 swift package generate-documentation --target PovioKitCore
//
// Xcode's `Product > Build Documentation` and `xcodebuild docbuild` do not require
// this plugin and work regardless of the env var.
if Context.environment["POVIOKIT_BUILD_DOCS"] != nil {
  package.dependencies.append(
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.5")
  )
}
