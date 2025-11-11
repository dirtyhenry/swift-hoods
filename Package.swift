// swift-tools-version:6.0

// 📜 https://github.com/apple/swift-package-manager/blob/main/Documentation/PackageDescription.md
import PackageDescription

let package = Package(
    name: "swift-hoods",
    platforms: [
        .macOS(.v13),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Hoods",
            targets: ["Hoods"]
        ),
        .library(
            name: "HoodsTestsTools",
            targets: ["HoodsTestsTools"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/dirtyhenry/swift-blocks",
            from: "0.8.0"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.3.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.23.1"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.18.0"
        ),
        .package(
            url: "https://github.com/jpsim/Yams.git",
            from: "6.0.0"
        ),
        .package(
            url: "https://github.com/vapor/jwt-kit.git",
            from: "5.0.0"
        )
    ],
    targets: [
        .target(
            name: "Hoods",
            dependencies: [
                .product(
                    name: "Blocks",
                    package: "swift-blocks"
                ),
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                .product(
                    name: "Yams",
                    package: "Yams"
                ),
                .product(
                    name: "JWTKit",
                    package: "jwt-kit"
                )
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "HoodsTestsTools",
            dependencies: [
                "Hoods",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                .product(
                    name: "SnapshotTesting",
                    package: "swift-snapshot-testing"
                )
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "HoodsTests",
            dependencies: ["Hoods", "HoodsTestsTools"],
            exclude: ["Hoods.xctestplan"],
            resources: [
                .process("Resources"),
                .process("__Snapshots__")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    ]
)
