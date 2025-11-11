---
"swift-hoods": minor
---

Add `SnapshottingTransport` to `HoodsTestsTools` for snapshot testing network
interactions. This Transport wrapper captures snapshots of URL requests and
responses using the SnapshotTesting framework, enabling verification of network
interactions in tests by comparing request/response snapshots.
