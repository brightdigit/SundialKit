.PHONY: demo-generate demo-build-pulse demo-build-flow demo-beta-pulse demo-beta-flow demo-beta-all demo-install-certs demo-update-certs

# Generate Xcode project from project.yml
demo-generate:
	xcodegen generate

# Build commands (local testing)
demo-build-pulse: demo-generate
	xcodebuild -scheme SundialCombine -destination "generic/platform=iOS" clean build

demo-build-flow: demo-generate
	xcodebuild -scheme SundialStream -destination "generic/platform=iOS" clean build

# Certificate management
demo-install-certs:
	bundle install && bundle exec fastlane match appstore --readonly

demo-update-certs:
	bundle exec fastlane update_appstore_certs

# TestFlight deployment
demo-beta-pulse: demo-install-certs
	bundle exec fastlane beta_pulse

demo-beta-flow: demo-install-certs
	bundle exec fastlane beta_flow

demo-beta-all: demo-install-certs
	bundle exec fastlane beta_all
