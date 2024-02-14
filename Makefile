CONFIG = debug
PLATFORM_IOS = iOS Simulator,id=$(call udid_for,iOS 17.2,iPhone \d\+ Pro [^M])
PLATFORM_MACOS = macOS

open: 
	open Hoods.xcworkspace

install:
	bundle install
	swift package resolve

build:
	swift build

test-debug:
	swift package clean
	swift test --verbose --very-verbose

test:
	for platform in "$(PLATFORM_IOS)" "$(PLATFORM_MACOS)"; do \
		xcodebuild test \
			-skipMacroValidation \
			-configuration $(CONFIG) \
			-workspace .github/package.xcworkspace \
			-scheme Hoods \
			-destination platform="$$platform" || exit 1; \
	done

release:
	swift build -c release

format:
	swiftformat --verbose .
	swiftlint lint --autocorrect .
	
lint:
	swiftformat --lint .
	swiftlint lint .

clean:
	rm -rf .build/
	rm -rf .swiftpm/
	rm -rf Examples/HoodsCLI/.build/
	rm -rf Examples/HoodsCLI/.swiftpm/
	rm -rf .Hoods.doccarchive/

docs:
	xcodebuild docbuild -scheme "Hoods" -derivedDataPath tmp/derivedDataPath -destination platform=macOS
	rsync -r tmp/derivedDataPath/Build/Products/Debug/Hoods.doccarchive/ .Hoods.doccarchive
	rm -rf tmp/

serve-docs:
	serve --single .Hoods.doccarchive

cli: ## Build the demo CLI	
	swift package update --package-path Examples/HoodsCLI/
	swift build --package-path Examples/HoodsCLI/

define udid_for
$(shell xcrun simctl list devices available '$(1)' | grep '$(2)' | sort -r | head -1 | awk -F '[()]' '{ print $$(NF-3) }')
endef
