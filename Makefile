P=MNAVChapters.xcodeproj

XCODEBUILD=xcodebuild

IOS_DEST=-destination 'platform=iOS Simulator,name=iPhone 7'

all: iOS

clean:
	$(XCODEBUILD) clean
	rm -rf build

test_%:
	$(XCODEBUILD) test -project $(P) -configuration Debug -scheme $(SCHEME) $(DEST)

build_%:
	$(XCODEBUILD) build -project $(P) -configuration Release -scheme $(SCHEME)

%iOS: SCHEME := MNAVChapters

test_iOS: DEST := $(IOS_DEST)

iOS: build_iOS

test: test_iOS

.PHONY: all, clean, test, %OS
