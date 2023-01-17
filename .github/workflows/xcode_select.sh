#!/bin/bash
set -e
echo "Selecting Xcode for environment"

printenv

sudo xcode-select -p
sudo xcode-select -s /Applications/Xcode_14.2.app

echo "Generating bazelrc"

# Setup for github actions - these are very flaky
echo "test --test_timeout=600 --flaky_test_attempts=//tests/ios/...@3" > user.bazelrc
echo "test --local_test_jobs=1" >> user.bazelrc

echo "build --jobs=4" >> user.bazelrc
echo "build --spawn_strategy=standalone" >> user.bazelrc
echo "build --xcode_version_config=//:host_xcodes" >> user.bazelrc

# `deleted_packages` is needed below in order to override the value of the .bazelrc file
echo "build:ios --apple_platform_type=ios --deleted_packages=''" >> user.bazelrc
