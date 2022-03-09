#!/bin/bash
set -e
echo "Selecting Xcode for environment"
printenv
sudo xcode-select -p
sudo xcode-select -s /Applications/Xcode_12.5.1.app

# Setup for github actions
echo "test --test_timeout=600" > ~/.bazelrc
echo "build --xcode_version_config=//:host_xcodes" >> ~/.bazelrc

bazelisk clean --expunge
