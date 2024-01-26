// swift-tools-version:5.7

// 📜 https://github.com/apple/swift-package-manager/blob/main/Documentation/PackageDescription.md
import PackageDescription

let package = Package(
    name: "swift-hoods",
    platforms: [
        // Limiting factor: os.Logger
        .macOS(.v11),
        .iOS(.v14)
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
            branch: "main"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.4.0"
        ),
        .package(
            url: "https://github.com/jpsim/Yams.git",
            from: "5.0.6"
        )
    ],
    targets: [
        .target(
            name: "Hoods",
            dependencies: [
                .product(name: "Blocks", package: "swift-blocks"),
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
                .product(
                    name: "Yams",
                    package: "Yams"
                )
            ]
        ),
        .target(
            name: "HoodsTestsTools",
            dependencies: [
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                )
            ]
        ),
        .testTarget(
            name: "HoodsTests",
            dependencies: ["Hoods", "HoodsTestsTools"],
            resources: [.process("Resources")]
        )
    ]
)
