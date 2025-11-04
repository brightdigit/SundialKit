# Sundial Demo Apps Deployment Guide

## Overview

This directory contains two demo applications:
- **Pulse** (SundialCombine) - Demonstrates SundialKit with Combine
- **Flow** (SundialStream) - Demonstrates SundialKit with AsyncStream

Both apps support iOS and watchOS.

## Prerequisites

- Xcode 16.0+ (Swift 6.1+)
- Ruby 3.3+ with bundler
- xcodegen installed (`brew install xcodegen`)
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
export DEVELOPMENT_TEAM="ask-team-for-team-id"
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

Then regenerate project and deploy:
```bash
xcodegen generate
make demo-beta-all
```

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

## App Information

### Bundle Identifiers

- Pulse iOS: `com.brightdigit.sundial.combine.ios`
- Pulse watchOS: `com.brightdigit.sundial.combine.ios.watchkitapp`
- Flow iOS: `com.brightdigit.sundial.stream.ios`
- Flow watchOS: `com.brightdigit.sundial.stream.ios.watchkitapp`

### Display Names

- Pulse (both iOS and watchOS)
- Flow (both iOS and watchOS)

### Team Information

- **Developer Team**: Configured via `DEVELOPMENT_TEAM` environment variable (ask team for value)
- **App Store Connect Team**: 2108001
- **Apple ID**: leogdion@brightdigit.com
- **Certificate Repo**: git@github.com:brightdigit/AppCerts.git

## Troubleshooting

### Certificate Issues

If certificates are out of sync:
```bash
bundle exec fastlane match appstore --readonly --force
```

### SSH Authentication Issues (CI/CD)

If GitHub Actions fails with certificate repository access errors:

1. Verify the `APPCERTS_DEPLOY_KEY` organizational secret is configured
2. Ensure the corresponding public key is added as a deploy key to the AppCerts repository
3. Check that the deploy key has read access enabled
4. Verify the workflow includes the `webfactory/ssh-agent` step before fastlane commands

To regenerate the deploy key:
```bash
# Generate new SSH key pair (no passphrase)
ssh-keygen -t ed25519 -C "brightdigit-github-actions" -f appcerts_deploy_key -N ""

# Add public key (appcerts_deploy_key.pub) as deploy key to AppCerts repo
# Add private key (appcerts_deploy_key) as APPCERTS_DEPLOY_KEY organizational secret
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

### Xcodegen Not Found

Install xcodegen:
```bash
brew install xcodegen
```

## Required GitHub Secrets

For CI/CD deployment, configure these secrets:

### Organization-Level Secrets
These are configured at the BrightDigit organization level and shared across repositories:

- `APPCERTS_DEPLOY_KEY` - SSH private key for accessing the AppCerts repository (deploy key with read-only access)

### Repository-Level Secrets
These are configured in the SundialKit repository settings:

- `DEVELOPMENT_TEAM` - Apple Developer Team ID (10-character alphanumeric identifier)
- `MATCH_PASSWORD` - Password to decrypt match certificates
- `APP_STORE_CONNECT_API_KEY_KEY_ID` - App Store Connect API key ID
- `APP_STORE_CONNECT_API_KEY_ISSUER_ID` - API issuer ID
- `APP_STORE_CONNECT_API_KEY_KEY` - API key content (base64 encoded)

Note: `FASTLANE_KEYCHAIN_PASSWORD` is automatically generated per-run and doesn't need to be configured.

## Resources

- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Fastlane Match](https://docs.fastlane.tools/actions/match/)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)

## App Icons

### Pulse (Warm Theme)
- Colors: Orange, red, yellow
- Visual: Rhythmic/heartbeat pattern, circular designs
- Location: `Resources/iOS/Assets.xcassets/AppIcon-Pulse.appiconset/`
- Location: `Resources/watchOS/Assets.xcassets/AppIcon-Pulse.appiconset/`

### Flow (Cool Theme)
- Colors: Blue, teal, cyan
- Visual: Flowing/stream pattern, water/gradients
- Location: `Resources/iOS/Assets.xcassets/AppIcon-Flow.appiconset/`
- Location: `Resources/watchOS/Assets.xcassets/AppIcon-Flow.appiconset/`

Place 1024x1024px icons in the respective directories.

## Support

For questions or issues:
- Check existing GitHub issues
- Contact the BrightDigit development team
- Review Fastlane logs in `Examples/Sundial/fastlane/report.xml`
