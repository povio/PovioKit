// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "PovioKit",
  platforms: [
    .iOS(.v16),
    .macOS(.v13)
  ],
  products: [
    .library(name: "PovioKitCore", targets: ["PovioKitCore"]),
    .library(name: "PovioKitUtilities", targets: ["PovioKitUtilities"]),
    .library(name: "PovioKitUIKit", targets: ["PovioKitUIKit"]),
    .library(name: "PovioKitSwiftUI", targets: ["PovioKitSwiftUI"]),
    .library(name: "PovioKitAsync", targets: ["PovioKitAsync"]),
  ],
  dependencies: [
    .package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "8.0.0"))
  ],
  targets: [
    .target(
      name: "PovioKitCore",
      dependencies: [
        "Kingfisher",
      ],
      path: "Sources/Core",
      resources: [.copy("../PrivacyInfo.xcprivacy")]
    ),
    .target(
      name: "PovioKitUIKit",
      dependencies: [
        "PovioKitCore",
        "PovioKitUtilities",
      ],
      path: "Sources/UI/UIKit",
      resources: [.copy("../../PrivacyInfo.xcprivacy")]
    ),
    .target(
      name: "PovioKitSwiftUI",
      dependencies: [
        "PovioKitCore",
      ],
      path: "Sources/UI/SwiftUI",
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
        "PovioKitUtilities",
        "PovioKitAsync",
      ],
      resources: [
        .process("Resources/")
      ]
    ),
  ],
  swiftLanguageVersions: [.v5]
)
