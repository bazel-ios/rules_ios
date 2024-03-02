#!/bin/bash

# If flag --no-bzlmod is passed, writes a user.bazelrc file to disable Bzlmod.
if [[ "$*" == *--no-bzlmod* ]]; then
  echo "build --noenable_bzlmod" >> user.bazelrc
fi
# If flag --use-remote-cache is passed, writes a user.bazelrc file to enable remote cache.
if [[ "$*" == *--use-remote-cache* ]]; then
  echo "build --config=ci_with_caches" >> user.bazelrc
fi

set -e
echo "Selecting Xcode for environment"

printenv

sudo xcode-select -p
sudo xcode-select -s /Applications/Xcode_15.2.app
