// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
    name: "swiftui-flow-navigation",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9)
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
        )
    ],
)
