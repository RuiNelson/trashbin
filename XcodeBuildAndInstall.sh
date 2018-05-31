#!/bin/sh

xcodebuild -project trashbin.xcodeproj
cp build/Release/trashbin /usr/local/bin
