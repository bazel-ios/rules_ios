#!/bin/bash

set -e

# Sets up the CI environment.
#
# Required environment variables:
#   - XCODE_VERSION: The version of Xcode to use.

# GitHub runners are hitting 'module not found pkg_resources' required by prepare_sim.py
pip3 install setuptools==69.5.1 --break-system-packages

# If flag --no-bzlmod is passed, writes a user.bazelrc file to disable Bzlmod.
if [[ "$*" == *--no-bzlmod* ]]; then
  echo "build --noenable_bzlmod" >> user.bazelrc
fi

# If `RULES_APPLE_SWIFT_VERSION` is set to `latest` use the master branch of rules_swift and rules_apple.
if [[ "${RULES_APPLE_RULES_SWIFT_VERSION}" == "latest" ]]; then
  gh repo clone bazelbuild/rules_swift /tmp/rules_swift
  gh repo clone bazelbuild/rules_apple /tmp/rules_apple
  echo "common --override_module=rules_swift=/tmp/rules_swift" >> user.bazelrc
  echo "common --override_module=rules_apple=/tmp/rules_apple" >> user.bazelrc
fi

# Add the ci config override.
echo "common --config=ci" >> user.bazelrc

echo "Selecting Xcode for environment"
echo "Xcode before: $(xcode-select -p)"
sudo xcode-select -s "/Applications/Xcode_$XCODE_VERSION.app"
echo "Xcode after: $(xcode-select -p)"

echo "Running with environment:"
printenv
