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
	swift test

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
