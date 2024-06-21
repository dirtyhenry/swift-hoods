#!/usr/bin/env bash

TEST_IOS_VERSION="iOS 17.4"
TEST_IOS_SIMULATOR_MODEL="iPhone 15"

xcrun xcodebuild -version
xcrun swift --version

# Download the script and make it executable
curl -sSL https://raw.githubusercontent.com/dirtyhenry/swift-blocks/main/Scripts/ListDevices.swift \
  -o findDevice
chmod +x findDevice
# Find the device identifier
DEVICE_ID=$(./findDevice "$TEST_IOS_VERSION" "$TEST_IOS_SIMULATOR_MODEL")
rm ./findDevice

# Run a build
set -o pipefail && xcodebuild build \
    -skipMacroValidation -skipPackagePluginValidation \
    -scheme Hoods \
    -destination generic/platform=ios \
    | xcpretty

# Run a test
set -o pipefail && xcodebuild test \
    -skipMacroValidation -skipPackagePluginValidation \
    -workspace Hoods.xcworkspace \
    -scheme Hoods \
    -destination platform="iOS Simulator,id=$DEVICE_ID" \
    | xcpretty

# Run a test
set -o pipefail && xcodebuild test \
    -skipMacroValidation -skipPackagePluginValidation \
    -workspace Hoods.xcworkspace \
    -scheme HoodsApp \
    -destination platform="iOS Simulator,id=$DEVICE_ID" \
    | xcpretty