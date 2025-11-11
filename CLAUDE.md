# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Swift Hoods is a Swift Package Manager library containing building blocks that depend on well-known dependencies like The Composable Architecture (TCA), JWTKit, and swift-blocks. It includes:

- **Hoods**: Main library target with reusable components
- **HoodsTestsTools**: Testing utilities and test dependencies
- **HoodsApp**: Example iOS/macOS app demonstrating library usage
- **HoodsCLI**: Example command-line tool

The project follows a multi-product SPM structure with separate targets for production code, test tools, and examples.

## Building and Testing

### Building
```bash
# Standard build
swift build

# Release build
swift build -c release

# Build the CLI example
make cli
```

### Testing
```bash
# Run all tests (iOS + macOS)
make test

# Run tests with verbose output (debug mode)
make test-debug

# Test script (iOS only, requires simulator)
./test.sh
```

Tests run on both iOS Simulator and macOS platforms using xcodebuild with `-skipMacroValidation` flag.

### Single Test Execution
```bash
# Run a specific test
swift test --filter <TestClassName>/<testMethodName>

# Example:
swift test --filter SnapshottingTransportTests/testSnapshotsMockTransport
```

### Linting and Formatting
```bash
# Format code
make format

# Lint code
make lint
```

Uses SwiftFormat and SwiftLint. Configuration files: `.swiftformat`, `.swiftlint.yml`

## Architecture

### The Composable Architecture (TCA) Pattern

The codebase heavily uses TCA for state management. Key patterns:

- **Features**: Each feature has a `Reducer` that defines state, actions, and business logic
- **Dependencies**: Custom dependencies are registered via `DependencyValues` extension
- **Testing**: Use `TestStore` for testing TCA features with `TestDependenciesFactory` for test doubles

Example dependency registration pattern (see `Sources/Hoods/Dependencies/`):
```swift
extension DependencyValues {
    var customDependency: CustomProtocol {
        get { self[CustomKey.self] }
        set { self[CustomKey.self] = newValue }
    }
}
```

### Core Components

- **KeychainUI**: TCA-based keychain management UI (`KeychainUIFeature`, `AddKeychainItemFeature`)
- **Mailer**: Email composition with TCA (`MailButtonFeature`, `MailerFeature`)
- **Dependencies**: Custom TCA dependencies:
  - `KeychainGateway`: iOS Keychain wrapper
  - `JWTFactory`: JWT signing/verification using JWTKit
  - `CopyText`: Clipboard operations
- **CMS**: Front matter parsing with CMark (`FrontMatterCMark`)
- **CLITools**: Utilities for command-line tools using ArgumentParser (`InputableValue`)

### Test Tools

`HoodsTestsTools` provides testing utilities:
- `TestDependenciesFactory`: Creates test doubles for TCA dependencies (OpenURL, CopyText)
- `SnapshottingTransport`: Custom transport for snapshot testing TCA effects
- Uses swift-snapshot-testing for snapshot-based tests

### Examples Structure

- **HoodsApp**: Demonstrates TCA features including Counter tutorial, mail composition, keychain UI, image picker, and copy text functionality
- **HoodsCLI**: Command-line utilities using ArgumentParser

## Dependencies

Key external dependencies:
- `swift-composable-architecture` (TCA): State management framework
- `swift-blocks`: Dependency-free utility library from the same author
- `swift-argument-parser`: CLI argument parsing
- `swift-snapshot-testing`: Snapshot testing
- `Yams`: YAML parsing
- `jwt-kit`: JWT operations

## Versioning

The project uses Commitizen for conventional commits. Version is tracked in `.cz.toml` (currently 0.3.0).

## Platform Requirements

- Swift 5.9+
- macOS 13+ / iOS 15+
- Runs on both iOS Simulator and macOS
