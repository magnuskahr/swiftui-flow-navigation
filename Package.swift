// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftui-flow-navigation",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "FlowNavigation",
            targets: ["FlowNavigation"]
        ),
    ],
    targets: [
        .target(
            name: "FlowNavigation",
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=complete"])
            ]
        ),
        .testTarget(
            name: "FlowNavigationTests",
            dependencies: ["FlowNavigation"],
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=complete"])
            ]
        ),
    ],
    swiftLanguageVersions: [.version("6"), .v5]
)
