// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "PovioKit",
  platforms: [
    .iOS(.v13),
    .macOS(.v12)
  ],
  products: [
    .library(
      name: "PovioKitCore",
      targets: ["PovioKitCore"]
    ),
    .library(
      name: "PovioKitUtilities", 
      targets: ["PovioKitUtilities"]
    ),
    .library(
      name: "PovioKitNetworking", 
      targets: ["PovioKitNetworking"]
    ),
    .library(
      name: "PovioKitPromise", 
      targets: ["PovioKitPromise"]
    ),
    .library(
      name: "PovioKitUIKit", 
      targets: ["PovioKitUIKit"]
    ),
    .library(
      name: "PovioKitSwiftUI", 
      targets: ["PovioKitSwiftUI"]
    ),
    .library(
      name: "PovioKitAsync", 
      targets: ["PovioKitAsync"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/Alamofire/Alamofire", 
      .upToNextMajor(from: "5.0.0")
    ),
    .package(
      url: "https://github.com/onevcat/Kingfisher",
      .upToNextMajor(from: "8.0.0")
    )
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
      name: "PovioKitNetworking",
      dependencies: [
        "Alamofire",
        "PovioKitCore",
        "PovioKitPromise",
      ],
      path: "Sources/Networking",
      resources: [.copy("../PrivacyInfo.xcprivacy")]
    ),
    .target(
      name: "PovioKitPromise",
      dependencies: [],
      path: "Sources/PromiseKit",
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
        "PovioKitPromise",
        "PovioKitNetworking",
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
