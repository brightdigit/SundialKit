# TestFlight Setup Plan for Pulse & Flow Demo Apps

**Date**: 2025-10-29
**Status**: Planning
**Target**: Internal TestFlight distribution only

## Overview

Set up fastlane automation for internal TestFlight distribution of both SundialKit demo apps with comprehensive CI/CD that includes building, testing, and linting (following Bitness repository patterns and SundialKit package CI patterns).

## Demo Apps

- **Pulse** - Combine variant demo (`SundialCombine`)
- **Flow** - Stream variant demo (`SundialStream`)

Both apps have iOS and watchOS companion targets.

---

## Phase 1: Display Names & Version Management in project.yml

**File**: `Examples/Sundial/project.yml`

### Add Global Settings for Version Management

```yaml
settings:
  base:
    MARKETING_VERSION: "1.0.0"
    CURRENT_PROJECT_VERSION: "1"
    SWIFT_VERSION: "6.1"
    ENABLE_USER_SCRIPT_SANDBOXING: NO
    DEVELOPMENT_TEAM: ${DEVELOPMENT_TEAM}
```

### Add Display Names Per Target

```yaml
targets:
  SundialCombine-iOS:
    settings:
      base:
        PRODUCT_NAME: SundialCombine
        PRODUCT_DISPLAY_NAME: Pulse
        # ... existing settings

  SundialCombine-watchOS:
    settings:
      base:
        PRODUCT_NAME: SundialCombine
        PRODUCT_DISPLAY_NAME: Pulse
        # ... existing settings

  SundialStream-iOS:
    settings:
      base:
        PRODUCT_NAME: SundialStream
        PRODUCT_DISPLAY_NAME: Flow
        # ... existing settings

  SundialStream-watchOS:
    settings:
      base:
        PRODUCT_NAME: SundialStream
        PRODUCT_DISPLAY_NAME: Flow
        # ... existing settings
```

### Regenerate Project

```bash
cd Examples/Sundial
xcodegen generate
```

---

## Phase 2: Code Signing Configuration in project.yml

**File**: `Examples/Sundial/project.yml`

Add signing settings to each target:

```yaml
targets:
  SundialCombine-iOS:
    settings:
      base:
        # ... existing settings
        CODE_SIGN_STYLE: Manual
        CODE_SIGN_IDENTITY: "iPhone Distribution"
        PROVISIONING_PROFILE_SPECIFIER: "match AppStore com.brightdigit.sundial.combine.ios"

  SundialCombine-watchOS:
    settings:
      base:
        # ... existing settings
        CODE_SIGN_STYLE: Manual
        CODE_SIGN_IDENTITY: "iPhone Distribution"
        PROVISIONING_PROFILE_SPECIFIER: "match AppStore com.brightdigit.sundial.combine.ios.watchkitapp"

  SundialStream-iOS:
    settings:
      base:
        # ... existing settings
        CODE_SIGN_STYLE: Manual
        CODE_SIGN_IDENTITY: "iPhone Distribution"
        PROVISIONING_PROFILE_SPECIFIER: "match AppStore com.brightdigit.sundial.stream.ios"

  SundialStream-watchOS:
    settings:
      base:
        # ... existing settings
        CODE_SIGN_STYLE: Manual
        CODE_SIGN_IDENTITY: "iPhone Distribution"
        PROVISIONING_PROFILE_SPECIFIER: "match AppStore com.brightdigit.sundial.stream.ios.watchkitapp"
```

---

## Phase 3: Fastlane Directory Structure

**Directory**: `Examples/Sundial/Fastlane/`

Note: Use capital 'F' following Bitness pattern.

### Fastfile

**File**: `Examples/Sundial/Fastlane/Fastfile`

