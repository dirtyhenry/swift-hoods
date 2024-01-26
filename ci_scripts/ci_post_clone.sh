#!/bin/sh

# Accepts to run macros.
# Since TCA uses macros such as `CasePathsMacros` or `ComposableArchitectureMacros`, this is required.
# 📜 https://stackoverflow.com/questions/77267883/how-do-i-trust-a-swift-macro-target-for-xcode-cloud-builds
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
