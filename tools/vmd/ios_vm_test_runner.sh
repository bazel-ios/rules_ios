#!/bin/bash

set -ex

RUNNER_TMP=$(mktemp -d)
trap "rm -rf $RUNNER_TMP" EXIT
trap 'rm -rf "${TMP_DIR}"' ERR EXIT

## ios_vmd_test_runner.template.sh -> ios_vm_test_runner.sh -> vm_runner.sh

# Pack runfiles an into a tarball. For limitations of the VM systems, this
# *must* be _copied_ in. We use scp for simplicity until other mechanims are
# built into vmd/tart https://github.com/cirruslabs/tart/issues/150
# This directory packs all of the test files into it
pushd $TMP_DIR
tar cfh $RUNNER_TMP/RUNNER_UPLOAD.tar .
popd

# Tar up dep runfiles
## https://docs.bazel.build/versions/main/test-encyclopedia.html 
pushd $TEST_SRCDIR 
tar rfh $RUNNER_TMP/RUNNER_UPLOAD.tar .
popd
pushd $PYTHON_RUNFILES
tar rfh $RUNNER_TMP/RUNNER_UPLOAD.tar .
popd

## Run the test with the upload feed this name into the rule
tools/vmd/vmd \
    --name macos-monterey-xcode:13.3.1 \
    --upload $RUNNER_TMP/RUNNER_UPLOAD.tar \
    -- "TEST_UNDECLARED_OUTPUTS_DIR='' build_bazel_rules_ios/external/xctestrunner/ios_test_runner $@"