```ruby
default_platform(:ios)

platform :ios do
  desc "Build and upload Pulse to TestFlight"
  lane :beta_pulse do
    build_and_upload(
      scheme: "SundialCombine",
      bundle_ids: {
        "com.brightdigit.sundial.combine.ios" => "match AppStore com.brightdigit.sundial.combine.ios",
        "com.brightdigit.sundial.combine.ios.watchkitapp" => "match AppStore com.brightdigit.sundial.combine.ios.watchkitapp"
      }
    )
  end

  desc "Build and upload Flow to TestFlight"
  lane :beta_flow do
    build_and_upload(
      scheme: "SundialStream",
      bundle_ids: {
        "com.brightdigit.sundial.stream.ios" => "match AppStore com.brightdigit.sundial.stream.ios",
        "com.brightdigit.sundial.stream.ios.watchkitapp" => "match AppStore com.brightdigit.sundial.stream.ios.watchkitapp"
      }
    )
  end

  desc "Build and upload both apps to TestFlight"
  lane :beta_all do
    beta_pulse
    beta_flow
  end

  desc "Sync certificates (readonly for CI)"
  lane :sync_certs do
    match(
      type: "appstore",
      readonly: true,
      keychain_password: ENV['FASTLANE_KEYCHAIN_PASSWORD']
    )
  end

  desc "Update App Store certificates (local only)"
  lane :update_appstore_certs do
    match(
      type: "appstore",
      readonly: false,
      force_for_new_devices: true
    )
  end

  # Private helper lane
  private_lane :build_and_upload do |options|
    # Generate Xcode project first
    sh("cd .. && xcodegen generate")

    # App Store Connect API authentication
    api_key = app_store_connect_api_key(
      key_id: ENV['APP_STORE_CONNECT_API_KEY_KEY_ID'],
      issuer_id: ENV['APP_STORE_CONNECT_API_KEY_ISSUER_ID'],
      key_content: ENV['APP_STORE_CONNECT_API_KEY_KEY']
    )

    # Fetch certificates (readonly for CI)
    match(
      type: "appstore",
      readonly: is_ci,
      keychain_password: ENV['FASTLANE_KEYCHAIN_PASSWORD']
    )

    # Build app
    build_app(
      scheme: options[:scheme],
      destination: "generic/platform=iOS",
      skip_package_pkg: true,
      export_options: {
        provisioningProfiles: options[:bundle_ids]
      }
    )

    # Upload to TestFlight
    upload_to_testflight(
      api_key: api_key,
      skip_waiting_for_build_processing: true
    )
  end
end
```

### Appfile

**File**: `Examples/Sundial/Fastlane/Appfile`

```ruby
apple_id("leogdion@brightdigit.com")
itc_team_id("2108001")
team_id("MLT7M394S7")
```

### Matchfile

**File**: `Examples/Sundial/Fastlane/Matchfile`

```ruby
git_url("git@github.com:brightdigit/AppCerts.git")
storage_mode("git")
type("appstore")
username("ci-appstore@brightdigit.com")
platform("ios")
app_identifier([
  "com.brightdigit.sundial.combine.ios",
  "com.brightdigit.sundial.combine.ios.watchkitapp",
  "com.brightdigit.sundial.stream.ios",
  "com.brightdigit.sundial.stream.ios.watchkitapp"
])
```

---

## Phase 4: Ruby Dependencies

**File**: `Examples/Sundial/Gemfile`

```ruby
source "https://rubygems.org"

gem "fastlane"
```

### Install Dependencies

```bash
cd Examples/Sundial
bundle install
```

This creates `Gemfile.lock` - commit both files to repository.

---

## Phase 5: App Icons

Create distinct app icons for each variant to easily differentiate on device.

### Design Themes

- **Pulse**: Warm colors (orange, red, yellow), rhythmic/heartbeat visual, circular patterns
- **Flow**: Cool colors (blue, teal, cyan), flowing/stream visual, water/gradient

### Implementation Options

**Option A: Separate Asset Catalogs**
- Create `Resources/iOS/Assets-Pulse.xcassets/`
- Create `Resources/iOS/Assets-Flow.xcassets/`
- Create `Resources/watchOS/Assets-Pulse.xcassets/`
- Create `Resources/watchOS/Assets-Flow.xcassets/`
- Update `project.yml` to point each target to its catalog

