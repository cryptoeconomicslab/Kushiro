// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Kushiro",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Kushiro",
            targets: ["Kushiro"]),
    ],
    dependencies: [
        // Core dependencies

        // Test dependencies
        .package(url: "https://github.com/Quick/Quick.git", from: "2.2.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.4")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Kushiro",
            dependencies: [],
            path: "Sources/Kushiro",
            sources: ["Core"]),
        .testTarget(
            name: "KushiroTests",
            dependencies: ["Kushiro", "Quick", "Nimble"]),
    ]
)
