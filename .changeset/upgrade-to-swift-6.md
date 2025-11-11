---
"swift-hoods": minor
---

Upgrade to Swift 6.0 with full strict concurrency support. This migration
includes:

- Upgraded Swift tools version from 5.9 to 6.0
- Updated to The Composable Architecture 1.23.1 with Swift 6 compatibility
- Upgraded Yams dependency from 5.0.6 to 6.0.0
- Added explicit strict concurrency settings to all Package.swift targets
- Updated all TCA reducers to use modern Swift 6 concurrency patterns with
  proper dependency capture in closures
- Modernized TCA code with @Reducer and @ObservableState macros throughout the
  codebase
