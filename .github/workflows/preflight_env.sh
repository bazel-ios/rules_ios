#!/bin/bash
set -e
echo "Selecting Xcode for environment"

printenv

sudo xcode-select -p
sudo xcode-select -s /Applications/Xcode_14.2.app

cat << EOF > $HOME/.bazelrc
build:ci --config=ci_remote_cache
EOF
