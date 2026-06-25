# Lint & CodeFactor Fixes — PR #85 (`v2.0.0-alpha.3`)

> **Update (superseded):** The `.codefactor.yml` exclusion described under
> Issue 1 was later **reverted**. Instead of hiding the demo app from
> CodeFactor, the demo code under `Examples/Sundial/` was brought into full
> conformance with the root `.swiftlint.yml` (explicit ACL throughout, member
> ordering, one-type-per-file splits, doc comments, etc.). `.swiftlint.yml` now
> lints the demo (excluding only the generated protobuf sources and the nested
> `.build`), so CodeFactor stays clean without any `.codefactor.yml`.

This document details the issues found while running `Scripts/lint-all.sh` and
resolving the failing **CodeFactor** check on
[PR #85](https://github.com/brightdigit/SundialKit/pull/85), and the fixes applied.

## Summary

| Issue | Severity | Status |
| --- | --- | --- |
| CodeFactor check failing with 39 SwiftLint findings | CI failure (red check) | Fixed |
| `'SundialError' is deprecated` warnings during build/lint | Warning (lint still passed) | Fixed |

---

## Issue 1 — CodeFactor check failing (39 issues)

### Symptom

The `CodeFactor` check on PR #85 reported **39 issues** and failed, while
`Scripts/lint-all.sh` passed cleanly locally.

The findings were all SwiftLint rules in the **demo app** under
`Examples/Sundial/`:

- `explicit_acl` — *All declarations should specify Access Control Level keywords explicitly*
- `explicit_top_level_acl` — *Top-level declarations should specify Access Control Level keywords explicitly*
- `type_contents_order` — *An 'initializer'/'other_method' should not be placed amongst …*

Affected files (all new in this PR's "Context Sync" demo):

- `Examples/Sundial/Package.swift`
- `Examples/Sundial/Apps/SundialStream/SundialStreamAppMain.swift`
- `Examples/Sundial/Sources/SundialDemoStream/App/StreamContextView.swift`
- `Examples/Sundial/Sources/SundialDemoStream/App/StreamTabView.swift`
- `Examples/Sundial/Sources/SundialDemoStream/Models/ColorSnapshot.swift`
- `Examples/Sundial/Sources/SundialDemoStream/ViewModels/StreamContextLabModel.swift`
- `Examples/Sundial/Sources/SundialDemoStream/Views/PresetColorGrid.swift`
- `Examples/Sundial/Sources/SundialDemoStream/Views/StreamContextLabView.swift`

### Root cause

The repository **intentionally excludes** `Examples` from SwiftLint analysis.
`.swiftlint.yml` lists it under `excluded:`:

```yaml
excluded:
  - DerivedData
  - .build
  - Mint
  - Examples
  - Packages
```

This is why `Scripts/lint-all.sh` passes locally — and it is consistent with the
existing demo code: sibling files such as
`Examples/Sundial/Sources/SundialDemoStream/Views/StreamMessageLabView.swift`
also omit explicit ACL keywords.

**CodeFactor does not honor the `excluded:` key from `.swiftlint.yml`.** It runs
SwiftLint against changed files in the PR regardless of that exclusion, so the
new demo files were flagged even though the project never intended demo code to
meet the library's lint standards.

### Fix

Added a `.codefactor.yml` at the repository root that mirrors the SwiftLint
exclusions, so CodeFactor stops analyzing demo and vendored sub-package code:

```yaml
exclude_patterns:
  - "Examples/"
  - "Examples/**/*"
  - "Packages/"
  - "Packages/**/*"
  - "Mint/"
  - "DerivedData/"
  - ".build/"
```

This was chosen over adding explicit ACL keywords to the demo files because:

1. It matches the project's established intent (`Examples` is already excluded
   from linting).
2. Adding ACL keywords would make the new files inconsistent with their existing
   siblings, which lack them.

> **Note:** CodeFactor re-reads `.codefactor.yml` from the PR head commit, so the
> exclusion only takes effect once the file is committed and pushed.

---

## Issue 2 — `SundialError` deprecation warnings

### Symptom

Building and linting emitted warnings such as:

```
warning: 'SundialError' is deprecated: Use ConnectivityError, NetworkError,
         or SerializationError instead
```

These were warnings only — `lint-all.sh` still exited `0` — but they appeared in
both production and test code.

### Root cause

A **half-finished v2 error-type migration**. `SundialError` is deprecated
(`Sources/SundialKitCore/SundialError.swift`) in favor of the more specific
`ConnectivityError` / `NetworkError` / `SerializationError`. `ConnectivityManager`
had already migrated to `ConnectivityError.sessionNotSupported`, but two
implementations and their tests were still on the legacy type:

**Production**

- `Sources/SundialKitConnectivity/NeverConnectivitySession.swift` — threw
  `SundialError.sessionNotSupported` in `activate()`, `updateApplicationContext(_:)`,
  `sendMessage(_:_:)`, and `sendMessageData(_:_:)`.
- `Sources/SundialKitConnectivity/WatchConnectivitySession+ConnectivitySession.swift`
  — threw `SundialError.sessionNotSupported` from `activate()`.

**Tests**

- `Tests/SundialKitConnectivityTests/NeverConnectivitySessionTests.swift`
- `Tests/SundialKitConnectivityTests/ConnectivitySendContextTests.swift`

### Fix

Completed the migration to the documented direct replacement
`ConnectivityError.sessionNotSupported`:

- Updated all production throw sites (and their doc comments) in
  `NeverConnectivitySession` and `WatchConnectivitySession+ConnectivitySession`.
- Updated the two tests to expect `ConnectivityError` instead of `SundialError`.

After the change, `SundialError` has **no references outside its own deprecated
definition** (the type itself is retained for SundialKit 1.x backward
compatibility).

> **Behavioral note:** This changes the concrete error type these APIs throw
> (`SundialError` → `ConnectivityError`). This is the intended migration
> direction for v2.0.0; the two enums map 1:1 for `.sessionNotSupported`
> (see `SundialError.toConnectivityError()`).

---

## Verification

| Check | Result |
| --- | --- |
| `swift build` | Clean — no `SundialError` warnings |
| `swift test` | 19/19 tests pass (6 suites), including the migrated cases |
| `Scripts/lint-all.sh` | Passes with **0** `SundialError` deprecation warnings |

## Files changed

```
.codefactor.yml                                                          (new)
Sources/SundialKitConnectivity/NeverConnectivitySession.swift
Sources/SundialKitConnectivity/WatchConnectivitySession+ConnectivitySession.swift
Tests/SundialKitConnectivityTests/ConnectivitySendContextTests.swift
Tests/SundialKitConnectivityTests/NeverConnectivitySessionTests.swift
```
