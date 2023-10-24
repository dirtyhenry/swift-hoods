// swift-tools-version:5.7

// 📜 https://github.com/apple/swift-package-manager/blob/main/Documentation/PackageDescription.md
import PackageDescription

let package = Package(
    name: "swift-blocks-tca",
    platforms: [
        // Limiting factor: os.Logger
        .macOS(.v11),
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "BlocksTCA",
            targets: ["BlocksTCA"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/dirtyhenry/swift-blocks",
            branch: "main"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.2.0"
        )
    ],
    targets: [
        .target(
            name: "BlocksTCA",
            dependencies: [
                .product(name: "Blocks", package: "swift-blocks"),
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                )
            ]
        ),
        .testTarget(
            name: "BlocksTCATests",
            dependencies: ["BlocksTCA"]
        )
    ]
)
