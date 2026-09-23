#!/usr/bin/env bash

set -ex

xcodebuild -version
xcodebuild -project cmdtab-macos.xcodeproj -scheme Release -showBuildSettings | grep SWIFT_VERSION

set -o pipefail && xcodebuild test -project cmdtab-macos.xcodeproj -scheme Test -configuration Release | scripts/xcbeautify
