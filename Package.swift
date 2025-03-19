// swift-tools-version: 6.0
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
            name: "FlowNavigation"
        ),
        .testTarget(
            name: "FlowNavigationTests",
            dependencies: ["FlowNavigation"]
        ),
    ],
    swiftLanguageModes: [.version("6"), .v5]
)
