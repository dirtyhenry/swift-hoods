// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HoodsCLI",
    platforms: [
        .macOS(.v11)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(name: "Hoods", path: "../../")
    ],
    targets: [
        .executableTarget(name: "HoodsCLI", dependencies: [
            .product(name: "Hoods", package: "Hoods"),
            .product(name: "ArgumentParser", package: "swift-argument-parser")
        ]),
        .testTarget(
            name: "HoodsCLITests",
            dependencies: ["HoodsCLI"]
        )
    ]
)