**Option B: Same Catalogs, Different AppIcon Sets**
- Keep existing asset catalogs
- Create multiple AppIcon sets within each catalog
- Update targets to reference different icon sets

### Update project.yml (if using Option A)

```yaml
targets:
  SundialCombine-iOS:
    sources:
      - path: Resources/iOS-Pulse
        type: folder
        buildPhase: resources

  SundialStream-iOS:
    sources:
      - path: Resources/iOS-Flow
        type: folder
        buildPhase: resources
```

---

## Phase 6: GitHub Actions CI/CD Workflow

**File**: `.github/workflows/sundial-demo.yml`

```yaml
name: Sundial Demo Apps
on:
  push:
    branches-ignore:
      - '*WIP'
    paths:
      - 'Examples/Sundial/**'
      - '.github/workflows/sundial-demo.yml'
  workflow_dispatch:
    inputs:
      deploy_testflight:
        description: 'Deploy to TestFlight'
        required: false
        type: boolean
        default: false

env:
  DEMO_PATH: Examples/Sundial

jobs:
  # Build and test demo apps across Xcode versions
  build-demo:
    name: Build Sundial Demo
    runs-on: ${{ matrix.runs-on }}
    if: ${{ !contains(github.event.head_commit.message, 'ci skip') }}
    strategy:
      fail-fast: false
      matrix:
        include:
          # iOS Builds - Xcode 26.1
          - type: ios
            runs-on: macos-26
            xcode: "/Applications/Xcode_26.1.app"
            scheme: "SundialCombine"
            deviceName: "iPhone 17 Pro"
            osVersion: "26.1"
            download-platform: true

          # iOS Builds - Xcode 16.4
          - type: ios
            runs-on: macos-15
            xcode: "/Applications/Xcode_16.4.app"
            scheme: "SundialCombine"
            deviceName: "iPhone 16e"
            osVersion: "18.5"

          # Stream variant builds
          - type: ios
            runs-on: macos-26
            xcode: "/Applications/Xcode_26.1.app"
            scheme: "SundialStream"
            deviceName: "iPhone 17 Pro"
            osVersion: "26.1"
            download-platform: true

          - type: ios
            runs-on: macos-15
            xcode: "/Applications/Xcode_16.4.app"
            scheme: "SundialStream"
            deviceName: "iPhone 16e"
            osVersion: "18.5"

          # watchOS Builds - Xcode 26.1
          - type: watchos
            runs-on: macos-26
            xcode: "/Applications/Xcode_26.1.app"
            scheme: "SundialCombine"
            deviceName: "Apple Watch Ultra 3 (49mm)"
            osVersion: "26.0"
            download-platform: true

          # watchOS Builds - Xcode 16.4
          - type: watchos
            runs-on: macos-15
            xcode: "/Applications/Xcode_16.4.app"
            scheme: "SundialCombine"
            deviceName: "Apple Watch Series 10 (46mm)"
            osVersion: "11.5"

    steps:
      - uses: actions/checkout@v4

      - name: Generate Xcode Project
        run: |
          cd ${{ env.DEMO_PATH }}
          xcodegen generate

      - name: Build and Test
        uses: brightdigit/swift-build@v1.4.0
        with:
          scheme: ${{ matrix.scheme }}
          type: ${{ matrix.type }}
          xcode: ${{ matrix.xcode }}
          deviceName: ${{ matrix.deviceName }}
          osVersion: ${{ matrix.osVersion }}
          download-platform: ${{ matrix.download-platform }}
          working-directory: ${{ env.DEMO_PATH }}

  # Lint demo app code
  lint-demo:
    name: Lint Sundial Demo
    runs-on: ubuntu-latest
    needs: [build-demo]
    if: ${{ !contains(github.event.head_commit.message, 'ci skip') }}
    env:
      MINT_PATH: .mint/lib
      MINT_LINK_PATH: .mint/bin
      LINT_MODE: STRICT
    steps:
      - uses: actions/checkout@v4

      - name: Cache mint
        id: cache-mint
        uses: actions/cache@v4
        with:
          path: |
            .mint
            Mint
          key: ${{ runner.os }}-mint-${{ hashFiles('**/Mintfile') }}
          restore-keys: |
            ${{ runner.os }}-mint-

      - name: Install mint
        if: steps.cache-mint.outputs.cache-hit == ''
        run: |
          git clone https://github.com/yonaskolb/Mint.git
          cd Mint
          swift run mint install yonaskolb/mint

      - name: Lint Demo Apps
        run: |
          # Run linting on demo app sources
          # Note: May need to create dedicated lint script for demo apps
          # or adapt Scripts/lint.sh to handle Examples/Sundial path
          ./Scripts/lint.sh

  # TestFlight deployment (manual trigger or on tags)
  deploy-testflight:
    name: Deploy to TestFlight
    runs-on: macos-latest
    needs: [build-demo, lint-demo]
    if: |
      (github.event_name == 'workflow_dispatch' &&
       github.event.inputs.deploy_testflight == 'true') ||
      startsWith(github.ref, 'refs/tags/demo-v')
    steps:
      - uses: actions/checkout@v4

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3.0'
          bundler-cache: true
          working-directory: ${{ env.DEMO_PATH }}

      - name: Generate Xcode Project
        run: |
          cd ${{ env.DEMO_PATH }}
          xcodegen generate

      - name: Deploy Pulse to TestFlight
        run: |
          cd ${{ env.DEMO_PATH }}
          bundle exec fastlane beta_pulse
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          FASTLANE_KEYCHAIN_PASSWORD: ${{ secrets.FASTLANE_KEYCHAIN_PASSWORD }}
          APP_STORE_CONNECT_API_KEY_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_KEY_ID }}
          APP_STORE_CONNECT_API_KEY_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ISSUER_ID }}
          APP_STORE_CONNECT_API_KEY_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY_KEY }}
          DEVELOPMENT_TEAM: MLT7M394S7

      - name: Deploy Flow to TestFlight
        run: |
          cd ${{ env.DEMO_PATH }}
          bundle exec fastlane beta_flow
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          FASTLANE_KEYCHAIN_PASSWORD: ${{ secrets.FASTLANE_KEYCHAIN_PASSWORD }}
          APP_STORE_CONNECT_API_KEY_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_KEY_ID }}
          APP_STORE_CONNECT_API_KEY_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ISSUER_ID }}
          APP_STORE_CONNECT_API_KEY_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY_KEY }}
          DEVELOPMENT_TEAM: MLT7M394S7
```

