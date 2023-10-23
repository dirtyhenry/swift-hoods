    # 🧱 Blocks “The Composable Architecture” Edition

A collection of my Swift building blocks when I use [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) _aka_ TCA.

This repository contains:

- `BlocksTCA`: a **dependency-free** (other than TCA) Swift library for my development needs;

And the following examples executables/apps:

- `BlocksAppTCA`: a basic App using `swift-blocks-tca` within an app.

## Usage

```swift
import BlocksTCA
```

## Installation

Swift Package Manager is recommended:

```swift
dependencies: [
    .package(
        url: "https://github.com/dirtyhenry/swift-blocks-tca",
        from: "0.1.0"
    ),
]
```

Next, add `Blocks` as a dependency of your test target:

```swift
targets: [
    .target(name: "MyTarget", dependencies: [
        .product(name: "BlocksTCA", package: "swift-blocks-tca")
    ])
]
```

## License

[MIT](https://choosealicense.com/licenses/mit/)
