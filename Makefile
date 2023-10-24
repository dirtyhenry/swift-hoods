open: 
	open BlocksTCA.xcworkspace

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
	rm -rf .BlocksTCA.doccarchive/

docs:
	xcodebuild docbuild -scheme "BlocksTCA" -derivedDataPath tmp/derivedDataPath -destination platform=macOS
	rsync -r tmp/derivedDataPath/Build/Products/Debug/BlocksTCA.doccarchive/ .BlocksTCA.doccarchive
	rm -rf tmp/

serve-docs:
	serve --single .BlocksTCA.doccarchive
