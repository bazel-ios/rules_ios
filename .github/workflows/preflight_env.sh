#!/bin/bash

# If flag --no-bzlmod is passed, writes a user.bazelrc file to disable Bzlmod.
if [[ "$*" == *--no-bzlmod* ]]; then
  echo "build --noexperimental_enable_bzlmod" > user.bazelrc
fi

set -e
echo "Selecting Xcode for environment"

printenv

sudo xcode-select -p
sudo xcode-select -s /Applications/Xcode_14.2.app
