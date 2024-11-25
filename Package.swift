// swift-tools-version:5.9

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
            branch: "0.5.0"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.3.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.6.0"
        ),
        .package(
            url: "https://github.com/jpsim/Yams.git",
            from: "5.0.6"
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
            ]
        ),
        .target(
            name: "HoodsTestsTools",
            dependencies: [
                "Hoods",
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
