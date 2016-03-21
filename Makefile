project=MNAVChapters.xcodeproj
scheme=MNAVChapters
sdk=iphonesimulator

all: build

.PHONY: clean
clean:
	-rm -rf build

build:
	xcodebuild -configuration build

.PHONY: test
test:
	xctool test \
		-project $(project) \
		-scheme $(scheme) \
		-sdk $(sdk) \
		-reporter pretty
