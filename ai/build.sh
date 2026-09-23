#!/bin/bash

xcodebuild \
  -project cmdtab-macos.xcodeproj \
  -scheme Debug \
  -configuration Debug \
  -derivedDataPath DerivedData
