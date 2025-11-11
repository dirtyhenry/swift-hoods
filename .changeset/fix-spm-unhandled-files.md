---
"swift-hoods": patch
---

Fix Swift Package Manager unhandled files warning by adding `__Snapshots__`
directory as a processed resource and excluding `Hoods.xctestplan` from the
HoodsTests target.
