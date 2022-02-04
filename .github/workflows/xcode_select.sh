#!/bin/bash
set -e
echo "Selecting Xcode for environment"
printenv
sudo xcode-select -p
sudo xcode-select -s /Applications/Xcode_12.5.1.app
# FIXME REMOVE CI DEBUGGING
bazelisk clean --expunge
