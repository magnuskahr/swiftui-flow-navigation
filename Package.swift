// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

var dependencies: [Package.Dependency] = []

if ProcessInfo.processInfo.environment["DEPENDENCY_DOCC"] == "1" {
    dependencies.append(
        .package(url: "https://github.com/apple/swift" + "-docc-plugin", from: "1.4.3")
    )
}

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
    dependencies: dependencies,
    targets: [
        .target(
            name: "FlowNavigation"
        )
    ]
)
