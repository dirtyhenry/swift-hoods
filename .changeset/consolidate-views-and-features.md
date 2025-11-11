---
"swift-hoods": patch
---

Refactor TCA features for better code organization and encapsulation:

- Consolidate view files into their respective feature files (KeychainUI,
  CopyTextDemo)
- Make internal TCA features non-public with public wrapper views for library
  consumers
- Simplify ImagePicker view implementations
- Update project references and remove redundant view files