### Workflow Triggers

- **Automatic build/lint**: On pushes to `Examples/Sundial/**`
- **Manual TestFlight deployment**: Via workflow_dispatch with checkbox
- **Automatic TestFlight deployment**: On version tags like `demo-v1.0.0`

### Required GitHub Secrets

Add these secrets to repository settings:

- `MATCH_PASSWORD` - Password to decrypt match certificates
- `FASTLANE_KEYCHAIN_PASSWORD` - CI keychain password
- `APP_STORE_CONNECT_API_KEY_KEY_ID` - App Store Connect API key ID
- `APP_STORE_CONNECT_API_KEY_ISSUER_ID` - API issuer ID
- `APP_STORE_CONNECT_API_KEY_KEY` - API key content (base64 encoded)

---

## Phase 7: Makefile Integration

**File**: `Makefile` (root) or create `Examples/Sundial/Makefile`

Add these targets:

```makefile
.PHONY: demo-generate demo-build-pulse demo-build-flow demo-beta-pulse demo-beta-flow demo-beta-all demo-install-certs

# Generate Xcode project from project.yml
demo-generate:
	cd Examples/Sundial && xcodegen generate

# Build commands (local testing)
demo-build-pulse: demo-generate
	cd Examples/Sundial && xcodebuild -scheme SundialCombine -destination "generic/platform=iOS" clean build

demo-build-flow: demo-generate
	cd Examples/Sundial && xcodebuild -scheme SundialStream -destination "generic/platform=iOS" clean build

# Certificate management
demo-install-certs:
	cd Examples/Sundial && bundle install && bundle exec fastlane match appstore --readonly

demo-update-certs:
	cd Examples/Sundial && bundle exec fastlane update_appstore_certs

# TestFlight deployment
demo-beta-pulse: demo-install-certs
	cd Examples/Sundial && bundle exec fastlane beta_pulse

demo-beta-flow: demo-install-certs
	cd Examples/Sundial && bundle exec fastlane beta_flow

demo-beta-all: demo-install-certs
	cd Examples/Sundial && bundle exec fastlane beta_all
```

