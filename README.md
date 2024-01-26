# 🏘️ Hoods

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdirtyhenry%2Fswift-hoods%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/dirtyhenry/swift-hoods)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdirtyhenry%2Fswift-hoods%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/dirtyhenry/swift-hoods)

A collection of my Swift building blocks that are using few well known
dependencies, such as [The Composable Architecture][2], as opposed to
[Blocks][1], my collection of dependency-free Swift code.

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

[1]: https://github.com/dirtyhenry/swift-blocks
[2]: https://github.com/pointfreeco/swift-composable-architecture
