# 🏘️ Hoods

A collection of my Swift building blocks that are using few well known dependencies, such as [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture), as opposed to Blocks, my collection of dependency-free Swift code.

This repository contains:

- `Hoods`: a Swift library for my development needs;

And the following examples executables/apps:

- `HoodsApp`: a basic App using `swift-hoods` within an app.

## Usage

```swift
import Hoods
```

## Installation

Swift Package Manager is recommended:

```swift
dependencies: [
    .package(
        url: "https://github.com/dirtyhenry/swift-hoods",
        from: "main"
    ),
]
```

Next, add `Hoods` as a dependency of your test target:

```swift
targets: [
    .target(name: "MyTarget", dependencies: [
        .product(name: "Hoods", package: "swift-hoods")
    ])
]
```

## License

[MIT](https://choosealicense.com/licenses/mit/)