---

## Phase 8: Code Signing Setup

### Initial Certificate Sync

```bash
cd Examples/Sundial
bundle exec fastlane match appstore --readonly
```

This syncs provisioning profiles from the existing `brightdigit/AppCerts` repository.

### What This Creates

Match will create/sync these profiles in AppCerts repo:
- `match AppStore com.brightdigit.sundial.combine.ios`
- `match AppStore com.brightdigit.sundial.combine.ios.watchkitapp`
- `match AppStore com.brightdigit.sundial.stream.ios`
- `match AppStore com.brightdigit.sundial.stream.ios.watchkitapp`

### Environment Variables

Set locally in `.env` or shell:
```bash
export MATCH_PASSWORD="your-match-password"
export DEVELOPMENT_TEAM="MLT7M394S7"
```

---

## Phase 9: App Store Connect Setup

### Create App Records

1. Log into App Store Connect
2. Create two new apps:

**App 1: Pulse**
- Name: Pulse (or "Sundial Pulse" to avoid collision)
- Primary Language: English
- Bundle ID: `com.brightdigit.sundial.combine.ios`
- SKU: `sundial-pulse`

**App 2: Flow**
- Name: Flow (or "Sundial Flow")
- Primary Language: English
- Bundle ID: `com.brightdigit.sundial.stream.ios`
- SKU: `sundial-flow`

### Enable TestFlight

For each app:
1. Go to TestFlight tab
2. Enable internal testing
3. Create internal testing group (e.g., "BrightDigit Team")
4. Add testers to group

### Compliance (Minimal)

For internal testing only, set:
- Export Compliance: "No" (if not using encryption)
- Or add `ITSAppUsesNonExemptEncryption: false` to Info.plist

### No Public Metadata Needed

Since this is internal TestFlight only:
- No App Store screenshots required
- No marketing description required
- No pricing/availability needed
- Beta App Description is optional but helpful

---

## Phase 10: Documentation

### Create DEPLOYMENT.md

**File**: `Examples/Sundial/DEPLOYMENT.md`

```markdown
# Sundial Demo Apps Deployment Guide

## Overview

This directory contains two demo applications:
- **Pulse** (SundialCombine) - Demonstrates SundialKit with Combine
- **Flow** (SundialStream) - Demonstrates SundialKit with AsyncStream

Both apps support iOS and watchOS.

## Prerequisites

- Xcode 16.4+ (Swift 6.1+)
- Ruby 3.3+ with bundler
- xcodegen installed
- Access to BrightDigit Apple Developer account
- Access to AppCerts repository

## Local Development

### Generate Xcode Project

```bash
cd Examples/Sundial
xcodegen generate
```

### Build Locally

```bash
# Build Pulse
make demo-build-pulse

# Build Flow
make demo-build-flow
```

### Run in Simulator

Open `Sundial.xcodeproj` and run the scheme:
- SundialCombine (Pulse)
- SundialStream (Flow)

## TestFlight Deployment

### Setup (One Time)

1. Install Ruby dependencies:
```bash
cd Examples/Sundial
bundle install
```

2. Sync code signing certificates:
```bash
bundle exec fastlane match appstore --readonly
```

3. Set environment variables:
```bash
export MATCH_PASSWORD="ask-team-for-password"
export DEVELOPMENT_TEAM="MLT7M394S7"
```

### Deploy to TestFlight

Deploy Pulse:
```bash
make demo-beta-pulse
```

Deploy Flow:
```bash
make demo-beta-flow
```

Deploy both:
```bash
make demo-beta-all
```

## Version Management

Update version in `project.yml`:

```yaml
settings:
  base:
    MARKETING_VERSION: "1.0.0"
    CURRENT_PROJECT_VERSION: "1"
