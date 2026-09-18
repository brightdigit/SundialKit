# Changelog

Append new releases at the top. For each GitHub release, copy from that version’s `## What's Changed` through its `**Full Changelog**` line.

## 2.0.0-alpha.4

## What's Changed

This alpha aligns SundialKit with SundialKitStream `1.0.0-alpha.4`: the demo uses the renamed `SundialKitContext` product, and install snippets pin the matching alpha.4 tags.

* Updated the Sundial demo and documentation for SundialKitStream `1.0.0-alpha.4` and the `SundialKitContext` product by @leogdion in https://github.com/brightdigit/SundialKit/pull/94
* Bumped README and DocC install examples to `2.0.0-alpha.4` / `1.0.0-alpha.4` by @leogdion in https://github.com/brightdigit/SundialKit/pull/94

Ship with [SundialKitStream `1.0.0-alpha.4`](https://github.com/brightdigit/SundialKitStream/releases).

**Full Changelog**: https://github.com/brightdigit/SundialKit/compare/2.0.0-alpha.3...2.0.0-alpha.4

## 2.0.0-alpha.3

## What's Changed

This alpha completes the v2 error-type migration, hardens WatchConnectivity session handling, and ships a new Context Sync demo — alongside a full lint/CI cleanup of the example app.

* Hardened `WCSession` delegate registration and reply handling for more reliable activation and message replies by @leogdion in https://github.com/brightdigit/SundialKit/pull/84
* Completed the v2 error migration — `NeverConnectivitySession` and `WatchConnectivitySession` now throw `ConnectivityError.sessionNotSupported` instead of the deprecated `SundialError`, clearing all deprecation warnings
* Stream activation now re-throws on failure so consumers no longer spin in an infinite `for await` loop on a dead session
* Added a Context Sync demo built on `SundialKitStreamContext` to the Sundial Stream example by @leogdion in https://github.com/brightdigit/SundialKit/pull/91
* Brought the demo app into full SwiftLint conformance with the library standard
* Demo fixes: per-field `ColorSnapshot` decode guards, real `ConnectivityObserver` state wiring in the Combine path, de-duplicated message builders with real per-platform OS detection
* Added the Swift 6.4 nightly toolchain (noble, SPM) as a non-blocking matrix row + matching devcontainer
* Reverted the coverage step to upstream `sersoft-gmbh/swift-coverage-action@v5`
* CodeFactor config tuned to ignore generated protobuf sources
* Pinned SundialKit/SundialKitStream dependencies to their release tags for the release
* Apply AtLeast customizations onto v2.0.0-alpha.3 by @leogdion in https://github.com/brightdigit/SundialKit/pull/90
* Updates from AtLeast by @leogdion in https://github.com/brightdigit/SundialKit/pull/81
* Updates from Bitness by @leogdion in https://github.com/brightdigit/SundialKit/pull/74

**Full Changelog**: https://github.com/brightdigit/SundialKit/compare/2.0.0-alpha.2...2.0.0-alpha.3

## 2.0.0-alpha.2

## What's Changed

* docs: update version references to alpha releases by @leogdion in https://github.com/brightdigit/SundialKit/pull/72
* Overhaul CI matrix, add Windows/Android builds, clean up tooling scaffolding by @leogdion in https://github.com/brightdigit/SundialKit/pull/79

**Full Changelog**: https://github.com/brightdigit/SundialKit/compare/2.0.0-alpha.1...2.0.0-alpha.2

## 2.0.0-alpha.1

## What's Changed

* Add Claude Code GitHub Workflow by @leogdion in https://github.com/brightdigit/SundialKit/pull/27
* Add Task Master and Claude Code integration documentation and configuration by @leogdion in https://github.com/brightdigit/SundialKit/pull/28
* Setup Subrepos for v2.0.0 development by @leogdion in https://github.com/brightdigit/SundialKit/pull/42
* Create SundialKitCore with protocols and typed error by @leogdion in https://github.com/brightdigit/SundialKit/pull/44
* feat(network): Task 2 - Extract NetworkMonitor from NetworkObserver by @leogdion in https://github.com/brightdigit/SundialKit/pull/46
* Extract ConnectivityManager from ConnectivityObserver by @leogdion in https://github.com/brightdigit/SundialKit/pull/47
* Adding Setup for Examples Demo by @leogdion in https://github.com/brightdigit/SundialKit/pull/50
* Adding Message Lab View by @leogdion in https://github.com/brightdigit/SundialKit/pull/51
* docs(demo): Add Demo Applications section to README by @leogdion in https://github.com/brightdigit/SundialKit/pull/53
* Creating Streaming Flow Demo Application by @leogdion in https://github.com/brightdigit/SundialKit/pull/54
* Posting First Version of Demo Application by @leogdion in https://github.com/brightdigit/SundialKit/pull/55
* fix(tests): increase test timeouts to prevent intermittent CI failures by @leogdion in https://github.com/brightdigit/SundialKit/pull/56
* refactor(connectivity): remove DispatchQueue from observer notifications by @leogdion in https://github.com/brightdigit/SundialKit/pull/60
* feat: migrate print statements to OSLog with unified logging infrastructure by @leogdion in https://github.com/brightdigit/SundialKit/pull/61
* Fixing CI Unit Test Issues with watchOS and iOS by @leogdion in https://github.com/brightdigit/SundialKit/pull/67
* Updating Documentation by @leogdion in https://github.com/brightdigit/SundialKit/pull/66
* Fix README Files by @leogdion in https://github.com/brightdigit/SundialKit/pull/70
* Fixing Remote Dependencies Script by @leogdion in https://github.com/brightdigit/SundialKit/pull/49
* Fixing DEVELOPMENT_TEAM for Demo by @leogdion in https://github.com/brightdigit/SundialKit/pull/57
* Fixing Transport Tab by @leogdion in https://github.com/brightdigit/SundialKit/pull/59

**Full Changelog**: https://github.com/brightdigit/SundialKit/compare/1.0.0-beta.1...2.0.0-alpha.1
