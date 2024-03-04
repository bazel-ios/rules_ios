#!/bin/bash

set -e

# Sets up the CI environment.
#
# Required environment variables:
#   - XCODE_VERSION: The version of Xcode to use.

# If flag --no-bzlmod is passed, writes a user.bazelrc file to disable Bzlmod.
if [[ "$*" == *--no-bzlmod* ]]; then
  echo "build --noenable_bzlmod" >> user.bazelrc
fi

# Add the ci config override.
echo "common --config=ci" >> user.bazelrc

echo "Selecting Xcode for environment"
echo "Xcode before: $(xcode-select -p)"
sudo xcode-select -s "/Applications/Xcode_$XCODE_VERSION.app"
echo "Xcode after: $(xcode-select -p)"

echo "Running with environment:"
printenv
