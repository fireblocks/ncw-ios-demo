#!/bin/bash

# Clean the build
rm -rf ./build

# Build the project
xcodebuild -project \
Fireblocks.xcodeproj \
-scheme NCW-dev \
-configuration Debug \
-destination 'platform=iOS Simulator,name=iPhone 15' \
-derivedDataPath build