```

Then regenerate project and deploy.

## CI/CD Deployment

### Manual Trigger

1. Go to Actions tab in GitHub
2. Select "Sundial Demo Apps" workflow
3. Click "Run workflow"
4. Check "Deploy to TestFlight"
5. Run

### Automatic Trigger

Create and push a version tag:
```bash
git tag demo-v1.0.0
git push origin demo-v1.0.0
```

## Troubleshooting

### Certificate Issues

If certificates are out of sync:
```bash
bundle exec fastlane match appstore --readonly --force
```

### Build Failures

Ensure Xcode project is up to date:
```bash
xcodegen generate
```

### Provisioning Profile Errors

Check that bundle IDs match in:
- `project.yml`
- App Store Connect
- `Matchfile`

### TestFlight Upload Fails

Verify App Store Connect API credentials are set:
- `APP_STORE_CONNECT_API_KEY_KEY_ID`
- `APP_STORE_CONNECT_API_KEY_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_KEY`

## Resources

- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Fastlane Match](https://docs.fastlane.tools/actions/match/)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)
```

### Update Main README

Add section to root `README.md`:

```markdown
## Demo Applications

SundialKit includes two demo applications showcasing different concurrency approaches:

- **Pulse** (`Examples/Sundial/SundialCombine`) - Combine-based reactive demo
- **Flow** (`Examples/Sundial/SundialStream`) - AsyncStream/actor-based demo

Both apps are available for internal testing via TestFlight.

See [Examples/Sundial/DEPLOYMENT.md](Examples/Sundial/DEPLOYMENT.md) for deployment instructions.
```

---

## Summary

### What Gets Created

- ✅ Version management in `project.yml`
- ✅ Display names: "Pulse" and "Flow"
- ✅ Fastlane configuration (Fastfile, Appfile, Matchfile)
- ✅ Ruby Gemfile with fastlane dependency
- ✅ Code signing with match and AppCerts repo
- ✅ GitHub Actions workflow (build + lint + deploy)
- ✅ Makefile targets for convenience
- ✅ Comprehensive deployment documentation
- ✅ Two App Store Connect records
- ✅ TestFlight internal testing groups

### What Needs Manual Work

- 🎨 Design distinct app icons for Pulse and Flow
- 🔑 Set up GitHub Secrets for CI/CD
- 🍎 Create App Store Connect app records
- 📝 Create lint script for demo apps (or adapt existing)

### Deployment Workflow

**Local:**
```bash
make demo-beta-pulse    # Deploy Pulse
make demo-beta-flow     # Deploy Flow
make demo-beta-all      # Deploy both
```

**CI/CD:**
- Push to main: Automatic build + lint
- Manual workflow dispatch: Build + lint + deploy to TestFlight
- Push tag `demo-v1.0.0`: Automatic build + lint + deploy to TestFlight

---

## Reference Information

### Team Information
- **Developer Team**: MLT7M394S7
- **App Store Connect Team**: 2108001
- **Apple ID**: leogdion@brightdigit.com
- **Certificate Repo**: git@github.com:brightdigit/AppCerts.git

### Bundle Identifiers
- Pulse iOS: `com.brightdigit.sundial.combine.ios`
- Pulse watchOS: `com.brightdigit.sundial.combine.ios.watchkitapp`
- Flow iOS: `com.brightdigit.sundial.stream.ios`
- Flow watchOS: `com.brightdigit.sundial.stream.ios.watchkitapp`

### Repository Patterns
- **Bitness**: Fastlane structure, Match configuration, API key auth
- **SundialKit**: CI workflow patterns, build matrix, lint integration
- **XcodeGen**: Project generation, version management in YAML

---

## Next Steps

1. Review and approve this plan
2. Execute Phase 1: Update project.yml
3. Execute remaining phases in order
4. Test locally before setting up CI/CD
5. Document any deviations or issues discovered during implementation
